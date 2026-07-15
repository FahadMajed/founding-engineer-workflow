# User Probes — hearing users who aren't in the room

Instruments for getting first-party evidence from customers and clients — the personas the internal proxy speaks *for* but is not. Every instrument here is deployable by a non-researcher over the channels that already exist ({{YOUR_MESSAGING_CHANNEL}}, a client call, a screen-share), in the customer's own language first.

**When to reach past the proxy:** any load-bearing claim about what a customer or client does, struggles with, or would adopt. The three-hats check in `evidence.md` catches proxy laundering; this file is what to do next. One real customer data point beats another hour of internal interrogation.

## Instrument rules (apply to everything below)

- **{{YOUR_PRIMARY_LANGUAGE}}-first, not translated-to-{{YOUR_PRIMARY_LANGUAGE}}.** Draft the instrument in the register the customer actually messages in; keep the English intent alongside for the record. Research run in a second language on first-language users returns vague, shallow answers.
- **Courtesy is not evidence.** Polite enthusiasm ("great", "amazing") approaches 100% regardless of truth — especially delivered to the person who owns the relationship. Count only what survives politeness: specific past events, observed behavior, and sacrifice (see the commitment ladder).
- **Never let the relationship owner ask the evaluative question.** A customer will not criticize their operator's work to that operator. Evaluative topics go through behavioral instruments (shadow session, replay, thread mining) or a different asker; the operator asks only about the customer's own operation.
- **Past events only.** Same Mom Test bans as `evidence.md`: no "would you use", no "do you like", no yes/no. Anchor every question to the last time something happened.
- **Voice notes welcome, and say so.** Customers answer richer by voice than typing; every messaging instrument ends with an explicit voice-note invitation.
- **Acquiescence runs high** (courtesy-norm effect): never signal which answer pleases you, never stack a suggestion inside a question, and offer an easy out ("no" is a useful answer — say that).

## The commitment ladder

Grade any expression of interest by what the speaker gave up, lowest to highest:
**words** (worthless alone) → **time** (booked the walkthrough, sent the diary entries, brought a colleague) → **reputation** (introduced another customer, championed internally) → **money/switching** (paid, upgraded, moved a workflow). A claim of demand cites its rung; below *time*, the verdict gate treats it as T5.

## The menu

### Operator debrief — instrument the proxy channel you can't eliminate
Within a day of any client call that touched the problem space, the operator answers five prompts (voice note fine, 2 minutes):
1. What did the client **say** — verbatim, in their own words kept as-is?
2. What did they **do or show** — behavior, artifacts, not opinion?
3. What did they **commit** to?
4. What **surprised** you?
5. What do **you think** it means? *(kept separate — this is the operator's read)*

Answers land in the evidence ledger with provenance labels: `[client-verbatim]`, `[client-behavior]`, `[client-commitment]`, `[operator-interpretation]`. A problem statement resting solely on `[operator-interpretation]` hasn't met the customer yet.

### Messaging micro-survey — 1–3 questions, event-adjacent
Messaging-channel response rates run roughly double email's, and asking right after the relevant event lifts them further (published survey benchmarks — treat the exact figures as rough priors). Rules the generator must obey: **max 3 questions**; each past-behavior-anchored and open; sent personally by the operator (never a blast link); timed next to the triggering event ("saw your orders spiked last week —"); voice-note invitation; a thank-you close that promises what happens with the answer. At a small account population, 9 answers is a good yield — and enough, because the questions are qualitative.

### Shadow session — watch them work instead of collecting more testimony
30–45 minutes, screen-share or in person: "do your normal weekly price update while I watch." Apprentice mode — five canned probes only: *what just happened? · is it always like this? · what were you looking at there? · who taught you this? · what happens if you skip it?* Never demo, never correct, never defend the product. Debrief records observed steps, workarounds, and the gap between what they said earlier and what they did. Interviews structurally cannot surface this; 3–5 sessions per workflow is enough.

### Switch interview — on every churn, uninstall, or downgrade, no exceptions
At a small account population each loss is a large share of revenue and the single most information-dense event the company has; "interview 100% of losses" is a real policy here, not aspiration. Reach out fast (days, not weeks), 15 minutes, timeline of the actual decision: first thought → passive looking → active looking → the switch moment → first use of the alternative. Analyze with the four forces (push / pull / habit / anxiety). Never argue, never win-back mid-interview — the price of the truth is not trying to reverse it in the room.

### Prototype walkthrough — the preview.html earns its keep
15 minutes with one person of the target persona: hand them the preview and a real task ("find which account needs you today"), then silence. Record where they hesitate, what they say first, what they never notice. Never: a guided tour, "as you can see", or asking whether they like it. One walkthrough converts a stack of T5 design assumptions into T1 observations for the cost of a single message.

### Buy-a-feature — forced trade-off instead of importance ratings
Give the customer a constrained budget (100 units of {{YOUR_CURRENCY}} play money) across 5–8 candidate struggles priced by rough effort. The constraint defeats politeness — they cannot politely fund everything. One participant yields a full preference ordering, so 5–8 participants give a stable picture. Results rank opportunities for further discovery; they are not a build order.

### Concierge pilot — deliver the outcome manually before building it
If the business already runs a manual service, the upgrade is treating one manual delivery as an instrumented experiment. Pre-register before starting: the assumption under test, the artifact and cadence (e.g. a weekly restock note to 3 accounts), a per-delivery log (sent / opened / acted / asked for more), and a kill-or-build threshold with an end date ("if ≤1 of 3 accounts acts on it twice in 4 weeks, we don't build it"). A concierge without a threshold and end date is not an experiment — it's permanent unpaid ops.

### Disclosed wizard-of-oz — the button is real, a human is behind it
For testing "automated" flows before the automation exists. With paying clients and subscribers, disclosure is mandatory — a pilot line in the customer's language ("this service is in beta — our team runs it manually for now") plus an operator-hours budget stated up front so the wizardry's cost is visible. Undisclosed wizardry with internal operators is fine; they're teammates.

## Ethics tiers — hard gates by audience

- **Internal (operators/advisors):** any instrument, disclosed or not.
- **Managed clients & paying subscribers:** **no fake doors, ever** (demand tests need traffic volumes this population will never supply, and they're relationally corrosive with retainer clients — one disappointed champion costs more than the learning); wizard-of-oz only disclosed; every experiment names its trust cost before running.
- **Self-serve trial users:** fake-door-style demand tests only with a transparent post-click reveal ("coming soon — register your interest"), never in trust-critical flows (orders, payments), never twice to the same user.

## Sampling at this scale

- **5 per segment per round** finds most problems; it licenses nothing about demand — only commitments do.
- **Counts with names, never percentages, below n≈30.** "Two of the five customers" — not "40%".
- **Segments never pool:** internal-operator, managed client, self-serve customer are different populations seeing different products.
- **Contact budget:** at most one research ask per customer per ~3 weeks, tracked in `docs/discovery/contact-log.md` (customer/account, date, instrument, asked-by, responded?) — created on first use; check it before deploying any instrument, append after. Multiple instruments competing for a small population can burn its goodwill in a month.
- **Fight the friendly-five:** convenience sampling here means the 3–5 warmest relationships answer everything — a politeness-selected sample of satisfied accounts. Deliberately include a quiet account, a small one, and (via switch interviews) the ones who left.
- **Close every loop.** Acknowledge every response; when their input shaped something, tell them. An unanswered ask teaches customers that responding is pointless, and the channel dies.
