# Domain — the mechanics that reject designs

Working knowledge for exploration and design — the mechanics of your channels, integrations, and market that reject designs. **This file is a template.** The *method* is fixed; the content is yours to fill in and grow.

**Customize this section for your product.** Replace every `{{PLACEHOLDER}}` with your own channels, mechanics, calendar, and market. Keep the structure — capability floor, per-channel mechanics, automation frontier, calendar stress test, pattern library, metric hierarchy — because exploration, ideation's action-envelope test, and the critique rubric all point at these sections by name.

Every claim carries its provenance: **[code]** proven by our integration code · **[prod YYYY-MM]** our production data · **[ticket-ID]** a tracked incident · **[web]** cited external source (T2-LANDSCAPE — never outranks what our accounts experience; record conflicts, prefer the local account) · **[unverified]** keep out of load-bearing decisions. Re-verify anything load-bearing older than a quarter — channel policies drift.

**How this file grows (and stays deep):** three inlets — the proposal interview's domain section (non-obvious context, folded in once verified), the evidence ledger (incidents that generalize), and outcome reviews (bets the market falsified). A mechanic enters as mechanism → design consequence → provenance; a clause that names a topic without teaching its consequence gets cut.

## The capability floor [code]

What your integrations prove each channel can and cannot do. Never design a generic cross-channel abstraction ("health score", "winner metric", "payout") without checking this floor — a design assuming a capability outside it is fiction until the integration changes. Fill the matrix for your channels:

| Channel | API | Order events | {{METRIC_A}} | {{METRIC_B}} | Inventory push | {{METRIC_C}} |
| --- | --- | --- | --- | --- | --- | --- |
| {{CHANNEL_1}} | {{API_KIND}} | {{yes/poll/none}} | {{yes/no}} | {{yes/no}} | {{yes/read-only}} | {{yes/no}} |
| {{CHANNEL_2}} | {{API_KIND}} | {{yes/poll/none}} | {{yes/no}} | {{yes/no}} | {{yes/read-only}} | {{yes/no}} |
| {{CHANNEL_3}} | {{API_KIND}} | {{yes/poll/none}} | {{yes/no}} | {{yes/no}} | {{yes/read-only}} | {{yes/no}} |

Note the non-obvious identity traps: one integration login may span multiple markets or accounts; an integration marked "declared only" has no real data behind it. Record which surface is the real source of truth when a third-party system sits behind the channel.

## Per-channel mechanics

For **each** channel or integration, capture the mechanics that reject designs — the rules a design has to survive. Use this shape per channel (the examples are placeholders to replace with your own, each with provenance):

### {{CHANNEL_1}}
- **Account/health states:** the readable states and their thresholds; which are healthy vs at-risk vs terminal [code/web]. A "suppressed"/"at-risk" surface must say which cause — the fix differs per cause.
- **What's exposed vs hidden:** which competitor/market signals the channel exposes and which it does not — render an unavailable signal honestly ("—", not 0) [code].
- **Fulfillment semantics:** who owns the stock, whether the seller can cancel, whether stock can legitimately read negative or zero-by-absence, whose fault damage/returns are (this decides whether a health metric may charge the account for it) [code].
- **Data honesty:** which numbers finalize late, which fields get destroyed on cancellation, how long history windows run [code]. A design that implies fresher or more complete data than the source provides is lying.
- **Discipline/penalties:** the strike/penalty thresholds and what they cost (visibility demotion, closure, termination) — read them from the channel's own dashboard where possible [code].
- **Onboarding gotchas:** the compliance/document requirements and the classic failure mode [web].
- **Masquerading gotchas:** the cases where a wrong config silently returns empty or wrong data (zero rows ≠ no data), where SKUs reference records that never synced, where only one webhook subscriber is allowed [code].

Repeat per channel. The point is not completeness — it's capturing the specific mechanic each time it rejects or reshapes a design, with provenance.

## Shared accounts & attribution (cross-channel)

- **One login often hosts many owned accounts.** Everything account-level — connections, sync failures, POs, penalties — fans out per owned account; surfaces must dedupe to one row per login or one incident reads as several [prod, code].
- **Attribution runs key → record → owner;** when the mapping is wrong, revenue lands on the wrong owner's report — historically discovered in customer-facing exports, the worst possible place [ticket].
- Third-party catalogs often carry **no stable owner identity** — auto-creating owners from catalog pulls duplicates them [ticket]. And "one sale" is ambiguous: order vs order-item granularity produces duplicate-looking reports; dedupe keys must include the owner because logins are shared [ticket].
- **Ingestion isn't guaranteed-complete** — receiving loses records routinely enough to justify monitoring; treat it as an expected failure mode, not an anomaly [ticket].
- **Staleness floors come from your own sync cadences** (e.g. orders every few minutes, catalog every few hours) [code]. A design that implies fresher data than its source cadence is lying.

