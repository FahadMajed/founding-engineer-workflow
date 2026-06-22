---
name: adhoc-feature
description: Lightweight workflow for small features that don't need the full feature lifecycle (no design doc). Tests still go through plan-tests + write-tests, but split across two fresh sub-agents so they're not written by the implementer. Use when (1) user says "/adhoc-feature", (2) user says the work is small/quick/adhoc, (3) the change is hours of work, not days.
---

# Adhoc Feature

Small features, fast, but still respecting the principles. Skip the design doc, keep investigation, tests, and review.

## Inputs

- Feature description from user (a sentence or two, not a design doc)

## Non-negotiables

Read once before starting:

- Your engineering principles (Keep It Simple, Question Everything, You Own It — see PHILOSOPHY.md)
- `.claude/skills/build-feature/references/` — ALL

These apply even when the lifecycle doesn't.

## Workflow

### 1. Understand

1. Restate the feature in one sentence. Confirm with user if ambiguous.
2. Identify files to touch (entity, service, controller, dto, spec).
3. Find similar features in the codebase — use `code-explorer` agent if not obvious. Match their patterns.

### 2. Implement

1. Follow the patterns you found in step 1. Do not invent new ones.
2. No `any` types. No comments unless the WHY is non-obvious.
3. Build what's asked, nothing more. No speculative abstractions, no "while I'm here" cleanups.

```bash
npm run build && npm run lint
```

### 3. Tests (Mandatory unless external-heavy)

**Default: write tests.** But you (the implementer) do NOT plan or write them — you're biased toward the code you just wrote and will test what you built instead of what was asked. Split it across two fresh sub-agents so coverage and gaps come from someone who didn't write the implementation.

**Agent A — Plan (implementation-agnostic).** Spawn an agent with `/plan-tests`. Give it ONLY the feature intent from step 1 (the one-sentence restatement + the behavior the user asked for) and the files' public surface (entity/dto/controller signatures). Do NOT give it your implementation diff or internal logic — the point is scenarios derived from what the feature should do, not from what you wrote. It outputs GIVEN/WHEN/THEN scenarios to `docs/for_ai/test_scenarios/[feature-name]_test_scenarios.md`.

**Agent B — Write (against the plan).** Spawn a second, separate agent with `/write-tests`. Give it (1) the scenarios doc from Agent A, (2) the implemented code location. It writes the actual tests, and flags any gap between plan and implementation (missing behavior, behavior mismatch, uncovered scenario). Surface those gaps to the user — don't silently make the test match the code.

Keep A and B as two distinct agents. One agent doing both collapses back into the same bias.

```bash
npm test -- --testNamePattern="Your Describe Block"
```

**Exception:** if the feature is mostly calling an external service and the test would be 90% mocks, skip both agents and call it out explicitly in the PR description ("No tests — external-service-heavy, mocking would dominate"). The user will confirm or push back.

### 4. When you finish, Review & Re-iterate

Launch 2 agents sequentially with different focuses:

- A references agent that ensures your WIP is 100% aligned with the references/ under this skill.

Then:

- Simplicity/DRY/Elegance and ALL refactoring principles: code quality and maintainability, focused on reuse without compromising human readability (code-simplifier agent).

Once you resolve what is needed, spawn 2 more agents:

- Bugs/Correctness: functional correctness and logic errors (code-reviewer), and verify the claims, preferably with a failing test using `/fix-bug`.
- JSDoc cleanup: delete noisy docs, add missing docs for non-obvious behavior (jsdoc agent on changed files).

### 5. PR

```bash
git add -A && git commit -m "feat: [short description]"
git push -u origin claude/[branch-name]
gh pr create --title "[short description]" --body "## What
[One-line summary]

## Why
[The user problem this solves]

## Tests
[What you added, or 'No tests — external-service-heavy']
"
```

### 6. Log

Invoke `/optional/task-management` to log the task and link the PR.

**Task rules:**
- Status: `in review`. The PR is open; shipping happens after merge + deploy.
- Description: written for non-technical reviewers. Lead with the user-facing problem and the user-facing change. Avoid file paths, class/function names, SQL, and code-level jargon unless they're the simplest way to say it.
- Don't include an "Out of Scope" section unless scope boundaries were explicitly discussed.

## Output

Report: feature shipped, files touched, tests added (or why not), PR URL, task link.

## CRITICAL Rules

- Never introduce new patterns without discussion — it's fine to suggest or improve some patterns.
- Never use `any` types — define interfaces, unless you can't help it.
- Add comments only when code cannot express intent; do not throw comments on every line.
- **Deep modules** — modules should have simple interfaces that hide complex implementation. A good module does a lot behind a small API surface. If a class/service interface is almost as complex as its implementation, it's too shallow — rethink the abstraction.
