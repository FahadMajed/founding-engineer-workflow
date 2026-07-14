# PR Stacks

Why: a 2000-line PR gets a skim; a stack of small, complete PRs gets real review. The unit of slicing is the **use case** — not the layer, not the file type.

## Slice by use case, not by concern

A slice is one use case, complete: its schema, its logic, its endpoint, its tests, its edge cases — everything that use case needs to ship, in one PR. It gets reviewed as if it deploys tomorrow: nothing about THIS use case is "handled in the next PR". Deferring a *different* use case is the whole point of stacking; deferring an edge case of the current one is a hole.

Why not layer slices (schema → service → api):

- A naked schema PR can't be judged — the reviewer sees columns without the behavior that justifies them, and its Try-it is a SELECT on an empty table. No picture.
- A use case split across layers gets its code re-altered by every later slice — the reviewer reads the same code N times and can only judge it once, at the end.
- A use-case slice has a real Try-it: call the endpoint, see the thing a user can now do.

## Rules

- **One use case per PR, terminally complete.** All inputs, edge cases, and tests for that use case land with it. The review sweep judges it as final — "will extend later" is only valid for *other* use cases in the stack map.
- **Never split a use case across PRs.** If one use case is far over size, the use case was cut too big — split it in the design into two smaller use cases; don't split the code mid-flight.
- **Foundation rides with the first use case that needs it.** Entities and migrations ship inside the first vertical slice, not as a naked PR of their own. Later use cases extend additively.
- **Stack in dependency order.** Core flow before variations (create before update, record before compute before export). Each PR builds only on the PRs below it; the bottom PR bases on the default branch. Every PR leaves the system working — dark code is fine, a broken build between PRs is not.
- **~400 changed source lines is a sizing signal, not a knife.** Tests, docs, lockfiles, snapshots, generated files, and evidence don't count — they make review easier; counting them would punish what every PR must ship more of. A use case landing near the number is normal; double it and the use-case cut was wrong upstream. Never trim scope or split a use case to duck the number. Measure:

  ```bash
  git diff --stat {base}...HEAD -- . ':(exclude)*.spec.ts' ':(exclude)*.test.*' ':(exclude)test/**' ':(exclude)e2e/**' ':(exclude)*.md' ':(exclude)docs/**' ':(exclude)*lock*' ':(exclude)*.snap'
  ```

  Migrations count — they run in prod.

## Example

Feature: inventory planning.

1. `claude/inventory-planning/1-record-settings` — replenishment settings: entity + migration + endpoint + validation + tests → base: default branch
2. `claude/inventory-planning/2-suggestions` — compute replenishment suggestions from settings + stock → base: 1
3. `claude/inventory-planning/3-apply` — apply/export a suggestion to the external integration → base: 2

Each PR is one thing a user can now do, demonstrated end to end in its Try-it. Fullstack: the frontend for a use case ships in the frontend repo, cross-linked — two repos, two PRs, same slicing.

## When a layer cut IS the right cut

- A pure data migration or backfill that is itself the deliverable.
- A cross-cutting refactor with no behavior change.
- A genuinely shared foundation so large it would dwarf the first use case — rare; justify it in the PR body.

## The reviewer needs the picture

Every PR body's **Stack** section carries the map: the design doc link, the ordered use-case list with PR links, and which one this PR is. The reviewer of slice 2 sees the whole feature's shape — what shipped below, what's coming above — without leaving the PR.

## Mechanics

- Branch names: `claude/{feature}/{n}-{use-case}`. A change that fits in one PR: `claude/{feature}`.
- Create: `gh pr create --draft --base claude/{feature}/{n-1}-{use-case}`
- Review sweep runs per PR on `git diff {base}...HEAD` — never on the whole stack at once.
- A fix on PR n → rebase every branch above it (bottom-up) and `git push --force-with-lease` each.
- After the bottom PR merges: `gh pr edit {next PR} --base {default branch}`, rebase the remaining stack onto the default branch, force-push with lease.

## When NOT to stack

The feature is one use case that fits review comfortably → one PR. A stack of one is the normal case for adhoc work. Don't slice for the sake of slicing.
