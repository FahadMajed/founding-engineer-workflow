---
name: adhoc-fullstack-feature
description: Drives a feature that spans the backend repo and the frontend repo, UX-first across both. Runs /ux-discovery-lite with a cheap HTML preview → a frontend demo → a short backend design doc, with a hard user-alignment checkpoint after each before any production code; then builds the backend, runs the two-agent test split, wires the UI to the real API, verifies the flow visually, ships two cross-linked PRs. Use when (1) user says "/adhoc-fullstack-feature", (2) a feature needs both an API and a UI, (3) it's hours of work across both repos, not days.
---

# Adhoc Fullstack Feature

A feature that touches both the API and the UI, driven UX-first across two repos.

## Repos

- **Backend repo** — branch + PR here.
- **Frontend repo** — separate branch + PR here.

Two repos → two branches → two PRs, cross-linked. Run each repo's build/lint/test from that repo's root. (Single-repo? Collapse to one branch and one PR.)

## Three checkpoints — hard stops

Stop at each and get the user's explicit sign-off before the next phase. They exist so divergence gets caught at the cheap stage, before a wrong assumption is built end to end.

1. **UX** — after discovery + the HTML preview, before any production UI.
2. **Frontend** — after the demo UI, before backend design.
3. **Backend design** — after the design doc, before backend implementation.

Never proceed past a checkpoint on assumption. If the user redirects, fold it in and re-confirm.

## Load skills, don't just read them

- When a step names a skill (`/ux-discovery-lite`, `/frontend-build`, `/chrome-verify`, `/plan-tests`, `/write-tests`, `/fix-bug`), load it with the Skill tool and follow it as binding instructions. Reading the SKILL.md file is not running the skill.
- When you spawn a sub-agent to run a skill, say so in its prompt ("invoke the Skill tool for X, follow every step, don't just read it") and require it to return proof of work — the artifact path, the findings list, the screenshots. If it returns nothing or clearly skipped the skill, re-run it.

## Inputs

- Feature description (a sentence or two) that needs both an API and a UI.

## When to use the full lifecycle instead

If discovery surfaces a new module, a real schema migration, cross-cutting domain logic, or a multi-day / design-heavy scope, switch to `/ux-discovery` → full design doc → `/build-feature`.

## Workflow

### 1. UX discovery + HTML preview — main session

Load `/ux-discovery-lite`. Clarify intent (2-5 Qs), challenge assumptions, quick design. Write to `docs/discovery/{feature-name}/DISCOVERY-LITE.md`.

Then build a cheap, low-fidelity **HTML mockup** of the key screen(s) and states — throwaway, not production code — so the UX is visible before any engineering effort goes into the real frontend. Save it to `docs/discovery/{feature-name}/preview.html` and render it inline for the user (the visualize widget works well for this).

→ **CHECKPOINT 1 (UX):** walk the user through the design and the HTML preview. Get sign-off before building production UI.

### 2. Frontend demo — `/frontend-build`, main session

Load `/frontend-build` against `DISCOVERY-LITE.md` + the approved preview, operating in the frontend repo. Component inventory gate (shadcn first), build with craft, polish pass, design-smell scan, i18n keys, responsive (check the narrow breakpoint).

Demo mode: a typed service returning mock data shaped to what the UX needs (`// TODO: Replace with real API`). This is a first cut — the real API shape is settled in step 3, not here.

From the frontend root: `npm run build && npm run lint`

→ **CHECKPOINT 2 (Frontend):** show the user the running demo UI. Get sign-off before designing the backend.

### 3. Backend design doc — main session

Read first: your engineering principles (PHILOSOPHY.md) + `.claude/skills/build-feature/references/`. Then write `docs/design_docs/{FEATURE}.md` following `docs/design_docs/TEMPLATE.md`, but only these three sections:

- **Data design** — entities, keys, schema diffs, constraints, indices, access patterns, migration/backfill (idempotent).
- **API design** — endpoints, request/response schemas, domain errors. Owner/tenant-scoped params; JSON shapes mirroring the schema; static labels as translation keys; a consistent empty-data envelope where it applies. This is the real contract — heavy backend influence, aligned to the approved UX + demo.
- **Components design** — backend modules/services/interfaces touched, data flow, edge cases, invariants.

