# Queue Error Verdicts (retry / terminal / deferral)

What the event queue does with a handler that threw. Three answers, not two, and the difference between them is attempts — a scarce thing, since a unit of work gets a fixed number before it is abandoned.

Vocabulary: the shared `retryable-error.ts`. Anchor for a handler combining many failures into one verdict: the shared `combine-failures.ts`.

## The three verdicts

| Verdict | Means | Costs an attempt |
| --- | --- | --- |
| **retryable** | might work later — a blip, a 429, a 503 | yes |
| **terminal** (`TerminalEventError`) | will never work by trying again — rejected data, a revoked credential, a record the provider does not have | no; remaining attempts are skipped |
| **deferral** (`isDeferral`) | never started — someone else holds the serialization lock | no; reschedules without spending one |

A deferral is not a failure. Counting it as one abandons work because a sibling happened to be running.

## The default is retryable, deliberately

`isRetryable` returns `true` for anything it does not recognize. Getting this backwards is asymmetric: a transient fault wrongly given up on loses the work outright, while a permanent one wrongly retried only spends attempts that were going to expire anyway.

It reads a verdict from, in order: `TerminalEventError` (terminal), a Postgres class-23 constraint violation (terminal — retrying re-violates it), then an HTTP status off `.response.status` / `.status` / `.statusCode`. `400/401/403/404/409/422` are terminal; `408/425/429/500/502/503/504` are retryable.

## Wrapping an error throws away its verdict

**This is the failure mode to watch, and it has bitten.** A client that catches an upstream 401 and rethrows its own error class hands the queue something with no status on it — so `isRetryable` falls back to its default and says *retry*. Every attempt is then spent re-presenting a credential the provider has already revoked.

So: **an error class that means "will never work" must be terminal in its own right**, not rely on a status it dropped.

```ts
// the wrapper keeps the verdict its cause carried
export class IntegrationAuthError extends TerminalEventError { ... }
```

A domain error class gets there another way — `IntegrationConnectError` extends `BadRequestException`, so it carries a 400 and reads terminal ([domain-errors.md](domain-errors.md)). Either is fine; having neither is the bug.

## When you add a handler

- Throw `TerminalEventError` for anything the queue should stop retrying, and pass the cause so the log still says what happened.
- Fan-out handlers decide once, over all their failures: `combineFailures` returns a terminal error only when **every** failure is terminal, since one retryable failure among many still deserves another attempt.
- Never catch-and-rethrow a bare `Error` around an HTTP failure. Either let it propagate or use a class that carries the verdict.
- A new error class that means "give up" gets a test asserting `isRetryable(new TheError(...)) === false`. That assertion is the contract; without it the class silently drifts back to retryable when someone changes its base.

## Not this mechanism

`@Retryable` (the shared retryable decorator) retries *inside* one call — a few fast attempts around a flaky HTTP request, with its own `shouldRetry` and backoff. The queue retries *across* runs, minutes or hours apart. They compose: exhausting `@Retryable` produces one failure the queue then judges. Don't reach for the decorator to solve a queue problem, or vice versa.
