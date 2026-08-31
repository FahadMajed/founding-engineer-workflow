---
name: scoped-fullstack-feature
description: Drives a feature that spans the backend repo and the frontend repo, UX-first across both. Runs /ux-discovery-lite → a production frontend with mocked API → a short backend design doc, with a hard user-alignment checkpoint after each before any production code; then builds the backend, runs the two-agent test split, wires the UI to the real API, verifies the flow visually, ships two cross-linked PRs. Use when (1) user says "/scoped-fullstack-feature", (2) a feature needs both an API and a UI, (3) it's hours of work across both repos, not days.
---

# Scoped Fullstack Feature

A feature that touches both the API and the UI, driven UX-first across two repos.

## The standard

Same bar as `/sdlc`. **What scales here is deliberation, not craft.** Scoped means a smaller scope, never a lower standard — nothing in the first list below is optional because the work is short.

**Not relaxed — identical to `/sdlc`:**

- Engineering principles + `build-feature/references/` read before the design doc
- A written design doc for schema + API + components, signed off before backend code
- The design doc reviewed agnostically before its checkpoint (step 3)
- Test scenarios planned from the design doc, before the implementation exists
- Two-agent test split — the implementer never plans or writes the tests
- jsdoc sweep, per repo
- The full `/ship-pr` review sweep on both PRs, every thread triaged
- One complete use case per PR; `/pr-evidence` on the frontend PR
- Bet registered, design doc reconciled with what shipped

**Traded away, and what each costs you:**

- **`/ux-discovery-lite` instead of the full one** — a smaller scope, not a lower standard: two ideation agents (one alternative, one kill-case) instead of the full fan-out, and a narrower web sweep. You get one direction thought through against a challenger, not several compared in depth. If the problem has more than one plausible shape, escalate — lite's own triggers say when, and `/sdlc` is where it goes.
- **Design doc narrative sections skipped** — no Existing Solution, Use Cases, or Alternatives written down. Nobody outside this run can reconstruct why the shape is what it is. Fine when mirroring an existing endpoint; costly when the feature is a new idea.
- **One agnostic review pass instead of four section skills** — the review is broad rather than deep per section. A subtle schema or contract mistake can survive it.
- **No parity sweep** — nobody walks the feature's other surfaces against its capability set, so a capability present on one surface and missing on its sibling ships that way. Raise it at Checkpoint 3 when the design already implies the sibling.

## Repos

- **Backend repo** — NestJS, jest. Branch + PR here.
- **Frontend repo** — React/Vite. Separate branch + PR here.

Resolve the frontend root once at the start of the run (`git -C <path> rev-parse --show-toplevel`, or find it) and reuse it. Never hardcode an absolute path — checkouts differ per machine and per session.

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
  `/write-tests`, `/ship-pr`, `/pr-evidence`, `/fix-bug`, `/visual-gate`, `/optional/task-management`), load it with the Skill tool and
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

Lite's intake finds or creates the effort's task (`/optional/task-management`); it rides the whole
run, and each checkpoint fills the section it decided — Problem at Checkpoint 1, Solution at
Checkpoint 2, What Ships at Checkpoint 3.

If the verdict lands on probe / solve another way / not now, stop there and present that deliverable —
a successful outcome, not a failed run. The task closes with that verdict as its completion comment.

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
- **API design** — endpoints, request/response schemas, domain errors. Owner/tenant-scoped params; JSON shapes mirroring the schema; static labels as translation keys; a consistent empty-data envelope where it applies. Consumes the frontend's `contract-draft.md` as the seed; this is the real contract — the backend owns it and adjusts freely, recording each divergence from the draft so step 7 adapts the frontend mechanically.
- **Components Design** — backend modules/services/interfaces touched, data flow across them.
- **Internal design** — only if the feature computes a persisted/judged value, has a lifecycle, can run the same work twice, has rules that can disagree, or has a window. Then: computations, edge semantics, invariants, replay, windows, not-handled. Skip anything `build-feature/references/` already answers. Most scoped work skips this section entirely.

