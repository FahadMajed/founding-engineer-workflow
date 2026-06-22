# Good vs Bad Examples

## Style Guide

**Voice:** Direct. Factual. Like a postmortem, not a blog post.

### Banned Phrases / Words

- "In this document, we will explore..."
- "It should be noted that..."
- "This comprehensive solution..."
- "We shipped it. It mostly worked."
- "Good enough. Ship it."
- Dramatic framing: "the pain", "the hunt", "the pivot", "aha moment", "what broke unexpectedly", "vivid", "tension".
- Banned words: comprehensive, robust, streamlined, enhanced, optimized, leveraged, addressed, validated, facilitated, solution, ensure, utilize.
- Passive voice overuse, wall-of-text paragraphs.

## Opening Paragraphs

### Bad — corporate speak

> This document describes the implementation of the order synchronization feature. The feature was developed to address requirements outlined in the design document. It includes webhook handling, database updates, and external API integration.

_Why it's bad:_ Spec-style preamble. Says nothing.

### Bad — dramatic

> Reconciling orders was painful. Every morning, operators stared at three browser tabs, manually matching rows. Something had to change.

_Why it's bad:_ Narrative framing, emotional adjectives, story hook. The write-up is a record, not a blog post.

### Good

> Operators spent ~30 min/day reconciling orders across three external systems. Mismatches between the external source and our DB ran ~4% of orders. Goal: drop reconciliation to a spot check, mismatch rate under 0.5%.

_Why it's good:_ Numbers, scope, target. Reader can evaluate the work against it.

---

## Explaining Architecture

### Bad

> The system uses a microservices architecture with event-driven communication. The OrderService publishes events to a queue, which are consumed by the SyncService. The SyncService uses the Repository pattern for data access and implements retry logic with exponential backoff.

_Why it's bad:_ Lists technologies without explaining what they do for this feature.

### Good

> External webhook → `OrderWebhookController` → `OrderQueue` (BullMQ) → `OrderSyncHandler`. Handler is idempotent on `externalOrderId`. Failures retry with exponential backoff (max 5, capped at 1h). On final failure, the job moves to `dead-letter` and pages on-call.

_Why it's good:_ Names the entry point, the path, the idempotency key, and the failure mode.

---

## Describing Bugs

### Bad — vague

> We encountered an issue with transaction handling. The fix involved modifying the database context to use isolated transactions.

### Bad — dramatic

> **The Hunt:** Logs said success. The DB said no. I stared at it for hours. Then it hit me — the timestamps clustered around traffic spikes.

_Why it's bad:_ Hero-narrative. The reader does not need the chase scene.

### Good

> **Symptom:** Inventory updates returned success but stock levels unchanged. Concentrated during peak traffic (>50 req/s).
> **Root Cause:** `AsyncLocalStorage` transaction context shared between order and inventory operations. When an order rolled back (payment failure), in-flight inventory updates inside the same context rolled back too.
> **Fix:** Separate `AsyncLocalStorage` contexts per domain. See `src/db/transaction.context.ts:42`.
> **Prevention:** Added integration test in `test/transaction-isolation.spec.ts` that runs concurrent order+inventory ops and asserts independent commit/rollback.

_Why it's good:_ Symptom, cause, fix, prevention. No drama.

---

## Lessons Learned

### Bad

> Key learnings:
> - Use proper error handling
> - Write tests before deployment
> - Consider edge cases
> - Document your code

_Why it's bad:_ Generic. Applies to anything.

### Good

> **Treat webhooks as at-least-once.**
>
> The provider retries webhooks on a non-2xx response, sometimes hours apart. The first version assumed single delivery and created duplicate orders. Fix: idempotent handler keyed on `externalOrderId`. Apply this to every external trigger — webhook, queue consumer, cron — not just the obvious ones.

_Why it's good:_ Specific cause, transferable rule, scope of where it applies.

---

## Overall Tone

### Bad — corporate

> The implementation successfully addressed all requirements as specified in the PRD. The architecture follows industry best practices and provides a scalable foundation for future enhancements.

### Bad — dramatic

> We shipped it. It mostly worked. The inventory sync took three tries to get right, and we discovered a timezone bug two weeks later that was quietly miscounting orders. But operators stopped losing orders, and the 2-hour daily reconciliation dropped to a 5-minute spot check. Good enough. Ship it.

_Why it's bad:_ Still a story — self-deprecation, beat-by-beat, "good enough, ship it" punchline.

### Good

> Shipped 2026-04-12. Reconciliation time dropped from ~30 min/day to <5 min. Mismatch rate dropped from 4% to 0.3%. Two follow-ups: timezone bug in `OrderSyncHandler.normalizeDate` fixed 2026-04-26; inventory sync race documented in the Gotchas section.

_Why it's good:_ Dates, numbers, follow-ups. Reader gets the state, not the feelings.
