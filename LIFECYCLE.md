# Feature Development Lifecycle with AI

## The Cycle

```
[UX Discovery → Demo → Team Feedback (if UI)] → Design Doc → Analyze → [Plan Tests ∥ Build] → Write Tests → Review → Staging → Prod → Document
```

## Phases

### 0. UX Discovery + Demo (If Feature Has UI)

Before backend design, if the feature has a user interface:

| Step          | Skill             | Output                                     |
| ------------- | ----------------- | ------------------------------------------ |
| UX Discovery  | `/ux-discovery`   | `docs/discovery/{feature}-ux-discovery.md` |
| Build Demo    | '/frontend-build' | Working UI with mock data                  |
| Team Feedback | Manual            | Comments, questions, adjustments           |
| Refine        | Manual            | Updated discovery doc if needed            |

**Purpose:**

- Team sees real UI, not abstract specs
- API shapes become clear from actual data needs
- Catch UX issues before backend work begins
- Faster iteration — mock data, no API dependencies

---

### 0.5. Write Design Doc (Manual)

After demo alignment, write the backend design doc. This is a thinking exercise.

**Inputs:**

- UX discovery doc (user flows, information hierarchy, edge cases)
- Working demo (actual data shapes, what the UI needs)
- Team feedback (adjustments, gaps, questions answered)
- Domain knowledge (how the business actually works)

**Thought process:**

| Step                | What you're doing                               | Where it goes     |
| ------------------- | ----------------------------------------------- | ----------------- |
| Define scope        | What's in/out? What are we NOT building?        | Overview          |
| Extract use cases   | What does the user do? Main flow + extensions   | Use Cases         |
| Make rules explicit | Status transitions, validation, formulas, rules | Business Rules    |
| Design data model   | Entities, fields, indices, migrations           | Data Design       |
| Design APIs         | Endpoints, request/response shapes, errors      | API Design        |
| Map dependencies    | Services, responsibilities, patterns to follow  | Components Design |

---

### 1. Analyze Design

**Skill:** `/analyze-design`

Find gaps before coding: edge cases, error scenarios, unclear business rules. Fix critical gaps before proceeding.

---

### 2. Plan Tests + Build (Parallel)

Run in **separate worktrees with separate Claude sessions** - prevents bias, each works purely from design.

```bash
./scripts/start-worktrees.sh feature-name
# Opens editor + spawns two Claude sessions
```

| Track A         | Track B          |
| --------------- | ---------------- |
| `/plan-tests`   | `/build-feature` |
| Test scenarios  | Implementation   |
| From design doc | From design doc  |

Why parallel: Blind spots in one track get caught by the other.

---

### 3. Write Tests (Feedback Loop)

**Skill:** `/write-tests`

Merge impl into tests branch, then reconcile:

- Convert scenarios to real tests
- Gaps in scenarios → add tests for cases impl handles
- Gaps in impl → fix code for cases scenarios expect

```bash
./scripts/merge-worktrees.sh feature-name
# Then:
claude → /write-tests
```

---

### 4. Review

Create PR, run code review (AI or human), fix issues, iterate.

Security review for sensitive changes.

Human review for final approval.

---

### 5. Staging & Production

Test in staging environment. Manual test critical paths.

Deploy to production. Record demo if helpful.

---

### 6. Document (Optional)

| Skill              | Purpose                    |
| ------------------ | -------------------------- |
| `/project-writeup` | Write the story, learnings |

---

## Supporting Skills

| Skill            | Purpose                       |
| ---------------- | ----------------------------- |
| `/local-testing` | Test endpoints with auto-auth |
| `/debug-errors`  | Investigate production errors |

---

## Key Files

| Purpose          | Location                                   |
| ---------------- | ------------------------------------------ |
| Coding patterns  | `.claude/skills/build-feature/references/` |
| Test patterns    | `.claude/skills/write-tests/references/`   |
| Design docs      | `docs/design_docs/`                        |
| Test scenarios   | `docs/for_ai/test_scenarios/`              |
| Worktree scripts | `scripts/`                                 |

---

## Worktree Scripts

```bash
# 1. Start (editor + two Claude sessions)
./scripts/start-worktrees.sh feature-name

# 2. Work in the two sessions - don't cross-pollinate

# 3. Merge impl into tests
./scripts/merge-worktrees.sh feature-name

# 4. Write tests (fresh Claude session in tests dir)
claude "/write-tests"

# 5. Push and create PR
git push -u origin feature/feature-name-tests
gh pr create

# 6. Cleanup after PR merged
./scripts/end-worktrees.sh feature-name
```

---

## Flexibility

Phases aren't strict — go back and forth, run in parallel. Not all features need this level of process. Match effort to complexity.
