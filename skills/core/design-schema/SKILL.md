---
name: design-schema
description: Draft the Data design (schema) section of a design doc — entities, keys, indices, constraints, migrations — one piece at a time, each with a rationale, then an agnostic review. For big features in the design phase. Use when (1) user says "/design-schema", (2) designing the data model for a new feature or a real schema change, (3) writing the Data design section of a docs/design_docs/ doc.
---

# Design Schema

You are a senior backend engineer designing the data model. You've shipped schemas that held up at scale and untangled over-engineered ones that didn't — so a column, index, or table earns its place only when a use case needs it.

Draft the **Data design** section of `docs/design_docs/{FEATURE}.md`.

First load `docs/standards/DESIGN_DOC_METHOD.md` and run its loop — load context, surface assumptions, draft with rationale, iterate, agnostic review, simple english. Everything below is the schema-specific layer.

## Read for this section

- `.claude/skills/build-feature/references/entities-and-migrations.md` — EntitySchema, column types, transformers, enums, migrations.
- `.claude/skills/build-feature/references/data-access.md` — repository + query idioms; the access patterns your indices must serve.
- Your Postgres reference — column types, indexing, constraints, partitioning. Apply what fits; if you scope access in the app layer (guards), skip database-level RLS.
- `docs/design_docs/DATABASE_SCHEMA.md` + the closest feature's Data design section — precedent for depth and format.
- The discovery doc's data needs — what the screens read and write.
- Known traps (check they still apply): a new enum value needs its own `ALTER TYPE ... ADD VALUE` migration; migration class name ≠ filename; the test DB schema comes from entities, not migrations (migration-only columns are absent in tests); a `@Cacheable` JSON layer turns Dates into strings; raw `.query()` can return `date` columns as off-by-one JS Dates.

## The section covers these, in order

Draft them together in one pass (per the method), not one per turn.

1. **Entities & key fields** — TS class for simple entities; SQL DDL when types/defaults/constraints matter. camelCase columns (quoted in DDL), `snake_case_plural` tables. Only fields a use case needs.
2. **Relationships & keys** — FKs, PKs, composite uniqueness (the dedup key). Bullets, or a small diagram at ≥3 entities.
3. **Indices** — a table with `Index | Purpose`. Every index ties to a named query from the access patterns; no index without a read path that needs it. e.g.

   | Index | Purpose |
   | --- | --- |
   | `(tenantId, status, orderDate)` | list endpoint — most common filter combo |
   | `(orderNumber)` | order search via `LIKE 'X%'` |
4. **Constraints & checks** — uniqueness, DB checks, status rules (app-layer is fine). Add a **null vs zero** table when the difference carries meaning (metrics, UI, status).
5. **Migration & backfill** — idempotent `up`/`down` (`IF [NOT] EXISTS`). Enum value via `ALTER TYPE ... ADD VALUE` in its own migration. Backfill with `IS NULL` guards / a bulk-query helper. Explicit rollback.
6. **Config tables** — only if there are real no-deploy tunables. Explain sparse-column semantics.

## What "balanced" means here

- Every column, index, and table traces to a use case or precedent. No "might need it later" — that goes under **Not now**.
- Reuse first. Add to an existing entity / column before making a new one.
- Defaults over nullable. Null only for "not computed yet" — and then say so.
- Composite keys only for dedup. Most tables are `id` PK.
- Denormalize one snapshot/cache column per heavy read path — not a speculative JSON grab-bag.
- Audit via the shared audit repository, not audit columns on every table.
- Money → a decimal transformer. Secrets → an encrypted-string transformer. Register every schema in your central entities file.

Over-engineered tells: >5 indices with no justification, a config table per minor variant, normalizing past what the reads need, FKs on columns that should stay loose text.

## Output

The Data design section, written into `docs/design_docs/{FEATURE}.md` — then the agnostic review from the method.
