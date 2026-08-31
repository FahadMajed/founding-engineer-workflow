---
name: call-api
description: Call existing API endpoints against any running server — local dev or deployed. Handles auth token acquisition and reuse. Use when testing an endpoint, debugging a response, verifying a new feature, or hitting an endpoint to actually do something (cancel an order, repair a sync, reauthorize an integration). Calls endpoints that already exist — never a reason to add one; for one-off probing or data fixes use scripts/ or SQL instead.
---

# Call API

Hit your own API endpoints against a running server, with auth handled.

> **Template.** Replace every `{{PLACEHOLDER}}` with your API's real base URLs, auth endpoint, read-only DB handle, and the handful of endpoints that are genuinely worth calling by hand. The reusable half is the discipline — never add an endpoint to probe with, confirm the path against the controller, confirm before a write on prod. The URLs and endpoint lists are yours.

This is for **your** API. For a third-party API (a channel, a marketplace, a payment provider), use a probe script — `scripts/probe-*.ts` — not this skill.

Two reasons to reach for this:

- **Read** — test an endpoint, check a response shape, verify a feature works.
- **Act** — hit an endpoint to change something: cancel an order, reauthorize an integration, reactivate an account.

## Never add an endpoint for this skill

**This skill calls endpoints that already exist. It is never a reason to add one.**

If the endpoint you want isn't there, that's the answer — not a gap to fill. An endpoint is permanent public surface: auth, permissions, validation, docs, and everyone's maintenance forever. Adding one to probe, test, or fix a one-off means shipping API surface with no user behind it.

Use these instead:

| Need                          | Use                                             |
| ----------------------------- | ----------------------------------------------- |
| Look at data                  | `{{PROD_DB_RO}}`                                |
| One-off data fix              | SQL, or a script in `scripts/`                  |
| Check what a third party says | a `scripts/probe-*.ts`                          |
| Verify a behavior             | `scripts/verify-*.ts`                           |
| Backfill a column             | `scripts/backfill-*.ts`                         |

Keep `scripts/` on those prefixes: `probe-*`, `verify-*`, `backfill-*`, `fix-*`. A script can boot the app module and use the real services and repositories, so "it needs our business logic" is not a reason to build an endpoint — a script reaches the same code.

### The exception: orchestration that already lives behind an endpoint

Some fixes can't be done in SQL because the write is only half the job. Anything mirrored to an external system is the clearest case: updating a record means writing your row **and** pushing it out, respecting per-integration rules, retries, and sync state. SQL updates your DB and silently skips the push — now you say one thing and the other side says another, which is worse than not fixing it.

When an existing endpoint already does that orchestration, **call it** rather than reproducing it:

| Endpoint                        | Why not SQL                                      |
| ------------------------------- | ------------------------------------------------ |
| `{{ORCHESTRATING_ENDPOINT_1}}`  | Pushes the change out to each integration        |
| `{{ORCHESTRATING_ENDPOINT_2}}`  | Recomputes and re-pushes derived state           |
| `{{ORCHESTRATING_ENDPOINT_3}}`  | Runs the full auth flow, returns a redirect URL  |

The test is whether the endpoint **already exists for a real product reason**. If it does, calling it is right. If you're about to add one, stop — write a script.

When one of these ships a `…/preview` twin, run the preview on prod first, show the user, then apply.

Paths drift. Confirm against the controller (`grep -n "@Controller\|@Post" src/**/*.controller.ts`) before calling.

## Pick the base URL first

| Env      | Base URL                                    | Notes                                                 |
| -------- | ------------------------------------------- | ----------------------------------------------------- |
| Local    | `http://localhost:{{PORT}}/{{API_PREFIX}}`  | Default. Server must be running (`npm run start:dev`) |
| Prod     | `{{PROD_BASE_URL}}`                         | Real data, real users. See below                      |

**Before any prod call that writes** (POST/PUT/PATCH/DELETE, or a GET that triggers a sync): say what it will do and confirm with the user first. Cancelling an order or reauthorizing an integration on prod is a real action against a real account — not a test.

