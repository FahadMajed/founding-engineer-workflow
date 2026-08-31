# Perf Instruments

The perf-reviewer's measurement sheet: every production instrument available at review time, the command to run it, and what it cannot answer. Measure first, then price — a finding's arithmetic is *measured per-call cost × counted cardinality*, both factors from instruments, neither guessed.

**Fill this in for your system.** Replace every `{{PLACEHOLDER}}` with the read-only handle your environment actually has, and cut a section whose instrument doesn't exist for you — an empty section is better than a command nobody can run. The SQL below assumes Postgres with camelCase columns and snake_case_plural tables; the shapes carry over, the identifiers won't. `{{JOBS_TABLE}}` and `{{EVENTS_TABLE}}` are the run-history and scheduled-event tables the house cron and queue patterns write to (`build-feature/references/crons-and-sync.md`).

These run wherever the read-only prod handles exist — `{{PROD_DB_RO}}` for the read replica, `{{INFRA_DESCRIBE_CMD}}` for infra (your CLAUDE.md documents both). If one is missing in your environment, say so in your summary instead of silently downgrading — the `/observability` rule. Code bounds and any historical ledger are cross-checks, not substitutes.

**Read-only contract.** Everything on this sheet reads. Never point a command at the writable prod handle, never run the disaster-recovery or maintenance scripts that share these command shapes (they create and drop instances), and treat a GET that triggers a sync as a write (the `/call-api` rule). `EXPLAIN` is safe; `EXPLAIN ANALYZE` executes the statement — SELECTs only.

## 1. Driver-set cardinality — count the set the loop actually iterates

The driver set is what the enumerator returns, not what the table holds. Read the enumerator, then write its COUNT:

```bash
{{PROD_DB_RO}} -c "SELECT COUNT(*) FROM integration_accounts a JOIN tenants t ON t.id = a.\"tenantId\" WHERE a.status = 'Active' AND ...;"  # mirror the enumerator's predicates
```

Whole-table ceilings only when a ceiling is the question:

```bash
{{PROD_DB_RO}} -c "SELECT relname, reltuples::bigint FROM pg_class WHERE relname IN ('products','orders','listings','integration_accounts');"
```

## 2. Job runtime history — the jobs table (the diff touches a cron or queue unit)

Baseline before pricing: what does this job cost *today*?

```bash
{{PROD_DB_RO}} -c "
SELECT \"jobType\", COUNT(*) AS runs,
  ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (\"completedAt\" - \"startedAt\")))::numeric, 1) AS p50_s,
  ROUND(percentile_cont(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (\"completedAt\" - \"startedAt\")))::numeric, 1) AS p95_s,
  ROUND(MAX(EXTRACT(EPOCH FROM (\"completedAt\" - \"startedAt\")))::numeric, 1) AS max_s
FROM {{JOBS_TABLE}}
WHERE \"startedAt\" IS NOT NULL AND \"completedAt\" IS NOT NULL
  AND \"createdAt\" >= NOW() - INTERVAL '14 days'
GROUP BY 1 ORDER BY p95_s DESC NULLS LAST;"
```

Scope with `AND \"jobType\" = '<TYPE>'` or the tenant/account predicate. Is it trending?

```bash
{{PROD_DB_RO}} -c "
SELECT ROUND(regr_slope(
    EXTRACT(EPOCH FROM (\"completedAt\" - \"startedAt\")),
    EXTRACT(EPOCH FROM \"startedAt\"))::numeric * 86400, 2) AS runtime_gain_s_per_day, COUNT(*) AS n
FROM {{JOBS_TABLE}}
WHERE \"jobType\" = '<TYPE>' AND \"startedAt\" IS NOT NULL AND \"completedAt\" IS NOT NULL
  AND \"startedAt\" >= NOW() - INTERVAL '14 days';"
```

Queue wait (is "the sync is slow" actually "the sync waits"?): same percentile shape over `("startedAt" - "createdAt")`. Normalize per item with `AVG("totalItems")`.

Caveats that change conclusions:

- The two NULL filters are mandatory; decide whether failed rows count (their `completedAt` marks abort time) and say which you chose.
- **A queue fan-out usually writes one row per unit plus one tick row for the enqueue itself.** A per-type aggregate then blends tick rows into unit runtimes — scope by the per-unit predicate (`"integrationAccountId" IS NOT NULL`, or the account/tenant column) when the question is unit runtime. Read the enqueue code for which shape yours writes; where the code and the docs disagree, trust the code.
- Check the retention sweep and the indexes before trusting a window: a table swept at ~30 days can't answer a 90-day question, and a time-windowed scan on an unindexed `createdAt` is a seq scan — fine as a one-off review read, never in code you ship.

