---
name: outcome-review
description: Grade shipped product bets against what their discoveries predicted — pull each registered metric from its source of truth, walk the watch items, verdict every falsification line. Use when (1) user says "/outcome-review", "did it work", "grade our bets", "outcome review", (2) a month has passed since the last review, (3) any outcomes-register row's first check date has passed.
---

# Outcome Review

Every discovery ships with predictions: success metrics with baselines, falsification lines ("we're wrong if…"), watch items. This skill is the half of the job that happens after shipping — without it, a wrong build verdict and a right one look identical forever, and the next verdict can't be calibrated by the last one.

Bets are registered at ship time by `/sdlc` and `/scoped-fullstack-feature`; this skill grades them.

## Inputs

- **The register:** `{{root}}/docs/discovery/outcomes-register.md` — every row whose status is `watching` and whose first check date has passed. Never check a bet before its registered date: an early read measures the novelty spike, not the truth.
- **Per feature:** its discovery folder (`DISCOVERY.md` §§12–13, 16, or `DISCOVERY-LITE.md`'s Design Decisions bets + "How we'll know it worked").

## Method — per due bet

1. **Pull the source of truth the register names.**

   **Customize this section for your product** — each bet names one of these metric stores:
   - `{{YOUR_SOURCE_ANALYTICS}}` — product analytics events (the codebase logs one on every state-changing action)
   - `{{PROD_DB_RO}}` — read-only production queries (the `/call-api` and `/observability` patterns)
   - `{{YOUR_LOG_SOURCE}}` — error/exception monitoring

   If a source can't be pulled in-session, name the exact query/export needed and grade `inconclusive — blocked on {x}`; an unmeasurable bet is a registration defect to name, not to skip.
2. **Compare against the registered baseline and expectation.** At small scale, evidence is named-actor behavior — "both operators opened it daily for three weeks", "2 of 5 self-serve users who saw it acted" — never percentages over tiny denominators.
3. **Walk the watch items and falsification lines.** Each falsification line gets an explicit verdict: fired / didn't fire / can't tell.
4. **Answer three questions, in writing:** What happened? What did we learn? Did the feature everyone was sure about deliver what the discovery promised?
5. **Grade the bet:** `confirmed` / `falsified` / `inconclusive` — and one mandated line: **what we got wrong**, even on confirmed bets (a scope cut, a missed edge case, a metric that measured the wrong thing). A review reporting only wins is suspicious by base rate — even elite experimentation shops find most ideas don't move their target metric; if every bet reads confirmed, the first hypothesis is that the measurement is too soft.

## Writes

- `{feature}/OUTCOMES.md` in the feature's discovery folder — dated, the per-bet detail from the method above.
- The register row: status updated, grades appended.
- `{{root}}/docs/proposals/DECISIONS.md`: the original verdict's row gets `→ confirmed` / `→ falsified (date)` so future intakes see how past verdicts aged.
- **Falsified bets feed the corrections loop:** when the miss generalizes (a class of assumption that keeps failing, an instrument that keeps overstating), encode it into the relevant `{{root}}/.claude/skills/ux-discovery/references/*.md` file as a BAD/GOOD pair and close with "Encoded: {file}" — the same mechanism requester corrections use. A falsified bet is a result the pipeline paid for; wasting it is the defect.

## Report

Anomaly-first digest in chat: bets graded this run (falsified first, with what they imply — iterate / remove / leave), what's blocked and on what, which watching bets come due next, and any register hygiene problems: sweep `{{root}}/docs/discovery/*/` for discoveries whose feature shipped (merged PRs) with no register row — features shipped outside `/sdlc` and `/scoped-fullstack-feature` miss the registration step, and this sweep is what catches them. Where a falsified bet traces to a specific requester's ask, say so plainly and kindly: the bet didn't pay, the raising was still right — the intake pipe lives on people staying willing to raise things.
