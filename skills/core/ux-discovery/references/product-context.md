# Product Context — business, personas, principles

Read this before any discovery work (full or lite). It is the shared, canonical context — personas and principles are quoted from here, never improvised.

**Customize this section for your product.** The blocks below are fill-in-the-blank templates. Replace every `{{PLACEHOLDER}}` with your own reality. Keep the *structure* — the enumerated personas, the reject-a-design principles, the live-fetch discipline — because the rest of the toolchain cites it.

## The business

```
**Product:** {{YOUR_PRODUCT_DESCRIPTION}}

**What we do:** {{CORE_CAPABILITIES}}
**What we don't do:** {{SCOPE_BOUNDARIES}}

**Current reality:** {{TEAM_SIZE}} operating {{ACCOUNT_COUNT}} accounts on {{CONSTRAINTS}}; the path to scale is {{HOW_YOU_SCALE}}.
```

**Automation reality:** what the system can execute is stated in one place — `domain.md`, automation frontier — and designs are checked against it, never against assumption. A design that implies an action outside that envelope misrepresents the work.

## Platform vision

```
{{YOUR_PLATFORM_VISION}} — one sentence naming what the user sees, what the platform handles for them, and who it serves.
```

## Strategy — live, never from memory

The company's current bets live in a source updated as the direction moves — quote it, don't recall it:

```
{{YOUR_STRATEGY_SOURCE}} — where the current business and product bets are written down (a live doc, a wiki page, a tracker). Fetch it; a baked copy or the model's recollection is stale by definition.
```

**When:** at framing/verdict time and at proposal Gate 1 — every ask answers "which strategy bet does this advance, or is it maintenance?", with "none" admissible and verdict-shaping. This is what keeps sizing arithmetic (frequency × breadth × cost) from letting the frequent-and-visible always beat the strategic-and-quiet. No phase guard: strategy is what we're betting, not what's built — it can't anchor solutions.

## Product overview — live, never from memory

What the platform currently does — surfaces, modules, their state — changes constantly; a baked copy or the model's recollection is stale by definition. Fetch it live when a phase needs it:

```
{{YOUR_PRODUCT_OVERVIEW_SOURCE}} — where the current surface/module inventory lives.
```

**When:** at the design phase (pattern-matching against what exists), at intake when an ask references a surface you don't know, or in `/ux-touch`. **Never during exploration or ideation** — what's built anchors what could be, the same rule that keeps the codebase out of those phases.

## Personas — the defined set

**Customize these personas for your product.** Name the fixed set your product serves and never substitute ad-hoc user lists. Every discovery names which of these it serves and disposes of the rest explicitly (designed-for / out of scope because / degraded-and-accepted / N/A). The four below are a common shape for an operator-tool with internal staff plus self-serve customers — adjust the count and the roles to your reality.

### {{PRIMARY_USER}} — power operator (internal)
- Runs a portfolio of accounts. Analytical, efficiency-focused, operational.
- Key question: **"What needs my attention today?"** — issues, pending tasks, blocked items.
- Daily power use, many accounts in parallel. High density tolerance, filters, keyboard.
- Frustrations: slow workflows, buried information, manual work that could be automated.
- The platform should handle busy work, surface what needs action, make operations fast.

### {{SECONDARY_USER}} — strategic advisor (internal)
- Strategic advisor; fewer accounts, deeper engagement, client-facing. Consumes data more than manages it.
- Key question: **"What did we do this month?"** — one-click wins, growth, AND issues resolved.
- Reviews performance periodically, prepares recommendations, presents to stakeholders.
- Frustrations: scattered data, no consolidated story, hard to quantify impact.
- The platform should surface opportunities, tell the story, arm the periodic review.

### {{SELF_SERVE_USER}} — self-serve customer
- Runs their own account — the same operator job as the internal operator, for one account. Any role on their side: owner, manager, staff, a hired freelancer. One login ≠ one persona — who's behind it shifts skill level and how much the UI must explain itself.
- Likely lower tooling literacy, {{DEVICE_CONTEXT}} (e.g. mobile-first), comparing you against many alternatives, able to churn within the trial window.
- Key question: **"How am I doing, and what should I fix or push next?"**
- The platform should give them the same surfaced-action experience an internal operator gets, in plain language, assuming no employee of yours in the loop.

### {{VIEWER_USER}} — read-mostly stakeholder
- An account you manage, logging in to see performance and what was done — mostly viewing, sometimes acting on what they see.
- Business owner, not analyst. Wants answers, not data.
- Key questions: **"Is my business growing?"** and **"What should I focus on?"**
- Client-facing surfaces serve the retention conversation: what was done, one win, one risk, one recommended next move — numbers tied to the account's goal, underperformance shown honestly with a plan.

## Product principles

Each principle earns its place by being able to reject a design. Every discovery engages each one: adopt, or argue the exception in writing — silent deviation is a defect. The disposition lands as a table in the design artifact (principle → adopted / exception + argument) and carries into the final document's design-decisions section.

**Customize the principles for your product** — the reject-a-design test is the method; the specific opinions below are a starting set to replace with your own.

1. **Act, don't announce — sacrifices cheap read-only builds.** Don't just report a problem, design the action that resolves it. When the action can't be in-system (see automation reality), design the handoff to the human fix — who's alerted, where they act, how the fix is confirmed.
2. **Surface exceptions, not inventories — sacrifices completeness.** Summarize-and-suppress the healthy majority ("19 accounts healthy" is one line, not 19 rows). A screen the user must remember to check is a design debt.
3. **Design for the power scanner on shared surfaces; degrade gracefully to the occasional user — sacrifices per-account richness on shared screens.** Same data, different altitude per persona; never the operator's screen with columns hidden.
4. **Growth command center, not stress dashboard — sacrifices alarm-only v1s.** Wins, recoveries, and opportunities are first-class signals, not decoration; they feed the advisor's story and the customer's motivation.
5. **One opinionated default over configurability — sacrifices flexibility.** A setting is an unmade decision shipped to the user. Ask "what is the one right way for this role?" and hard-code it.
6. **Prefer UX over code simplicity; UX first, technology later.** Auto-sync after connection beats manual import even when the code is harder.
7. **Same number everywhere — sacrifices per-view convenience.** Any metric visible to two roles computes identically; drift surfaces mid client conversation and destroys trust faster than any layout flaw.

## Domain concepts

```
{{KEY_DOMAIN_TERMS}} — the nouns your product is built around (the entities, their relationships, the units you report on). Define them once here so every discovery uses the same vocabulary.
```

## Setting

Professional, utilitarian tool for running accounts: denser for power-user operators, plainer for self-serve customers and viewers. High stakes — decisions made here move real businesses.
