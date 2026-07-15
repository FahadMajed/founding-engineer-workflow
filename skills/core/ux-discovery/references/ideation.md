# Ideation — divergence that isn't cosmetic

Parallel agents that differ only by a lens name converge: same inputs produce the same conclusions, which synthesis then misreads as independent validation. Real divergence requires **different information, different objectives, different constraints**.

## Exploration output: facts vs bets

`01-exploration.md` has two sections with different audiences:

- **FACTS** — verified landscape observations, user context, per-channel constraints, anti-patterns observed elsewhere, the action envelope (what the system can execute today). Every FACTS entry — user context included — carries its tier stamp; T4/T5 items either stay out or sit under an explicit **HYPOTHESES (unverified)** subheading inside the packet. A FACTS line without a tier is a BET wearing a FACTS costume. This is what ideation agents receive.
- **BETS** — your own design convictions, pattern preferences, "high-conviction" directions. Withheld from ideation agents; handed only to synthesis. Any conviction that leaks into FACTS pre-decides ideation and manufactures consensus.

During exploration: search the web, interrogate the domain, mine the proposal — but do **not** look at existing implementations, because they anchor concepts to what's already built: not just source files, but the running app, past PRs, and UI screenshots in tickets. The same mechanism is why other features' discovery folders stay closed. If feasibility genuinely blocks ideation, ask the requester. (Pattern-matching against the product belongs to the design phase.)

## The fan-out: 3 + 1 agents

Every agent gets a shared base — the problem statement, the outcome, the personas, and the FACTS section — never the requester's parked candidate, your leanings, or the BETS. Then each differs on two axes, always:

1. **Objective to maximize** — pick per feature from: operator minutes saved per week; self-serve customer unassisted success (no employee in the loop); client trust and retention; business margin.
2. **One hard constraint** — the three constraints are **mutually exclusive**, each closing off another agent's solution space: e.g. "no new screens; extend existing surfaces only" / "must work for an occasional, phone-first user" / "zero backend changes". **At least one agent is barred from the requester's parked candidate**: name the banned solution explicitly in that agent's prompt ("the obvious solution is X; you may not propose X or a variant").

A third axis applies when the evidence genuinely partitions — a multi-persona feature whose material splits into customer-side stories, operator incidents, and business/cost data: give each agent a different **evidence packet** from `requester-input.md` and the `00-framing.md` table, and note the partition in `01-exploration.md`. For a single-persona feature the material usually can't partition — all agents get the full FACTS and the constraints carry the divergence alone.

Plus one **kill-case agent**: argues from the actual evidence gaps and the four forces (habit + anxiety of switching vs push + pull) why this shouldn't be built, or should be solved without software. Give it the real gap list — a devil's advocate without ammunition produces discountable objections.

Each agent returns: the concept (**what the user does differently**, not a layout), the moment it serves, its key insight, what it deliberately cuts, its biggest risk, and **the situation in which this concept wins**. An alternative with no winning situation is a strawman — replace it, don't score it.

**Isolation is operational, not asserted:** each ideation agent is a real spawned subagent (Agent tool) whose prompt contains only the shared base plus its own packet — never run ideation inline in the authoring conversation, where your leanings leak by construction. Each `02-ideation/*.md` opens with the verbatim prompt the agent received (objective, constraint, packet manifest), so the isolation is auditable from the artifacts.

## Synthesis rules

- **Discount seeded convergence.** Ideas present in the shared FACTS — or matching the requester's parked candidate — don't count as agreement; only convergence on unseeded ideas is signal.
- **Dispose of every concept explicitly**: adopted / absorbed into [what] / discarded because [why]. An idea that silently evaporates is the failure the discarded-ideas ledger exists to prevent.
- **Sacrifice something.** Name what the chosen direction refuses to graft from each losing concept, and the cost of that refusal. If every tension resolves to "both", the tension table was theater.
- **Test the key insight against the action envelope.** If the winning concept's core appeal is an action the system cannot execute today (see `domain.md`, automation frontier), the concept must either redesign around the human handoff or lose. Choosing a direction for an unbuildable property is a defect.
- **Abstraction skeptic pass.** For every interpretive layer a concept introduces (scores, verdicts, thresholds, roll-ups): what does the raw fact look like, and is the abstraction earning its calibration and trust costs?
- **Pre-mortem, three distinct narratives**: "It's 3 months post-launch and nobody uses this — the most plausible story is…" Each narrative names a different failure mechanism (adoption, trust, volume, wrong-problem).
- Techniques (How-Might-We, SCAMPER) only where a tension is genuinely unresolved — and every HMW raised must map to a named decision or carry into open questions. A technique section that restates conclusions gets deleted.

## Gate I — do-confirm before the design interview

The ticked block is appended to the end of `03-synthesis.md` — gates live in the artifacts so the fresh critic can audit them. Each tick carries **a pointer to the artifact line that satisfies it** — a bare tick is a claim, not a check:

- [ ] Agents ran as spawned subagents; each `02-ideation/*.md` opens with its verbatim prompt, and the objectives/constraints quoted there actually differ
- [ ] Kill-case argued with the real evidence gaps
- [ ] Every concept disposed of explicitly
- [ ] At least one named sacrifice with its cost
- [ ] Convergence discounted against the shared inputs
- [ ] Pre-mortem with three distinct failure narratives
