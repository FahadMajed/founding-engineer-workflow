# Crons, Sync Jobs & Advisory Locks

Lookup table.

## Scheduled jobs

`@RunEvery(expr, { timeZone? })` on a service method (the run-every decorator).

- `expr` — a `CronExpression` enum value or a raw cron string (`'0 23 * * *'`).
- `timeZone` — an IANA zone like `'UTC'` or `'America/New_York'`.

Crons are **disabled locally** — they won't fire on your machine. Test the method body directly.

A cron that throws outside its own try/catch surfaces as an unhandled rejection, which is logged but not attributed to the cron. If you want the failure to name itself, catch and log it.

## Two rails: pick the queue one

A recurring job either resolves units of work and hands them to the queue, or does the work inline. **Fan out unless the job has no units.**

### Fan out (the default)

```ts
@RunEvery(CronExpression.EVERY_6_HOURS)
async syncThing(): Promise<void> {
  await this.syncJobService.enqueueUnits({
    eventName: DomainEvent.ThingSyncRequested,
    units: async () => (await this.accountRepository.getAllActive())
      .map((account) => ({
        tenantId: account.tenantId,
        integrationAccountId: account.id,
      })),
  });
}

@OnDomainEvent(DomainEvent.ThingSyncRequested)
async onThingSyncRequested(
  payload: ThingSyncRequestedEvent,
  eventId?: number,
): Promise<void> {
  await this.syncJobService.withTracking({
    tenantId: payload.tenantId,
    integrationAccountId: payload.integrationAccountId,
    syncType: SyncType.Thing,
    eventId,
    lock: `thing-sync:${payload.integrationAccountId}`,
    run: async () => { /* one unit's work */ },
  });
}
```

The unit gets retry with exponential backoff, error classification, stale-claim recovery, a `sync_jobs` row of its own, and release-on-shutdown. Inline, a failed unit's only other attempt is the next tick — a full period later.

`enqueueUnits` derives its own advisory lock from the event name, drops units the queue is still working on, inserts the rest in one statement, and writes a tick row so "did it fire" is answerable even on a tick that found nothing.

**Rules that are not optional:**

- **A unit payload carries identity only** — ids. Never a quantity, delta, cutoff or window. A second delivery re-derives; a stored derivation applies a number computed against state that has since moved.
- **Declare the unit, don't assume it.** Per account when the writes are keyed to that account. Per tenant when the work reads the tenant whole, or when concurrent accounts of one tenant would collide on a unique index.
- **An announcement is not a fan-in.** If the job would otherwise collect across units and emit one batched event, check the consumers (`grep` for `@OnDomainEvent(...)` and `EVENTS_WITHOUT_SUBSCRIBERS`). Each unit announcing its own slice is usually right. Don't invent a completion barrier — the queue has none.
- **Locks:** a per-unit string key with `{ wait: false, throwOnBusy: eventId !== undefined }`, which is what `withTracking`'s `lock` already applies. Never `{ wait: true }` on a fan-out — N units queue behind one lock each holding a claim and heartbeating, and the wait path never throws, so a unit that only waited looks like one that worked. A busy lock **defers** without spending a retry ([queue-error-verdicts.md](queue-error-verdicts.md)).

To wire one: add the `DomainEvent` + `EventPayload` entry ([events.md](events.md)), then the `SYNC_TYPE_BY_EVENT` entry in the shared `enqueueable-events.ts`. That map is the compile-time definition of a fan-out event — `enqueueUnits` accepts nothing else.

### Inline (only when there are no units)

```ts
await this.syncJobService.withCronTracking({
  syncType: SyncType.X,
  lockId: AdvisoryLockType.X,
  run: async (): Promise<SyncResult> => {
    return { totalItems, successfulItems, failedItems, failures };
  },
});
```

One `sync_jobs` row per run (`InProgress` → `Completed` / `PartiallyCompleted` / `Failed`), and it **swallows** the error — there is no caller to catch it — so a job that can fail per unit belongs on the queue instead. If you do stay inline and count failures, populate `failures[]` with the identifier of each thing that failed; a count nobody can act on is not a signal. Run history lives in `sync_jobs` — query by `syncType` ordered by `createdAt DESC` for the last run or last failure.

Legitimately inline: single-statement sweeps whose predicate is *monotone* — the next run's target set contains the failed run's, so a failure costs a period and self-heals (the `cleanupOldEvents` / `cleanupOldSyncJobs` sweeps).

## A failure a human must decide

`failures[]` and retries are for faults time will clear. A unit that fails on a missing *decision* — attribution, matching, anything the system can't know — parked there re-fails every run forever. Route it to a review row instead (a `review_items` table the operator resolves):

- Upsert on the natural unique key (`integrationAccountId, externalItemKey`) — re-runs refresh `lastSeenAt` on one row, never a duplicate.
- Filter out keys already `Dismissed` before upserting — an answered question is never re-asked.
- Store the full snapshot the resolve action needs (`externalData`) so resolving doesn't re-fetch.
- The resolve action writes back the fact the automation was missing (assigning an owner registers the SKU under the chosen tenant), so the next run resolves the unit with no queue involved.
- Routed units count as neither `successfulItems` nor `failedItems` — they're routed, not failed.

## Making a run visible

`sync_jobs` rows only reach the sync-health surface through the lists in the sync-health entities file:

- `STREAM_BY_SYNC_TYPE` — **the real gate.** `indexRunsByStream` drops any type absent from it.
- `PER_ACCOUNT_ERROR_TYPES` — the failure text is on the account's own row (`errorMessage`).
- `GLOBAL_FAILURE_TYPES` — per-account failures itemised in a global row's `failures` jsonb.

A fan-out job belongs in the second list and an inline one in the third, because on the queue a failure stops being an item in a global row and becomes a row of its own. Getting this wrong makes failures invisible rather than loud.

## SyncType

The sync-job entities file — one member per recurring job. Derive the live list from the file; it grows. A value must also exist in the production `sync_type` enum before a job can report under it:

```bash
psql "$PROD_RO_URL" -c "SELECT unnest(enum_range(NULL::sync_type));"
```

## AdvisoryLockType

The shared `lock-types.ts`. Use integer ids in a high reserved range (e.g. **900000+**) to avoid collision with any id (like a `tenantId`) used as a lockId elsewhere. Take highest+1 for the next value; don't fill gaps even when earlier numbers are unused.

A fan-out job needs no entry here — `enqueueUnits` derives its lock from the event name, and `withTracking` takes a string key. Entries are for inline jobs only.

The plain `runWithAdvisoryLock` primitive (mutual exclusion without a `sync_jobs` row) and `DatabaseLockType` row-lock modes are in [data-access.md](data-access.md).
