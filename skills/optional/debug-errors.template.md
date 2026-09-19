---
name: debug-errors
description: Debug production errors — request errors (400/500) and background errors from crons, event handlers and services. Fetches grouped errors from logs, shows counts, then investigates. Use when debugging API failures or reviewing recent server errors.
---

# Debug Production Errors

Fetch production errors, group by type, investigate, and suggest fixes.

## Usage

User can specify:
- Default (no argument) — every logged error, whatever its status
- `500` — server errors only
- `400` — client errors only
- `both` — 400 and 500 together

**Only errors thrown inside an HTTP request carry a status.** A cron, an event handler, or a background service has no request in scope, so its errors carry none — and a `500`/`400` sweep cannot see them. Those are routinely the loudest breaks in a system. Start from the default sweep, which filters on nothing but "an error is present", and use the status modes to narrow once you know what you're chasing.

Tag every grouped row with its status — `[500]`, `[404]`, or `[background]` for a row with no status. A tall `[background]` row is a silent recurring break, not noise.

## Log Source Setup

Customize for your logging infrastructure:

```
{{YOUR_LOG_SOURCE}}

Examples:
- CloudWatch: aws logs filter-log-events ...
- Datadog: Use Datadog CLI or API
- ELK: curl to Elasticsearch
- Local: tail -f /var/log/app.log | grep ERROR
```

## Workflow

1. Fetch grouped errors (low egress, grouped by default)
2. Present unique error types with counts
3. For errors to investigate:
   - Fetch full details
   - Read source at stack trace location
   - Query DB if data-related
   - Suggest fix

## Fetch Logs

Scripts default to **grouped/unique view** to reduce output noise.

```bash
# Customize these for your environment
{{YOUR_500_ERROR_SCRIPT}}
{{YOUR_400_ERROR_SCRIPT}}

# Filter for specific error
{{YOUR_FILTER_SCRIPT}} "error pattern"

# Custom timeframe
{{YOUR_TIMEFRAME_SCRIPT}} --hours 24
```

## Output Format

Grouped view shows:
- Status tag — `[500]`, `[404]`, `[background]`
- Error message, truncated
- Count (how many times it occurred)
- First seen / Last seen timestamps

This helps prioritize high-frequency errors first.

## Drill Down

The grouped message is truncated and drops everything around it, so a signature like `Failed to sync for account 1632:` tells you nothing about the cause. Filtering on a substring of the error returns the whole log record — full error text, the message it was logged under, context fields (ids), and the stack when there is one. It works the same for background errors, which usually carry context fields instead of a trace.

```bash
{{YOUR_FILTER_SCRIPT}} "error substring" --limit 3
```

**Group by trace shape before counting findings.** One shared trace signature (an aggregate error wrapping the same HTTP-client and socket frames) across several unrelated accounts is one network blip, not N separate breaks.

## DB Investigation (if applicable)

```bash
# Customize for your database
{{YOUR_DB_QUERY_COMMAND}} "SELECT * FROM {{table}} WHERE id = '{{id}}' LIMIT 1;"
```

## Suggest Fix

For each error:

1. **Root cause** - why it happens
2. **Fix** - code change needed
3. **Prevention** - avoid similar issues

## Common Patterns

### 500 Errors (Server)

| Pattern                                    | Likely Cause       | Fix                    |
| ------------------------------------------ | ------------------ | ---------------------- |
| "Cannot read property X of undefined"      | Null not handled   | Add optional chaining  |
| "duplicate key violates unique constraint" | Race condition     | Add upsert             |
| "Query timeout"                            | Missing index      | Add index              |
| "Entity not found"                         | Data inconsistency | Validate input         |

### 400 Errors (Client)

| Pattern             | Likely Cause         | Fix                       |
| ------------------- | -------------------- | ------------------------- |
| "Validation failed" | Bad input            | Check frontend validation |
| "Unauthorized"      | Token expired/bad    | Check auth flow           |
| "Not found"         | Invalid ID           | Validate entity exists    |
| "Bad Request"       | Missing/invalid body | Check request format      |
