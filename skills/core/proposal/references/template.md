# Proposal: [problem-first title]

Name the problem or opportunity, not the solution. "X loss surfaces too late," not "X monitor." Keep the filled proposal to 2 pages. The examples under each section come from different cases — problems and opportunities — to show the range a good answer can take. They use generic channel/integration language; swap in your product's real nouns.

Requester fills sections 1–6. Product fills the decisions at the bottom. For AI help, use the `/proposal` skill: it interviews you, then writes the proposal from your answers.

## 1. The problem or opportunity

Frame the gap between where the user is and where they could be. Two shapes are valid. A **problem** is something going wrong now: name what it costs and through what mechanism, and don't write "we don't have [tool]." An **opportunity** is revenue not yet captured: name the upside and back it with evidence the demand is real and capturable, not an "imagine if." Either way, locate where the cost or value actually lives.

Examples:
- **Margin (problem):** an account's top item on a channel shows as its strongest product, but once commission, fulfillment, returns and the ad spend defending its rank are counted it sells at a loss, and the better it performs the more it loses. The cost is units sold confidently at a loss, not a missing margin report.
- **New channel (opportunity):** two accounts sell out their fast movers on their main channel every month, and comparable operators already turn the same items over on a second channel, yet we've never listed them there. The value is demand we can see in comparable operators and aren't capturing, not "we should be on channel B."
- **Promotion overlap (problem):** accounts run promotions on three channels on separate calendars, and when they overlap the discounts stack into sales below margin nobody decided to make. The cost is margin given away in unplanned overlaps, not "we don't see promotions in one place."

## 2. Who it affects, and when

Whose work does this change (usually a {{PRIMARY_USER}}), or who gains? At what exact moment does the problem bite or the opportunity pay off?

Examples:
- **Margin:** the {{PRIMARY_USER}}, at the moment they approve a price that looks profitable on the listing but isn't.
- **Replenishment:** the {{PRIMARY_USER}} and the account together, at the point channel stock runs low and neither clearly owns the next step.
- **Suspension:** the account, the moment a listing is suppressed and its sales route elsewhere before anyone notices.

## 3. How often, how big, and where it comes from

Frequency (times last month), breadth (how many accounts), cost or upside per occurrence. And the source: your own ops experience, one client asking, or a pattern you've seen across accounts. This is what we use to decide how much time it's worth.

Examples:
- **Promotion overlap:** hit 4 accounts last quarter; one overlap sold a week below margin. From reconciling invoices, not a complaint.
- **New channel:** 6 accounts have fast movers that sell on comparable operators' second-channel listings. A rough read is a meaningful slice of their main-channel volume left on the table. A pattern across the portfolio.
- **Partial acceptance:** most weeks at least one account gets a partial order acceptance from a channel, and the cancelled units are revenue we'd planned for. From my own ops work.

## 4. Non-obvious context

The domain knowledge an engineer cannot Google. Channel mechanics, penalties, thresholds, edge cases that shape this. Be specific. If you're unsure of a number or rule, write "I think"; don't state it as fact.

Examples:
- **Parity:** channels can suppress your offer if the same product is cheaper elsewhere, so a discount on one channel can quietly knock the account off another channel's featured placement. I think it's price-parity logic but I'm not certain of the exact trigger.
- **Fulfillment pools:** stock held in one channel's fulfillment program is that channel's to fulfill and won't cover another channel's orders, so an account can read as in stock overall and still stock out on a specific channel.
- **Returns:** on some channels a returned item comes back unsellable and the seller still absorbs the return shipping, so a returns spike costs more than the refunded revenue.

## 5. What "better" looks like

The outcome, not the feature. Higher placement time, fewer stock-outs, revenue captured on a new channel — not "a new screen." Then mark one: **measurable now / measurable later / judgment bet**. And name one signal you could watch starting now.

Examples:
- **Margin:** users stop approving below-margin prices, so true net margin per active item rises. Measurable now once we compute the real cost stack; watch the count of items selling below margin.
- **New channel:** incremental revenue from the new channel without cannibalizing the main one. Measurable later, and a judgment bet on cannibalization; watch new-channel orders that aren't substitutes for existing ones.
- **Replenishment:** fewer stock-out days per account. Measurable now; watch days-out-of-stock before and after.

## 6. Has this been tried without software?

SOP, checklist, process change, AI, or an existing tool or partner. What was tried, what happened, and why a process can't solve it. If it hasn't been tried, say so.

Examples:
- **Margin:** we keep margin in a per-account spreadsheet. It goes stale the moment fees or ad spend change, and nobody checks it before pricing. The number has to be live at the moment of the decision, which a spreadsheet isn't.
- **New channel:** not tried. The first question is whether the unit economics work on channel B at all, which is a call before any build.
- **Promotion overlap:** we asked the team to log promotions in a shared sheet. They forget under load, and the sheet doesn't catch an overlap until after the discounted sales have happened.

---

*Below filled by Product.*

## Gate 1 — Worth shaping?

Appetite set here, jointly: how much time we're willing to spend if we do this. Then decide — and whatever the decision, the author hears the reason. A "not now" archives the proposal here (no tracking ticket) and lands as a `not now (Gate 1)` row in `DECISIONS.md` with its reopens-when condition; re-raising it takes one new piece of evidence.

- **Strategy bet:** (which current bet — from the live strategy pages — this advances, or "maintenance"/"none")
- **Appetite:**
- **Decision:** shape now / send back for more / not now
- **Reason:**
- **Reopens when:** (for not now / send back)

## Scope (after shaping)

What ships, what's explicitly out, rough estimate. Product's call, produced during shaping. The build/kill verdict itself lands at the discovery's Checkpoint 1 and is recorded in `DECISIONS.md`.

- **What ships:**
- **Out of scope:**
- **Estimate:**
