---
name: design-internals
description: Draft the Internal design section of a design doc — what runs under the public interface. Internal collaborators, state machines, computations, invariants, edge semantics, replay. In one pass with a rationale per decision, then an agnostic review. For big features in the design phase. Use when (1) user says "/design-internals", (2) a feature computes a value, has a lifecycle, or can run twice, (3) writing the Internal design section of a docs/design_docs/ doc.
---

# Design Internals

You are a senior backend engineer designing what runs under the public interface. Components design holds the outside — which classes exist and who calls whom. You design the inside: the computation, the order, what must always hold. You write decisions, not procedures, because the implementer already knows the patterns.

Draft the **Internal design** section of `docs/design_docs/{FEATURE}.md`.

First load `docs/standards/DESIGN_DOC_METHOD.md` and run its loop — load context, surface assumptions, draft with rationale, iterate, agnostic review, simple english. Everything below is the internals-specific layer.

## Does this feature need the section?

It applies if **any** of these is true:

1. Computes a value that gets persisted or shown as a judgment — score, band, rate, forecast, price, commission.
2. Something has a lifecycle — more than two states, or transitions with rules.
3. The same work can run twice — cron plus event on one path, retries, replay, backfill.
4. Two rules can disagree about one output, so precedence is needed.
5. There is a window or a boundary — 30d, a business-timezone day, month-end.

None true → write `N/A — CRUD over existing entities` and stop. Don't manufacture a section.

## The rule that keeps it short

**If `.claude/skills/build-feature/references/` answers it, it does not go in the doc.** The implementer reads those. Re-stating them is noise that hides the decisions.

Already covered there, so never write it here:

| Don't write | Covered by |
| --- | --- |
| Bulk-load vs per-item, `Map` lookups, chunked bulk queries | `data-access.md` |
| How to transact or lock, allocating a lock id, cron job-tracking | `data-access.md`, `crons-and-sync.md` |
| Empty-array guards, tenant scoping | `data-access.md` |
| `allSettled` vs `all` vs sequential, per-account rate limits | `conventions.md` |
| Retry and backoff on handlers | `events.md` |
| Intermediate DTO naming, deriving types from the entity | `conventions.md` |
| Framework exceptions, localized error messages, no logging in services | `conventions.md` |

What's left is only what the references can't know: what this feature computes, what must hold, what we're choosing not to do.

## Read for this section

- `.claude/skills/build-feature/references/` — read to know what **not** to write. At minimum `data-access.md`, `conventions.md`, `crons-and-sync.md`.
- The **Components design** — the public interfaces you design under. If drilling in exposes a gap there (or in Data design), fix it at the source and re-confirm at its gate — per the method.
- The **Data design** — the rows this writes, and the null-vs-zero table if there is one.
- The discovery doc + the doc's **Business Rules** — the thresholds, windows, and precedence come from there. Where a rule is stated loosely, this is where it gets pinned to a number.
- The **closest existing feature with an Internal design section** — precedent for depth. Match its *depth per decision*: the load-bearing rule stated with its "why" (e.g. a cooldown that's *time-gated, not cycle-gated*), the resolution order when rules compete and why that order matters, the transition table, the one-line idempotency rule on any writer, "the tier is read at recompute time — no historical re-attribution".

  Do **not** match its length. The biggest feature in a codebase is the outlier — many dimensions, several driver shapes, a config layer, a daily ledger, spanning most of the platform's data. Almost nothing else is that big, and a section that long on a normal feature means references material has crept in.

## The section covers these, in order

Draft them together in one pass (per the method), not one per turn. Skip the ones that don't apply — 2 and 8 often don't.

1. **Internal collaborators** — the private classes inside the component, one line and a signature each. Not the public service; Components owns that. e.g. `ScoreCalculator`, `StatusResolver`, `CooldownGate`, `TransitionWriter` — nobody outside the module sees them. Add an internal sequence diagram only when 3+ collaborators interact in a non-obvious order; two collaborators → a numbered list is shorter.
2. **State machine** — where state exists. A transition table (state × trigger → next state + side effect), terminal states, and which transitions are illegal. State the machine; don't mandate a class-per-state — that's the implementer's call.
3. **Computations** — the formula, thresholds with units, rounding, tie-breaks, and **precedence when two rules disagree**. A decision table when several conditions map to outcomes.
4. **Edge semantics** — does 0 mean healthy or no-signal? null vs 0 vs empty. Below-floor. Empty set. Product calls, not SQL guards.
5. **Invariants** — what must always hold inside the component. This is where a break is silent, so write the ones nothing would fail loudly on.
6. **Failure & replay** — is a half-written batch acceptable, is the write idempotent, what the dedup key is, what a re-run over the same window produces. And per-unit disposition: first ask whether the failing state can be prevented where it's written — when your system authors the record (it creates the item, it ingests the entity), capture the link at that write and the failure never exists. What's outside your write path routes on failure to a completable review row whose resolution writes back what the automation lacked, so the next run resolves it alone — never to a `failures[]` array, where it re-fails every run forever.
7. **Time & windows** — which clock, which timezone, edges inclusive or exclusive, and what a late-arriving row does to a window already computed.
8. **Config read timing** — only if there are no-deploy tunables: read at boot, per run, or cached, and what happens if they change mid-run. Data design says the table exists; this says when it's read.
9. **Not handled** — the deliberate internal non-handling. One line each. Highest value-per-word in the section: *"tier is read at recompute time — no historical re-attribution"* closes a whole rabbit hole.

## What "balanced" means here

- Every line closes a decision the implementer would otherwise make alone. Can't name the decision it closes → cut the line.
- Decisions, not procedures. A table or a sentence. Pseudocode only where a rule genuinely can't be stated any other way, never as a narration of the implementation.
- **Name the existing thing** — the specific finder, service, or decorator to call, in the spots where the natural move is to write a new one. References says "reuse first"; this says which.
- A number, not an adjective. "Below 20 orders in 30d" beats "when the sample is small".
- A normal feature's Internal design lands around 40–50 lines. If it's much longer, references material has crept in.

Over-engineered tells: pseudocode restating a reference pattern (bulk-load, `allSettled`, transaction wrapping); a sequence diagram of two collaborators; a state machine for a boolean; re-declaring the public interface Components already has; explaining *how* to lock instead of *what* needs locking; naming intermediate DTOs.

## Output

The Internal design section, written into `docs/design_docs/{FEATURE}.md` — then the agnostic review from the method.
