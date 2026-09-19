# Evidence Discipline

A discovery is only as good as what it rests on. Every load-bearing claim gets a tier, and tiers carry consequences — a tag that changes nothing downstream is ritual.

## The ladder

Stamp claims as you collect them:

- **T1 OBSERVED** — someone watched it happen, or an artifact of the incident exists: screenshot, tracker ticket, message thread, channel notice, invoice, screen recording.
- **T2 RECORDED** — first-party data: a prod query, {{YOUR_ANALYTICS}}/{{YOUR_ERROR_MONITOR}}, a channel report about our accounts. A **cited** external source (channel policy pages, competitor docs, market reports) is **T2-LANDSCAPE**: it supports mechanism and market claims. A **problem's** core-claim gate it never satisfies — that takes something that happened to our accounts, customers, or staff; an **opportunity's** demand signal it can carry (a citable comparable, category growth on the target channel), since the value there hasn't happened to us yet by definition.
- **T3 RECOUNTED** — a firsthand story from the person it happened to, specific and dated ("[name], the [account] PO, two weeks ago"). Reached only after interrogation (below).
- **T4 REPORTED** — secondhand ("a customer told the operator…"), or an external claim without a source. Mark uncited external claims **[UNVERIFIED]**.
- **T5 ASSUMED** — opinion, inference, "would/should/probably". AI-generated user reasoning is always T5, labeled hypothesis. **Never invent evidence.**

At discovery stage, evidence is mostly external and testimonial — the web, the task tracker, channel docs, the requester's interrogated stories. That is expected and sufficient. Product-internal data (prod queries, analytics events) is corroboration when it's cheap, not a prerequisite. What is not acceptable: T4/T5 dressed as fact.

## Consequences

- The core claim's gate depends on its shape. A **problem** needs at least one interrogated first-party T1–T3 incident before framing completes. An **opportunity** needs at least one T1–T2 demand signal about our own accounts or a citable comparable (the records already exist on another channel; a comparable account does it there) — asserted upside without a signal is the same failure as a problem without an incident. If the gate can't be met, the verdict is **Probe** — the deliverable becomes the cheapest way to get one real data point, not a design.
- A design decision resting only on T4/T5 carries either a named cheap test or an explicit recorded bet with its cost-of-being-wrong (what breaks — pixels, workflow, money, trust; would we detect it within a week; is rollback clean).
- Numbers get provenance: source + date + scope ("prod DB, 2026-07-10, all accounts" / "[name], verbal, June"). An unprovenanced number becomes unfalsifiable folklore.
- Never write "operators / customers / clients want, feel, or would…" from model reasoning. Admissible user-claim forms: a quote (person, date), an artifact (ticket, thread, screenshot), recorded behavior (analytics, replay, prod data), or an interrogated firsthand story. Everything else is a labeled hypothesis routed to a test. Model knowledge of user psychology and channel mechanics is a prior, not a source.
- **Load-bearing sources are read raw, never through a summarizer.** A fetch tool that answers a prompt *about* a page returns a small model's paraphrase — that paraphrase is T4 even when the underlying source is T2. When a source will carry a decision (a policy page, a methodology, a spec), pull the actual text and quote from it; the artifact states which was done. Summarized fetches are fine for triage ("is this worth reading?"), never for the claim itself.
- External claims a decision rests on get a source URL or a verification pass (WebSearch/WebFetch) — distinguish "observed fact" from "plausible pattern I generated". When a web fact and the requester's local experience conflict, defer to the requester (global channel facts often don't hold for your specific market or channel) and note the conflict. Tiers rank provenance, not applicability — a T2-LANDSCAPE global source loses to a T3/T4 local account on how your channels actually behave; record both and the conflict.

## The ledger

Interrogated evidence outlives its discovery. Check `docs/discovery/evidence-ledger.md` at intake and cite entries by ID instead of re-eliciting them — asking the requester to re-tell a banked incident is a defect; when nothing relevant exists, the framing says "no prior evidence on X" plainly. Before the session ends, bank every newly interrogated claim into the ledger (observation + verbatim + tier + provenance + segment tag), consolidating onto an existing entry when it's the same fact recurring — recurrence across discoveries is signal the folders can't carry. Struggles distilled from evidence go to `docs/discovery/opportunities.md`; verdicts to `docs/proposals/DECISIONS.md`.

## Raw before cooked

When raw material exists (tickets, threads, exports, review dumps), elicit the requester's own read first — "what stood out to you in this?" — then present yours as a diff: what you add, what they saw that you missed, where you disagree. AI-only synthesis of user material drops a large share of the important detail (Torres's published experiments put it at 20–40%): synthesize one conversation at a time, immediately, never a bulk batch, and store verbatim quotes rather than paraphrase.

## Felt experience is evidence — at the tier it earns

