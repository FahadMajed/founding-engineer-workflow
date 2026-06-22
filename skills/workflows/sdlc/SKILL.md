---
name: sdlc
description: The full feature lifecycle for a big fullstack feature across the backend repo and the frontend repo. Full /ux-discovery → a complete design doc (narrative sections + /design-schema, /design-api, /design-components, each agnostically reviewed) → /build-feature → two-agent tests → wire + visual verify → two cross-linked PRs. Iterative and collaborative — the agent does the work, you sign off every gate. Use when (1) user says "/sdlc", (2) a feature is large enough to need a real design doc and days of work, (3) it spans API + UI. For small work, use /adhoc-fullstack-feature instead.
---

# SDLC

You are a senior product engineer. You own the whole thing — from the customer's problem to the code in production — flat team, no handoffs. The requester thinks with you at every gate; you do the work between them.

The full lifecycle for a big fullstack feature, across two repos.

## Repos

- **Backend repo** — branch + PR here.
- **Frontend repo** — separate branch + PR here.

Two repos → two branches → two PRs, cross-linked. Run each repo's build/lint/test from that repo's root. (Single-repo? Collapse to one branch and one PR — the phases don't change.)

## How this runs

- **Collaborative, not autonomous.** Every phase ends at a **gate** — present, think together, get sign-off, then continue. Never blow through a gate on assumption.
- **Load skills, don't just read them.** Invoke the Skill tool and follow it. When you spawn a sub-agent to run one, tell it to load the skill and return proof of work (artifact path, findings, screenshots); re-run it if it skipped.
- **Read at the phase that needs it.** Each skill below pulls its own references when it runs — the engineering standards and design method load with the build and design phases, not up front. Keep discovery clean of implementation thinking.

## Lifecycle

### 1. Discover — full `/ux-discovery`

Load `/ux-discovery` (the full one, not lite): problem framing, ideation, synthesis, design, evaluation → the discovery doc tree in `docs/discovery/{feature}/`. Add a cheap HTML preview of the key screens.

→ **GATE (UX):** walk the discovery + preview. Sign-off before any code.

### 2. Frontend demo — `/frontend-build` (demo mode)

Production frontend, mock data shaped to the UX (`// TODO: Replace with real API`). The feature becomes real to look at before the design is committed.

→ **GATE (Frontend):** sign-off on the demo UI.

### 3. Design doc — `docs/design_docs/{FEATURE}.md`

Follow `docs/design_docs/TEMPLATE.md`, drafted via `DESIGN_DOC_METHOD.md`.

- **Narrative** — Overview, Existing Solution, Use Cases + Business Rules, Alternatives, Open Questions. Port and sharpen from the discovery; don't re-litigate it. → **GATE.**
- **Technical** — each its own skill, each with its own agnostic review + sign-off:
  - `/design-schema`
  - `/design-api`
  - `/design-components`
- **Tail** — Implementation Details, Assumptions/dependencies, Milestone, Glossary. Inline.

→ **GATE (Design doc):** sign-off on the whole doc.

### 4. Plan tests — `/plan-tests` (fresh agent)

From the design doc, not the implementation. Behavior scenarios → `docs/for_ai/test_scenarios/{feature}_test_scenarios.md`. Feeds step 6 verify too.

### 5. Build

- **Backend:** load `/build-feature` against the design doc — it runs its own impl plan, build, and review sweep.
- **Frontend:** wire the demo to the real API per the design doc's API section. Adjust types/API where they don't line up.
- Build + lint both, from each repo root.

→ **GATE (Built):** both green.

### 6. Tests + verify

- **Backend:** `/write-tests` (fresh agent B) → real tests + gap report. Run the suite scoped to the new feature.
- **Frontend:** `/chrome-verify` (fresh agent) — the test scenarios re-framed as the user's flow(s), at the narrow breakpoint, a screenshot per scenario, surfaced to the requester.

### 7. Review — frontend sweep

The backend was reviewed inside `/build-feature`. Run the `/adhoc-feature` sweep on the **frontend** changes: references (frontend-build reference) → code-simplifier, then code-reviewer (+ `/fix-bug`) → jsdoc. Each agent returns findings; an empty return means it skipped — re-run it.

### 8. PRs — two, cross-linked

Backend PR in the backend repo, frontend PR in the frontend repo. Run git + gh from each repo root. Each body links the other PR + the design doc + the discovery doc.

### 9. Log

One task in your tracker (see `/optional/task-management`), or the design doc's Milestone broken into subtasks. Link both PRs + the docs. Status `in review`. Description for non-technical reviewers.

## Output

Report: feature shipped, the discovery doc + design doc, backend + frontend files, tests, both PR URLs, task link.

## CRITICAL Rules

- Every gate is a sign-off. Collaborative, not autonomous — never run the whole lifecycle on assumption.
- Reuse the design method + the three design-section skills for the design doc — don't freehand it.
- Two repos, two PRs — never mix frontend and backend into one repo.
- Load skills and apply them. Fresh agents for plan-tests, write-tests, chrome-verify, and each design-section review.
- No `any`. Deep modules. Match existing patterns; no new ones without discussion.
