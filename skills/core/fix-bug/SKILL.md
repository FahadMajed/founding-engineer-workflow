---
name: fix-bug
description: Bug fixing workflow. Use when (1) user reports a bug, (2) user says "fix bug" or "/fix-bug", (3) debugging failing behavior. Reproduce, fix at the right layer, run tests, open PR, resolve comments, log the task. Add a test only when it captures the bug through observable behavior.

---

# Fix Bug

Reproduce → fix at the root cause → PR + task log. A test comes first **only when it earns its place** (see step 2) — a straightforward, obvious fix ships without one.

## Input

Bug description from user, error message, or reproduction steps.

## Workflow

### 1. Identify

1. Understand the bug: what's expected vs actual
2. Find the related code - trace from symptom to root cause
3. Find the related test file (same directory, `*.spec.ts`)

you can use code-explorer agent.

### 2. Write a Failing Test — when it earns its place

A test is worth writing when it captures the bug through **observable behavior** a consumer can see — a wrong response shape, a wrong persisted row, a wrong classification — and would fail before the fix and pass after. Then write it first, confirm it fails for the right reason, and keep it:

```bash
npm test -- --testNamePattern="should [your test name]"
```

Name it `should [expected behavior] when [condition]`. Rerun if flaky FK/unique issues.

**Skip the test — no shallow tests.** Do NOT invent a test just to have one. Skip it when:
- The fix is straightforward and obvious (a null return, a wrong constant, a reordered check, a missing guard) — the diff is self-evidently correct.
- The only way to "test" it is a change-detector: mocking the code's own dependency and asserting call counts, arguments, private methods, or "was X called with Y". That asserts the implementation, not a contract — banned (see `write-tests/SKILL.md`).
- It's a thin adapter over an external API with no observable contract on our side — verify live against the real service instead (`/optional/local-testing`), ship without a unit test.

When you skip, say why in the PR (one line). A shallow test is worse than no test — it locks in the implementation and rots.

### 3. Fix
BEFORE WRITING CODE, READ THIS: - `.claude/skills/build-feature/references/` — ALL
to align with our coding standards.

1. Write minimal code to make the test pass
2. Run the single test again to confirm it passes
3. Run all tests:

```bash
npm test
```

Fix any regressions before continuing.

from the available agents under `.claude/agents`, see what agent will be useful for your fix and run it.

### 4. Branch + Ship

Stage only the files this fix touched — never `git add -A`. The working tree may hold unrelated changes; sweeping them into your commit is how out-of-scope edits ship. Run `git status` first, then add the specific paths.

```bash
git checkout -b fix/[short-bug-description]
git status                       # confirm what's yours vs pre-existing
git add [path1] [path2]          # only the files this fix changed
git commit -m "fix: [description]"
```

Load `/ship-pr`. The fix flow already gives the PR its Tests section (the regression test, or the one-line no-test rationale from step 2) and its **Try it** (the failing-then-passing test command, or the repro request against a local server). Add Problem / Root Cause to the body's What/Why. `/ship-pr` opens the draft PR, runs the review sweep (agents comment inline), triages every thread, and marks ready.

### 5. Log the task

Invoke `/optional/task-management` to:
- Update existing bug task if one exists (move to done, add PR link)
- Or create new task: `[Fix] [Bug description]` in the Bugs list

## Output

Report: bug identified, fix applied, whether a test was added (and if not, why), PR URL, task link.
