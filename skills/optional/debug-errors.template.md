---
name: debug-errors
description: Debug production HTTP errors (400, 500, or both). Fetches grouped errors from logs, shows counts, then investigates. Use when debugging API failures or reviewing recent server errors.
---

# Debug HTTP Errors

Fetch production errors, group by type, investigate, and suggest fixes.

## Usage

User can specify:
- `500` - server errors only
- `400` - client errors only
- `both` or `all` - both 400 and 500 errors
- Default: 500 if not specified

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
- Error message
- Count (how many times it occurred)
- First seen / Last seen timestamps

This helps prioritize high-frequency errors first.

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
