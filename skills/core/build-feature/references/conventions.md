# Conventions

Naming, params, DTOs, async fan-out, errors, docs. Read in full — these apply to all code.

## Naming

- **Entity classes**: PascalCase singular (`Order`)
- **Table names**: snake_case plural (`orders`)
- **Foreign keys**: `{entityName}Id` (`tenantId`)
- **Booleans**: `is{Condition}` (`isActive`)
- **Methods**: `create{Entity}`, `update{Entity}`, `get{Entity}ById`, `get{Entities}`
- **Request DTOs**: `Create{Entity}Request`, `Update{Entity}Request`, `Get{Entities}Request`
- **Collections** — name by *role*, not a generic catch-all:
  - Entities you hold / read / persist → `{entity}s` (`orders`, `reports`); `rows` only when the entity doesn't pluralize cleanly (`runBulkQuery(rows, (batch) => …)`, `batch` = a chunk). Avoid `records` / `writes` / generic `items` — they're just `rows` under another name.
  - ID lists → `{entity}Ids` / `ids` / `skus`.
  - A patch to apply (`{ id, updates: Partial<X> }`, `OrderUpdate[]`) → `updates`; a list of changed field names → `changes: string[]`. These are **not** `rows` — keep them distinct.
  - Sync/event work-units → `items` (`SyncResult` counts, event payloads). Note: a paginated HTTP response still keys on the resource name, not `items` (see Pagination).
  - **Element type mirrors the role**: `rows: XRow[]`, `updates: XUpdate[]`, `items: XItem[]`, a domain event's payload element → `{Domain}ChangedItem`. No one-off suffixes (`XWrite`) — derive from the entity instead (`Omit<Entity, 'id'>`).

- **Vendor names stay at the edge** — a third party's name belongs on the enum value, the adapter that speaks its protocol (`{{Vendor}}Warehouse`), and the user-facing label. Never on a route path, DTO, service method, column, or capability member: `POST /warehouses/discovery` taking `provider` and `DiscoverWarehouseRequest`, not `POST /warehouses/{{vendor}}/discovery` and `Discover{{Vendor}}HubsRequest`. The test is whether a second vendor of the same kind could reuse the surface unchanged. Full rule + the shared-code branching it generalizes to: [../../ship-pr/references/naming-and-language.md](../../ship-pr/references/naming-and-language.md).

## Named parameters

**Two or more args → one named object. Never positional.** A single arg can stay positional.

**Never name the arg `input`** — it's generic and tells the caller nothing. Pick a name that carries the semantic: `request` (default for command/query inputs), `options` (config knobs), `filter`, `criteria`, etc. Pair `request` with a `{Verb}{Entity}Request` type. Destructure inside the body.

```typescript
// Good
createOrder(request: CreateOrderRequest)             // command/query input
getOrderById(id: number)                             // one arg, positional is fine
configureReport(options: ReportOptions)              // config-style knobs

// Bad
createOrder(tenantId, sku, price, isActive)          // order is easy to mix up
loadAggregates(input: { … })                         // `input` is banned — pick a semantic name
```

Why: call sites stay readable, argument order can't be transposed silently, and the arg name itself communicates what the object is.

## DTOs & validation

- Live in `endpoints/*.dto.ts` (or `<module>.dto.ts`).
- class-validator decorators: `@IsString`, `@IsInt`, `@IsOptional`, `@IsEmail`, `@Min`, `@Max`, `@IsArray` + `@IsInt({ each: true })`.
- Query params: coerce and default with `@Transform(({ value }) => (value ? parseInt(value) : default))`.
- Controller takes the DTO as one arg: `@Query() query: GetXRequest` or `@Body() dto: CreateXRequest`.

Anchor: a `<module>.dto.ts` in an existing module.

## Write & derived types — reuse the entity

When a type is just an entity's columns — a row you persist, or a computed subset of it — derive it from the entity with TypeScript utility types. Don't hand-declare a parallel `XWrite` / `XInput` interface that re-lists the columns: it duplicates the schema and silently drifts when the entity changes.

