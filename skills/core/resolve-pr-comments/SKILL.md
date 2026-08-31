---
name: resolve-pr-comments
description: Triage and resolve PR review comments — from the /ship-pr review agents (security, design, conventions, bug-hunter, sql-and-migration, perf), from humans, or both. Verify each finding, fix or push back, reply on every thread. Use when user says "/resolve-pr-comments" or asks to resolve PR comments.
---

# Resolve PR Comments

Review comments come from the `/ship-pr` agent sweep (inline, prefixed like `**[bug-hunter]**`) and from humans. Same discipline for both: findings are hypotheses to verify, not instructions to follow.

## Input

PR number, URL, or "latest"

## Process

### 1. Checkout + Gather

```bash
gh pr checkout {number}
gh pr diff {number} --name-only
# all unresolved review threads, with ids for resolving later
gh api graphql -f query='query($owner:String!,$repo:String!,$pr:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$pr){reviewThreads(first:100){nodes{id isResolved path line comments(first:20){nodes{databaseId author{login}body}}}}}}}' -f owner={{YOUR_ORG}} -f repo={{YOUR_REPO}} -F pr={number} --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved|not)'
```

### 2. Verify + Fix

For each unresolved thread:

1. Read the file + surrounding context
2. Before fixing, answer: **"When would this actually break?"** - describe a concrete, realistic scenario
3. State your assumptions explicitly (e.g., "I'm assuming ...)
4. `**[bug-hunter]**` threads carry a failing test — run it. Fails as claimed → fix, and commit that test as the regression test. Bug claims without a test → reproduce via /fix-bug before believing them.
5. If scenario is realistic and assumptions are verifiable from code → fix. Otherwise → push back on the thread (and raise to user if it matters).

Also look for: dead code, repeated patterns, unnecessary complexity.

### 3. Commit + Push + Reply (--no-verify and no claude signature)

```bash
git add -A && git commit -m "address review feedback" --no-verify && git push
```

Every thread gets an answer:

- **Fixed** → reply on the thread with the fixing commit SHA, then resolve it:

```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id={threadId}
```

- **Wrong or not worth it** → reply why on the thread and leave it **unresolved** — the user adjudicates disagreements, and an open thread is how they see there was one.

### 4. Iterate

Nothing re-reviews automatically — the agents run only when spawned. If your fixes added a substantial new diff (~50+ lines), re-run the relevant review agent(s) on the new commits (they post inline like before). **Max 2 iterations**, then stop and hand the user the unsettled threads with your analysis attached. They do the heavy lifting and final judgment once — they should never have to repeat a comment because round 3 re-litigated it.

When an unsettled thread contests a **behavior** claim (does the code do X under Y), don't hand over prose vs prose — build a `/visual-review` artifact of the disputed case and link it in the thread, so they operate the behavior and rule in a minute.

## Output

Report per iteration: fixed (with SHAs), pushed back (with reasons), threads left for the user.
