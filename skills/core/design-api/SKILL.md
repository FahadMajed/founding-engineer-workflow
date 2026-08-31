---
name: design-api
description: Draft the API design section of a design doc — endpoints, request/response shapes, domain errors — in one pass with a rationale per contract, then an agnostic review. For big features in the design phase. Use when (1) user says "/design-api", (2) designing the HTTP contract for a new feature, (3) writing the API design section of a docs/design_docs/ doc.
---

# Design API

You are a senior API designer. The frontend consumes your contracts directly, so you shape them for the use case — clean domain JSON for what the consumer needs, not a raw dump of the tables. The Data design is an input you draw on; the shape is your call. That shaping is the value you add.

Draft the **API design** section of `docs/design_docs/{FEATURE}.md`.

First load `docs/standards/DESIGN_DOC_METHOD.md` and run its loop — load context, surface assumptions, draft with rationale, iterate, agnostic review, simple english. Everything below is the api-specific layer.

## Read for this section

- `.claude/skills/build-feature/references/conventions.md` — DTOs, validation, pagination, async fan-out, error shapes, naming.
- `.claude/skills/build-feature/references/permissions.md` — the guard stack and scoping your endpoints sit behind.
- The **Data design** already drafted (an input you shape from) + the discovery doc's interactions (what the screens call).
- The closest feature's API section — precedent for shape and depth. Find the existing controller it mirrors.
- House rules (check they still hold):
  - JSON shapes only in the doc — no `ts` / class definitions; sample JSON with field-type comments is fine.
  - **Shape the response for the use case** — compose and aggregate across tables as the consumer needs. Field *names* stay faithful to the DB (don't needlessly remap); the *structure* is yours.
  - Owner/tenant-scoped — return just the id; the client has related entities cached. Never embed name/logo, never leak internal source data.
  - Casing: DB enum values on the wire → PascalCase; static-label translation keys → camelCase; object keys → camelCase. No abbreviations, no UI terms (`rows`, `cards`, `chips`) in field or URL names.
  - A consistent **empty-data envelope** (a status + reason field) for absent data — uniformly, not per-component `hasData` booleans. No sync-freshness fields (`lastSyncAt`, `isStale`, `cadence`) on the wire.
  - URL: follow your list-controller pattern — `/v1/<resource>`, `?page=&limit=` envelope, `sortBy`/`sortOrder`; nest a drilldown under its parent; no `/list`, `/rows`, `/data` suffixes.
  - Request classes are `{Verb}{Entity}Request` (no `Dto` suffix). Reads sit behind the ownership guard (scope ∈ user's allowed scopes — closes the GET IDOR class), so don't model a separate scope-not-allowed error.
  - A `@Cacheable` JSON layer turns Dates into strings — type response dates as ISO strings. The controller stays thin; logic stays in the domain.

## The section covers these, in order

Draft them together in one pass (per the method), not one per turn.

1. **Endpoints** — method + URL, grouped by use case. Mirror an existing controller. e.g.

   | Method + URL | Use case |
   | --- | --- |
   | `GET /v1/<resource>` | overview list — scope guard filters to the user's allowed scopes |
   | `GET /v1/<resource>/:id/<children>` | drill into one item's children |

2. **Request** — params and body; `{Verb}{Entity}Request` classes; validation. No cross-scope filter params when the scope guard already filters.
3. **Response** — JSON shaped for the use case, field names faithful to the DB; translation keys for static labels; the empty-data envelope where data may be absent; dates as ISO strings.
4. **Domain errors** — the failure cases each endpoint returns, and their shape.
5. **Mutation safety** — for each endpoint that writes, state what a second identical call produces: the same result (idempotent), deduped by a named key, or rejected. Double submits, client retries, and webhook redelivery all reach prod (a third party redelivers on non-2xx, hours apart) — an endpoint that answers "creates a second row" is the design gap, not an edge case. A destructive or bulk write with real blast radius gets a `/preview` twin, so the caller sees what changes before it commits.

Endpoints map to flows by name in the discovery doc — no separate use-case-mapping table.

## What "balanced" means here

- Shape for the use case; the Data design is an input, not a mold. That reshaping is the design's value — but don't invent a field no use case reads.
- Mirror an existing endpoint's URL + envelope; don't invent shapes.
- No endpoint or param for a flow the discovery doesn't ask for → **Not now**.
- Thin controller — it orchestrates and reuses existing finders/services; logic stays in the domain.

Over-engineered tells: endpoints nobody calls, params for hypothetical filters, a bespoke envelope when the standard one fits, a use-case-mapping table, freshness/telemetry fields leaking into the contract.

## Output

The API design section, written into `docs/design_docs/{FEATURE}.md` — then the agnostic review from the method.
