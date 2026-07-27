# Ideation — divergence that isn't cosmetic

Parallel agents that differ only by a lens name converge: same inputs produce the same conclusions, which synthesis then misreads as independent validation. Real divergence requires **different information, different objectives, different constraints**.

## Exploration output: facts vs bets

`01-exploration.md` has two sections with different audiences:

- **FACTS** — verified landscape observations, user context, per-channel constraints, anti-patterns observed elsewhere, the action envelope (what the system can execute today). Every FACTS entry — user context included — carries its tier stamp; T4/T5 items either stay out or sit under an explicit **HYPOTHESES (unverified)** subheading inside the packet. A FACTS line without a tier is a BET wearing a FACTS costume. This is what ideation agents receive.
- **BETS** — your own design convictions, pattern preferences, "high-conviction" directions. Withheld from ideation agents; handed only to synthesis. Any conviction that leaks into FACTS pre-decides ideation and manufactures consensus.

During exploration: search the web, interrogate the domain, mine the proposal — but do **not** look at existing implementations, because they anchor concepts to what's already built: not just source files, but the running app, past PRs, and UI screenshots in tickets. The same mechanism is why other features' discovery folders stay closed. If feasibility genuinely blocks ideation, ask the requester. (Pattern-matching against the product belongs to the design phase.)

## The fan-out: 1 + 3 + 1 agents

Every agent gets a shared base — the problem statement, the outcome, the personas, and the FACTS section — never the requester's parked candidate, your leanings, or the BETS.

**One baseline agent** gets the shared base and nothing else: no objective, no constraint, full autonomy. Its concept is what the inputs naturally produce — the default the diversified agents must beat. It is maximally seeded by construction, so convergence with it is zero signal; its role in synthesis is incumbent, not voter (see synthesis rules).

The three diversified agents each differ on two axes, always:

1. **Objective to maximize** — pick per feature from: operator minutes saved per week; self-serve customer unassisted success (no employee in the loop); client trust and retention; business margin.
2. **One hard constraint** — the three constraints are **mutually exclusive**, each closing off another agent's solution space: e.g. "no new screens; extend existing surfaces only" / "must work for an occasional, phone-first user" / "zero backend changes". **At least one agent is barred from the requester's parked candidate**: name the banned solution explicitly in that agent's prompt ("the obvious solution is X; you may not propose X or a variant"). Altitude is a valid constraint axis: barring an agent from the evidence's granularity ("you may not organize the surface around individual transactions") forces the portfolio-level concept the data's vocabulary hides.

A third axis applies when the evidence genuinely partitions — a multi-persona feature whose material splits into customer-side stories, operator incidents, and business/cost data: give each agent a different **evidence packet** from `requester-input.md` and the `00-framing.md` table, and note the partition in `01-exploration.md`. For a single-persona feature the material usually can't partition — all agents get the full FACTS and the constraints carry the divergence alone.

Plus one **kill-case agent**: argues from the actual evidence gaps and the four forces (habit + anxiety of switching vs push + pull) why this shouldn't be built, or should be solved without software. Give it the real gap list — a devil's advocate without ammunition produces discountable objections.

Each agent returns: the concept (**what the user does differently**, not a layout), the moment it serves, **the question the user arrives with and the organizing unit derived from that question** — not from the granularity the evidence happened to arrive in (the system stores transactions, feedback rows, order events; the user arrives asking "am I making money, by account?"), its key insight, what it deliberately cuts, its biggest risk, and **the situation in which this concept wins**. An alternative with no winning situation is a strawman — replace it, don't score it.

**Isolation is operational, not asserted:** each ideation agent is a real spawned subagent (Agent tool) whose prompt contains only the shared base plus its own packet — never run ideation inline in the authoring conversation, where your leanings leak by construction. Each `02-ideation/*.md` opens with the verbatim prompt the agent received (objective, constraint, packet manifest), so the isolation is auditable from the artifacts.

## Synthesis rules