- **Repo write/upsert methods** take the entity, or `Partial<Entity>` for a patch. Anchors: `upsertForOrders(orders: Partial<Order>[])`, `bulkUpdate(batch: Array<{ id: number; updates: Partial<Order> }>)` in the repository for the entity.
- **A subset** is `Pick<Entity, 'a' | 'b'>` or `Omit<Entity, 'id'>` — not a fresh interface.

```typescript
// Bad — re-declares every column OrderPlan already has
interface OrderPlanWrite {
  orderId: number;
  velocity: number | null;
  daysOfStock: number | null;
  /* …8 more, kept in sync by hand… */
}
async upsertOrderPlan(rows: OrderPlanWrite[]): Promise<void>

// Good — the entity is the write shape; a computed subset is Omit/Pick of it
async upsertOrderPlan(rows: OrderPlan[]): Promise<void>
type DerivedPlan = Omit<OrderPlan, 'orderId'>;  // what the calc returns
```

## Pagination

Query DTO: `page` (default 1), `limit` (default + `@Max`). Response key is the **resource name**, not `items`:

```ts
return {
  orders,
  pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
};
```

`PaginationMeta` lives in a shared helpers/interfaces file. Anchor: an existing list controller.

## Async fan-out

Independent async calls run concurrently — never a sequential `for…await` loop over work that doesn't depend on prior iterations.

- **`Promise.allSettled`** — default for fan-out where one item's failure must not kill its siblings (per-account, per-tenant, per-integration work). Count `fulfilled`/`rejected` for the `SyncResult`.
- **`Promise.all`** — only when any failure should abort the whole batch (results consumed together, all-or-nothing).
- **Sequential `for…await`** — only when iteration N needs the result of N-1, or when deliberately serializing against a rate limit.

Rate limits shape the fan-out: external API limits are often **per-account**, so parallelize *across* accounts/tenants freely, but serialize or batch calls *within* one account. Internal work (DB writes, event scheduling) has no such limit — fan it out. For large arrays hitting one constrained target, split with `chunk()` (a shared chunking helper) and await batches in order: parallel inside the batch, sequential between batches.

Anchor: an order-syncing service — per-account `allSettled` fan-out with nested fan-out per order payload.

## Errors

Throw standard Nest exceptions (`NotFoundException`, `BadRequestException`, …). The global `AllExceptionsFilter` shapes them into `{ statusCode, message, path }`. Reuse user-facing message constants from a shared `error-messages` file. **Don't log in services**; the filter logs.

Messages are **localized pairs**, not bare strings: one entry per language you serve, resolved with `localized()` at the point you throw, since the caller's language is only known inside their request. The product's primary language is the default for a caller that asks for nothing.

One exception to "standard exceptions only", and only one: a **domain failure the person in the flow can act on**, where the client wants to word it in its own voice. Those carry a stable code alongside the message, thrown through a small per-domain error class. **The code's value is camelCase, because the client uses it directly as an i18n key** — `signInRejected`, not `INTEGRATION_SIGN_IN_REJECTED`, which would force a hand-written map that goes stale silently. That is the *only* sanctioned custom exception class — everything else stays a standard Nest exception. Shape, boundary, and what disqualifies a code: [domain-errors.md](domain-errors.md).

An error thrown inside a queued handler also carries a **retry verdict**, and wrapping one throws that verdict away: [queue-error-verdicts.md](queue-error-verdicts.md).

## JSDoc

JSDoc is for the **caller**. Document what they need to know, not how it works internally.

**Add when:** non-obvious logic, side effects, external integrations, complex workflows.
**Skip when:** name + types tell the story, standard CRUD, obvious one-liners.

```typescript
// Good: caller learns something useful ( in addition to signature specification)
/** Syncs data. ProviderA is async (queue), ProviderB is sync. Fails silently per item. */

// Bad: restates the signature
/** Gets order by ID @param id - order ID @returns order */
```

## Shared Logic

Contribute to or use the helper/ folder where relevant, for extractable general code.
