---
name: ship-pr
description: Ship a finished slice of work as a PR — open a draft PR, run the review-agent sweep (agents comment inline on the PR), triage every finding, then mark ready. The agents replace the external review bot as the review authority. Use when (1) a workflow skill says "ship with /ship-pr", (2) user asks to open a PR for completed work, (3) work on a branch is built + tested and needs review.
---

# Ship PR

Code first, PR second, review on the PR. The main session opens the PR; the review agents comment inline on GitHub so what happened is visible on the PR itself, not buried in a chat transcript.

Run everything from the repo the PR belongs to (or `gh -R {{YOUR_ORG}}/{repo}`).

## Preconditions — don't open the PR without these

1. The slice is built: `npm run build && npm run lint` green.
2. The slice's tests are written (two-agent split from the calling workflow), passing, and in this diff. No tests → back to the workflow. Exception: external-service-heavy — say so in the PR body.
3. The slice respects the stack rules — read [references/pr-stack.md](references/pr-stack.md): one **complete use case** (all its edge cases and tests in this diff — nothing about it deferred), sized by the ~400 changed-source-line signal (tests and docs don't count), based on the stack PR below it (or the default branch).
4. The `jsdoc` agent swept the changed files. It edits code, so it runs before the PR — it is not a PR commenter.

## 1. Evidence

**Frontend work** → run `/pr-evidence` (frontend repo skill) from the branch's final state: a screenshot per state (empty, loading, error, populated), a GIF of the key interaction end to end, before/after where behavior changed. It returns a markdown block for the PR body.

**Backend work with decision or temporal semantics** → run `/visual-review` and link the artifact in the Evidence section. Trigger: the slice's core is a behavior one Try-it command can't show — routing decisions, state transitions, retry/reconciliation policies, pricing rules — where the reviewer needs to operate the decision space, not see one path through it. Skip it for CRUD and straight-line logic: Try-it is enough there, and an interactive explainer for a getter is ceremony.

Both follow the same staleness rule: evidence and artifacts reflect the branch's **final** state — behavior changes during triage → re-capture / republish (same file path keeps the artifact URL).

## 2. Open the draft PR

```bash
git push -u origin {branch}
gh pr create --draft --base {stack-base-or-default} --title "{one focused change, no 'and'}" --body "..."
```

Body template:

```markdown
## What
[One-line summary]

## Why
[The user problem this solves]

## Stack
[PR n/m · base: {branch below} · full stack: #a → #b → #c — omit section if not stacked]

## Tests
[Test files + suite names, and the run command]

## Try it
[One command a reviewer runs against this branch + the exact output that proves it works]

## Evidence
[Frontend PRs: the /pr-evidence block. Backend PRs with decision/temporal semantics: the /visual-review artifact link. Omit otherwise.]
```

**Try it is mandatory.** Prefer a real observation over a test invocation: curl the endpoint locally (see `/local-testing`), run the script, query the table — and paste the expected output. `npm test -- --testNamePattern="..."` is the fallback when nothing else is observable.

## 3. Spawn the review sweep

All in parallel, after the PR exists. Each agent gets: PR number, repo, base branch, head SHA.

- **security-reviewer**
- **design-reviewer**
- **conventions-reviewer**
- **bug-hunter** — also gets the specified behavior (feature intent / design doc / scenarios doc) and the test writer's gap report. It runs after tests are written — that's precondition 2, so at PR time it always can.
- **data-migration-reviewer** — only if the diff touches `src/migrations/`, entity schemas, or repository queries.

Each agent posts its own inline comments (prefixed `**[agent-name]**`) and a "no findings" comment when clean. An agent that returns without having posted anything on the PR skipped the work — re-run it.

**Lanes — one owner per concern, so findings don't collide:**

| Concern | Owner |
| --- | --- |
| Exploitable: scoping, authz, injection, secrets, webhooks | security-reviewer |
| Wrong behavior vs spec, edge cases, prod failure modes | bug-hunter |
| Structure: module depth, layering, duplication, house-pattern adaptation | design-reviewer |
| What code says + house-way conformance (full build-feature/references) | conventions-reviewer |
| Schema/query safety at prod data volume | data-migration-reviewer |

Tiebreakers the defs carry: missing guard/tenant scope = security (exploitable); guard shaped wrong but safe = conventions. Schema conventions = conventions; schema safety = data-migration. Bad name from bad structure = design, as one finding. Two agents commenting the same line means one left its lane — note it when triaging.

## 4. Triage — every thread gets an answer

For each finding (verification discipline: `/resolve-pr-comments`):

- **Real** → fix, commit, push. Reply on the thread with the fixing commit SHA, then resolve the thread.
- **Wrong or not worth it** → reply why on the thread. Leave it unresolved — the user adjudicates disagreements, and an unresolved thread is how they see there was one.
- **bug-hunter finding** → the comment carries a failing test. Commit it with the fix as the regression test.
- Findings are hypotheses, not instructions — same skepticism as `/resolve-pr-comments`.

After triage:

- UI code changed → re-run `/pr-evidence` for the affected shots. Evidence must match the branch's final state.
- Fixes added a substantial new diff (~50+ lines) → run one more sweep pass scoped to the new commits. Max 2 sweep rounds total; still churning → stop and surface to the user.

## 5. Mark ready

```bash
gh pr ready {number}
```

Ready = handed to **human review**. The sweep loop is done and bounded (max 2 rounds); it does not run again on its own. Anything posted after this point — human comments, replies on disputed threads — is handled by `/resolve-pr-comments` (itself bounded at 2 rounds per invocation, then unsettled threads go to the user with analysis — they judge once, they don't repeat themselves): run it when asked, or on each new batch of comments if the session is watching the PR. The PR leaves this workflow comment-clean: every agent thread fixed-and-resolved or answered-and-left-open for the user.

## Output

Report: PR URL, per-agent finding counts (fixed / disputed), evidence links (frontend), and the Try-it line so the user can run it straight from the report.
