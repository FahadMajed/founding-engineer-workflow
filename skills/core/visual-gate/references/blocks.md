# Blocks

Each block below names its source, the command that derives it, what it must carry, and what kills it. Build only the blocks whose source exists.

The line that governs all of them: **you write the connective narrative, the files write the facts.** If you can't point at the file a value came from, it doesn't go on the page.

---

## What changes for the user

The only prose block. 1–3 paragraphs from the doc's Overview + Use Cases: what a person can do after this that they couldn't before, and what it costs them today.

Must: name the persona and the current pain. Written for a non-engineer — same bar as the gate message.
Kills it: restating the section headings that follow. It's the reason, not the table of contents.

## Use-case flows

Source: the doc's Use Cases section (UML-style — actor, preconditions, trigger, main scenario, extensions, postconditions).

One card per use case. The main scenario renders as numbered steps; extensions render as branches off the step they leave from — not as a separate list, which is what the markdown already does badly. Business Rules attach to the use case they constrain.

Must: every use case in the doc, including modified ones, with their "notable deltas vs existing" marked.
Kills it: paraphrasing steps. Copy them; a step reworded on the page and not in the doc is a fork.

## Schema before → after

Source: the doc's Data design section. For a feature touching existing tables, get the current shape from the database rather than from the doc's account of it:

```bash
{{PROD_DB_RO}} -c "\d+ {table}"
```

Two columns side by side, existing → proposed. Added rows marked, changed rows showing both values, dropped rows struck. Keys, indices, and constraints are rows in the same table, not a footnote — an index is where a design gets judged at prod volume.

Must: the migration and its backfill, with the backfill's idempotency stated. Row-count estimate for anything that rewrites (`SELECT count(*)`), because that's the lock-risk conversation.
Kills it: "adds a few columns to the orders table" — the whole point is that the reviewer sees which.

A `\d+` that disagrees with the doc's account of the existing schema is a finding, not a rendering problem. Fix the doc.

## Endpoint cards

Source: the doc's API design section, seeded from `contract-draft.md` when the frontend ran first.

One card per endpoint: method + path, params, request shape, response shape, domain errors with their status codes. Recorded divergences from `contract-draft.md` render on the card that diverged.

Must: every domain error. The error list is the half of a contract that gets skipped in review and hurts in production.
Kills it: a response shape with `...` in it. Complete or absent.

## Module + data flow

Source: the doc's Components design section. A diagram — Mermaid, pre-rendered to SVG (Artifact CSP blocks scripts).

Participants are real classes from the doc; edges are real calls. Mark which modules are new, which are touched, which are untouched-but-adjacent — the last group is where reviewers ask "does that still work?"
Kills it: boxes named after layers ("Service", "Repository"). Name the actual module.

## State machine / computation / invariants

Source: the doc's Internal design section. Omit entirely when the doc marks it N/A — most scoped work does.

States and transitions as a diagram, with guards on the edges. Invariants as a list the reviewer can check off. Replay behavior stated plainly: what happens when the same work runs twice.
Kills it: rendering this for CRUD. A getter with a state diagram is ceremony.

When the behavior is the point of the feature — a routing rule, a retry policy, a reconciliation — this block links a `/visual-review` artifact instead of trying to be one. Static diagram here, operable thing there.

## Slice stack

Source: the doc's Milestone section, cut per `.claude/skills/ship-pr/references/pr-stack.md`.

Ordered list, one complete use case per slice, each showing what it depends on below it. This is what the requester actually decides at the gate when effort is past appetite — which slices ride this cycle.

Must: every slice traceable to a use-case card above. A slice with no use case is a layer cut; go fix the slicing.

## Open decisions

Source: the doc's Open Questions section.

Each one: the question, what it blocks, and the options with their consequence. Not a list of unknowns — a list of choices with someone's name on them.
Kills it: questions you could have answered by reading the code. Answer those first; what's left is the requester's.

---

## The pivot

One interaction: select a use case → its schema rows, endpoints, and modules highlight across the other blocks.

That cross-cut is why the page exists. It's how the reviewer catches a use case with no data behind it, an endpoint no use case calls, or a column nothing reads — three gaps a linear doc hides by construction, because each section reads fine on its own.

Wire it with data attributes tying every row, card, and node back to a use-case id, and one click toggling a class. No framework, no state library — it's a filter, and the Artifact CSP blocks the CDN you'd reach for anyway.
