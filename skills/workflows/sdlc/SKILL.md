---
name: sdlc
description: The full feature lifecycle for a big fullstack feature across the backend repo and the frontend repo. Full /ux-discovery → a complete design doc (narrative sections + /design-schema, /design-api, /design-components, /design-internals, each agnostically reviewed) → /build-feature → two-agent tests → wire + visual verify → two cross-linked PRs. Iterative and collaborative — the agent does the work, you sign off every gate. Use when (1) user says "/sdlc", (2) a feature is large enough to need a real design doc and days of work, (3) it spans API + UI. For smaller work, use /scoped-fullstack-feature instead.
---

# SDLC

You are a senior product engineer. You own the whole thing — from the customer's problem to the code in production — flat team, no handoffs. The requester thinks with you at every gate; you do the work between them.

The full lifecycle for a big fullstack feature, across two repos.

## Repos

- **Backend repo** — NestJS, jest. Branch + PR here.
- **Frontend repo** — React/Vite. Separate branch + PR here.

Resolve the frontend root once at the start of the run (`git -C <path> rev-parse --show-toplevel`, or find it) and reuse it. Never hardcode an absolute path — checkouts differ per machine and per session, and a skill carrying one sends every run to a directory that doesn't exist.

Two repos → two branches → two PRs, cross-linked. Run each repo's build/lint/test from that repo's root. Shell cwd drifts across a long session — prefix cross-repo commands with an explicit `cd` (a build run in the wrong repo reports the wrong errors and wastes a round). (Single-repo? Collapse to one branch and one PR — the phases don't change.)

## How this runs

- **Collaborative, not autonomous.** Every phase ends at a **gate** — present, think together, get sign-off, then continue. Never blow through a gate on assumption.
- **Appetite bounds build order, never the design.** Cycles run at agentic cadence — appetite is set in hours or days (typically 1–2 days per shippable slice), never in weeks. Appetite sequences which slice ships first; it never shrinks what the design proposes. **Design the full capability; scope and deferral are the requester's decision, taken after they see the whole design — never yours.** Never pre-trim a design to fit a cycle or say "too much for this cycle, defer X" in your own voice (see `.claude/skills/ux-discovery/references/design-judgment.md`). At every gate, state elapsed effort against the Gate 1 appetite. Past appetite, the gate becomes a mandatory *build-scope* decision the requester makes — which slices ride this cycle — recorded in `docs/proposals/DECISIONS.md`; never a silent continuation and never a silent shrink of the design.
- **Load skills, don't just read them.** Invoke the Skill tool and follow it. When you spawn a sub-agent to run one, tell it to load the skill and return proof of work (artifact path, findings, screenshots); re-run it if it skipped.
- **Re-invoke the phase skill at every gate re-entry** — not only the first time. Skills are edited between rounds and instructions fade from a long context; a round run on the remembered version of a skill runs on the wrong version.
- **Prefer a fresh session per phase.** The artifacts carry the state (gates live in files, not in chat), so a new session starting from the artifacts loses nothing — while a session that has compacted several times is running on a degraded memory of its own decisions. A suggestion, not a rule: continue when momentum genuinely helps, but treat multiple compactions in one phase as the signal to restart from the files.
- **Gate messages are for the requester, who may not be an engineer.** Plain language, no code vocabulary, ordered by what they're most likely to change (data and user-facing behavior first, mechanics buried). Every gate message ends with the two disclosure sections from the phase's implementation notes: **Decisions you didn't specify** and **Deviations** — stated as empty when empty. A scope or quality cut never appears as a disclosure; it appears as a question before the fact.
- **Read at the phase that needs it.** Each skill below pulls its own references when it runs — the engineering standards and design method load with the build and design phases, not up front. Keep discovery clean of implementation thinking.
- **A hard gate bounce is an unknowns failure, not bad luck.** When the requester rejects a direction, corrects a premise, or names a missing surface at a gate — don't just fix and re-present. Name which unknown produced the miss and which phase should have caught it, and encode it there (see Skill upkeep) before continuing.

## Lifecycle

### 0. Intake — the proposal

The discovery-side skills (`/proposal`, `/ux-discovery`, `/ux-discovery-lite`, `/design-critique`) live in the frontend repo's `.claude/skills/`.

An sdlc-scale feature enters on a filled proposal (`docs/proposals/{slug}.md`) with Gate 1 (worth shaping + appetite) decided. If the ask arrives as a sentence or two with no proposal, load `/proposal` first — interview the requester, write the proposal, get Gate 1 decided — then continue. Discovery consumes the proposal as its evidence seed.

When the effort's open decisions can't resolve in one sitting — answers gated on external parties, groundwork, or several humans — chart them as a decision map on your tracker first (`.claude/skills/ux-discovery/references/decision-map.md`) and work it until the way is clear; the lifecycle below consumes its decisions.

The effort's task rides the whole lifecycle. Find it or create it (`/optional/task-management`) — before phase 1, not at the end. Each gate that passes fills the section it decided — Problem at the UX gate, Solution at the frontend gate, What Ships and Out of Scope from the design doc — so the task reads current at any point in the run. A verdict that stops the lifecycle closes the task with that verdict as its completion comment.

### 1. Discover — full `/ux-discovery`

Load `/ux-discovery` (the full one, not lite): interview + evidence, framing + verdict, exploration, ideation, synthesis, design, critique gate → the discovery doc tree in `docs/discovery/{feature}/`. The discovery documents stay conceptual — no throwaway mockup. The design becomes visible in the production frontend (next phase), which is the real thing built in the real app, not a disposable HTML sketch whose compromises leak into production.

If Checkpoint 1's verdict is probe / solve another way / not now, the lifecycle stops there with that deliverable — that is a successful outcome, not a failed run.

→ **GATE (UX):** walk the discovery — the framing, direction, flows, and IA, in chat. Sign-off on the direction before the frontend is built.

### 2. Frontend build — `/frontend-build` (production frontend, mocked API)

Production React in the real app, mock data shaped to the UX (`// TODO: Replace with real API`). The feature becomes real to look at, in the actual chrome, before the design is committed — this is where the design is judged. The frontend is also **the backend contract seed**: its types, service signatures, and response/request shapes are what the design doc's schema + API sections formalize and what the backend implements. Only mock *values* get replaced — the shapes must be complete (every field, every state, filters/sort/pagination modeled), so nothing the backend must build is faked away. When it serves a persona who is not the requester, the default before committing is a 15-minute walkthrough of the running frontend with one person of that persona (protocol: `.claude/skills/ux-discovery/references/user-probes.md`) — or a recorded bet in the discovery's design decisions naming why not and its cost-of-being-wrong.

→ **GATE (Frontend):** sign-off on the frontend UI. Two artifacts ride this gate:
- **`contract-draft.md`** (per `/frontend-build`'s gate handoff): the mock's types + service signatures extracted and checked against the API conventions. An engineering artifact — feeds phase 3, never shown in the gate message.
- **Parity sweep** — a fresh agent walks *all* the feature's surfaces (not only what changed) against the feature's capability set, and reports inconsistencies: a capability present on one form of a surface and absent on its sibling, identity marks dropped at one altitude, a switcher or export that didn't travel. Findings are fixed or dispositioned before sign-off.

Feedback rounds after this gate re-enter `/frontend-build` + `/chrome-verify` — reload the skills for the round; refinements run the same polish + visual loop as the first build, and every correction is treated as a class (frontend-build, Refinement rounds).

### 3. Design doc — `docs/design_docs/{FEATURE}.md`

Follow `docs/design_docs/TEMPLATE.md`, drafted via `DESIGN_DOC_METHOD.md`.

- **Narrative** — Overview, Existing Solution, Use Cases + Business Rules, Alternatives, Open Questions. Port and sharpen from the discovery; don't re-litigate it. For Existing Solution, when the current flow is call choreography across services, derive its sequence diagram with `/visual-review` — diagram what is before proposing what will be. → **GATE.**
- **Technical** — each its own skill, each with its own agnostic review + sign-off:
  - `/design-schema`
  - `/design-api` — consumes the discovery doc **and `contract-draft.md`** from the frontend gate. The draft is the seed, not the verdict: **the backend owns the final contract** and adjusts freely (renames, reshapes, splits); every divergence from the draft is recorded in the API section so phase 6 adapts the frontend mechanically instead of re-discovering the deltas.
  - `/design-components`
  - `/design-internals` — the inside of those interfaces: computations, state machine, invariants, replay, windows. `N/A` for CRUD over existing entities; the skill carries the trigger test.
- **Tail** — Implementation Details, Assumptions/dependencies, Milestone, Glossary. Inline.

Before the gate, run **simplicity-challenger** once on the **whole doc**. The per-section reviews can't see the challenge that spans sections — a table plus an endpoint plus a cron that an existing surface and a column would have covered. It returns SIMPLER challenges (each proved against the use cases), EARNED lines for the weight it tried to cut and couldn't, and nothing when there's nothing. Resolve them into the doc, then carry the verdict into the gate message: what got cut, and what complexity is earned and why.

→ **GATE (Design doc):** sign-off on the whole doc. Render it with `/visual-gate` and link the page in the gate message — the requester decides on shape (schema before/after, use-case flows, endpoint cards, the slice stack) rather than on seven sections of prose. The doc stays canonical; a gap the render surfaces gets fixed in the doc, then re-rendered.

### 4. Plan tests — `/plan-tests` (fresh agent)

From the design doc, not the implementation. Behavior scenarios → `docs/for_ai/test_scenarios/{feature}_test_scenarios.md`. These scenarios feed step 5 (Agent B per slice), step 6 (chrome-verify flows), and the bug-hunter in every sweep.

### 5. Build + ship the backend — `/build-feature`, per slice

Load `/build-feature` with the design doc **and the step-4 scenarios doc**. It saves its impl plan and proceeds (no sign-off — the plan is the immutable first-shot record) and slices the stack (the design doc's Use Cases + Milestone sections are the stack plan — one complete use case per slice, foundation riding with the first that needs it, per `.claude/skills/ship-pr/references/pr-stack.md`).

Per slice, build-feature runs the full pipeline: build + lint green → `/write-tests` (fresh agent B against the step-4 scenarios — no new Agent A; gap report surfaced, `npm test -- --testNamePattern="..."`) → jsdoc on changed files → `/ship-pr` (draft PR → inline sweep, bug-hunter fed the design doc + scenarios + gap report → triage → ready).

Slices ship as they finish — there is no whole-feature "built" gate; `/ship-pr`'s preconditions are the gate, per PR.

### 6. Wire + verify the frontend

Wire the frontend to the real API per the design doc's API section — the recorded divergences from `contract-draft.md` are the work list; anything not recorded that doesn't line up is a design-doc defect to fix there first. Build + lint from the frontend root. Then `/chrome-verify` (fresh agent) — the step-4 scenarios re-framed as the user's flow(s), at the narrow breakpoint, a screenshot per scenario, surfaced to the requester.

### 7. Ship the frontend — `/ship-pr`, cross-linked

jsdoc on the frontend's changed files, then `/ship-pr` from the frontend repo root (or `gh -R`), sliced per pr-stack.md by use case — one complete use case per PR, with ~400 changed source lines (tests/docs excluded) as a signal on that cut, never the cutter: draft PR carrying `/pr-evidence` from the branch's final state (a screenshot per state — empty, loading, error, populated; a GIF of the key interaction; before/after where behavior changed; re-capture if triage changes UI code) → inline sweep → triage → ready.

Each body links the other repo's PRs + the design doc + the discovery doc.

### 8. Register the bet + log

Append the feature's row to `docs/discovery/outcomes-register.md`: metrics with baselines from DISCOVERY §13, falsification lines from §12, first check date ≥ 3 weeks post-ship. `/outcome-review` grades it when the date arrives — a shipped feature with no register row is a bet nobody can lose, which means nobody can learn from it.

Then **reconcile the design doc with what shipped**: walk its Data + API sections against the merged migrations, entities, controllers, and DTOs, and fold every delta into the doc — the ones the API section already recorded against `contract-draft.md`, plus anything triage changed on the PRs. The doc is what the next person and the next agent read; a doc describing the design instead of the system is worse than no doc, because it's believed.

Then `/optional/task-management` on the effort's task (from step 0): status `in review`, a completion comment linking both PRs + the docs, and the design doc's Milestone section broken into subtasks when the slices warrant tracking. The description reads for non-technical reviewers.

Optionally, close with a short plain-language quiz for the requester on what shipped — what changed, what it does and doesn't do, what to watch. The runner of this lifecycle should be able to *represent* the work to the team, not just approve it; offer the quiz, don't impose it.

## Skill upkeep

The lifecycle improves by encoding what it learns — the skills are the compiled form of every correction. When a requester correction generalizes — a smell, a product-thinking move, a missing step, a gate, a domain fact — fold it into the relevant skill or reference *in the same session*, not a personal note. Every phase closes with one visible line: "Encoded: {file} — {what}" or "No generalizing corrections this phase." A lesson that lives only in the session's chat is lost by the next run.

## Output

Report: feature shipped, the discovery doc + design doc, backend + frontend files, tests, both PR URLs, task link.

## CRITICAL Rules

- Every gate is a sign-off. Collaborative, not autonomous — never run the whole lifecycle on assumption.
- Reuse the design method + the three design-section skills for the design doc — don't freehand it.
- Two repos, two PRs — never mix frontend and backend into one repo.
- Load skills and apply them. Fresh agents for plan-tests, write-tests, chrome-verify, and each design-section review.
- No `any`. Deep modules. Match existing patterns; no new ones without discussion.
