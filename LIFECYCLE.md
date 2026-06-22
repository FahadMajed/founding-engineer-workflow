# Feature Development Lifecycle with AI

The level of process scales with the size of the work. Three entry points, one set of underlying skills.

| Size                       | Entry point                | Design                      | Tests                | PRs |
| -------------------------- | -------------------------- | --------------------------- | -------------------- | --- |
| Big (days, API + UI)       | `/sdlc`                    | Full design doc, section-by-section | plan + write (2 agents) | 2   |
| Medium (hours, API + UI)   | `/adhoc-fullstack-feature` | 3-section short design doc  | plan + write (2 agents) | 2   |
| Small (hours, backend)     | `/adhoc-feature`           | None                        | plan + write (2 agents) | 1   |

It's collaborative, not autonomous. The agent moves fast between phases; you think with it at the boundaries. The goal is to ship fast *and* keep the code maintainable — because maintainable code is what keeps you fast.

---

## The Full Lifecycle (`/sdlc`)

```
[UX Discovery → Demo] → Design Doc → [Plan Tests ∥ Build] → Write Tests + Verify → Review → Ship → Document
```

Every phase ends at a **gate**: present, think together, adjust, then continue. Gates aren't rubber-stamps — they're where your judgment shapes the output: redirect the backend design, critique or add a test scenario, raise the bar on implementation quality. The agent does the work between gates; you steer at each one. Never blow through a gate on assumption.

### 0. UX Discovery + Demo (if the feature has UI)

| Step          | Skill             | Output                                     |
| ------------- | ----------------- | ------------------------------------------ |
| UX Discovery  | `/ux-discovery`   | `docs/discovery/{feature}/` tree           |
| Build Demo    | `/frontend-build` | Working UI with mock data                  |
| Feedback      | Manual            | Comments, questions, adjustments           |

**Purpose:** see real UI instead of abstract specs; let the actual data needs surface the API shape; catch UX issues before backend work begins. Mock data, no API dependencies, fast iteration.

→ **GATE (UX), GATE (Frontend).**

### 1. Design Doc

Written section by section, not freehand. The method lives in `DESIGN_DOC_METHOD.md`; the structure in `design-doc.template.md`.

- **Narrative** — Overview, Existing Solution, Use Cases + Business Rules, Alternatives, Open Questions. Port and sharpen from the discovery. → **GATE.**
- **Technical** — each its own skill, each with its own fresh-eyes review:
  - `/design-schema` — entities, keys, indices, constraints, migrations
  - `/design-api` — endpoints, request/response shapes, domain errors
  - `/design-components` — modules, service interfaces, data flow, invariants
- **Tail** — Implementation Details, Assumptions, Milestones, Glossary.

Each technical section runs the same loop: load context → draft with a one-line *why* per element → iterate with you → **agnostic review** by a fresh agent (`/analyze-design` + a simplicity/fit pass) → write it in.

→ **GATE (Design doc).**

### 2. Plan Tests ∥ Build

Spawn a separate agent to plan tests from the design doc while you build. The implementer is biased toward the code they just wrote; a planner that never saw the implementation catches the blind spots.

| Track A (`/plan-tests`) | Track B (`/build-feature`)        |
| ----------------------- | --------------------------------- |
| Behavior scenarios      | Implementation + self-review sweep |
| From the design doc     | From the design doc               |

`/build-feature` reads its references in full, walks the new-module scoping checklist, builds, then runs its own review sweep (references → simplifier → reviewer → jsdoc).

→ **GATE (Built):** build + lint green.

### 3. Write Tests + Verify

- **`/write-tests`** (fresh agent) converts scenarios into real tests and reports gaps:
  - Gap in scenarios → add tests for cases the implementation handles
  - Gap in implementation → surface it; don't silently make the test match the code
- **`/chrome-verify`** (frontend) walks the scenarios as user flows, screenshots each at the narrow breakpoint.

### 4. Review

Backend was reviewed inside `/build-feature`. Run the review sweep on the frontend changes. Security review for sensitive changes. Human review for final approval.

### 5. Ship

Two repos → two cross-linked PRs (collapse to one if you're single-repo). Test critical paths. Deploy.

### 6. Document (optional)

`/project-writeup` — a factual record of the problem, the build, the bugs, the lessons. Not a story.

---

## The Two Adhoc Tracks

### `/adhoc-fullstack-feature` (medium, API + UI)

UX-first across both repos with three hard checkpoints, so divergence is caught at the cheap stage:

1. **UX** — `/ux-discovery-lite` + a throwaway HTML preview → sign-off before production UI.
2. **Frontend** — a demo built on mock data → sign-off before backend design.
3. **Backend design** — a 3-section short design doc (data, API, components) → sign-off before backend code.

Then build → two-agent tests → wire the UI to the real API → visual verify → two PRs.

### `/adhoc-feature` (small, backend)

Skip the design doc; keep investigation, tests, and review. Understand → match existing patterns → implement → two-agent tests → review sweep → PR.

---

## Supporting Skills

| Skill            | Purpose                                              |
| ---------------- | --------------------------------------------------- |
| `/fix-bug`       | TDD: failing test first, then fix, then PR           |
| `/observability` | Read-only prod triage → classify → fix or escalate   |
| `/local-testing` | Test endpoints with auto-auth                        |
| `/debug-errors`  | Investigate production errors                         |
| `/ux-touch`      | Design a targeted addition to a shipped feature      |
| `/design-critique` | Structured feedback on a UX concept or built UI    |

---

## Key Files

| Purpose          | Location                                   |
| ---------------- | ------------------------------------------ |
| Design method    | `docs/standards/DESIGN_DOC_METHOD.md`      |
| Coding patterns  | `.claude/skills/build-feature/references/` |
| Test patterns    | `.claude/skills/write-tests/references/`   |
| Design docs      | `docs/design_docs/`                        |
| Test scenarios   | `docs/for_ai/test_scenarios/`              |

---

## Flexibility

Nothing here is law. Phases aren't strict — go back and forth, collapse steps, run them in parallel. Not every feature needs this much process; match the effort to the complexity. Treat the skills and references as a starting point and bend them to how you actually work — the workflow should fit you, not the other way around.
