# Design Judgment — ops-tool taste

Rules for flows, IA, and interaction design. Each carries its why, so it can be applied to unseen cases — and each can reject a design.

## Design the full capability — scope is the requester's call, never yours

Design for the complete capability the problem deserves, at full ambition. Never trim, defer, or phase the design to fit an appetite or a cycle — "this is too much for this cycle, let's defer X", "we'll do Y later", "keep v1 small" in your own voice is the failure. Scope and what-defers is the requester's decision, made after they see the full design, in an explicit conversation — you present the whole thing and the trade-offs, they draw the line. Appetite sequences the *build* (which slice ships first), it never shrinks what the design proposes. A design already cut down to the cycle robs the requester of the decision that is theirs and ships a half-measure they never chose.

The one legitimate designer-side "sacrifice" is resolving a genuine design *tension* (two concepts can't both hold — name what you refuse to graft and its cost). That is not the same as dropping a capability to save time; the first is design judgment, the second is scope, and scope is not yours.

## "Out of scope" means the simplest exclusion

When the requester rules something out of scope, the design *excludes* it by the cheapest honest means — a filter, an omission, a hidden option — and moves on. It does not build a faithful representation of the excluded thing (an "honest empty state," a dedicated disabled treatment, per-component branching): out-of-scope means less work, and elaborate handling of an excluded case is the opposite. BAD: "this channel class is out of scope" → a status flag, a bespoke excluded-row, a recomputed aggregate around it. GOOD: the same verdict → the group filtered out of the page, one line of config. When the exclusion's premise might be temporary (the capability could exist later), exclude simply now and leave the door open in the contract — don't bake the absence in as a permanent truth.

## The specificity tension — stop and ask

Two failure modes bracket every instruction: too-specific makes you follow orders when a pivot is warranted; too-vague makes you fill the gap with an "industry best practice" that doesn't fit this product. When you feel that tension — the instruction underdetermines a choice that changes scope, capability, or user-visible behavior — stop and ask one line instead of pushing through. A wrong guess at a scope-shaped gap costs a rework round; the question costs a sentence.

## Honesty caps the claim, not the feature

When a value can't be known exactly at the grain the user asks for — a figure before its source finalizes, a metric mid-window — the honest answer is to show it as a labelled estimate that firms up later, not to disable the grain and caption why it's absent. A greyed control with a "can't be read at this grain" note removes a capability the user watched a competitor ship; the constraint bounds the *precision claim* (mark the estimate, reconcile it when the real number lands), never the capability. The tell: you're about to gate off a view in the name of honesty — first find the labelled-estimate path; only a value with no honest approximation at all stays out. A reviewer asking "why can't we have X — the competitor does" is usually naming a feature you disabled when you should have labelled.

## Classify every screen by cognitive mode

**MONITOR** (glanceable, peripheral, exception-first) / **SCAN** (dense, tabular, keyboard-first — sweeping many accounts at once) / **DECIDE** (one decision, full evidence, action + preview). Density, chart choice, and interaction style follow the mode — never a global "dense vs airy" aesthetic. A screen mixing modes is a flag: split it or pick.

## The decision test, per element

For every metric, chart, column, panel: **who looks at it, what decision does it change, what action follows, what breaks if we cut it.** No decision changed → cut. A screen whose only exit is "now they know" must justify itself as genuine monitoring. Every screen names its **exit action** — what the user does next from here.

## Queues must be completable

Any "needs attention" surface specifies: entry condition, the full disposition set (act / delegate / dismiss), where each disposition sends the item, and the designed empty state. An item that can't leave the queue makes it a dashboard in disguise — operators learn to ignore it within weeks, and real exceptions die there. Design the re-entry experience: what does it show tomorrow, and after a week away?

**Signals auto-resolve — the platform is not a task manager.** An attention item clears when its underlying signal clears (the next sync, the next state change), never by the operator marking it "done/fixed/handled" — manual resolution states belong to a task tracker, not the product surface. Valid operator inputs are classifications that encode domain knowledge the system can't infer (e.g. "this loss is intentional"), not workflow states. No snooze: an item that persists is still true; one that resolved disappears on its own.

**Attention surfaces aggregate to the unit the context calls for — never N raw per-item rows.** A portfolio surface rolls its items up to one row per the natural entity the operator acts on, with item-level detail inside the drill-in. The grouping unit is a design decision, not a constant: per account is common, but the right unit may be a shared parent and its aliases (one shared event, not N sibling rows), a channel, an organization, or whatever the surface's decision turns on. Pick the unit that matches how the operator triages there; the invariant is the roll-up, not any one entity.

## Alerts

Per trigger: maps to user-visible business damage (lost sales, penalty, angry customer — not internal state); the receiver can act on it now; it has a clear/decay lifecycle (an issue clears when its signal clears); expected volume per operator per day is estimated and capped. Ration surfaced insights — a feed that scrolls is a feed that's ignored; if everything is an insight, nothing is. An insight = a change + a cause hypothesis + an implied action, in business language. A trend chart is not an insight.

## Recommendations five-pack

Any "the platform suggests X" specifies: (1) the one-line why, inline; (2) deeper rationale on demand; (3) impact preview before commit (what changes, on which records, expected effect); (4) undo/rollback; (5) a dismissal path and what dismissal signals. Experts distrust unexplained automation most — the operator needs the evidence chain; the self-serve customer needs guardrails against over-trust (conservative defaults, confidence framing).

## Dual audience

For a feature touching more than one persona, fill the matrix: persona × vocabulary, density, default view, forbidden jargon. One shared metric model underneath — any number visible to both an operator and their customer must be byte-identical (see principle 7). Never ship the operator's screen to a customer with columns hidden and softer colors; the altitude, not the styling, is what's wrong.

**"Answers, not data" is hierarchy, not starvation.** The customer gets the answer first — then the evidence beneath it, tappable. Reducing a persona's surface to a single artifact (one paragraph, one card) under-serves them as surely as a 15-column grid does; a customer's summary page carries the headline number, where it went, and what drove it — answer-ordered.

**Every persona lives in the same responsive app.** There is no separate phone product: a customer's or client's surfaces are pages in the platform, designed to stack at 375px. Mockups and previews present them as app pages, never as phone-chassis artifacts.

## Progressive disclosure

Layer 1 = the decision and its action; layer 2 = supporting evidence on demand; layer 3 = raw data / audit. The asymmetry rule: an expert may pay one extra click; a novice may never pay comprehension.

## Click economics

List the persona's top 5 daily tasks; count interactions to complete each in the proposed design. A daily task costing more than ~2 navigations is a defect. Anything done 10+ times a day earns a keyboard shortcut and optimistic UI. Never split what one glance used to cover into tabs to look cleaner — click-taxing routine tasks is what operators actually rage about.

## Opinionation probe

Every setting, view toggle, or "let the user choose" is an unmade decision shipped to the user. Ask "what is the one right way for this role?" and hard-code it; record the opinion as a design decision so the default is deliberate. Any **persistent global state** (sticky filters, saved views) must answer: how does the user discover it's active, how do they clear it in one action, and what happens on surfaces that don't honor it?

## One datum, one place

A value appears once per screen, in its single most decision-useful form. The failure is parallel re-presentation: a labeled bar AND a legend AND a "where it went" list are the same groups three times; a hero figure that also reads as the bar's first segment and again as a "reached you" line is one number worn four ways. Before adding a component, ask "is this datum already on this screen?" — if yes, either replace the weaker representation or cut the new one. Repetition is not emphasis; it is indecision about which view earns the space. (Distinct from progressive disclosure, where a value is summarized then drilled — that is one value at two depths, not the same value beside itself.)

## A capability is a lens, not a parallel destination

A new capability is usually another way to look at entities the app already navigates — an account, a product, an order — not a new destination that re-lists them. Reach it through the entity (a dimension, a tab, a column), and reuse what exists: the entity's navigation, the global filter bar (scope / channel / date range), the existing list surface. The tells of the anti-pattern: a second entity list, a page-local date/period control that duplicates the global filter, a snapshot of another surface pasted in for context. Each is redundancy at the IA level, and it fragments the operator's mental model into parallel worlds of the same entities. A genuinely new surface is warranted only for something the existing entities can't express (e.g. a cross-entity aggregate) — and even then it shows the new thing, never a re-skin of the old.

## Lenses travel across altitudes

A lens that earns its place at one altitude — a vs-own-history drift card, a by-dimension breakdown toggle, a raw-records ledger — is considered at every altitude where the data composes: instance, entity, portfolio. Three axes: **scope** (aggregate by default, narrow by filter — an entity picker is never a gate to a question that exists at portfolio altitude), **time** (anything with a periodic stream compares to its own trailing baseline), **dimension** (aggregates decompose by channel/category with a toggle, reusing the house split pattern). The recursive rule that keeps rollups honest: **drift explains itself one level down** — an instance's driver is a line item, an entity's is a dimension or instance, a portfolio's is an entity — and that named driver is also the drill path. Boundaries: only composable metrics roll up (sums, weighted rates); instance-bound facts (a deposit, a receipt, a reconciliation stamp) stay at their instance — an aggregate shows *coverage* of them, never a pretend instance-level stamp; and shared parents (one account spanning several entities) must be attributed before aggregating or the rollup double-counts.

## Restructuring carries a parity manifest

When a surface is restructured — aggregated to a higher altitude, split, re-parented, or replaced by a richer component — its existing capabilities do not carry themselves. Before the change, enumerate what the old surface offered (columns, identity marks like entity refs, actions, exports, view switchers, lenses, drills, filters) and disposition each: **carried / adapted / dropped-because**. An undispositioned capability silently vanishes and is discovered by the user as a regression ("where did Export go?"). The manifest is a few lines in the round's notes, and the visual verify checks against it. The tell that you skipped it: a capability exists on one form of a surface (single-entity) and is absent on its sibling (aggregate) with no recorded reason.

## A dialog is never the only path to a class of facts

A dialog tells one instance's story; a table enables comparison across the class. The moment a fact shown per-instance in a modal matters across many instances — per-item economics, per-record status, per-order fees — it also needs a scannable class-level surface (a table, a column) or the user is forced through serial dialog-opening, which dies at real volume. The dialog stays as the drill-in narrative; the column is where comparison, sorting, and bulk action live. BAD: unit margin visible only by opening each item's receipt dialog. GOOD: an economics table with margin, floor price, and current price as columns — the receipt one click deeper.

## Distribution answers "how much of my X is…"

When the question is portfolio composition — how much of my catalog is healthy, how many records are compliant — the answer is a banded distribution (few named bands, reusing the house band vocabulary), not a scrollable ranked list. Weight by money, not only by count: a count histogram lies when ten items carry 90% of revenue — show both or lead with the money weighting. Each band is a filter: clicking it opens the class-level table scoped to that band (aggregate narrows by filter, again).

## Honor the global filters

Before adding any page-local filter, sort, or date/period control, check the app's global filter bar. If it already scopes account, channel, or time, the page consumes those — a local duplicate is a second source of truth the user must reconcile. Add page-local controls only for a dimension the global bar doesn't carry.

## Design for real data volume

Design every list surface for production volume, not the mock's handful. A list that will hold hundreds of rows (products, records, drivers, orders) needs pagination or virtualization, a total count, sort, and its loading/empty states — decided at design time. Mock brevity hides the need; the design doc names the volume each list must survive. **The volume to design for is the extreme account being signed, not the demo case** — and the test is on the *approach*, not just the list mechanics: a per-instance dialog flow, an item×period heatmap, a search-less picker may each be fine at 200 items and structurally wrong at thousands. At the extreme, glanceable aggregates (distributions, bands) replace enumeration; if a surface only works because the data is small, it's a different design, not a pagination task.

## Visual grammar

Hierarchy through type scale and spacing; color reserved for state and primary actions. Cross-account or cross-channel comparisons default to small multiples with identical axes; a trend-bearing number in a table row gets an inline sparkline. Every decorative element names the data it encodes, or goes. A screen where everything is emphasized means no hierarchy decision was made.

## States are design, not QA

Empty (a new customer with three records must not see a broken-feeling product), loading, error with recovery, and the domain's real edge cases first: stale syncs, partial channel data, shared/alias accounts, "not supported on this channel" as an explicit state (never a zero or blank — fabricated certainty poisons every other number on the screen).

## UX writing — design thinking never leaks into copy

Copy states what the user needs at that moment — a fact about their world and their next action — never the design's rationale, its mechanism narration, or its principle vocabulary. The tells: copy explaining how the system decides ("clears automatically when the next sync shows no issue"), copy defending a design choice ("below target is not a loss — we never show it as one"), meta-captions narrating rules ("no manual states — signals auto-resolve"). That text is the designer talking to the reviewer; it belongs in the design doc, not the screen.

BAD: "Repriced in-app — clears itself when the next cycle shows no loss."
GOOD: "Repriced yesterday — next cycle confirms."
BAD: "3 items below their target margin (still profitable) — below target ≠ loss, never shown to the client as one."
GOOD: "3 items below target margin — still profitable."

The boundary: information the user needs to *interpret or trust the number* is content (a reconciliation stamp, "same units sold" on a retrospective preview, a data-coverage note); information about *why the design is shaped this way* is leakage. Ask of every label and subline: does the reader act or interpret differently because of it? If not, delete it.

## Instance vs mechanism

When a design or demo shows a specific vivid example (a cost line that spiked ×4, one late order, one flagged item), ask: is the *example* the feature, or an *instance* of a general capability? Hardcoding the instance ships a demo that impresses once and a product that only handles the demoed case. The cost anomaly is one draw of "watch every cost line against its own history"; a single late-order alert is one draw of "SLA-breach detection." Model the mechanism (baseline → deviation → surface), let the vivid case fall out of it, and make a *second, different* instance visible so the generality is legible. A reviewer who says "you captured this in a hardcoded manner, not the bigger picture" is naming exactly this defect. **This applies to primary actions as much as data:** a CTA hardcoded to the vivid instance ("Dispute the storage weight") is the same sin as the hardcoded anomaly — the primary action is driven by what actually happened (the line that drifted, the state that changed). Stronger still: **a remediation named after the vivid instance must not be the primary CTA at all** — the primary is the general lever the operator always controls, and the instance-specific remediation is a secondary, clearly-a-suggestion chip. Making the label data-driven is not enough if the only rendered case is the one instance; the frontend must show the action *varying* across cases or the generality is invisible.

## Traceability

Every screen, flow, and IA choice cites an evidence item or opportunity — or is labeled **convention** (follows an existing product pattern; name the pattern) or **invention** (a bet; justify inline). New patterns require a stated failure of existing ones. Codebase pattern-matching happens here, in design — never during exploration or ideation.
