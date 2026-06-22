# Crons, Sync Jobs & Advisory Locks

Lookup table.

## Scheduled jobs

`@RunEvery(expr, { timeZone? })` on a service method (the run-every decorator).

- `expr` — a `CronExpression` enum value or a raw cron string (`'0 23 * * *'`).
- `timeZone` — an IANA zone like `'UTC'` or `'America/New_York'`.

Crons are **disabled locally** — they won't fire on your machine. Test the method body directly.

## Cron tracking + locking

For a job that must not overlap, or where concurrent runs corrupt data, wrap the body:

```ts
await this.syncJobService.withCronTracking({
  syncType: SyncType.X,
  lockId: AdvisoryLockType.X,
  run: async (): Promise<SyncResult> => {
    // ...
    return { totalItems, successfulItems, failedItems };
  },
});
```

One `sync_jobs` row per run (`InProgress` → `Completed` / `PartiallyCompleted` / `Failed`). Skips silently if the lock is already held (`wait: false`). Run history lives in `sync_jobs` — query by `syncType` ordered by `createdAt DESC` for the last run or last failure.

To wire one:
- Add a `SyncType` value (below) in the sync-job entities file.
- Add an `AdvisoryLockType` value (below) in the shared `lock-types.ts`.

## SyncType

The sync-job entities file. One member per recurring job, e.g.

```
ExistingRecords, ExistingOrders, RecordUpdates, CancelledOrders, ReturnedOrders,
MissedOrders, Catalog, Content, Ratings, PhantomCleanup
```

## AdvisoryLockType

The shared `lock-types.ts`. Use integer ids in a high reserved range (e.g. **900000+**) to avoid collision with any id (like a `tenantId`) used as a lockId elsewhere. Take highest+1 for the next value; don't fill gaps even when earlier numbers are unused.

The plain `runWithAdvisoryLock` primitive (mutual exclusion without a `sync_jobs` row) and `DatabaseLockType` row-lock modes are in [data-access.md](data-access.md).
