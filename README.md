# Founding Engineer Workflow

A feature development workflow for people who build — who think about problems before solutions, user needs before technologies, and shipping fast without trading away quality.

It's a set of Claude Code skills and supporting docs that take a feature from user problem → discovery → design → build → tests → review → ship, with the level of process matched to the size of the work.

## Who This Is For

**Founding engineers, solo builders, or teams where one person owns a feature from user problem to production.**

This workflow assumes:

- You understand the user, you design, you build, you test, you ship
- No designer, no QA, no product manager — just you (and AI as your assistant)
- You want velocity AND quality, not one at the expense of the other

**Not for:** Junior devs learning the basics, or orgs with strict role separation.

## What's Opinionated vs. What's Yours

This is one engineer's taste, extracted from a real product and stripped of its business.

- **The engineering references are concrete** — the backend patterns assume NestJS + TypeORM + Postgres + jest; the frontend assumes React + Tailwind + shadcn/ui. They're not fill-in-the-blank. Copy them as-is if you share the taste, adapt them if you don't.
- **The business context is left blank on purpose** — product description, user personas, and domain rules are `{{PLACEHOLDERS}}` in the discovery skills. Nothing here makes you inherit someone else's domain. Fill in your own.

## The Workflow — match effort to size

Three entry points. Pick by how big the work is, not by habit.

```
BIG feature (days, API + UI)        →  /sdlc
   proposal → ux-discovery → frontend demo → full design doc
   (narrative + design-schema ∥ design-api ∥ design-components)
   → plan-tests ∥ build-feature (build → test → ship, per slice)
   → wire + chrome-verify → two cross-linked PRs → register the bet

MEDIUM feature (hours, API + UI)    →  /adhoc-fullstack-feature
   ux-discovery-lite + HTML preview → demo → short design doc
   → build → two-agent tests → wire + visual verify → two PRs
   (three hard checkpoints: UX, frontend, backend design)

SMALL feature (hours, backend)      →  /adhoc-feature
   understand → implement → two-agent tests → ship → PR
```

Every slice ships through **`/ship-pr`**: open a draft PR, run the review-agent sweep (they comment inline), triage every finding, then mark ready — followed by **`/resolve-pr-comments`** for the reply-and-fix loop.

Supporting flows: **`/proposal`** (problem-first intake), **`/signals`** (mine sources for problems nobody raised), **`/fix-bug`** (TDD bug fix), **`/visual-review`** (interactive explainers + sequence diagrams), **`/project-writeup`** (document what you built), **`/outcome-review`** (grade the bet after it ships).

A few ideas run through all of it:

- **You steer between phases.** The agent moves fast; you think with it at the gates — push back on the design, critique a test scenario, raise the bar on quality. The aim is fast *and* maintainable, because maintainable code is what keeps you fast.
- **Design before code.** Big features get a real design doc, drafted section by section (schema, API, components), each with a fresh-eyes review before anything is built.
- **Tests written by someone who didn't write the code.** `/plan-tests` and `/write-tests` run as two separate agents so coverage comes from the spec, not from the implementation's blind spots.
- **Review is a sweep of specialist agents, not one pass.** Each PR gets a panel — security, design, conventions, bug-hunter, data-migration — commenting inline against a distinct rubric. You triage; they don't merge for you.
- **A shipped feature is a bet you can grade.** Big features register their metrics + falsification lines at ship time, and `/outcome-review` scores them later — so the loop closes and you actually learn.

## Quick Start

### 1. Copy the skills into your project

```bash
cp -r skills/workflows/* your-project/.claude/skills/
cp -r skills/core/*      your-project/.claude/skills/
cp -r skills/frontend/*  your-project/.claude/skills/   # if you have a frontend
# optional add-ons (rename .template.md → SKILL.md after filling them in):
cp -r skills/optional/*  your-project/.claude/skills/
```

### 2. Install the shared docs

```bash
cp templates/DESIGN_DOC_METHOD.md  your-project/docs/standards/DESIGN_DOC_METHOD.md
cp templates/design-doc.template.md your-project/docs/design_docs/TEMPLATE.md
cp PHILOSOPHY.md                    your-project/docs/standards/   # your engineering principles
```

### 3. Customize for your stack

- Edit `build-feature/references/*` to match your backend patterns (or keep them if you run NestJS).
- Edit `frontend-build/reference/*` for your component system.
- Fill in the `{{PLACEHOLDERS}}` (product, users, principles) in `ux-discovery` and `ux-discovery-lite`.

### 4. Create your CLAUDE.md

Copy `templates/CLAUDE.template.md` to your project root as `CLAUDE.md`. Fill in your stack, commands, and rules.

## Skills Reference

### Workflow orchestrators

| Skill                      | Use when                                                        |
| -------------------------- | --------------------------------------------------------------- |
| `/sdlc`                    | A big fullstack feature — days of work, needs a real design doc |
| `/adhoc-fullstack-feature` | A small feature spanning API + UI — hours, not days             |
| `/adhoc-feature`           | A small backend feature — no design doc, single PR              |