Skip the template's other sections (Overview, Existing Solution, Use Cases, Alternatives, Open
Questions, etc.). Find a similar existing endpoint and mirror it.

**Then get it reviewed agnostically — fresh sub-agent, before the checkpoint.** You wrote the doc and
you're about to implement it; that's the same bias the test split exists to break, applied to design.
Spawn one agent that has not seen this run's reasoning. Give it the doc, `contract-draft.md`, and
`.claude/skills/build-feature/references/` — not your rationale. Ask it to argue against each choice on
its own merits: does the schema hold at real volume (keys, indices, the migration's idempotence), does
the API match house conventions and mirror the schema, are the components deep or shallow, what does
the doc not say that an implementer would have to guess. It returns findings, not edits. Fix or
push back on every one in the doc before presenting; carry anything unresolved into the checkpoint as
an open question rather than burying it.

**Alongside it, spawn `simplicity-challenger` on the same doc** (parallel, same inputs). The broad
reviewer argues each choice on its merits — it takes the machinery as given. The challenger asks
whether the machinery is needed at all and builds the cheaper version to prove it, coming back
SIMPLER / EQUIVALENT / EARNED. Cutting a table here costs a paragraph; cutting it at the PR costs the
build.

`/sdlc` gets four of these, one per section, each deeper than this. One broad pass is the trade — it
catches shape mistakes, it can miss a subtle one.

→ **CHECKPOINT 3 (Backend design):** get sign-off on schema + API + components before writing backend code. Render the doc with `/visual-gate` and link the page — schema before/after and endpoint cards are what the user is actually deciding on, and prose hides both. Doc stays canonical: a gap the render surfaces is a doc fix, then re-render. Carry the review's unresolved findings into this message — flagged as follow-ups, decided here, never dropped silently.

### 4. Plan the backend tests — fresh sub-agent, before any backend code

Spawn **Agent A** with `/plan-tests`, against the **design doc** — not an implementation, because none
exists yet. That ordering is the point: scenarios written from the design catch gaps while a gap still
costs a doc edit. Written after the code, they document what got built.

Give it the design doc + `DISCOVERY-LITE.md`. It returns GIVEN/WHEN/THEN scenarios at
`docs/for_ai/test_scenarios/{feature}_test_scenarios.md`.

If it surfaces a behavior the design doc doesn't answer, that's a design gap — fix the doc (and
re-confirm with the user if it changes what was signed off at Checkpoint 3) before writing code.

These scenarios feed step 6 (Agent B), step 8 (chrome-verify), and the bug-hunter in step 10's sweep.

### 5. Build the backend — main session

Implement the design doc. Identify files (entity, service, controller, dto, spec). Match existing
patterns. No `any`, no comment spam, build only what's designed.

`npm run build && npm run lint`

### 6. Write the backend tests — fresh sub-agent (mandatory unless external-heavy)

The implementer does NOT write the tests. Spawn **Agent B** with `/write-tests` — a different agent
from step 4's Agent A, and not the one that built step 5.

- **Agent B** `/write-tests`: step-4 scenarios doc + code location → real tests + gap report.

Tell it to load its skill and return its artifact path. Its gap report is the payoff of the step-4
ordering: every mismatch between the scenarios and the built code is either a bug in the code or a
behavior the design missed. Surface both to the user — never make the test match the code.

`npm test -- --testNamePattern="Your Describe Block"`

Exception: external-service-heavy (test would be 90% mocks) → skip Agent B, call it out in the PR.
Step 4 still runs — the scenarios are what chrome-verify and the bug-hunter read.

### 7. Wire the frontend to the real API — main session

Replace the demo service with the real api-client call against the design doc's API section. The
recorded divergences from `contract-draft.md` are the work list — adapt the frontend to each. A
mismatch that isn't recorded is a design-doc defect: fix the doc first, then wire to it (the doc
stays the source of truth). Keep an analytics event on every state-changing action.

From the frontend root: `npm run build && npm run lint`

### 8. Verify the UI flow — fresh sub-agent