- **A constraint is a divergence device, never a design ceiling.** When synthesis adopts a concept produced under a hard constraint (no dashboard, zero backend, no new screens), re-ask what the concept becomes with the constraint lifted — adopt the insight, not the handicap. BAD: Agent B was barred from dashboards, so the client's entire experience ships as a written summary with "no drill-down, the summary is terminal." GOOD: the summary's insight (annex the payout moment, deposit-first, loss-never-unexplained) survives as the narrative layer on a full client finance surface the constraint had merely hidden.
- **The baseline is the incumbent, not a voter.** The baseline agent's concept is the default to beat: a diversified concept is adopted only if it beats the baseline on the outcome, and if none does, adopt the baseline honestly — never pick a constraint-warped concept for looking clever. Convergence with the baseline is zero signal (it holds only the shared inputs; anything it produced is derivable from them).
- **Discount seeded convergence.** Ideas present in the shared FACTS — or matching the requester's parked candidate — don't count as agreement; only convergence on unseeded ideas is signal. Vocabulary seeds harder than ideas: the noun the FACTS use as the domain's primitive becomes every agent's organizing unit unless an axis diverges it.
- **Organizing-unit test.** For the winning concept: is the surface's spine the user's arrival question, or the data's primitive? The rationale: storage granularity reflects how data *arrives* (per event, per row, per channel) — an engineering fact; the user's question lives at the altitude of the decision they came to make. A screen shaped like the table makes the user do the aggregation in their head. BAD: a money surface that is a list of transactions viewed per channel per account; a feedback surface that is a feed of individual feedback rows. GOOD: accounts ranked by what they kept over the period, a transaction the drill-in evidence for one number; products ranked by rating damage, individual feedback entries the drill-in. The primitive-shaped spine must justify itself against the arrival question or lose — it wins only when the user's job genuinely is auditing individual records (a reconciliation clerk, an error queue).
- **Dispose of every concept explicitly**: adopted / absorbed into [what] / discarded because [why]. An idea that silently evaporates is the failure the discarded-ideas ledger exists to prevent.
- **Sacrifice something.** Name what the chosen direction refuses to graft from each losing concept, and the cost of that refusal. If every tension resolves to "both", the tension table was theater.
- **Test the key insight against the action envelope.** If the winning concept's core appeal is an action the system cannot execute today (see `domain.md`, automation frontier), the concept must either redesign around the human handoff or lose. Choosing a direction for an unbuildable property is a defect.
- **Abstraction skeptic pass.** For every interpretive layer a concept introduces (scores, verdicts, thresholds, roll-ups): what does the raw fact look like, and is the abstraction earning its calibration and trust costs?
- **Pre-mortem, three distinct narratives**: "It's 3 months post-launch and nobody uses this — the most plausible story is…" Each narrative names a different failure mechanism (adoption, trust, volume, wrong-problem).
- Techniques (How-Might-We, SCAMPER) only where a tension is genuinely unresolved — and every HMW raised must map to a named decision or carry into open questions. A technique section that restates conclusions gets deleted.

## Gate I — do-confirm before the design interview

The ticked block is appended to the end of `03-synthesis.md` — gates live in the artifacts so the fresh critic can audit them. Each tick carries **a pointer to the artifact line that satisfies it** — a bare tick is a claim, not a check:

- [ ] Agents ran as spawned subagents; each `02-ideation/*.md` opens with its verbatim prompt, and the objectives/constraints quoted there actually differ
- [ ] Baseline agent ran unconstrained; synthesis treated it as the incumbent to beat, not a vote
- [ ] Winning concept passed the organizing-unit test (spine = arrival question, not data primitive — or the match is justified)
- [ ] Kill-case argued with the real evidence gaps
- [ ] Every concept disposed of explicitly
- [ ] At least one named sacrifice with its cost
- [ ] Convergence discounted against the shared inputs
- [ ] Pre-mortem with three distinct failure narratives
