---
name: adhoc-fullstack-feature
description: Drives a feature that spans the backend repo and the frontend repo, UX-first across both. Runs /ux-discovery-lite → a production frontend with mocked API → a short backend design doc, with a hard user-alignment checkpoint after each before any production code; then builds the backend, runs the two-agent test split, wires the UI to the real API, verifies the flow visually, ships two cross-linked PRs. Use when (1) user says "/adhoc-fullstack-feature", (2) a feature needs both an API and a UI, (3) it's hours of work across both repos, not days.
---

# Adhoc Fullstack Feature

A feature that touches both the API and the UI, driven UX-first across two repos.

## Repos

- **Backend repo** — NestJS, jest. Branch + PR here.
- **Frontend repo** — React/Vite. Separate branch + PR here.

Two repos → two branches → two PRs, cross-linked. Run each repo's build/lint/test from that repo's root. (Single-repo? Collapse to one branch and one PR.)

## Three checkpoints — hard stops

Stop at each and get the user's explicit sign-off before the next phase. They exist so divergence
gets caught at the cheap stage, before a wrong assumption is built end to end.

1. **UX** — after discovery, on the direction (framing, flows, IA), before the demo is built.
2. **Frontend** — after the demo UI, before backend design. When the design serves a persona who is not the requester, the default before this sign-off is a 15-minute walkthrough of the running frontend with one person of that persona (protocol: `.claude/skills/ux-discovery/references/user-probes.md`) — or a recorded bet in the doc's Design Decisions naming why not and its cost-of-being-wrong.
3. **Backend design** — after the design doc, before backend implementation.

Never proceed past a checkpoint on assumption. If the user redirects, fold it in and re-confirm. At each checkpoint, state elapsed effort against the verdict's appetite; past appetite, the checkpoint becomes a shrink / stop decision recorded in `docs/proposals/DECISIONS.md`, not a silent continuation.

## Load skills, don't just read them

- When a step names a skill (`/ux-discovery-lite`, `/frontend-build`, `/chrome-verify`, `/plan-tests`,
  `/write-tests`, `/ship-pr`, `/pr-evidence`, `/fix-bug`, `/optional/task-management`), load it with the Skill tool and
  follow it as binding instructions. Reading the SKILL.md file is not running the skill.
