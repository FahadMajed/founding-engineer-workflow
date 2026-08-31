# Framing — problem, outcome, verdict

## Two valid shapes

Matches the proposal template (`{{root}}/.claude/skills/proposal/references/template.md`):

- **A problem** is damage accumulating now: name what it costs and through what mechanism. The lazy version is "we don't have [tool]".
- **An opportunity** is value not yet captured: name the upside and the signal that demand is real and capturable (the records already exist on another channel, a comparable account does it there, the category is growing on the target channel) — never an asserted "imagine if".

Cost or value lives somewhere specific: a time gap, a number a decision trusts that is wrong, a seam between two owners, a rare high-severity event, a capacity ceiling, a counterfactual, a moment of perception. If the framing could be reused for a different feature by swapping nouns, it's too generic.

## The binary test

Run before every checkpoint, aloud: the statement names **(a)** a role or person, **(b)** a concrete moment where it bites or pays off, **(c)** the cost or forgone value — and contains **zero UI nouns** (page, screen, dashboard, view, filter, column, alert, "single place"). Any UI noun = FAIL, rewrite.

BAD: "Users need to filter Overview and Products by category and tier… there's no way to quickly select all accounts under an organization."
GOOD: "The channel treats a PO acknowledgement as a full replacement of the whole PO and implicitly rejects any line it doesn't see; last month an account lost the unacknowledged units' revenue without anyone deciding to."
The delta: the GOOD version survives deleting the feature entirely — it describes the world, not the backlog.

BAD: "Operators have no single place to see listing issues."
GOOD: "A channel listing rejection surfaces days later through a customer message; by then the product has been unsellable through its peak week."
The delta: mechanism, actor, and accumulated cost — a reader learns something true before any solution appears.

## Laddering solution-shaped requests

Requests arrive as attributes ("add a bulk price editor"). Record three rungs before ideation:
**ATTRIBUTE** (the request, verbatim) → **CONSEQUENCE** ("what did not having it cost, in the last concrete instance?") → **STAKE** ("what did that put at risk — the customer relationship, the sale, the margin?").
STAKE carries the felt cost beside the business cost when a quote supports it — trust burned mid-meeting, the client message the operator dreads — quoted or observed, never imagined; a felt stake with no quote behind it is a T5 assumption-map row, not a rung.
The problem statement is written at rungs 2–3. The request itself is parked as candidate #1, restated as a hypothesis, and must compete in ideation like any other concept.

## The mechanism chain — which rung the verdict targets

The ladder runs *upward* from the request to the stake. This runs *downward* from the incident: take the core incident and chain the mechanism one layer at a time — each rung answers "and what makes *that* happen?"

**The stopping rule is evidence, not a count.** Stop at the last rung a T1–T3 source supports; the first rung you can only guess at is written `[UNVERIFIED]` and becomes an assumption-map row, never a link you reason from. Two or three rungs is normal. A five-rung chain on a two-rung evidence base is fiction, and fiction at the bottom of the chain is what a verdict then gets built on.

Then name **which rung the verdict targets** — that choice *is* the verdict. One incident, three intervention points:

> "A channel listing rejection surfaces days later through a client message"
> ← nobody opens the channel's panel daily [T1, operator interview]
> ← listing status isn't synced into the system [T1, backend]
> ← the channel's status endpoint was never integrated [UNVERIFIED]

Target rung 1 → a checklist SOP ("solve another way"). Rung 2 → surface the status already synced ("build"). Rung 3 → a spike before anything ("probe first"). The chain doesn't pick for you; it makes the pick explicit and shows what the unpicked rungs would have cost.

Two failure modes to name: **forcing one line** when the incident has two independent causes — write both branches rather than picking the tidier one; and **chaining past the evidence to reach a rung you already wanted to build on**, which is the same defect as an uncited domain claim, wearing a causal costume.

## Outcome gate (before any ideation)

One sentence: **whose behavior changes, from what to what, observable how.** "Increase revenue" fails (not directly movable); "have a page for X" fails (an output). Then classify — measurable now / measurable later / judgment bet — and name one signal watchable starting today.

## Sizing

Who is affected × how often × cost per occurrence, using the real numbers ({{YOUR_TEAM_SIZE}}, {{YOUR_ACCOUNT_COUNT}}, the actual customer count). Frame value in {{YOUR_CURRENCY}} where possible — a preventable loss avoided, a suppressed record's daily revenue, a below-margin week — the "pays for itself" test. This feeds the verdict; a monthly-advisor feature and a daily-operator feature differ by orders of magnitude in reach.

## Assumption map

List the assumptions the direction depends on; place each on importance × evidence (use the tiers from `evidence.md`). Every important-but-weak assumption gets exactly one of:
- a cheap pre-build test — menu: desk/web check, ask the operators directly, a 5-day micro-diary ("did X happen today? which account? minutes lost?"), a one-account concierge run, a prototype walkthrough with 3 users, a prod query;
- or a written bet with its cost-of-being-wrong: if wrong, what breaks — pixels, workflow, money, trust? Would we detect it within a week, via which signal? Is rollback clean?