Skip the template's other sections (Overview, Existing Solution, Use Cases, Alternatives, Open Questions, etc.). Find a similar existing endpoint and mirror it.

→ **CHECKPOINT 3 (Backend design):** get sign-off on schema + API + components before writing backend code.

### 4. Build the backend — main session

Implement the design doc. Identify files (entity, service, controller, dto, spec). Match existing patterns. No `any`, no comment spam, build only what's designed.

`npm run build && npm run lint`

### 5. Backend tests (mandatory unless external-heavy)

Two-agent split — the implementer does NOT write the tests. Spawn each as its own sub-agent.

- **Agent A** `/plan-tests`: feature intent + public surface only (no impl diff) → `docs/for_ai/test_scenarios/{feature}_test_scenarios.md`
- **Agent B** `/write-tests`: scenarios doc + code location → real tests + gap report. Surface gaps; don't make the test match the code.

Tell each agent to load its skill and return its artifact path. The scenarios from Agent A also feed step 7.

`npm test -- --testNamePattern="Your Describe Block"`

Exception: external-service-heavy (test would be 90% mocks) → skip both, call it out in the PR.

### 6. Wire the frontend to the real API — main session

Replace the demo service with the real api-client call against the design doc's API section. Where the demo's assumed shape and the real API don't line up, adjust the frontend types or the API to match — wiring is where the shape settles. Keep an analytics event on every state-changing action.

From the frontend root: `npm run build && npm run lint`

### 7. Verify the UI flow — fresh sub-agent

Spawn a separate agent (not the builder) to load `/chrome-verify`. Give it the planned test scenarios from step 5 as influence, **re-framed from the UI perspective as the user's flow(s)** — what they actually do and see end to end, not isolated cases. If the feature has multiple paths, walk each; if one path, walk it.

Run at the **narrow breakpoint** (where responsiveness breaks; desktop is usually fine). Capture a screenshot at each scenario/step of the flow, save them under the discovery folder, and return the paths + a pass/fail per view. Surface the screenshots to the user so they see each path.

### 8. Review & re-iterate — per repo

Run the `/adhoc-feature` sweep on each repo, using that repo's references:

- references agent (aligned with that repo's references) → code-simplifier

then

- code-reviewer (verify claims, prefer a failing test via `/fix-bug`) → jsdoc on changed files

Backend uses `build-feature/references`; frontend uses `frontend-build/reference` + its CLAUDE.md. Each agent returns its findings; an agent that returns nothing skipped the work — re-run it.

### 9. PRs (two, cross-linked)

Backend PR in the backend repo, frontend PR in the frontend repo. Run git + gh from each repo root. Each body links the other PR and its doc (design doc / discovery doc).

```bash
git add -A && git commit -m "feat: [short description]"
git push -u origin claude/[branch-name]
gh pr create --title "[short description]" --body "## What
[One-line summary]

## Why
[The user problem this solves]

## Tests
[What you added, or 'No tests — external-service-heavy']

Paired PR: [other repo PR URL]"
```

### 10. Log

One task covering both PRs (see `/optional/task-management`). Link both + the docs. Status: `in review`. Description for non-technical reviewers — lead with the user-facing problem and change, no file paths or code jargon.

## Output

Report: feature shipped, backend + frontend files touched, the design doc + discovery doc, tests (or why not), both PR URLs, task link.

## CRITICAL Rules

- The three checkpoints are mandatory. Never run the whole flow on assumption.
- The design doc's API section is the source of truth — the backend response and the frontend types must match it exactly.
- Load skills with the Skill tool and apply them; verify sub-agents did the work.
- Two repos, two PRs — never mix frontend and backend changes into one repo.
- Match existing patterns; no new ones without discussion. No `any` types. Comments only when code can't express intent. Deep modules — small interface over hidden complexity.
- Frontend: shadcn first, responsive, i18n keys, analytics on every state-changing action.