## Automation frontier

Industry-wide, detection is automated and remediation increasingly is; **state here exactly what your system can execute today** — if the answer is "nothing is system-executed; every fix is human on the channel's own portal", say that. Every detection design closes the loop: who is alerted → where they act (often the portal, not our app) → how the fix is confirmed and the item clears.

**The envelope is data; the rules are invariant.** This paragraph is the single place that states what the system can execute — ideation's action-envelope test, the critique rubric, and principle 1's handoff clause all point here instead of restating it. An action enters the envelope by being listed here with its guardrails named: impact preview, undo/rollback, an audit trail, and the recommendation five-pack on any surface that triggers it. Automation shifts a design's cognitive modes rather than escaping them — an automated action's surfaces become MONITOR ("what did it change, is it behaving") and approval-queue DECIDE; the trust burden moves into the five-pack's evidence chain and conservative defaults.

## Calendar

- **Name your market's peak events.** {{YOUR_PEAK_EVENT}} (the biggest single spike) vs {{YOUR_PEAK_SEASON}} (the longer season with the larger total) — which dominates depends on category; verify per account [web]. Capture the real demand multipliers from prod where you have them — they're usually account-level, not category-level [prod].
- Stress-test every design against your peak: do trend charts mislead across any calendar shift your market follows? Does stock-cover math assume steady daily velocity? Do alert thresholds flood at surge volume? Is there a delivery-cutoff concept where relevant? A feature that behaves sensibly in a normal week and lies during the peak is a domain failure.

## {{YOUR_PRIMARY_LANGUAGE}}-first & i18n

A design-time constraint, not a translation pass: imagine key screens in your users' primary language first — text expansion, label length, navigation-depth preference, numeral direction inside an RTL layout where relevant. Flag any layout that only works with short English labels. Copy register follows the project's language rules. No emoji-as-iconography in specs. (Keep RTL/i18n handling as a genuine engineering concern wherever your audience needs it.)

## The jobs this domain keeps hiring for

List the recurring jobs your product exists to do (the equivalents of: health monitoring, stockout prevention, content compliance, penalty avoidance, reconciliation). During interviews, hunt for: "the one number you don't trust today", "the number you rebuild in a spreadsheet every week", "what did you check this morning, in what order, and what were you afraid of finding?", "what gets a record penalized on THIS channel and how do you find out today?"

## Pattern library (patterns to reference, not clone)

Archetypes worth stealing the *lesson* from — replace with the actual exemplars in your category, but keep the move:

- **The one-trusted-number tool** — beloved for a single trusted number (e.g. true net after every hidden cost), not ten panels; the "pays for itself in recovered money" framing is often the strongest business case in an ops category.
- **The connected-suite vs the tool-chain** — a suite where data flows between jobs with no manual exports wins; the counter-example is a set of named tools the user must chain to finish one job. Frame IA around recurring jobs (morning health check, pre-peak stock plan, monthly review), not data domains.
- **The managed-service exemplar** — a tool whose users forgive its UI because humans do the work and outcomes are visible. Validates a hybrid: managed surfaces show outcome and status ("what was done, what changed"); self-serve surfaces enable unassisted completion.
- **The triage-inbox exemplar** — a disposition lifecycle and a reachable empty state; sub-100ms feel and optimistic UI on daily-driver actions.
- **The calm-hierarchy exemplar** — hierarchy via typography, color only for state and action, overview as launchpad rather than encyclopedia.
- **The anti-pattern floor** — the incumbent everyone hates: click-taxes on routine tasks, fragmented views, redesigns that hide what one glance used to cover. "Better than [the incumbent]" is a floor, not a differentiator.

## Self-serve customer reality

Describe your self-serve population honestly: their tooling literacy, device context, budget, and dependence. What their native tools give them vs the gap you fill. Their documented top pains. For anything a self-serve customer touches, the discovery question is time-to-first-value: what does the customer see in the first unassisted session, on their primary device, that proves value inside the trial window?

## The client-reporting job

Poor reporting is a top churn driver in agency/managed models. Client-facing surfaces are designed for the retention conversation, not data completeness: a 3–5 sentence executive summary a non-analyst understands, one win + one risk + one recommended next move, metrics tied to the account's goal (not raw channel metrics), underperformance shown honestly with a recovery plan, and the work made visible. Ask: "What does the advisor say in the monthly review meeting, and what's on the slide?"

## Metric hierarchy for analytics asks

(1) health numbers — is the account OK; (2) diagnostic numbers — why not; (3) actionable numbers — what can be moved this week. A screen should know which tier it serves; mixing tiers is the smell behind "we need a dashboard" requests — reframe to the Tuesday-morning decision it's for, and for which persona.
