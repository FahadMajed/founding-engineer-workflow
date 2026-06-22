---
name: build-feature
description: Implement features from design docs. Use when (1) user references a design doc from docs/design_docs/, (2) user says "build feature" or "implement feature", (3) user references an existing impl plan from docs/for_ai/plans/. Creates implementation plan from design doc if none exists, then builds.
---

# Build Feature

Implement features following established patterns.

## Required reading

**Read in full, every time** — these apply to all code. Don't skim, don't assume you remember them:

1. [references/architecture.md](references/architecture.md) — module structure, factory pattern, service layer rules
2. [references/conventions.md](references/conventions.md) — naming, named params, DTOs, validation, pagination, async fan-out, errors, JSDoc
3. [references/data-access.md](references/data-access.md) — repository pattern, query idioms, transactions, advisory locks

**Then route through** [references/new-module-map.md](references/new-module-map.md) — walk the scoping checklist; it points you to the domain references your feature actually needs. Those are **lookup tables** (concrete enum values + anchors) — open the relevant section, don't read end to end:

- [references/permissions.md](references/permissions.md) — guard stack, resource/action, scoping
- [references/events.md](references/events.md) — domain event emit/consume + existing events
- [references/crons-and-sync.md](references/crons-and-sync.md) — `@RunEvery`, job types, job tracking, advisory lock ids
- [references/entities-and-migrations.md](references/entities-and-migrations.md) — `EntitySchema`, column types, encryption, migrations, audit enums

## Workflow

### 1. Understand Scope

1. Read the design doc from `docs/design_docs/` (primary input).
2. Check if an implementation plan exists in `docs/for_ai/plans/`.
3. Identify files to create/modify.

### 2. Plan (if no impl plan exists)

1. Walk the scoping checklist in [references/new-module-map.md](references/new-module-map.md).
2. Analyze similar features in the codebase (using the `code-explorer` agent).
3. Deeply think & plan the feature.
4. Copy the approved plan you wrote to `docs/for_ai/plans/FEATURE_NAME_IMPLEMENTATION_PLAN.md`.
5. If no plan file exists and you are not in plan mode, notify the user to switch to plan mode — this is a must.
6. Implement your plan.
7. Verify with `npm run build` & `npm run lint` — that is the full extent of build-step verification.
8. Do NOT run tests or write a manual test plan. Functional/QA correctness is delegated to the separate review agents in "Review & Re-iterate" below.

### 3. When you finish, Review & Re-iterate

Launch 2 agents sequentially with different focuses:

- A references agent that ensures your WIP is 100% aligned with the references/ under this skill.

Then:

- Simplicity/DRY/Elegance and ALL refactoring principles: code quality and maintainability, focused on reuse without compromising human readability (code-simplifier agent).

Once you resolve what is needed, spawn 2 more agents:

- Bugs/Correctness: functional correctness and logic errors (code-reviewer), and verify the claims, preferably with a failing test using `/fix-bug`.
- JSDoc cleanup: delete noisy docs, add missing docs for non-obvious behavior (jsdoc agent on changed files).

## CRITICAL Rules

- Never introduce new patterns without discussion — it's fine to suggest or improve some patterns.
- Never use `any` types — define interfaces, unless you can't help it.
- Add comments only when code cannot express intent; do not throw comments on every line.
- **Deep modules** — modules should have simple interfaces that hide complex implementation. A good module does a lot behind a small API surface. If a class/service interface is almost as complex as its implementation, it's too shallow — rethink the abstraction.
