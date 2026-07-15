# Design Judgment — ops-tool taste

Rules for flows, IA, and interaction design. Each carries its why, so it can be applied to unseen cases — and each can reject a design.

## Classify every screen by cognitive mode

**MONITOR** (glanceable, peripheral, exception-first) / **SCAN** (dense, tabular, keyboard-first — sweeping many accounts at once) / **DECIDE** (one decision, full evidence, action + preview). Density, chart choice, and interaction style follow the mode — never a global "dense vs airy" aesthetic. A screen mixing modes is a flag: split it or pick.

## The decision test, per element

For every metric, chart, column, panel: **who looks at it, what decision does it change, what action follows, what breaks if we cut it.** No decision changed → cut. A screen whose only exit is "now they know" must justify itself as genuine monitoring. Every screen names its **exit action** — what the user does next from here.

## Queues must be completable

Any "needs attention" surface specifies: entry condition, the full disposition set (act / delegate / snooze / dismiss), where each disposition sends the item, and the designed empty state. An item that can't leave the queue makes it a dashboard in disguise — operators learn to ignore it within weeks, and real exceptions die there. Design the re-entry experience: what does it show tomorrow, and after a week away?

## Alerts

Per trigger: maps to user-visible business damage (lost sales, penalty, angry customer — not internal state); the receiver can act on it now; it has a clear/decay lifecycle (an issue clears when its signal clears); expected volume per operator per day is estimated and capped. Ration surfaced insights — a feed that scrolls is a feed that's ignored; if everything is an insight, nothing is. An insight = a change + a cause hypothesis + an implied action, in business language. A trend chart is not an insight.

## Recommendations five-pack

Any "the platform suggests X" specifies: (1) the one-line why, inline; (2) deeper rationale on demand; (3) impact preview before commit (what changes, on which records, expected effect); (4) undo/rollback; (5) a dismissal path and what dismissal signals. Experts distrust unexplained automation most — the operator needs the evidence chain; the self-serve customer needs guardrails against over-trust (conservative defaults, confidence framing).

## Dual audience

For a feature touching more than one persona, fill the matrix: persona × vocabulary, density, default view, forbidden jargon. One shared metric model underneath — any number visible to both an operator and their customer must be byte-identical (see principle 7). Never ship the operator's screen to a customer with columns hidden and softer colors; the altitude, not the styling, is what's wrong.

## Progressive disclosure

Layer 1 = the decision and its action; layer 2 = supporting evidence on demand; layer 3 = raw data / audit. The asymmetry rule: an expert may pay one extra click; a novice may never pay comprehension.

## Click economics

List the persona's top 5 daily tasks; count interactions to complete each in the proposed design. A daily task costing more than ~2 navigations is a defect. Anything done 10+ times a day earns a keyboard shortcut and optimistic UI. Never split what one glance used to cover into tabs to look cleaner — click-taxing routine tasks is what operators actually rage about.

## Opinionation probe

Every setting, view toggle, or "let the user choose" is an unmade decision shipped to the user. Ask "what is the one right way for this role?" and hard-code it; record the opinion as a design decision so the default is deliberate. Any **persistent global state** (sticky filters, saved views) must answer: how does the user discover it's active, how do they clear it in one action, and what happens on surfaces that don't honor it?

## Visual grammar

Hierarchy through type scale and spacing; color reserved for state and primary actions. Cross-account or cross-channel comparisons default to small multiples with identical axes; a trend-bearing number in a table row gets an inline sparkline. Every decorative element names the data it encodes, or goes. A screen where everything is emphasized means no hierarchy decision was made.

## States are design, not QA

Empty (a new customer with three records must not see a broken-feeling product), loading, error with recovery, and the domain's real edge cases first: stale syncs, partial channel data, shared/alias accounts, "not supported on this channel" as an explicit state (never a zero or blank — fabricated certainty poisons every other number on the screen).

## Traceability

Every screen, flow, and IA choice cites an evidence item or opportunity — or is labeled **convention** (follows an existing product pattern; name the pattern) or **invention** (a bet; justify inline). New patterns require a stated failure of existing ones. Codebase pattern-matching happens here, in design — never during exploration or ideation.
