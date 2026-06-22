# Design Doc Method

How to draft one section of a design doc, together. For big features where the design itself takes days.

The design-section skills — `/design-schema`, `/design-api`, `/design-components` — all run this loop. Each one adds what to read and what "good" means for its section. The loop lives here, written once.

Each section skill opens in the voice of a senior engineer for that section. Stay in that role — it sets the bar and the instincts.

## The loop

Run this per section, sub-section by sub-section.

### 1. Load context first — don't ask what you can read

Before proposing anything, read:

- The **discovery doc** for this feature — the UX intent, the jobs, the data the screens need.
- The **1-2 closest existing design docs** in `docs/design_docs/` — match a feature like this one, mirror its depth and shape.
- The **codebase patterns** — `.claude/skills/build-feature/references/` (the section skill names the files).
- Your engineering principles — Keep It Simple, Question Everything (see PHILOSOPHY.md).
- Your **loaded memories** — how the requester approaches this, gotchas already learned.

Ask the requester only for what none of these answer. Asking what's already in the discovery doc or the code is the worst thing you can do here.

### 2. Draft the section — propose with rationale

Draft the whole section in one pass — all its sub-sections — then put it in front of the requester. Don't dribble it out one entity at a time; that's too slow. Split into two passes only if the section is genuinely huge.

Every element carries a one-line **why**, tied to a use case or to precedent. If you can't write the why in one line, cut the element. That is the whole anti-over-engineering rule:

- Build what the use cases need today, not what might be needed tomorrow.
- Reuse before adding — find the existing entity / endpoint / service first.
- No abstraction until a second caller needs it.
- An idea worth keeping but not building now → write it under **Not now**. Don't build it.

**Surface your assumptions.** Where you inferred something from the discovery doc, precedent, or code, say so — don't bury it. List the load-bearing assumptions at the top of the draft, each with its source ("Assuming one snapshot row per account per day — from the closest precedent doc"). Stated assumptions beat both stupid questions and silent guesses: the requester scans and vetoes.

### 3. Iterate with the requester

Show the draft. They react. Adjust. Get sign-off on the sub-section before the next one. This is collaborative thinking, not a handoff — best idea wins.

### 4. Agnostic review — a fresh pair of eyes

When the section draft is settled, spawn a fresh sub-agent that did **not** draft it. Two lenses:

- **Gaps** — load `/analyze-design`. Missing edge cases, ambiguous rules, unnecessary features, good-feature-wrong-approach.
- **Simplicity + fit** — over-engineering, premature abstraction, and "does this match how we already do it in the codebase and the precedent docs?"

Tell the agent to load the skill and return findings — don't let it just read. You resolve the findings; the requester sees the verdict and what changed.

### 5. Write it into the doc

Write the section into `docs/design_docs/{FEATURE}.md`. Simple english.

## Questions and assumptions

- Don't ask what the discovery doc, a design doc, or the code already answers — state the assumption you drew from it (step 2) and let the requester correct it.
- Ask only genuine forks you can't resolve from context. Batch them. Propose a default with each, so a "yes" is one word.
- The load-bearing assumptions sit at the top of the draft, each with its source — easy to scan, easy to veto.

## Writing style

- Simple english. Short sentences. Sacrifice grammar for clarity — it's a thinking artifact, not prose.
- Tables, bullets, DDL, signatures — over paragraphs.
- Domain terms, the ones in the discovery doc and the code.
- Write the steady state. No "this used to", no narrating the change.