Reads against prod are fine without asking. When the goal is only to look at data, `{{PROD_DB_RO}}` is usually faster than an endpoint.

Ask which env if it's not obvious from the request. "test the new endpoint" → local. "cancel this order" → almost always prod.

## Setup

1. **Get credentials:**
   - Check your env files (e.g. `.env.dev`, `.env.prod`) for test user credentials
   - If not found, ask the user for email/password
   - Prod creds sign in to prod; dev creds to local — don't cross them

## Auth flow

```bash
# Get access token (swap base URL for the env you picked)
curl -s -X POST "http://localhost:{{PORT}}/{{API_PREFIX}}/{{AUTH_ENDPOINT}}" \
  -H "Content-Type: application/json" \
  -d '{"email": "{{email}}", "password": "{{password}}"}' | jq '.accessToken'
```

**Store the token** — reuse it for all subsequent requests in the session. Tokens are per-env: a local token won't work against prod.

ALWAYS use single quotes for the header.

## Call the endpoint

```bash
curl -s -X {{METHOD}} "{{base_url}}/{{endpoint}}" \
  -H "Authorization: Bearer {{token}}" \
  -H "Content-Type: application/json" \
  {{-d 'body' if POST/PUT/PATCH}} | jq '.'
```

## Workflow

1. Ask what endpoint to hit (method, path, body if needed) and which env
2. If it writes to prod, state the effect and confirm
3. Obtain the token if not already stored
4. Execute the request with jq formatting
5. Show the response and help interpret the results

## Troubleshooting

| Issue                 | Fix                                                       |
| --------------------- | --------------------------------------------------------- |
| 401 Unauthorized      | Token expired, re-authenticate                            |
| 401 Invalid token     | Use single quotes for -H 'Authorization: Bearer ...'      |
| 401 No token provided | Avoid storing the token in a bash variable, inline it     |
| 401 on prod only      | Token was minted against local — sign in again on prod    |
| Connection refused    | Server not running, check the port                        |
| 403 Forbidden         | User lacks permission for this endpoint                   |
| ECONNREFUSED          | Wrong port or server down                                 |

**Token tip**: tokens with special chars can break when stored in variables. Prefer inlining:

```bash
# Good - single quotes, inline token
curl -s -X GET "http://localhost:{{PORT}}/{{API_PREFIX}}/{{endpoint}}" \
  -H 'Authorization: Bearer eyJhbG...' | jq '.'

# Bad - variable expansion can corrupt token
TOKEN="eyJhbG..."
curl ... -H "Authorization: Bearer $TOKEN"
```

## Self-updating

If you hit auth changes, new required headers, or a different token format:

1. Document the fix
2. Update this skill file with the correction
3. Note the date and what changed

This keeps the skill current as the API evolves.

## Examples

```bash
# GET with query params
curl -s -X GET "http://localhost:{{PORT}}/{{API_PREFIX}}/{{items}}?page=1&limit=10" \
  -H 'Authorization: Bearer {{token}}' | jq '.'

# POST with body
curl -s -X POST "http://localhost:{{PORT}}/{{API_PREFIX}}/{{items}}" \
  -H 'Authorization: Bearer {{token}}' \
  -H "Content-Type: application/json" \
  -d '{"name": "example", "quantity": 1}' | jq '.'

# List tenants - response is {tenants: [...]} not paginated
curl -s "http://localhost:{{PORT}}/{{API_PREFIX}}/{{tenants}}" \
  -H 'Authorization: Bearer {{token}}' | jq '.tenants[] | {id, name}'

# Against prod (confirm first if it writes)
curl -s "{{PROD_BASE_URL}}/{{tenants}}" \
  -H 'Authorization: Bearer {{token}}' | jq '.tenants[] | {id, name}'
```

## Common endpoints

| Endpoint                  | Response structure                 |
| ------------------------- | ---------------------------------- |
| GET /{{tenants}}          | `{tenants: [{id, name, ...}]}`     |
| GET /{{items}}            | `{items: [{id, name, ...}], meta}` |
| DELETE /{{items}}/:id     | Requires `?tenantId=N` query param |