- When you spawn a sub-agent to run a skill, say so in its prompt ("invoke the Skill tool for X,
  follow every step, don't just read it") and require it to return proof of work — the artifact path,
  the findings list, the screenshots. If it returns nothing or clearly skipped the skill, re-run it.

## Inputs

- Feature description (a sentence or two) that needs both an API and a UI.

## When to use the full lifecycle instead

If discovery surfaces a new module, a real schema migration, cross-cutting domain logic, or a
multi-day / design-heavy scope, switch to `/ux-discovery` → full design doc → `/build-feature`.

## Workflow

### 1. UX discovery — main session

Load `/ux-discovery-lite` (it lives in the frontend repo's `.claude/skills/`). If the input is a
shallow sentence with no proposal behind it, the skill's intake runs the proposal probes first (the
last concrete incident, frequency × breadth × cost, what's been tried without software, the outcome);
a full `/proposal` doc is optional at this scale. Clarify intent (2-5 Qs), challenge assumptions,
reach a verdict, quick design. Write to
`docs/discovery/{feature-name}/DISCOVERY-LITE.md`.

If the verdict lands on probe / solve another way / not now, stop there and present that deliverable —
a successful outcome, not a failed run.

→ **CHECKPOINT 1 (UX):** walk the user through the design — framing, direction, flows, IA — in chat.
Get sign-off on the direction before building the frontend. No throwaway mockup: the design becomes
visible in the production frontend (next step), built in the real app.

### 2. Frontend — `/frontend-build` (production frontend, mocked API), main session

Load `/frontend-build` against `DISCOVERY-LITE.md`, operating in the frontend
repo. Prior-art & capabilities sweep gate (shadcn-first), build with craft, polish pass, design-smell scan, i18n
keys, responsive (check the narrow breakpoint).

Mocked API: a typed service returning mock data shaped to what the UX needs (`// TODO: Replace with
real API`). The shapes seed the backend contract — extract them into the feature's `contract-draft.md`
at the checkpoint (per `/frontend-build`'s gate handoff), checked against the API conventions; step 3
consumes the draft and owns the final contract, so nothing the backend must build gets faked away here.

From the frontend root: `npm run build && npm run lint`

→ **CHECKPOINT 2 (Frontend):** show the user the running frontend. Get sign-off before designing the backend.
The checkpoint message carries the implementation-notes disclosures (decisions the user didn't specify;
deviations, conservative option taken) — stated as empty when empty, plain language.
Feedback rounds after this checkpoint re-enter `/frontend-build` + `/chrome-verify` — reload the skills
for the round; every correction is treated as a class (sweep the feature for siblings before replying).

### 3. Backend design doc — main session

Read first: your engineering principles (PHILOSOPHY.md) + `.claude/skills/build-feature/references/`. Then write `docs/design_docs/{FEATURE}.md` following `docs/design_docs/TEMPLATE.md`, but only these three sections:

- **Data design** — entities, keys, schema diffs, constraints, indices, access patterns, migration/backfill (idempotent).
- **API design** — endpoints, request/response schemas, domain errors. Owner/tenant-scoped params; JSON shapes mirroring the schema; static labels as translation keys; a consistent empty-data envelope where it applies. Consumes the frontend's `contract-draft.md` as the seed; this is the real contract — the backend owns it and adjusts freely, recording each divergence from the draft so step 6 adapts the frontend mechanically.
- **Components Design** — backend modules/services/interfaces touched, data flow across them.
- **Internal design** — only if the feature computes a persisted/judged value, has a lifecycle, can run the same work twice, has rules that can disagree, or has a window. Then: computations, edge semantics, invariants, replay, windows, not-handled. Skip anything `build-feature/references/` already answers. Most adhoc work skips this section entirely.

Skip the template's other sections (Overview, Existing Solution, Use Cases, Alternatives, Open
Questions, etc.). Find a similar existing endpoint and mirror it.

→ **CHECKPOINT 3 (Backend design):** get sign-off on schema + API + components before writing backend code.

### 4. Build the backend — main session

Implement the design doc. Identify files (entity, service, controller, dto, spec). Match existing
patterns. No `any`, no comment spam, build only what's designed.

`npm run build && npm run lint`

### 5. Backend tests (mandatory unless external-heavy)

Two-agent split — the implementer does NOT write the tests. Spawn each as its own sub-agent.

- **Agent A** `/plan-tests`: feature intent + public surface only (no impl diff) → `docs/for_ai/test_scenarios/{feature}_test_scenarios.md`
- **Agent B** `/write-tests`: scenarios doc + code location → real tests + gap report. Surface gaps; don't make the test match the code.

Tell each agent to load its skill and return its artifact path. The scenarios from Agent A also feed step 7.

`npm test -- --testNamePattern="Your Describe Block"`

Exception: external-service-heavy (test would be 90% mocks) → skip both, call it out in the PR.

### 6. Wire the frontend to the real API — main session

Replace the demo service with the real api-client call against the design doc's API section. The
recorded divergences from `contract-draft.md` are the work list — adapt the frontend to each. A
mismatch that isn't recorded is a design-doc defect: fix the doc first, then wire to it (the doc
stays the source of truth). Keep an analytics event on every state-changing action.

From the frontend root: `npm run build && npm run lint`

### 7. Verify the UI flow — fresh sub-agent

Spawn a separate agent (not the builder) to load `/chrome-verify`. Give it the planned test scenarios
from step 5 as influence, **re-framed from the UI perspective as the user's flow(s)** — what they
actually do and see end to end, not isolated cases. If the feature has multiple paths, walk each;
if one path, walk it.

Run at the **narrow breakpoint** (where responsiveness breaks; desktop is usually fine). Capture a screenshot at each
scenario/step of the flow, save them under the discovery folder, and return the paths + a pass/fail per
view. Surface the screenshots to the user so they see each path.

### 8. JSDoc sweep — per repo

Run the `jsdoc` agent on each repo's changed files. It edits code directly, so it runs before the PRs.

### 9. Ship — /ship-pr per repo, cross-linked

Backend PR in the backend repo, frontend PR in the frontend repo. Run git + gh from each repo root (or `gh -R`
the right repo). Either side over 400 changed source lines (tests/docs excluded) → slice it per
`.claude/skills/ship-pr/references/pr-stack.md` first.

Load `/ship-pr` for each repo. Per PR it opens the **draft PR** (What / Why / Stack / Tests / **Try it**
— for the backend a curl + expected JSON, for the frontend the flow to click through), then spawns the
review sweep — `security-reviewer`, `design-reviewer`, `conventions-reviewer`, `bug-hunter` (fed the
design doc + step-5 scenarios + gap report), `data-migration-reviewer` when the diff touches
migrations/entities/queries. The agents comment inline on the PR; triage every thread, then mark ready.

The frontend PR carries evidence from `/pr-evidence`, captured from the branch's final state: a
screenshot per state (empty, loading, error, populated), a GIF of the key interaction end to end,
before/after where behavior changed. Triage changed UI code → re-capture before marking ready.

Each PR body links the other PR and its doc (design doc / discovery doc): `Paired PR: [other repo PR URL]`.

### 10. Register the bet + log

Append the feature's row to `docs/discovery/outcomes-register.md`: the observable
changes from DISCOVERY-LITE's "How we'll know it worked" (with baselines and sources of truth), any
Design Decisions bets' falsification lines, first check date ≥ 3 weeks post-ship. `/outcome-review`
grades it when the date arrives.

Then one `/optional/task-management` task covering both PRs. Link both + the docs. Status: `in review`. Description for
non-technical reviewers — lead with the user-facing problem and change, no file paths or code jargon.

## Output

Report: feature shipped, backend + frontend files touched, the design doc + discovery doc, tests
(or why not), both PR URLs, task link.

## CRITICAL Rules

- The three checkpoints are mandatory. Never run the whole flow on assumption.
- The design doc's API section is the source of truth — the backend response and the frontend TS types must match it exactly.
- Load skills with the Skill tool and apply them; verify sub-agents did the work.
- Two repos, two PRs — never mix frontend and backend changes into one repo.
- Match existing patterns; no new ones without discussion. No `any` types. Comments only when code can't express intent. Deep modules — small interface over hidden complexity.
- Frontend: shadcn first, responsive, i18n keys, analytics on every state-changing action.
