---
name: sdlc
description: The full feature lifecycle for a big fullstack feature across the backend repo and the frontend repo. Full /ux-discovery → a complete design doc (narrative sections + /design-schema, /design-api, /design-components, each agnostically reviewed) → /build-feature → two-agent tests → wire + visual verify → two cross-linked PRs. Iterative and collaborative — the agent does the work, you sign off every gate. Use when (1) user says "/sdlc", (2) a feature is large enough to need a real design doc and days of work, (3) it spans API + UI. For small work, use /adhoc-fullstack-feature instead.
---

# SDLC

You are a senior product engineer. You own the whole thing — from the customer's problem to the code in production — flat team, no handoffs. The requester thinks with you at every gate; you do the work between them.

The full lifecycle for a big fullstack feature, across two repos.

## Repos

- **Backend repo** — NestJS, jest. Branch + PR here.
- **Frontend repo** — React/Vite. Separate branch + PR here.

Two repos → two branches → two PRs, cross-linked. Run each repo's build/lint/test from that repo's root. (Single-repo? Collapse to one branch and one PR — the phases don't change.)

## How this runs

- **Collaborative, not autonomous.** Every phase ends at a **gate** — present, think together, get sign-off, then continue. Never blow through a gate on assumption.
- **Appetite is a circuit breaker, not a wish.** At every gate, state elapsed effort against the Gate 1 appetite. Past appetite, the gate becomes a mandatory shrink / stop decision, recorded in `docs/proposals/DECISIONS.md` — never a silent continuation; one silently swelling feature can consume the capacity every other bet was counting on.
- **Load skills, don't just read them.** Invoke the Skill tool and follow it. When you spawn a sub-agent to run one, tell it to load the skill and return proof of work (artifact path, findings, screenshots); re-run it if it skipped.
- **Read at the phase that needs it.** Each skill below pulls its own references when it runs — the engineering standards and design method load with the build and design phases, not up front. Keep discovery clean of implementation thinking.

## Lifecycle

### 0. Intake — the proposal

The discovery-side skills (`/proposal`, `/ux-discovery`, `/ux-discovery-lite`, `/design-critique`) live in the frontend repo's `.claude/skills/`.

An sdlc-scale feature enters on a filled proposal (`docs/proposals/{slug}.md`) with Gate 1 (worth shaping + appetite) decided. If the ask arrives as a sentence or two with no proposal, load `/proposal` first — interview the requester, write the proposal, get Gate 1 decided — then continue. Discovery consumes the proposal as its evidence seed.

### 1. Discover — full `/ux-discovery`

Load `/ux-discovery` (the full one, not lite): interview + evidence, framing + verdict, exploration, ideation, synthesis, design, critique gate → the discovery doc tree in `docs/discovery/{feature}/`. After `DISCOVERY.md` is written, build a cheap throwaway HTML mockup of the key screens at `docs/discovery/{feature}/preview.html` — outside the discovery documents, which stay conceptual.

If Checkpoint 1's verdict is probe / solve another way / not now, the lifecycle stops there with that deliverable — that is a successful outcome, not a failed run.

→ **GATE (UX):** walk the discovery + preview. When the design serves a persona who is not the requester, the default before sign-off is a 15-minute walkthrough of `preview.html` with one person of that persona (protocol: `.claude/skills/ux-discovery/references/user-probes.md`) — or a recorded bet in the discovery's design decisions naming why not and its cost-of-being-wrong. Sign-off before any code.

### 2. Frontend demo — `/frontend-build` (demo mode)

Production frontend, mock data shaped to the UX (`// TODO: Replace with real API`). The feature becomes real to look at before the design is committed.

→ **GATE (Frontend):** sign-off on the demo UI.

### 3. Design doc — `docs/design_docs/{FEATURE}.md`

Follow `docs/design_docs/TEMPLATE.md`, drafted via `DESIGN_DOC_METHOD.md`.

- **Narrative** — Overview, Existing Solution, Use Cases + Business Rules, Alternatives, Open Questions. Port and sharpen from the discovery; don't re-litigate it. For Existing Solution, when the current flow is call choreography across services, derive its sequence diagram with `/visual-review` — diagram what is before proposing what will be. → **GATE.**
- **Technical** — each its own skill, each with its own agnostic review + sign-off:
  - `/design-schema`
  - `/design-api`
  - `/design-components`
- **Tail** — Implementation Details, Assumptions/dependencies, Milestone, Glossary. Inline.

→ **GATE (Design doc):** sign-off on the whole doc.

### 4. Plan tests — `/plan-tests` (fresh agent)

From the design doc, not the implementation. Behavior scenarios → `docs/for_ai/test_scenarios/{feature}_test_scenarios.md`. These scenarios feed step 5 (Agent B per slice), step 6 (chrome-verify flows), and the bug-hunter in every sweep.

### 5. Build + ship the backend — `/build-feature`, per slice

Load `/build-feature` with the design doc **and the step-4 scenarios doc**. It saves its impl plan and proceeds (no sign-off — the plan is the immutable first-shot record) and slices the stack (the design doc's Use Cases + Milestone sections are the stack plan — one complete use case per slice, foundation riding with the first that needs it, per `.claude/skills/ship-pr/references/pr-stack.md`).

Per slice, build-feature runs the full pipeline: build + lint green → `/write-tests` (fresh agent B against the step-4 scenarios — no new Agent A; gap report surfaced, `npm test -- --testNamePattern="..."`) → jsdoc on changed files → `/ship-pr` (draft PR → inline sweep, bug-hunter fed the design doc + scenarios + gap report → triage → ready).

Slices ship as they finish — there is no whole-feature "built" gate; `/ship-pr`'s preconditions are the gate, per PR.

### 6. Wire + verify the frontend

Wire the demo to the real API per the design doc's API section; adjust types/API where they don't line up. Build + lint from the frontend root. Then `/chrome-verify` (fresh agent) — the step-4 scenarios re-framed as the user's flow(s), at the narrow breakpoint, a screenshot per scenario, surfaced to the requester.

### 7. Ship the frontend — `/ship-pr`, cross-linked

jsdoc on the frontend's changed files, then `/ship-pr` from the frontend repo root (or `gh -R`), sliced per pr-stack.md if over 400 changed source lines (tests/docs excluded): draft PR carrying `/pr-evidence` from the branch's final state (a screenshot per state — empty, loading, error, populated; a GIF of the key interaction; before/after where behavior changed; re-capture if triage changes UI code) → inline sweep → triage → ready.

Each body links the other repo's PRs + the design doc + the discovery doc.

### 8. Register the bet + log

Append the feature's row to `docs/discovery/outcomes-register.md`: metrics with baselines from DISCOVERY §13, falsification lines from §12, first check date ≥ 3 weeks post-ship. `/outcome-review` grades it when the date arrives — a shipped feature with no register row is a bet nobody can lose, which means nobody can learn from it.

Then `/optional/task-management`: one task, or the design doc's Milestone broken into subtasks. Link both PRs + the docs. Status `in review`. Description for non-technical reviewers.

## Output

Report: feature shipped, the discovery doc + design doc, backend + frontend files, tests, both PR URLs, task link.

## CRITICAL Rules

- Every gate is a sign-off. Collaborative, not autonomous — never run the whole lifecycle on assumption.
- Reuse the design method + the three design-section skills for the design doc — don't freehand it.
- Two repos, two PRs — never mix frontend and backend into one repo.
- Load skills and apply them. Fresh agents for plan-tests, write-tests, chrome-verify, and each design-section review.
- No `any`. Deep modules. Match existing patterns; no new ones without discussion.
