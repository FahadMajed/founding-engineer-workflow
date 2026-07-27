---
name: design-critique
description: Structured critique in two modes — discovery mode for UX discovery documents (run by a fresh-context agent as the ux-discovery critique gate), visual mode for rendered UI, mockups, and React components.
---

# Design Critique

Two modes. Pick by artifact: a discovery/design **document** → discovery mode; a rendered **screen/mockup/component** → visual mode.

Both modes follow the same admissibility ordering — **describe, then analyze, then judge**. Judgment vocabulary ("clean", "intuitive", "confusing") is inadmissible until you've described the mechanism that produces it.

## Discovery mode

Run with fresh context — never the authoring conversation. Inputs: the artifacts handed to you (typically `requester-input.md` + `00-framing.md` + `03-synthesis.md` + `04-design.md`, or a final `DISCOVERY.md` / `DISCOVERY-LITE.md`) plus the canonical shared context, which is required reading, not contamination: under `../../core/ux-discovery/references/` read `product-context.md` (personas, principles), `design-judgment.md`, `domain.md`, and `view-archetypes.md`. Rubric items that test a field living only in an artifact you weren't given are skipped, stated as skipped — not reported as missing.

**Your brief is adversarial toward the recommendation, not the requester:** build the strongest case that the problem isn't worth solving, the evidence is misread, or the chosen direction is wrong — then report what survives that case as honestly as what doesn't. The rubric below is your instrument set, not your deliverable.

Output findings as defects with severity (critical / major / minor), each with the evidence quoted and what it breaks for whom. **No verdicts** — no "ready for implementation", no "proceed"; readiness is the requester's call. **No quotas either:** a finding that wouldn't change the design if true is noise, and padding to look thorough is itself a defect — a short list of real findings beats three decorated ones.

**1. DESCRIBE** — before any evaluation, write down what the proposed design makes each persona actually do: the steps, the reading load, the decisions per screen, what they see first, how they leave. If you can't reconstruct the user's path from the doc, that's finding #1.

**2. ANALYZE** against each test:

- **Problem framing:** passes the binary test (names a role, a concrete moment, a cost — zero UI nouns)? Rests on cited incidents with tiers and provenance, or on assertion?
- **Evidence honesty:** are tiers stamped and consequential (assumed load-bearing claims carry a test or recorded bet)? Any external claim without a source? Any invented precision — formulas, thresholds, or targets with no rationale at the actual scale (real team size, real account count)? When `requester-input.md` is among the inputs, spot-check 2–3 load-bearing claims against the verbatim answers: tier inflation, a dropped hedge ("I think" becoming fact), or a customer-proxy answer recorded as customer evidence are each a major defect.
- **Gate honesty:** the gate tick blocks live at the end of the artifacts (Gate F in `00-framing.md`, Gate I in `03-synthesis.md`, Gate D in `04-design.md`, the tier check atop `DISCOVERY-LITE.md`) — spot-check two ticks against the lines they point to; a tick whose pointer doesn't hold is a major defect. A tripped lite escalation trigger without a recorded override is a **critical finding that blocks presenting**: the authoring session must escalate or record the override before continuing (readiness stays the requester's call — this is a defect report, not a verdict).
- **Verdict integrity:** was not-building / shrinking / solving-another-way genuinely considered, or does the doc design exactly what was asked with rationale decorating it? Does the discovery delta say what changed and why? When `00-framing.md` is among the inputs, check the mechanism chain against the verdict: a chain whose targeted rung is a habit or a process gap answered with a build verdict — or a rung marked `[UNVERIFIED]` reasoned from as if established — is a major defect, because the design is then solving a layer the evidence never reached.
- **Role disposal:** every persona explicitly disposed (designed-for / out-of-scope-because / degraded-accepted / N/A)? Shared surfaces checked for the non-primary roles who will see them?
- **Self-consistency:** does the design honor the doc's own problem filter and the product principles — or violate them silently? (A principle deviation is fine argued, a defect silent.) Do mechanisms contradict stated stances (e.g. "no thresholds" plus a trend-drop detector)?
- **Design judgment** (per `design-judgment.md` from the required reading): decision test per Primary element; queue completability; alert lifecycle and volume; recommendation five-pack; dual-audience altitude and metric identity; click economics on daily tasks; states designed (empty, re-entry, domain edge cases); "not supported on this channel" honest?
- **Coverage derivation:** view candidates derived and dispositioned per `view-archetypes.md` (a missing disposition is the defect, not a missing view)? Surface map present — every existing screen dispositioned against the capability? Rabbit holes named and each patched / cut / spiked — an under-specified piece with no disposition is where the build will improvise?
- **Domain claims:** any account model, settlement mechanic, or policy distinction the design leans on that cites neither `domain.md`, backend entities, nor a requester answer is a major defect — asserted domain structure is how designs get built on false premises.
- **Domain checks** (per `domain.md` from the required reading): peak/calendar stress test on trends and stock math; primary-language layout and copy; per-channel semantics not flattened into a generic abstraction; every action the design implies either sits inside the envelope `domain.md`'s automation frontier currently states, or names its human handoff.
- **Falsifiability:** do key bets carry "we're wrong if…" lines pointing at watched signals? Steelman check (needs synthesis or the final doc among inputs): is the strongest rejected alternative represented in its own best form, or a weakened restatement? When a final document (`DISCOVERY.md` or `DISCOVERY-LITE.md`) is among the inputs, also check: metrics ("How we'll know it worked" in lite) carry number + baseline + source + first check date; the discovery delta is stated; the open-questions ledger is complete (every question answered / deferred / assumed — no Primary element depending on an unanswered one).

**3. JUDGE** — rank findings by severity, each tied to what it breaks for whom. Separate "fix before build" from "carry as open question".

## Visual mode

For rendered UI, mockups, HTML previews, React components.

1. **First impression (2 seconds):** what draws the eye first — is that the right thing? Is the purpose immediately clear?
2. **Usability:** can the user accomplish the goal? Unnecessary steps? Interactive elements obvious?
3. **Hierarchy:** clear reading order; the right elements emphasized; whitespace and typography doing the work (color reserved for state and action).
4. **Consistency:** follows the design system; spacing/colors/type consistent; similar elements behave similarly.
5. **Accessibility & i18n:** contrast, touch targets, readability — and RTL/localization: does the layout survive text expansion, do numerals and directionality behave?
6. **States:** empty, loading, error, and the domain's real edge cases — not just the populated happy path.

## Giving feedback (both modes)

- Be specific: "the CTA competes with the navigation", not "the layout is confusing".
- Explain the mechanism: connect each finding to a principle or a user cost.
- Propose the alternative, not just the objection.
- Acknowledge what works — findings land better beside named strengths.
- Match the stage: early exploration gets direction-level feedback, final polish gets detail-level.
- **A finding is a class, not an instance.** When you find a defect in one place, sweep the artifact (or the rendered feature) for its siblings before reporting — one entry naming the class and listing every instance found beats N duplicate findings, and a class reported as a one-off gets fixed as a one-off.