### Discovery & product

| Skill                | Purpose                                                              |
| -------------------- | ------------------------------------------------------------------- |
| `/proposal`          | Problem-first intake — interview, then a proposal that feeds a workflow |
| `/signals`           | Mine first-party sources for problems nobody raised, tier the evidence |
| `/ux-discovery`      | Deep UX thinking before building. Outputs a structured discovery doc |
| `/ux-discovery-lite` | Lightweight discovery for small features                            |
| `/outcome-review`    | Grade a shipped bet against the metrics + falsification lines it predicted |

### Design

| Skill                | Purpose                                                              |
| -------------------- | ------------------------------------------------------------------- |
| `/analyze-design`    | Find gaps in a design doc before implementation                     |
| `/design-schema`     | Draft the Data design section — entities, keys, indices, migrations  |
| `/design-api`        | Draft the API design section — endpoints, shapes, domain errors      |
| `/design-components` | Draft the Components design section — modules, interfaces, data flow |

### Build & test

| Skill                | Purpose                                                              |
| -------------------- | ------------------------------------------------------------------- |
| `/plan-tests`        | Create behavior scenarios from the design (before code exists)       |
| `/build-feature`     | Implement features following codebase patterns; ships per slice      |
| `/write-tests`       | Convert scenarios to tests, detect gaps                             |
| `/fix-bug`           | TDD bug fix — failing test first, then fix, then PR                  |

### Review & ship

| Skill                   | Purpose                                                          |
| ----------------------- | --------------------------------------------------------------- |
| `/ship-pr`              | Draft PR → review-agent sweep (inline) → triage → mark ready     |
| `/resolve-pr-comments`  | Triage and resolve review comments — verify, fix or push back, reply |
| `/visual-review`        | Interactive explainers + Mermaid sequence diagrams for code under review |
| `/project-writeup`      | Document the feature factually — what, why, bugs, lessons        |

### Frontend

| Skill              | Purpose                                              |
| ------------------ | --------------------------------------------------- |
| `/frontend-build`  | Build polished UI from discovery docs (shadcn-first) |
| `/chrome-verify`   | Visual verification with headless screenshots        |
| `/pr-evidence`     | State screenshots + interaction GIF + before/after on a PR |
| `/design-critique` | Structured design feedback on a concept or built UI  |
| `/ux-touch`        | Design a targeted addition to a shipped feature      |

### Optional (templates — fill in your tools, then rename to `SKILL.md`)

| Template              | Purpose                                  |
| --------------------- | ---------------------------------------- |
| `local-testing`       | Test endpoints with auto-auth            |
| `debug-errors`        | Investigate production errors            |
| `observability`       | Read-only prod triage → classify → route |
| `task-management`     | Integrate with your task tracker         |

## Agents

`/ship-pr` runs a **review sweep** — a panel of subagents in [`agents/`](agents/), each reviewing the PR diff against a distinct rubric and commenting inline:

| Agent                     | Lane                                                        |
| ------------------------- | ---------------------------------------------------------- |
| `security-reviewer`       | Vulnerabilities and sensitive changes (high confidence bar) |
| `bug-hunter`              | Correctness — proves each claim with a failing test         |
| `design-reviewer`        | Design quality — deep modules, layering, house patterns     |
| `conventions-reviewer`   | Naming, ubiquitous language, conformance to your references  |
| `data-migration-reviewer` | What breaks at prod data volume — only when migrations/entities change |

Plus `code-explorer` (find patterns to match before building) and `qa-reviewer` (test-scenario coverage). Copy them all to `.claude/agents/`.

## File Structure

```
your-project/
├── .claude/
│   ├── skills/
│   │   ├── sdlc/  adhoc-feature/  adhoc-fullstack-feature/
│   │   ├── proposal/  ux-discovery/  signals/  outcome-review/
│   │   ├── design-schema/  design-api/  design-components/
│   │   ├── build-feature/references/      # your backend patterns
│   │   ├── write-tests/references/        # your test patterns
│   │   ├── ship-pr/references/            # PR-stack rules, review rubrics
│   │   ├── frontend-build/reference/      # design-smell guides, shadcn-first
│   │   └── ...
│   └── agents/                            # the review-sweep panel
├── docs/
│   ├── standards/
│   │   ├── DESIGN_DOC_METHOD.md
│   │   └── PHILOSOPHY.md
│   ├── discovery/                         # UX discovery outputs
│   ├── design_docs/                       # design docs + TEMPLATE.md
│   └── for_ai/test_scenarios/             # test scenario files
└── CLAUDE.md                              # your project context
```

## Related

- [LIFECYCLE.md](LIFECYCLE.md) — Full workflow documentation
- [PHILOSOPHY.md](PHILOSOPHY.md) — Engineering principles

## License

MIT
