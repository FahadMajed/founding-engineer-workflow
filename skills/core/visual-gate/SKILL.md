---
name: visual-gate
description: Render a design doc as a navigable page for the human who has to sign off on it — schema before/after, use-case flows, endpoint cards, the slice stack. The markdown doc stays canonical and agent-readable; the page is a projection of it, grounded mechanically in files. Use when (1) a workflow skill reaches a design-doc gate, (2) user says "/visual-gate" or "render the design", (3) a requester is deciding on shape that prose hides.
---

# Visual gate

A design gate asks a human for a decision. Today the ask arrives as chat plus a markdown file — fine for a schema diff of two columns, hopeless for a feature whose shape lives across seven sections. This renders the doc as a page they can walk.

**The failure mode this exists to prevent:** re-typing the doc into styled boxes. The doc is already readable. A page that re-lays-out prose is strictly worse than the doc — a second copy that goes stale. The page earns its place only by doing what markdown can't: showing **shape** (schema before/after side by side, a state machine, a flow as steps) and offering the **pivot** (see one use case across every section) that a linear document can't.

**Test before you publish:** if the page could be pasted back into the doc without losing anything, don't publish it. Fix the doc instead.

## Routing — this vs `/visual-review`

Not before/after code — `/visual-review` already runs on both sides (sdlc step 3 uses it to diagram the Existing Solution before any code exists). The split is what's being rendered:

| Rendering… | Skill |
| --- | --- |
| **Behavior** — routing, retries, reconciliation, pricing rules, state transitions. The reviewer operates it. | `/visual-review` |
| **A design doc** — the artifact under sign-off at its gate. | `/visual-gate` |

They compose: a design whose core is a decision engine gets a visual-gate page for the whole doc, linking a visual-review artifact from its Internal design block. Build the interactive one once.

**Nothing here runs after the code ships.** That ground is taken and doesn't need a fourth surface: `/pr-evidence` for frontend states, `/visual-review` for behavior, the PR body's Stack section for the feature whole (`ship-pr/references/pr-stack.md`), and the design doc itself for what shipped differently than designed.

## Two rules that make this worth building

**1. The doc stays canonical.** The markdown in `docs/design_docs/` is the source of truth and what agents read. The page carries no fact the doc doesn't. When rendering surfaces a gap — an undefined error, a use case with no endpoint, a column with no access pattern — **fix the doc and re-render**. Never patch it into the page only; that forks the truth, and the fork wins in the room and loses in the repo.

**2. Every block is derived, not remembered.** Structured blocks come mechanically out of files — schema from the doc's Data design checked against `\d+ {table}`, endpoints from the API section, slices from the Milestone section. You write only the connective narrative. A number, a column name, or a status code you typed from memory is a defect: read the file.

## Blocks

In order — each derived from the doc section named. Skip any section the doc skips; never invent one to fill the layout.

| Block | Source section |
| --- | --- |
| What changes for the user, 1–3 paragraphs | Overview + Use Cases — the only prose you write |
| Use-case flows, one card each, walkable steps + extensions | Use Cases |
| Schema before → after: columns, keys, indices, constraints, migration + backfill | Data design |
| Endpoint cards: method, path, request, response, domain errors | API design |
| Module + data-flow diagram | Components design |
| State machine / computation / invariants / replay | Internal design (omit when the doc marks it N/A) |
| Slice stack, ordered, one complete use case each | Milestone |
| Open decisions — what the requester must answer to unblock | Open Questions |

The pivot that pays: **select a use case, see the schema, endpoint, and module it touches.** That cross-cut is the thing the linear doc can't show, and it's how a reviewer catches a use case with no data behind it.

Read [references/blocks.md](references/blocks.md) before building any of these — it carries the derivation command per block, what each must contain, and what kills it.

→ Publish, link it in the gate message, then walk it with the requester. Gate language rules from the calling workflow still apply — plain words, no code vocabulary, user-facing changes first.

## Harness

Same page mechanics as `/visual-review` — read its **Harness facts** and **Verification contract** and follow both; they are not repeated here and they are not optional. In addition:

- **File path is the identity.** Write to `{scratchpad}/visual-gate/{feature}.html` and republish the same path every round — the URL survives, so the gate message's link never goes stale.
- **Staleness is the same rule the rest of the pipeline runs.** The page reflects the doc's current state. Doc edited after a gate round → re-render before the next ask.
- **Redact before publishing.** The page is shareable and leaves the repo boundary. Strip tokens, keys, connection strings, real customer data, and internal hostnames from every excerpt.

## Where this plugs in

- **sdlc** step 3 — at the design-doc GATE.
- **scoped-fullstack-feature** — at CHECKPOINT 3.
- **scoped-feature** — nothing to add. No design doc, one use case.

## Output

Report: the artifact URL, the doc it derived from, and any gap the render surfaced — with the doc fix, or why it's still open.

## CRITICAL Rules

- The doc is canonical. A fact on the page and not in the doc is a bug — fix the doc, re-render.
- Derive every block from a file. Nothing from memory: not a column, not a status code.
- No simulation here — behavior that needs operating goes to `/visual-review` and gets linked, not rebuilt.
- Redact secrets and customer data before publishing. The page leaves the repo.
- Skip a block the source doesn't have. An empty section rendered as a styled placeholder is the styled-boxes failure with extra steps.
