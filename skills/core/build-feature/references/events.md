# Domain Events

Lookup table. Async pub/sub over a DB-backed queue (`scheduled_events`), not in-process `EventEmitter`. Handlers run on a short poll, decoupled from the emit.

## Existing events

The shared `event.types.ts` — `DomainEvent` enum + `EventPayload` map (name → payload type).

```
OrderCreated, OrderCancelled, OrderReturned, OrderStatusChanged,
IntegrationAccountConnected, AccountStatusChanged, ExistingRecordsSynced,
DataPushRequested, EntityChanged
```

`OrderCancelled` / `OrderReturned` may fire per-shipment for integrations that split one order into multiple packages; an `isPartialOrderEvent` flag on the payload distinguishes one-of-N shipments from the terminal one. Keep event names stable once shipped — in-flight `scheduled_events` rows reference them.

## Add a new event

1. Define the payload interface in your module's `<module>.events.ts`.
2. In `event.types.ts`, register in **both** spots: add the name to the `DomainEvent` enum, and map name → payload in `EventPayload`.

## Emit

Inject `EventSchedulingService`, call `scheduleEvent({ eventName, payload, processAfter? })`. Returns the event id; `processAfter` delays the run.

## Consume

Decorate an injectable method with `@OnDomainEvent(DomainEvent.X)` (the typed-event decorator). A scanner registers it at boot. Multiple handlers per event run one after another, each tracked on its own. A failed handler retries with exponential backoff.
