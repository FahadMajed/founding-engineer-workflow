---
name: adhoc-feature
description: Lightweight workflow for small features that don't need the full feature lifecycle (no design doc, no parallel worktrees). Tests still go through plan-tests + write-tests, but split across two fresh sub-agents so they're not written by the implementer. Use when (1) user says "/adhoc-feature", (2) user says the work is small/quick/adhoc, (3) the change is hours of work, not days.
---

# Adhoc Feature

Small features, fast, but still respecting the principles. Skip design doc and parallel worktrees, keep investigation, tests, and review.

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
4. Size it. One use case fitting review comfortably (~400 changed **source** lines is the signal; tests/docs don't count) → one PR (the normal case). More than one use case → slice a PR stack now, before writing code: read `.claude/skills/ship-pr/references/pr-stack.md`. Each slice is one **complete use case** with its own tests — never a layer, never half a use case — and the rest of this workflow runs per slice.

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

**Agent B — Write (against the plan).** Spawn a second, separate agent with `/write-tests`. Give it (1) the scenarios doc from Agent A, (2) the implemented code location. It writes the actual `*.spec.ts`, and flags any gap between plan and implementation (missing behavior, behavior mismatch, uncovered scenario). Surface those gaps to the user — don't silently make the test match the code.

Keep A and B as two distinct agents. One agent doing both collapses back into the same bias.

```bash
npm test -- --testNamePattern="Your Describe Block"
```

**Exception:** if the feature is mostly calling an external service and the test would be 90% mocks, skip both agents and call it out explicitly in the PR description ("No tests — external-service-heavy, mocking would dominate"). The user will confirm or push back.

### 4. JSDoc sweep

Run the `jsdoc` agent on the changed files. It edits code directly, so it runs before the PR — it is not one of the PR review agents.

### 5. Ship — /ship-pr

```bash
git add -A && git commit -m "feat: [short description]"
```

Load `/ship-pr` (per slice, if stacked). It opens the **draft PR** (body: What / Why / Stack / Tests / **Try it** — a command + expected output that shows the slice working), then spawns the review sweep — `security-reviewer`, `design-reviewer`, `conventions-reviewer`, `bug-hunter` (fed the step-1 intent + Agent A's scenarios + Agent B's gap report), and `data-migration-reviewer` if the diff touches migrations/entities/queries. The agents comment inline on the PR; triage every thread (fix + reply with commit SHA, or push back with reasoning), then mark ready.

Review happens on the PR, not before it — findings and their resolutions stay visible on the PR.

### 6. Log

Invoke `/optional/task-management` to log the task and link the PR.

**Task rules:**
- Status: `in review`. The PR is open; shipping happens after merge + deploy.
- Description: written for non-technical reviewers (the team reviews the tracker weekly). Lead with the user-facing problem and the user-facing change. Avoid file paths, class/function names, SQL, and code-level jargon unless they're the simplest way to say it.
- Don't include an "Out of Scope" section unless scope boundaries were explicitly discussed.

## Output

Report: feature shipped, files touched, tests added (or why not), PR URL, task link.

## CRITICAL Rules

- Never introduce new patterns without discussion — it's fine to suggest or improve some patterns.
- Never use `any` types — define interfaces, unless you can't help it.
- Add comments only when code cannot express intent; do not throw comments on every line.
- **Deep modules** — modules should have simple interfaces that hide complex implementation. A good module does a lot behind a small API surface. If a class/service interface is almost as complex as its implementation, it's too shallow — rethink the abstraction.
