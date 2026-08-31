# Feature Development Lifecycle with AI

The level of process scales with the size of the work. Three entry points, one set of underlying skills.

| Size                       | Entry point                | Design                      | Tests                | PRs |
| -------------------------- | -------------------------- | --------------------------- | -------------------- | --- |
| Big (days, API + UI)       | `/sdlc`                    | Full design doc, section-by-section | plan + write (2 agents) | 2   |
| Medium (hours, API + UI)   | `/scoped-fullstack-feature` | 3-section short design doc  | plan + write (2 agents) | 2   |
| Small (hours, backend)     | `/scoped-feature`           | None                        | plan + write (2 agents) | 1   |

It's collaborative, not autonomous. The agent moves fast between phases; you think with it at the boundaries. The goal is to ship fast *and* keep the code maintainable — because maintainable code is what keeps you fast.

---

## The Full Lifecycle (`/sdlc`)

```
Proposal → [UX Discovery → Demo] → Design Doc → Plan Tests ∥ Build+Test+Ship (per slice)
→ Wire + Verify → Ship Frontend → Register the bet
```

Every phase ends at a **gate**: present, think together, adjust, then continue. Gates aren't rubber-stamps — they're where your judgment shapes the output: redirect the backend design, critique or add a test scenario, raise the bar on implementation quality. The agent does the work between gates; you steer at each one. Never blow through a gate on assumption.

**Appetite bounds build order, never the design.** At every gate, state elapsed effort against the appetite set at intake. Appetite sequences which slice ships first; it never shrinks what the design proposes — scope and deferral are the requester's call, made after they see the whole design. Past appetite the gate becomes a build-scope decision the requester makes, recorded — never a silent continuation, and never a silent shrink of the design.

### 0. Intake — the proposal

A big feature enters on a filled proposal (`docs/proposals/{slug}.md`) with the first gate — worth shaping + appetite — decided. If the ask arrives as a sentence, run `/proposal` first: interview the requester, write the proposal, decide the gate. `/signals` feeds it when the problem needs merchant-side evidence nobody has raised yet. Discovery then consumes the proposal as its evidence seed.

### 1. UX Discovery + Demo (if the feature has UI)

| Step          | Skill             | Output                                     |
| ------------- | ----------------- | ------------------------------------------ |
| UX Discovery  | `/ux-discovery`   | `docs/discovery/{feature}/` tree           |
| Build frontend | `/frontend-build` | Production UI on mock data (the demo)     |
| Feedback      | Manual            | Comments, questions, adjustments           |

**Purpose:** see real UI instead of abstract specs; let the actual data needs surface the API shape; catch UX issues before backend work begins. Mock data, no API dependencies, fast iteration.

→ **GATE (UX), GATE (Frontend).**

### 2. Design Doc

Written section by section, not freehand. The method lives in `DESIGN_DOC_METHOD.md`; the structure in `design-doc.template.md`.

- **Narrative** — Overview, Existing Solution, Use Cases + Business Rules, Alternatives, Open Questions. Port and sharpen from the discovery. When the existing flow is call choreography across services, derive its sequence diagram with `/visual-review` — diagram what *is* before proposing what *will be*. → **GATE.**
- **Technical** — each its own skill, each with its own fresh-eyes review:
  - `/design-schema` — entities, keys, indices, constraints, migrations
  - `/design-api` — endpoints, request/response shapes, domain errors
  - `/design-components` — the outside: modules, public interfaces, data flow across them
  - `/design-internals` — the inside: computations, state machines, invariants, replay, windows (N/A for CRUD)
- **Tail** — Implementation Details, Assumptions, Milestones, Glossary.

Each technical section runs the same loop: load context → draft with a one-line *why* per element → iterate with you → **agnostic review** by a fresh agent (`/analyze-design` + a simplicity/fit pass) → write it in.

→ **GATE (Design doc).** Render it with `/visual-gate` when the shape is what needs deciding — schema before/after, flows, the slice stack — and walk the page with the requester.

### 3. Plan Tests ∥ Build + Test + Ship (per slice)

Spawn a separate agent to plan behavior scenarios from the design doc (`/plan-tests`) while `/build-feature` implements. The implementer is biased toward the code they just wrote; a planner that never saw the implementation catches the blind spots.

`/build-feature` reads its references in full, walks the new-module scoping checklist, saves its impl plan, and **slices the stack** — one complete use case per slice. There is no whole-feature "built" gate. Each slice runs the full pipeline on its own:

**build + lint green → `/write-tests` (fresh agent, against the step-1 scenarios; gap report) → jsdoc on changed files → `/ship-pr`.**

- **`/write-tests`** converts scenarios into real tests and reports gaps — a gap in scenarios means add tests; a gap in implementation means surface it, don't silently make the test match the code.
- **`/ship-pr`** opens a draft PR (sliced under ~400 source lines, per `ship-pr/references/pr-stack.md`), runs the review-agent sweep, you triage, then it marks ready.

Slices ship as they finish; `/ship-pr`'s preconditions are the gate, per PR.

### 4. Review — the sweep

Review isn't a phase bolted on at the end; it's the sweep `/ship-pr` runs on every PR. A panel of specialist agents comments inline, each against its own rubric:

| Agent                     | Lane                                                |
| ------------------------- | --------------------------------------------------- |
| `security-reviewer`       | Vulnerabilities, sensitive changes                  |
| `bug-hunter`              | Correctness — proves each claim with a failing test  |
| `design-reviewer`        | Deep modules, layering, house-pattern fit            |
| `conventions-reviewer`   | Naming, ubiquitous language, references conformance   |
| `sql-and-migration-reviewer` | Prod-volume breakage — when migrations/entities change |
| `perf-reviewer`           | Runtime cost, proved with numbers                    |
| `simplicity-challenger`   | Complexity the problem doesn't require               |

You triage every finding. `/resolve-pr-comments` runs the reply-and-fix loop (verify, fix or push back, reply on every thread; capped at two rounds). Human review for final approval.

### 5. Wire + Ship the Frontend

Wire the demo to the real API per the design doc's API section. `/chrome-verify` (fresh agent) walks the step-1 scenarios as user flows and screenshots each at the narrow breakpoint. Then `/ship-pr` from the frontend repo, carrying `/pr-evidence` — a screenshot per state (empty, loading, error, populated), a GIF of the key interaction, before/after where behavior changed.

Two repos → two cross-linked PRs (collapse to one if you're single-repo). Each body links the other repo's PR + the design doc + the discovery.

### 6. Register the bet + Document

Append the feature's row to the outcomes register: metrics with baselines, falsification lines, first check date a few weeks out. `/outcome-review` grades it when the date arrives — a shipped feature with no register row is a bet nobody can lose, so nobody learns from it.

`/project-writeup` (optional) — a factual record of the problem, the build, the bugs, the lessons. Not a story.

---

## The Two Scoped Tracks

### `/scoped-fullstack-feature` (medium, API + UI)

UX-first across both repos with three hard checkpoints, so divergence is caught at the cheap stage:

1. **UX** — `/ux-discovery-lite` → sign-off on the direction before the frontend is built.
2. **Frontend** — the production frontend on mock data → sign-off before backend design.
3. **Backend design** — a 3-section short design doc (data, API, components) → sign-off before backend code.

Then build → two-agent tests → wire the UI to the real API → visual verify → two PRs.

### `/scoped-feature` (small, backend)

Skip the design doc; keep investigation, tests, and review. Understand → match existing patterns → implement → two-agent tests → `/ship-pr` (review sweep) → PR.

---

## Supporting Skills

| Skill            | Purpose                                              |
| ---------------- | --------------------------------------------------- |
| `/fix-bug`       | TDD: failing test first, then fix, then PR           |
| `/signals`       | Mine first-party sources for problems nobody raised  |
| `/visual-review` | Interactive explainers + sequence diagrams for a diff |
| `/observability` | Read-only prod triage → classify → fix or escalate   |
| `/call-api`      | Call your API with auto-auth                         |
| `/visual-gate`   | Render a design doc as a page for its sign-off gate  |
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
| PR-stack + review rubrics | `.claude/skills/ship-pr/references/` |
| Proposals        | `docs/proposals/`                          |
| Design docs      | `docs/design_docs/`                        |
| Test scenarios   | `docs/for_ai/test_scenarios/`              |
| Outcomes register | `docs/discovery/outcomes-register.md`     |

---

## Flexibility

Nothing here is law. Phases aren't strict — go back and forth, collapse steps, run them in parallel. Not every feature needs this much process; match the effort to the complexity. Treat the skills and references as a starting point and bend them to how you actually work — the workflow should fit you, not the other way around.
