---
name: signals
description: Mine first-party sources for problems nobody raised — public reviews, intake capture forms, analytics funnels, trial/churn data, support threads — and turn them into tier-stamped evidence and candidate problem statements. Use when (1) user says "/signals" or "mine signals", (2) a month has passed since the last sweep, (3) a discovery needs user-side evidence and the requester has none.
---

# Signals

The discovery pipeline is reactive: it runs when someone raises an ask. The people most exposed to the product's failures raise the fewest asks — a self-serve user churns silently inside the trial window and files nothing. This skill walks the first-party sources on a cadence and converts what they say into intake: evidence-ledger entries and candidate problem statements the pipeline can act on.

## Sources — walk each, skip none silently

**Customize this section for your product.** Replace each `{{YOUR_SOURCE_*}}` with the concrete tool/store/query you actually use, and keep the tier stamp and the reasoning next to it. On the first run, verify each mapping (form → list, event → funnel) and correct it here if it differs.

1. **Intake capture forms — `{{YOUR_SOURCE_INTAKE}}`** — the in-app feedback control posts to your bug and idea intake lists. Pull items created since the last sweep (marker in the ledger's Sweeps section; no marker = take everything); these are T1 artifacts logged the day they happened.
2. **Public reviews and ratings — `{{YOUR_SOURCE_REVIEWS}}`** — your product's public listing. Read the text, not the stars: where ratings inflate under politeness norms, a user who typed a complaint into a public review has crossed the politeness barrier — weight it accordingly. T2-LANDSCAPE for market claims, T1 for what a named reviewer reports about your product.
3. **Trial-to-paid and churn — `{{YOUR_SOURCE_CHURN}}`** — read-only production queries (the backend repo's `/observability` and `/local-testing` patterns): trials that never converted, subscribers gone quiet, uninstalls. Every loss is a switch-interview candidate (`../ux-discovery/references/user-probes.md`); at small scale, interview all of them.
4. **Analytics on self-serve surfaces — `{{YOUR_SOURCE_ANALYTICS}}`** — funnels and drop-offs for the flows a self-serve user walks unassisted. Where API access isn't configured in-session, name the query and ask for the export rather than skipping.
5. **Support threads — `{{YOUR_SOURCE_SUPPORT}}`** — only what's provided or exported into the session. Never reconstruct a thread from memory or plausibility.

## Method

- **Read everything.** At tens of users, sampling is a big-company habit — total reading costs an hour and misses nothing.
- **Tag small and stable.** Tag findings against a short taxonomy (`{{YOUR_TAXONOMY_TAGS}}` — start with the handful of areas your product is organized around: onboarding, trust, pricing, core-workflow, reporting, billing, performance, i18n/RTL, mobile). Extend it deliberately, never per-run, or trends stop being comparable across sweeps.
- **Verbatims attached.** Every tagged item keeps its quote and link; a summary without its quotes becomes debate material, not evidence.
- **Consolidate into the ledger.** New instances of a known fact append to the existing `{{root}}/docs/discovery/evidence-ledger.md` entry (recurrence is the signal); genuinely new facts get new entries with tier + provenance + segment tag. Segments never pool — an internal-operator complaint and a self-serve user review are different populations.
- **Counts, not percentages,** below n≈30 — "3 of 11 reviews this quarter", never "27%".

## Output

1. Ledger entries written (new + consolidated), listed by ID.
2. **2–3 candidate problem statements** — binary-test form (role, concrete moment, cost, zero UI nouns), each citing its evidence — appended to the problem & opportunity backlog (`{{root}}/docs/discovery/opportunities.md`) as `raw` entries with their shape marked (attach to existing entries where they match).
3. A short digest in chat, ranked by recurrence × breadth: what's new, which existing opportunities gained or lost evidence, and explicitly what the currently-targeted opportunity got — including "nothing", which is a flag.
4. Churn/uninstall candidates for switch interviews, if any — named, with the reach-out window (days, not weeks).
5. The sweep line appended to the ledger's Sweeps section: date + sources walked — the next run's "since" boundary.

Absence is a finding: a source that yielded nothing gets a line saying so, not silence.
