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

1. Read the design doc from `docs/design_docs/` (primary input)
2. Check if implementation plan exists in `docs/for_ai/plans/`
3. Identify files to create/modify

### 2. Plan (if no impl plan exists)

1. Walk the scoping checklist in [references/new-module-map.md](references/new-module-map.md)
2. Analyze similar features in codebase (using code-explorer agent)
3. Deeply Think & Plan feature
4. Slice the PR stack as part of the plan — big features are stacks by default, **one complete use case per slice** (its schema, logic, endpoint, edge cases, and tests ride together; foundation ships with the first use case that needs it). ~400 source lines per slice is the sizing signal — a use case far over it was cut too big in the design. Read `.claude/skills/ship-pr/references/pr-stack.md`.
5. Save the plan to `docs/for_ai/plans/FEATURE_NAME_IMPLEMENTATION_PLAN.md` and **proceed — no user sign-off on the plan**. The PR review sweep is the quality gate now; the design doc already carried the human decisions.
6. **The plan is immutable once implementation starts.** Never edit it to match what you ended up building — it is the record of the first shot. Diffing it against the shipped PRs and the sweep's findings is how planning quality gets measured and improved.

### 3. Build (per slice)

1. Implement the slice on its stack branch. Keep `docs/for_ai/plans/{FEATURE}_implementation_notes.md` alongside the immutable plan: when reality forces a call the design doc didn't specify, split by blast radius — a choice that changes **scope, contract, or behavior** goes back to the requester as a one-line question; an **implementation-detail** ambiguity gets the *conservative* option, logged under `## Deviations` with one line of why. Never silently change direction. The notes ride into the PR body's What/Why and are what the plan-vs-shipped diff reads.
2. Verify (scripted — run, don't eyeball):
   - `npm run build` && `npm run lint` green.
   - `bash scripts/verify-feature.sh` — static checks build/lint don't do: no `any` added (the CRITICAL rule, made checkable), and a warning when entity schema decorators change with no migration (the silent prod-drift killer). Extend the script when a new failure mode turns out to be mechanically checkable — capture what's verifiable so a future slice can't repeat it.
   - When the diff touches migrations: `npm run migration:show` to confirm the pending set is what you expect (migrations are tracked by class name, not filename).
3. Do NOT write a manual test plan. The slice's tests come from the two-agent split: if the caller already produced a scenarios doc (e.g. sdlc's plan-tests step), skip Agent A and spawn only `/write-tests` (fresh agent B) against it for this slice's behavior; otherwise run both `/plan-tests` and `/write-tests` as fresh sub-agents yourself. Functional review comes from the PR sweep in step 4.

### 4. Ship (per slice) — /ship-pr

Run the `jsdoc` agent on changed files (it edits code — pre-PR), then load `/ship-pr`: it opens the draft PR (What / Why / Stack / Tests / Try it), spawns the review sweep — `security-reviewer`, `design-reviewer`, `conventions-reviewer`, `bug-hunter` (fed the design doc + scenarios + gap report), `data-migration-reviewer` when the diff touches migrations/entities/queries — which comments inline on the PR, then triages every thread and marks ready. Review happens on the PR, not before it.


## CRITICAL Rules

- Never introduce new patterns without discussion, it is fine to improve to suggest or improve some patterns.
- Never use `any` types - define interfaces, unless you cant help it
- Add comments only when code cannot express intent, do not throw comments on every line
- **Deep modules** — Modules should have simple interfaces that hide complex implementation. A good module does a lot behind a small API surface. If a class/service interface is almost as complex as its implementation, it's too shallow — rethink the abstraction.