Phrase the single riskiest assumption as a test card: "We believe [assumption]. To verify we will [test]. We'll measure [signal]. We're right if [threshold]."

## Role disposal

Dispose of every persona (from `product-context.md`) at framing time — whose problem is this, who else is affected, and how: designed-for / affected-but-secondary [how] / out of scope because […] / N/A. This shapes the verdict: a feature "for operators" that changes a surface customers and viewers also see isn't only for operators. The surface-level content test (what each persona sees or misses) is re-run at the document stage per `document.md`.

## The verdict

Checkpoint 1 must end with one — aligned with the proposal's Gate 1:

- **Build** — evidence clears the bar and the outcome is worth the appetite.
- **Shrink** — the *requester* chooses to build only the evidenced kernel; you name what the full version would be and what falls away, they draw the line. Never pre-shrink the design yourself to fit appetite — design full, present, let them cut.
- **Probe first** — a specific cheap test, then re-decide. A Probe ships as a plan, not a wish: write `docs/discovery/{feature}/probe-plan.md` — the test card plus instrument, owner, sample, deadline, and threshold. Desk-shaped probes run before the session ends where the tools allow: a read-only prod query (`{{PROD_DB_RO}}`, per the backend repo's observability/call-api patterns), {{YOUR_ANALYTICS}}, {{YOUR_SOURCE_REVIEWS}}, task-tracker capture mining. Customer-facing probes take their instrument from `user-probes.md`. Anything not runnable now becomes a tracked task carrying the deadline — an open probe past its deadline is a defect the decision ledger makes visible.
- **Solve another way** — an SOP or process change, an existing tool or partner (an off-the-shelf system instead of building one), or the manual service doing it. If the ask reveals a company-direction call — a new capability, a fixed cost, a strategic line — say it belongs to the founders, not a feature pipeline.
- **Not now** — real, but the outcome doesn't justify the appetite. Say it plainly — and give it a door: name what would change the verdict (a threshold crossed, a second account hit, a probe result). The proposal stays archived in `docs/proposals/`; no tracking ticket. Re-raising requires at least one new piece of evidence, so persistence alone never beats evidence — and the requester hears the reason and the reopening condition, not just the no.

Recommending anything other than Build is a successful discovery outcome. Do not design a feature to be polite.

Every verdict is appended to `docs/proposals/DECISIONS.md` (date, ask, verdict, one-sentence reason, reopens-when, link) — the ledger every future intake checks so a returning ask starts from its prior verdict, not from scratch.

If no Gate 1 appetite exists (the shallow-ask path), propose one at Checkpoint 1 — hours / days / a cycle — and get it confirmed with the verdict; a verdict against an unstated appetite is unfalsifiable.

A Probe verdict has a re-entry path: the probe's result is appended to `requester-input.md` with its tier; if the signal clears the bar, the discovery re-enters at framing (not from scratch), citing the probe as the core evidence.

## Charter

The request is one hypothesis about a solution, not the problem. Restate the problem in your own words, without reference to the proposed solution, before evaluating it. When the evidence contradicts the requester's framing, say so and show the evidence. When they push back with domain knowledge you lack, update honestly — they know the domain; you supply the discipline.

## Gate F — do-confirm before Checkpoint 1

The ticked block is appended to the end of `00-framing.md` — gates live in the artifacts so the fresh critic can audit them. Each tick carries **a pointer to the artifact line that satisfies it** (quote or cite the `00-framing.md` section) — a bare tick is a claim, not a check:

- [ ] Problem/opportunity statement passes the binary test
- [ ] Core-claim gate met for its shape: problem → interrogated first-party T1–T3 incident; opportunity → T1–T2 demand signal — with provenance
- [ ] Evidence table complete: tier, provenance, sampling caveat, consequence per load-bearing claim; ledger checked (entries cited by ID, or "no prior evidence" stated)
- [ ] The requester's ask restated as a hypothesis, laddered to consequence and stake
- [ ] Mechanism chain written from the core incident, each rung tiered (stopped at the evidence, not padded); the targeted intervention rung named, and the verdict is the one that rung implies
- [ ] Outcome gate passed, with one watchable signal named
- [ ] Frequency × breadth × cost stated with real numbers
- [ ] All personas disposed
- [ ] Strategy line stated: which current bet (fetched live per `product-context.md`) this advances — or "maintenance"/"none", said plainly
- [ ] Verdict proposed with its reason and an appetite (proposed or inherited from Gate 1)
- [ ] Tier check: if the feature trips none of lite's escalation triggers, recommend downgrading to `/ux-discovery-lite` with the reason and record the requester's choice — full-pipeline burden on a lite-scale feature teaches people to stop invoking discovery at all
