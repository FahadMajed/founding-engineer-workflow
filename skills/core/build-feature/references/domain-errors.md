# Domain Errors (stable codes)

How an endpoint tells a client *which* thing went wrong, as opposed to telling a person. A message is prose in one language; a client wording the failure in its own voice needs something language-independent to key off. That is the code.

Anchor: a `<module>.errors.ts` in a module whose flow a person drives — connecting an integration account is the exemplar.

## The pattern

Three things in one file per domain: the codes, the message for each, and the error that carries both.

```ts
/**
 * Stable identifiers for the ways connecting an integration account can fail.
 *
 * The values are camelCase because a client's job is to word these itself: the
 * code drops straight into an i18n key path, so nobody maintains a map from our
 * codes to their strings.
 */
export enum IntegrationConnectErrorCode {
  SignInRejected = 'signInRejected',
  Unreachable = 'providerUnreachable',
  NoLocations = 'noLocations',
}

const MESSAGE_BY_CODE: Record<IntegrationConnectErrorCode, LocalizedText> = {
  [IntegrationConnectErrorCode.SignInRejected]: {
    en: 'Sign-in failed — check the username and password.',
    // …one entry per language you serve
  },
  ...
};

export class IntegrationConnectError extends BadRequestException {
  constructor(readonly code: IntegrationConnectErrorCode) {
    super({ message: localized(MESSAGE_BY_CODE[code]), code });
  }
}
```

Throwing is `throw new IntegrationConnectError(IntegrationConnectErrorCode.NoLocations)` — one argument, and the message can never drift from the code.

**The values are camelCase, and that is the whole point.** The client renders ``t(`{feature}.{code}`)``, so a code is an i18n key. `SCREAMING_SNAKE` forces a hand-written map from our codes to their keys, and such a map goes wrong silently — a stale entry still renders a real sentence, so nothing looks broken. Name the value exactly as the string key should be named.

**No filter change is needed.** `AllExceptionsFilter` already spreads an `HttpException`'s object payload into the response body, so `code` reaches the client untouched. Passing an object to `super()` instead of a string is the whole mechanism.

**Messages are `LocalizedText`, resolved at the throw.** `localized()` reads the language the request came in with (the locale service), so it only works inside the request — which is where you are when you throw. The product's primary language is the default for a caller that asks for nothing.

## The file holds the domain's whole error vocabulary

Including the ones that are not HTTP exceptions. A read that fails transiently raises a plain `Error` subclass, deliberately — the event queue treats 4xx as terminal, so a retryable failure must not be one. It still lives in `<module>.errors.ts`, next to the codes, so "what can go wrong in this domain" is one file rather than a hunt.

Keep them with the codes rather than beside the transport that raises them — declared next to the HTTP client or the queue, they scatter the vocabulary across files nobody thinks to open.

## When to use it

Use it for **failures a person in a flow can act on** — a rejected password, an address that isn't reachable, a login that reaches nothing. Those get a code because a client has to word them.

Don't use it for programmer errors or guard rails a customer cannot hit (`tenantId` mismatches, an unsupported provider). A plain Nest exception is fine there.

But watch the seam: if one endpoint answers a customer with coded messages for some failures and uncoded prose for others, the ones without codes are exactly the ones the client can neither translate nor word. Either the failure is reachable by a person — code it — or it isn't, and it should not be phrased as advice.

## What kills it

- **`SCREAMING_SNAKE` values.** They read like constants and force the map this pattern exists to delete. Match the client's i18n key naming, which is camelCase.
- **A code that restates the HTTP status.** `badRequest` says nothing the status didn't. Codes name the *situation*.
- **Codes invented at the call site.** They live in the enum, or clients can't enumerate them.
- **Changing a value.** The string is the contract *and* a key in the client's translation files; a rename breaks both. Rename the enum *member* freely, never the value.
- **Leaking internals into the message.** The message reaches a person. Reasons, stack text, upstream bodies do not.

## The client half

The client derives its i18n key from the code and never displays the server's prose — that is what makes the message a fallback rather than the product. It sanitizes the server-supplied code before keying on it, and always passes a default translation for a code its bundle doesn't carry yet.
