---
name: fix-bug
description: TDD-style bug fixing workflow. Use when (1) user reports a bug, (2) user says "fix bug" or "/fix-bug", (3) debugging failing behavior. Write failing test first, make it pass, run all tests, branch, open PR, resolve comments, log the task.
---

# Fix Bug

TDD workflow: failing test first, then fix, then PR + task log.

## Input

Bug description from user, error message, or reproduction steps.

## Workflow

### 1. Identify

1. Understand the bug: what's expected vs actual.
2. Find the related code — trace from symptom to root cause.
3. Find the related test file (same directory, `*.spec.ts`).

You can use the `code-explorer` agent.

### 2. Write Failing Test

1. In the related spec file, add a test that captures the bug.
2. Name it clearly: `should [expected behavior] when [condition]`.
3. Run the test to confirm it fails for the right reason:

```bash
npm test -- --testNamePattern="should [your test name]"
```

Rerun if flaky FK/unique issues. The test must fail before proceeding.

### 3. Fix

BEFORE WRITING CODE, READ THIS: `.claude/skills/build-feature/references/` — ALL, to align with the coding standards.

1. Write minimal code to make the test pass.
2. Run the single test again to confirm it passes.
3. Run all tests:

```bash
npm test
```

Fix any regressions before continuing.

From the available agents under `.claude/agents`, see which agent is useful for your fix and run it.

### 4. Branch + PR

```bash
git checkout -b fix/[short-bug-description]
git add -A && git commit -m "fix: [description]"
git push -u origin fix/[short-bug-description]
gh pr create --title "Fix: [description]" --body "## Problem
[What was broken]

## Root Cause
[Why it was broken]

## Fix
[What was changed]

## Test
Added test: \`should [test name]\`"
```

### 5. Resolve PR Comments

Invoke `/resolve-pr-comments` with the PR number. Iterate until clean.

### 6. Log the task

Invoke `/optional/task-management` to:
- Update the existing bug task if one exists (move to done, add PR link).
- Or create a new task: `[Fix] [Bug description]` in the bugs list.

## Output

Report: bug identified, test added, fix applied, PR URL, task link.