What the moment felt like is a claim like any other, on the same ladder: an observed reaction (an angry voice note, a public review's own wording, hesitation in a walkthrough) is T1–T2; the person naming their own feeling, dated and specific, is T3; the requester's read of someone else's feeling is T4; a feeling produced by model reasoning is T5, labeled. Capture the reaction, not a diagnosis — the words used, the tone, what they lingered on or brushed past. Why it earns collection: reading emotional tone accurately is the one empathy measure shown to track finding important unmet needs (Li et al. 2022), while imagining a user's inner state without contact raises confidence, not accuracy (Eyal et al. 2018) — so a felt claim takes the same provenance as a number, and pays the same way.

BAD: "Customers feel anxious about pricing changes."
GOOD: "«the price changed and nobody told me?» — subscriber voice note in their own language, June, forwarded by the operator [T1]; the frustration is in their wording, not our read of it."

## The evidence table

Written into `00-framing.md`, one row per load-bearing claim: **claim → tier → provenance (source, date, scope) → sampling caveat → consequence** (VALIDATED: build on it / SUPPORTED: build + instrument / ASSUMED: named test or recorded bet). The sampling-caveat cell holds the correction that applies — base rate for ticket-derived claims, hat + proxy-check result for customer claims, per-link tiers for inference chains. An empty caveat cell means unchecked, and Gate F tests for it.

## Anecdote interrogation

Run on every anecdote; cap at ~3 follow-ups, bank the claim at the tier it earned, move on. (An interview that exhausts the requester produces vaguer answers, not better evidence.)

1. When did you last see this — this week, this month, longer?
2. Which account / customer / channel exactly — name it.
3. How many separate times in the last 4 weeks? (With an enumerable account population: "which of the accounts does this apply to?")
4. What did that specific instance cost — minutes, a lost sale, a penalty, an angry customer message?
5. What did that moment feel like — their words at the time (the voice note, the message), not a read after the fact?
6. Who else has hit this?

## Question craft (Mom Test)

Banned: "Would you use…", "Would this help…", "Do you like this idea?", "How often do you usually…", "What features do you want?" — hypotheticals invoke an idealized self that never shows up as an actual user; polite fiction in, confident fiction out.

Instead:
- "What happened recently that made you raise this **now**?" (every request has a firing event; the event is the evidence, the request is a hypothesis)
- "Walk me through the last time — which account, which day, what did you do next?"
- "What do you do today instead — spreadsheet, a chat thread, the portal, memory, nothing?" The workaround is the incumbent being fired; "nothing" means a weak push and predicts non-adoption.
- "What did that cost?"

Grade any expression of interest by what the speaker gave up: words < time (booked the walkthrough, sent the entries) < reputation (introduced a peer) < money/switching. Under courtesy-politeness norms, enthusiasm without sacrifice is T5 — the commitment ladder and its instruments live in `user-probes.md`.

## The requester's three hats

An internal requester speaks from three positions with different evidentiary weight. For each claim, establish the hat — never blend them in the doc:

- **(a) As user** — describing their own platform work. Strong evidence for operator-facing features; they ARE the audience.
- **(b) As customer proxy** — speaking for an account or customer. Mandatory follow-up: "Did the customer say or show this, or is it your read?" An inference recorded as customer evidence is laundering.
- **(c) As domain expert** — channel mechanics, penalties, thresholds. Strong, but verify numbers: "How do you know that threshold?" If they say "I think", record it as T4, not fact.

**Expertise calibration — platform power-use is not domain expertise.** A requester (or persona) who is a daily power user of the product can still be a non-expert in the specialty the feature serves, and the two get silently conflated. Probe it at interview: "Do you trust your own decisions in this area — when did one go wrong?" BAD: ideation cuts recommendations ("these operators know what to do") because the persona sheet says power users; the requester corrects that nobody on the team is an expert in the specialty — themselves included, and their own calls go wrong — reversing a core design cut after synthesis. GOOD: operator surfaces stay dense and keyboard-first (a power-use fact) while the feature assumes no specialist expertise and grades its own recommendations in public (an expertise fact); the two attributes are designed for separately.

Customer-facing claims aren't deadlocked on proxies. First-party customer evidence exists without interviews: {{YOUR_SOURCE_REVIEWS}} and ratings, subscriber support/message threads, {{YOUR_ANALYTICS}} funnels and drop-off on self-serve surfaces, trial-to-paid and churn queries. And customers can be asked directly — the deployable instruments (operator debrief protocol, micro-surveys, shadow sessions, switch interviews, prototype walkthroughs), with their ethics tiers and contact budget, live in `user-probes.md`. A Probe verdict on a customer claim names its instrument or source from there.

## Sampling corrections

- **Proxy distortion:** staff project power-user needs (density, bulk ops, shortcuts). For anything customer-facing ask: "How would a customer who opens this twice a month, on a phone, experience it?"
- **Survivorship:** tickets and complaints contain only users who noticed, cared, and stayed. State the base rate ("N complaints out of how many exposed?") and the absence question ("who hits this and never tells us — churned customers, silent workaround-builders?").
- **Availability:** the most vivid incident is not the most frequent or costly one. Frequency questions come before sizing.
- **Inference stacking:** "tickets are up → customers are confused → they need onboarding" is a chain; each link carries its own tier and the chain's confidence is its weakest link.