## 3. Event traffic — the scheduled-events table (the diff touches a handler)

How often does this path actually run?

```bash
{{PROD_DB_RO}} -c "
SELECT DATE_TRUNC('day', \"scheduledTime\")::date AS day, COUNT(*) AS fired,
  COUNT(*) FILTER (WHERE status = 'Completed') AS completed,
  COUNT(*) FILTER (WHERE status IN ('Failed','PartialCompletion')) AS bad
FROM {{EVENTS_TABLE}}
WHERE \"eventName\" = '<DomainEvent>' AND \"scheduledTime\" >= NOW() - INTERVAL '7 days'
GROUP BY 1 ORDER BY 1 DESC;"
```

`DATE_TRUNC('hour', ...)` for burst detection. The window predicate is mandatory — a raw COUNT blends whatever history the sweep has left, and a window wider than the retention period undercounts. Pickup delay = `lastExecutionTime - scheduledTime`, with `AND "retryCount" = 0` to strip backoff. If the table stores no handler durations, a unit's runtime is its jobs-table row when it runs under job tracking — and if it doesn't, handler runtime is unmeasured; say so.

## 4. HTTP endpoint latency

**Mutations, historical, per route** — if the app logs a `responseTime` per request, aggregate it in your log store (`{{REQUEST_LOG_QUERY}}`): filter to rows where `responseTime` is present, then `count`, `avg`, and `p95` grouped by route, sorted by p95 descending. Scope to the route the diff touches. Check first what the middleware actually logs — a common setup logs mutations only, which makes this blind to GETs by design.

**Reads, current, prod** — when GETs are never logged server-side, measure client-side via `/call-api` (auth from your prod env file, token inlined, single-quoted header; pure reads only — a GET that triggers a sync is a write):

```bash
for i in 1 2 3; do
  curl -s -o /dev/null -w '%{http_code} %{time_total}s (ttfb %{time_starttransfer}s)\n' \
    "https://{{PROD_API_HOST}}/v1/<path>" -H 'Authorization: Bearer <token>'
done
```

One discarded warm-up first. Read the numbers knowing a response cache may sit on the read path — a warm number can be a cache-hit number, and if local runs disable the cache, local and prod are not comparable on cached paths.

## 5. Per-statement cost — `pg_stat_statements` (probe before trusting)

```bash
{{PROD_DB_RO}} -c "SELECT e.extname, n.nspname FROM pg_extension e JOIN pg_namespace n ON n.oid = e.extnamespace WHERE e.extname = 'pg_stat_statements';"
```

0 rows = not installed on prod (installing is a write — the user's call, not yours). If present:

```bash
{{PROD_DB_RO}} -c "
SELECT calls, ROUND(mean_exec_time::numeric, 2) AS mean_ms, rows, LEFT(query, 110) AS query
FROM pg_stat_statements WHERE query ILIKE '%<table>%' ORDER BY total_exec_time DESC LIMIT 15;"
```

`mean_exec_time` per call is the strongest per-item cost factor available. Cumulative since the last reset — a lifetime blend, never "the last 14 days". Pre-PG13 the columns are `mean_time`/`total_time`.

## 6. Ceilings and context — is the system already near a limit?

```bash
{{PROD_DB_RO}} -c "SHOW max_connections;"   # the pool's hard ceiling; compare against the app's pool config
{{INFRA_DESCRIBE_CMD}}                      # instance class, status, environment health — derive real names first, don't hardcode
```

Then the metric series over the same window (`{{METRICS_QUERY_CMD}}`): DB CPU, connection count, and free memory for the instance you just named; request rate and target response time for the load balancer in front of the app; host memory and disk where the agent publishes them. Instance sizes, autoscaling bounds, and target-group settings come from your infra snapshot — and if that snapshot carries decrypted secrets, never quote its contents into a PR.

## What nothing measures today

So you stop hunting — fill in your own blind spots, and check each still holds before relying on it:

- Third-party per-call latency, when the clients record nothing: the whole-job span is the only proxy.
- Per-handler event durations, when the events table stores no runtime.
- Prod GET latency history, when the request middleware logs mutations only.
- Load testing, when no harness or scenario config exists in the repo.

If a finding needs one of these, say so — naming the missing instrument is part of the review.