Spawn a separate agent (not the builder) to load `/chrome-verify`. Give it the planned test scenarios
from step 4 as influence, **re-framed from the UI perspective as the user's flow(s)** — what they
actually do and see end to end, not isolated cases. If the feature has multiple paths, walk each;
if one path, walk it.

Run at the **narrow breakpoint** (where responsiveness breaks; desktop is usually fine). Capture a screenshot at each
scenario/step of the flow, save them under the discovery folder, and return the paths + a pass/fail per
view. Surface the screenshots to the user so they see each path.

### 9. JSDoc sweep — per repo

Run the `jsdoc` agent on each repo's changed files. It edits code directly, so it runs before the PRs.

### 10. Ship — /ship-pr per repo, cross-linked

Backend PR in the backend repo, frontend PR in the frontend repo. Run git + gh from each repo root (or `gh -R`
the right repo). Slice each side **by use case** per `.claude/skills/ship-pr/references/pr-stack.md`
— one complete use case per PR, never a layer, never half a use case. ~400 changed source lines
(tests/docs excluded) is a signal on that cut, not the cutter: a use case landing near it is normal,
far over it means the use case was cut too big upstream. Never split a use case to duck the number.

Load `/ship-pr` for each repo. Per PR it opens the **draft PR** (What / Why / Stack / Tests / **Try it**
— for the backend a curl + expected JSON, for the frontend the flow to click through), then spawns the
review sweep — `security-reviewer`, `design-reviewer`, `conventions-reviewer`, `bug-hunter` (fed the
design doc + step-4 scenarios + step-6 gap report), `simplicity-challenger` whenever the diff adds
new machinery, `sql-and-migration-reviewer` whenever the diff contains a query or changes how data is
read or written (a migration is its rarest trigger, not its gate), and `perf-reviewer` whenever the
diff touches a runtime path, pricing loops, fan-outs, and memory at prod cardinality. The agents
comment inline on the PR; triage every thread, then mark ready.

The frontend PR carries evidence from `/pr-evidence`, captured from the branch's final state: a
screenshot per state (empty, loading, error, populated), a GIF of the key interaction end to end,
before/after where behavior changed. Triage changed UI code → re-capture before marking ready.

Each PR body links the other PR and its doc (design doc / discovery doc): `Paired PR: [other repo PR URL]`.

### 11. Register the bet + log

Append the feature's row to `docs/discovery/outcomes-register.md`: the observable
changes from DISCOVERY-LITE's "How we'll know it worked" (with baselines and sources of truth), any
Design Decisions bets' falsification lines, first check date ≥ 3 weeks post-ship. `/outcome-review`
grades it when the date arrives.

Then reconcile the design doc with what shipped: walk its Data + API sections against the merged
migrations, entities, controllers, and DTOs, and fold every delta into the doc — including the ones the
API section already recorded against `contract-draft.md`. A doc describing the design instead of the
system is worse than no doc, because it's believed.

Then `/optional/task-management` on the effort's task (from step 1's intake): status `in review`, a
completion comment linking both PRs + the docs. The description reads for non-technical reviewers —
lead with the user-facing problem and change, no file paths or code jargon.

## Output

Report: feature shipped, backend + frontend files touched, the design doc + discovery doc, tests
(or why not), both PR URLs, task link.

## CRITICAL Rules

- Smaller scope, same standard. Never treat this workflow as permission to cut craft.
- The three checkpoints are mandatory. Never run the whole flow on assumption.
- Design doc reviewed by a fresh agent before Checkpoint 3; tests planned from the doc before backend code exists.
- The design doc's API section is the source of truth — the backend response and the frontend TS types must match it exactly.
- Load skills with the Skill tool and apply them; verify sub-agents did the work.
- Two repos, two PRs — never mix frontend and backend changes into one repo.
- Match existing patterns; no new ones without discussion. No `any` types. Comments only when code can't express intent. Deep modules — small interface over hidden complexity.
- Frontend: shadcn first, responsive, i18n keys, analytics on every state-changing action.
