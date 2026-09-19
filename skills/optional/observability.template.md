---
name: observability
description: The agent's eyes for production — pull context on any break (internal bug, external integration, or infra), classify it, then fix or escalate. Reads prod read-only across your error logs, job/queue tables, integration status, the DB, and infra; routes to /fix-bug or an escalation. Use when the user says "check errors", "what's broken", "is everything ok", "system health", "are syncs healthy", "why is X failing", or asks why anything in prod is erroring, failing, or not updating.
---

# Observability — the agent's eyes

> **Template.** Replace every `{{PLACEHOLDER}}` with your stack's real read-only commands, tables, and dashboards. The value of this skill is the *concrete* map of where to look — fill it in once, for your system. The structure (observe-vs-act, triage → classify → route, ledger memory) is what's reusable; the signal sources are yours.

One place to pull context on any production break — a bug in your own code, an external integration that stopped, or the infra underneath — so you're not blocked by missing context. Read the signal, decide which *kind* of break it is, then fix or escalate.

## Two modes: observe (free) and act (confirm first)

- **Observe** = reads only — read-only DB connection, log queries, infra `describe` calls. Run freely.
- **Act** = a prod write, a real external API call (reauthorize/reactivate), or filing a task. These are visible or hard to undo. **Always say what you're about to do and confirm before running.** Never blind-retry a failure you haven't classified — retrying a code bug just burns another failure.
- **On a scheduled / unattended run:** do the analyze half + report + ledger bookkeeping only. Queue every act under "Recommended actions" for a human — never run an act, and never add an Ignore row, without a live confirmation.

## What you can observe (pick the signal for the question)

Match the question to the signal. Fill in your sources:

| The question / symptom | Signal source | Where |
|---|---|---|
| App throwing 4xx/5xx, an endpoint erroring | error logs / APM | `{{ERROR_LOG_QUERY}}` → route to `/fix-bug` |
| Background work not running (jobs, syncs, events) | job/queue tables | `{{JOBS_TABLE}}` — failure + staleness signals |
| An external integration is off / stale | integration status table | `{{INTEGRATION_STATUS_TABLE}}` |
| "Is X in the DB / does this data look right" | prod DB (read replica) | `{{PROD_DB_RO}}` (ad-hoc) |
| Deploy failed, instance unhealthy, DB maxed | infra | `{{INFRA_DESCRIBE_CMD}}` |

Don't know which? Sweep the triage (Step 1), glance at infra, then drill where it's red.

## Step 0 — Load the ledger (memory between runs)

Read your ledger file first (e.g. `ledger.md`). It carries two lists across runs so a daily schedule doesn't re-chew the same breaks:

- **Ignore** — signatures known not-our-problem or expected. Suppress these from "needs attention"; still tally them as one `suppressed: N` line so nothing goes fully invisible.
- **Tracked** — breaks already escalated with an open PR/task. Don't re-raise as new; list them under "Already tracked" with their link.

Applying both lists is free. **Adding an Ignore row needs a human OK** (a wrong ignore hides a real outage). Recording/closing a Tracked row is free bookkeeping.

## Step 1 — Triage (three legs, all every run)

Run this first, every time.

**Leg 1 — the job/state sweep.** One pass over each signal source for the last window (e.g. 24h), counting failures and staleness. Output a compact table — one row per layer, with counts — so the red areas are obvious at a glance.

**Leg 2 — the app-error sweep.** Leg 1 only catches breaks that got logged as a job, event, or connection row. An error thrown *before* anything writes a row never lands there, so a green Leg 1 is not an all-clear. Sweep the error log every run (`/debug-errors`) — with the **default, status-less mode**: errors thrown outside an HTTP request (crons, handlers, background services) carry no status, and a `500`-scoped sweep is blind to exactly the breaks that run unattended.

**Leg 3 — the consistency sweep.** Legs 1 and 2 answer *"did it run?"*. They go green when a job completes and throws nothing, and they are blind to work that **succeeds and stores the wrong value** — a field never fetched, a mapping bug, a state transition that lands after the window already swept that record. Sweep it in two tiers:

- **Tier 1 — pure-DB anomalies.** Free, no external calls: an entity stuck non-terminal past its own deadline; two stored columns that contradict each other. A hit is a *suspicion*.
- **Tier 2 — source-sampled.** Sample those records and re-fetch from the system of record to confirm. Read-only, safe unattended. A mismatch is a *confirmed* silent-success break → classify (Step 3) and route (Step 4).

**"All clear" needs all three legs clean** — the job sweep green, the error sweep showing nothing new, *and* no unexplained mismatch. Apply the ledger to all three: suppress known-ignorable, set aside tracked, and what's left is this run's work.

## Step 2 — Drill

For each red area, pull the detail: the stack trace, the failing job's payload, the integration's last error, the unhealthy instance. Enough to classify, not to fix yet.

## Step 3 — Classify (before any act)

Decide which kind of break it is:

- **Internal bug** — our code. → `/fix-bug` (turn it into a tested PR).
- **External integration** — the other side broke, expired auth, rate limit. → reauthorize/reactivate (an *act* — confirm first), or escalate.
- **Infra** — deploy, instance, DB capacity. → escalate with the infra detail.
- **Expected / not-our-problem** — propose an Ignore row (needs human OK).

**Transient vs consistent — earn the "transient" label.** "Transient" means *this same account/entity already recovered on an adjacent run* — not that the failure count is low, and not that other accounts are fine. Prove it: pull the per-entity, per-run outcome and look for a clean run after a failed one. A signature that has failed *every* run since it first appeared is a regression, not a blip — compare its first-seen time to the last deploy, and treat a fresh-since-deploy failure as an internal bug, never a blind retry.

**Classes that hide from failure counts.** Each of these reads green in a naive sweep — learn them or you will report "all clear" over a live incident:

- **Terminal status, not the retry counter.** A queue that marks a row terminal on its *last* attempt leaves the counter one below the max, so filtering on `retries >= maxRetries` returns **zero rows during a live incident**. Key on the terminal status instead. And since these rows usually accumulate forever, a raw lifetime `COUNT(*)` is not a rate — bucket by day over 7–14 days before calling it a fire.
- **Duration is half the signal.** A job that runs long *completes* — while the caller gave up waiting at its polling cap and threw the result away. The work fails; the job table reads 100% healthy. Check durations every run and read them against the same job type elsewhere: seconds on other accounts and thousands of seconds on one is that account, not the system.
- **Retry amplification (self-inflicted).** A failing handler that kicks off expensive recovery work on *every* retry generates lock contention and a flood of downstream errors. The loud rows are noise; suppressing them fixes nothing. Trace back to the event that retries, classify *that*, and ask whether its recovery path could ever fix the condition — a re-sync cannot invent a missing link.
- **Check-then-lock duplicate work.** A guard evaluated *before* the work takes its lock lets every waiter that passed the guard re-run the whole job; the losers of the race can hang in-progress forever, invisible to failure counts. Don't re-arm — it re-races. Move the guard inside the lock, and sweep separately for rows stuck in-progress past a sane age.
- **An automation wall misreported as bad credentials.** A portal/browser automation blocked by a bot check often surfaces as "incorrect username or password" after its retries burn out. Read the duration and the neighbouring runs before touching credentials: a burst that ends with a clean run minutes later is a wall that self-healed. Rotating credentials that are fine costs a human and fixes nothing.

Never act before classifying — the fix for each kind is different.

## Step 4 — Act or escalate (confirm first)

With classification in hand, either fix (route to the right skill), perform the confirmed act, or escalate with a clear, non-technical summary. Update the ledger: close resolved Tracked rows, add new ones for what you escalated.

## Output

A short report: what was scanned, the triage table, what's newly broken (by kind), what's already tracked, what was suppressed (count), and a "Recommended actions" list for anything requiring an act.
