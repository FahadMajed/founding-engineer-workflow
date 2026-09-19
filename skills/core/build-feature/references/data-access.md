# Data Access

Codebase-specific persistence patterns for reading/writing data at runtime. Standard TypeORM knowledge not included. For defining entities, columns, and migrations see [entities-and-migrations.md](entities-and-migrations.md).

## Custom Repository Pattern

All data access through custom repositories extending the base class in the shared database layer (`repository.ts`).

```typescript
@Injectable()
export class OrderRepository extends Repository {
  async getOrderById(orderId: number): Promise<Order> {
    return this.repositoryOf(OrderSchema).findOneOrFail({
      where: { id: orderId },
    });
  }
}
```

Key methods from base `Repository`:

- `repositoryOf(schema)` - Get TypeORM repo respecting transaction context
- `runTransaction(fn)` - Execute in transaction with auto-rollback
- `runWithAdvisoryLock({ lockId, operation })` - PostgreSQL advisory lock
- `runWithRowLock(query, lockMode, fn)` - Row-level locking
- `findOrCreate({ entity, where, orCreateWith })` - Get or create

Never inject TypeORM repositories directly in services.

## Query Idioms

How data access is actually written — the helpers above are the plumbing. Anchors live in the repository for the entity unless noted.

- **Array filters** — `In(ids)` inside a `where` object, or `IN (:...ids)` in a QueryBuilder. Guard empty input first (`if (!ids.length) return new Map()` / `[]`) — an empty `IN ()` is invalid SQL. See a bulk-lookup method.
- **Tenant scoping** — filter by the caller's tenants through `scopeByTenant(qb, column, tenantIds)` (QueryBuilder) or `tenantScopeParam(tenantIds)` (raw SQL gated on `$n::int[] IS NULL OR col = ANY($n)`), both in the shared tenant-scope helper. `undefined` = all tenants (admin), empty list = none, concrete list = those. Never `if (tenantIds?.length)` — it reads an empty scope as "all tenants" and leaks; a guardrail spec fails the build on it. See permissions.md → Current user + tenant scoping.
- **Bulk lookup → `Map<key, entity>`** — fetch many rows in one query and return a `Map` keyed by the lookup id, so callers get O(1) hits instead of re-querying per item. Supports dual keys (sets both `sku` and `barcode`). See a `findByIdentifiers` method.
- **QueryBuilder for dynamic filters** — build the base `qb`, add `.andWhere(...)` per optional filter. `getMany()` for entities, `getRawMany()` for projections (DISTINCT, aggregates). See a `getDistinctCategories` method.
- **Upsert** — `repository.upsert(rows, ['sku'])` for plain insert-or-update on a conflict key. See an `upsert` method.
- **Upsert when you need new-vs-updated** — raw CTE that `RETURNING`s an `isNew` flag per row, when the caller reacts differently to inserts vs updates. See an `upsertWithStatus` method.
- **Multi-bucket counts in one query** — raw SQL with `COUNT(*) FILTER (WHERE ...)` and `$n` params (`= ANY($n)` for arrays), instead of N separate `count()` calls. See a `getFilterCounts` method. For a single count, `repositoryOf(Schema).count({ where })` is enough.
- **Set-based writes / backfills** — `this.dataSource.query(...)` raw SQL for bulk `UPDATE`s, not a row-by-row loop. See the `@RunEvery` backfills in this repo.
- **Day-bucketed reporting** — convert UTC timestamps to local day with `... AT TIME ZONE 'UTC' AT TIME ZONE '<your-timezone>'` in raw SQL before grouping by date. See a reporting query in the order repository.

## Filter in the query, not after it

The predicate belongs in `WHERE`. A repository call that fetches a page and then
narrows it in JavaScript has moved the database's job into the service, and pays
for it three times: rows crossing the wire that are thrown away, a page ceiling
that silently truncates the answer, and a rule now stated in two places that can
disagree.

BAD — fetches 500 organizations and 1,000 tenants to keep 6 and 9:

```ts
const orgPage = await this.organizationRepository.findAll({ page: 1, limit: 500 });
const organizations = orgPage.organizations.filter(
  (org) =>
    org.isActive &&
    (org.billingModel == null || org.billingModel === BillingModel.Commission),
);

const tenantPage = await this.tenantRepository.getAllTenants({ page: 1, limit: 1000 });
for (const tenant of tenantPage.tenants) {
  if (!tenant.isActive || tenant.organizationId == null) continue;
  // …
}
```

GOOD — a purpose-built method per question, the predicate in SQL:

```ts
const organizations = await this.organizationRepository.findBillableOrganizations();
const tenants = await this.tenantRepository.findActiveByOrganizationIds(
  organizations.map((org) => org.id),
);
```

### And let it do the grouping

The same instinct one level up: three reads reassembled into `Map`s in a service
is a join written in JavaScript. Postgres nests children in one statement with
`LEFT JOIN LATERAL` + `json_agg`, and the caller gets the shape it actually
wants — one row per parent, children already attached.

BAD — three round trips, then rebuild the relationships by hand:

```ts
const organizations = await orgRepo.findBillableOrganizations();
const tenants = await tenantRepo.findActiveByOrganizationIds(ids);
const integrations = await orgRepo.findConnectedIntegrationsForOrganizations(ids);
const tenantsByOrg = new Map(); for (const t of tenants) { /* group */ }
const integrationsByOrg = new Map(); for (const i of integrations) { /* group */ }
```

GOOD — one statement, children nested:

```sql
SELECT o.*, COALESCE(t.tenants, '[]'::json) AS tenants
FROM organizations o
LEFT JOIN LATERAL (
  SELECT json_agg(json_build_object('id', tn.id, 'name', tn.name) ORDER BY tn.name) AS tenants
  FROM tenants tn WHERE tn."organizationId" = o.id AND tn."isActive"
) t ON TRUE
WHERE …
```

`LEFT JOIN LATERAL … ON TRUE` keeps parents with no children (the plain join
would drop them); `COALESCE(…, '[]'::json)` turns their `NULL` into an empty
array so the caller never branches on it. Use `json_agg(DISTINCT jsonb_build_object(…))`
when the child join can duplicate rows — `jsonb` because `json` has no equality
operator for `DISTINCT`.

**Raw queries bypass the column transformers.** `decimalTransformer` does not run,
so numerics arrive as strings and `row.fee > 0` compares a string. Cast in SQL
(`col::float8 AS "col"`) rather than coercing at every read site, and keep the
quoted alias or Postgres lowercases the column.

Two reads are not automatically wrong — separate queries are right when the
children are optional, paginated independently, or reused across parents. The
smell is specifically *fetch several sets, then re-derive the relationship the
database already knows*.

### Why the page limit is the tell

Reaching for a generic list method forces a `limit`, and any `limit` you pick is
either too small (the tail is silently missing) or a guess that rots. A guard
that throws when `total > rows.length` treats the symptom: the query should
return the set, not a page of a superset. **A magic page size in a domain
service is almost always a filter that belongs in the query.**

### The rule

- One question, one repository method, named for the question — `findBillableOrganizations`, not `findAll` + a filter.
- Scope by id when you already hold the ids: `WHERE "organizationId" = ANY($1)`, not fetch-everything-then-group.
- Filtering **in memory is right** when the rows are already loaded for another reason, or when the predicate cannot be expressed in SQL. Deriving counts from a set you already have is not this smell.
- Two places stating the same predicate is the real cost. When a rule (who gets invoiced, what counts as active) lives in both a query and a service filter, they drift, and the drift is silent.

## Bulk INSERT / UPDATE — `runBulkQuery`

**Any multi-row write** must go through the base `Repository` — whether it builds the `VALUES (…),(…),(…)` clause by hand (`runBulkQuery`) or hands an array to TypeORM (`runBulkUpsert` / `runBulkInsert`, which wrap `repository.upsert` / `repository.insert`). Postgres caps a single statement at 65535 bind parameters (uint16 wire-protocol limit); exceeding it surfaces as `bind message has N parameter formats but 0 parameters` — cryptic and only triggered under real data volumes, so unit tests won't catch it. A bare `repository.upsert(rows, …)` is the form that slips through review, because nothing in it looks like SQL.

`runBulkQuery` chunks the input, fans chunks out via `Promise.allSettled`, and surfaces the first rejection after all settle. Inside `runTransaction` chunks serialize on the single connection; outside they parallelize across the pool.

```typescript
async upsertMany(rows: Row[]): Promise<Result[]> {
  return this.runBulkQuery(rows, (batch) => {
    const values = batch.map((_, i) => `($${i * N + 1}, …, $${i * N + N})`).join(',');
    const params = batch.flatMap((r) => [r.a, r.b, …]);
    return { sql: `INSERT … VALUES ${values} …`, params };
  });
}
```

- Build `values` and `params` from `batch`, never the outer `rows` — placeholders and params would come from different sets and the chunk blows up.
- For `UPDATE … RETURNING …`, wrap in a CTE + outer `SELECT` so the driver returns rows directly instead of the `[rows, count]` tuple. See a bulk `updateQuantities` method.
- **Chunk by parameter count, not row count.** The chunk size derives from the row's real width — `runBulkQuery` builds one row to count its parameters, and `runBulkUpsert` / `runBulkInsert` read the entity's insertable column count. Pass `{ chunkSize: N }` only to go **below** that. A column added later narrows the chunk on its own.
- Empty input is handled by the helper — no `!rows.length` guard needed.
- Type the row param as the entity or `Partial<Entity>`, not a bespoke `XWrite` interface — see conventions.md → Write & derived types.

Reference impls: `upsertWithStatus`, `upsertForOrders`, `bulkInsertOrders`, an `upsertMany` on a report repository.

## Advisory Locks

For operations where concurrent execution corrupts data (quantity updates, order processing).

```typescript
async updateQuantities(tenantId: number) {
  await this.runWithAdvisoryLock({
    lockId: AdvisoryLockType.QuantitySyncing,
    operation: async () => {
      // Only one process runs this at a time
    },
  });
}
```

Lock types defined in the shared `lock-types.ts` — the `AdvisoryLockType` inventory and how to add one live in [crons-and-sync.md](crons-and-sync.md). When the locked work is a scheduled job that needs run tracking, use `withCronTracking` instead (also in that file).
