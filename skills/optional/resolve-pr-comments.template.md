---
name: resolve-pr-comments
description: Resolve PR comments - fix issues found by code reviewers + own analysis, iterate until clean. Use when asked to resolve PR comments.
---

# Resolve PR Comments

## Input

PR number, URL, or "latest"

## Process

### 1. Checkout + Gather

```bash
gh pr checkout {number}
gh pr diff {number} --name-only
gh api repos/{{YOUR_ORG}}/{{YOUR_REPO}}/pulls/{number}/comments --jq '.[] | {path, line: (.line // .original_line), body}'
```

### 2. Verify + Fix

For each review finding:

1. Read the file + surrounding context
2. Before fixing, answer: **"When would this actually break?"** - describe a concrete, realistic scenario
3. State your assumptions explicitly
4. If scenario is realistic and assumptions are verifiable from code → fix. Otherwise → raise to user.

Reviewer comments are input, not authority. Treat findings as hypotheses to verify, not instructions to follow.

Also look for: dead code, repeated patterns, unnecessary complexity.

### 3. Commit + Push + Comment

```bash
git add -A && git commit -m "address review feedback" && git push
gh pr comment {number} --body "Fixed: ... / Skipped: ... (reason)"
```

Comment summarizes what was fixed and why anything was skipped (for human readers).

### 4. Iterate

Reviewers may re-review on push. Check new comments, fix, repeat.
Max 3 iterations - escalate if still failing.

## Output

Report what was fixed per iteration.

## Philosophy

- **Verify before fixing** — Not every comment is correct
- **Explain skips** — If you don't fix something, say why
- **Learn from patterns** — If same feedback keeps coming, update your patterns
- **Don't over-engineer** — Fix the issue, don't rewrite the feature
