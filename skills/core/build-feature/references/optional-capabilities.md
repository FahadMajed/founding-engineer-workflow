# Optional Capabilities (capability object)

How a base class exposes a surface that only some subclasses support — e.g. a payment provider where only card gateways support refunds, a notification channel where only some carriers report delivery receipts, a storage provider where only some issue signed URLs.

## The pattern

One nullable getter on the abstract base returns a **capability object** that carries the capability's metadata and behavior together. Non-supporting subclasses inherit the `null` default; supporting ones override the getter.

```ts
// abstract base
abstract class PaymentProvider {
  /** Providers that support programmatic refunds return their refund surface; others null. */
  get refunds(): Refunds | null {
    return null;
  }
}

// the capability: metadata + behavior in one object
interface Refunds {
  readonly methods: RefundMethod[];
  readonly windowDays: number | null;
  refund(transactionId: string, amount: Money): Promise<RefundResult>;
}

// supporting adapter — object literal delegating to private methods
class CardProvider extends PaymentProvider {
  override get refunds(): Refunds {
    return {
      methods: ['Full', 'Partial'],
      windowDays: 180,
      refund: (txnId, amount) => this.submitRefund(txnId, amount),
    };
  }
}
```

Callers prove support **once** by holding a non-null object; the compiler carries that proof through every subsequent call:

```ts
const refunds = provider.refunds;
if (!refunds) continue;                       // the ONE null check, at the boundary
const result = await refunds.refund(txn.id, amount);   // non-null surface from here on
```

### `implements`-style hierarchies

When concrete classes `implement` the abstract (rather than extend it — e.g. `CardProvider extends BaseProvider implements PaymentProvider`), a getter with a `null` default is not inherited, so declare the capability as an **optional readonly member** instead — same semantics, undefined = not supported:

```ts
abstract class PaymentProvider {
  readonly refunds?: Refunds;
}
class CardProvider extends BaseProvider implements PaymentProvider {
  override get refunds(): Refunds { return { ... }; }
}
```

## Rules

- **Metadata rides the object, not separate methods.** A caller deciding behavior from capability facts (`windowDays == null → no clock`) reads them off the same object it calls — the link between "supported" and "callable" is structural, not remembered.
- **Behavior methods on the capability never return `null`-meaning-unsupported.** Empty array = "no data" (transient); `null` getter = "not supported" (structural). Keeping these distinct is the point.
- **The getter is cheap and side-effect-free** — callers may probe it for applicability checks (e.g. "which accounts have a capable provider") without triggering I/O.

## Anti-patterns this replaces

- **Null-returning behavior methods on the base** (`refund() { return null; }`) — every call site re-litigates support with its own check; nothing stops calling it on a non-supporting subclass and shipping the null-handling bug.
- **Marker interfaces + type guards** (`SupportsRefunds`, `'refund' in provider`) — interface taxonomy and hand-written guards to encode what one nullable getter encodes structurally.
- **Name/type branching in shared code** (`if (provider.kind === 'card')`, the provider-factory switch) — capability facts belong to the adapter that owns them; shared logic reads the descriptor, never the identity.

## When not to use it

- Every subclass supports the operation → it's just an abstract method.
- The "capability" is a single scalar fact with no behavior → a plain readonly property is enough.
- Support varies per *account/config*, not per subclass → that's runtime state; check the config, don't model it as a class capability.
