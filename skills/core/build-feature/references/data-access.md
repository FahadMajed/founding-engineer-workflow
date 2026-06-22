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

## Bulk INSERT / UPDATE — `runBulkQuery`

Any method that builds a multi-row `VALUES (…),(…),(…)` clause with `$N` placeholders per row must go through `this.runBulkQuery` on the base `Repository`. Postgres caps a single statement at 65535 bind parameters (uint16 wire-protocol limit); exceeding it surfaces as `bind message has N parameter formats but 0 parameters` — cryptic and only triggered under real data volumes, so unit tests won't catch it.

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
- Pass `{ chunkSize: N }` when rows are wide (>60 params/row). Default is 1000; safe cap is `params/row × chunkSize < 65535`.
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
