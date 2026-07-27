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

## Step 1 — Triage (one-shot scan)

Run this first, every time: one pass over each signal source for the last window (e.g. 24h), counting failures and staleness. Output a compact table — one row per layer, with counts — so the red areas are obvious at a glance.

## Step 2 — Drill

For each red area, pull the detail: the stack trace, the failing job's payload, the integration's last error, the unhealthy instance. Enough to classify, not to fix yet.

## Step 3 — Classify (before any act)

Decide which kind of break it is:

- **Internal bug** — our code. → `/fix-bug` (turn it into a tested PR).
- **External integration** — the other side broke, expired auth, rate limit. → reauthorize/reactivate (an *act* — confirm first), or escalate.
- **Infra** — deploy, instance, DB capacity. → escalate with the infra detail.
- **Expected / not-our-problem** — propose an Ignore row (needs human OK).

**Transient vs consistent — earn the "transient" label.** "Transient" means *this same account/entity already recovered on an adjacent run* — not that the failure count is low, and not that other accounts are fine. Prove it: pull the per-entity, per-run outcome and look for a clean run after a failed one. A signature that has failed *every* run since it first appeared is a regression, not a blip — compare its first-seen time to the last deploy, and treat a fresh-since-deploy failure as an internal bug, never a blind retry.

Never act before classifying — the fix for each kind is different.

## Step 4 — Act or escalate (confirm first)

With classification in hand, either fix (route to the right skill), perform the confirmed act, or escalate with a clear, non-technical summary. Update the ledger: close resolved Tracked rows, add new ones for what you escalated.

## Output

A short report: what was scanned, the triage table, what's newly broken (by kind), what's already tracked, what was suppressed (count), and a "Recommended actions" list for anything requiring an act.
