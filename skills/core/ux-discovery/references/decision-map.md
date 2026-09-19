# Decision Map — multi-session efforts

Some efforts are too big for their open decisions to live in one discovery's artifacts: many interdependent decisions whose resolution order matters, answers gated on external parties (a vendor reply, account provisioning, data that must move first), several humans owning pieces, weeks of elapsed time. There, a doc's open-questions section stops working as the ledger — a new session can't see what's decided vs open vs blocked, can't claim a question without re-reading everything, and teammates outside the session can't see decision state at all.

The decision map is that ledger, kept on the task tracker where the team already works: one parent task indexing the effort's decisions, one subtask per open decision, worked one at a time until the way to the destination is clear. The map is **planning**: each ticket resolves a decision, never a slice of the build. When the pull is to just go do the work, the map is done — hand off to the lifecycle.

## When to chart one — and when not to

Chart a map when open decisions block each other **across working sessions** — you can see the dependency chain but cannot resolve it in one sitting, because answers wait on external parties, on groundwork, or on more humans than the requester.

Never chart one when the way is already clear: a normal feature (artifacts + gates already carry its state), a big-but-clear build (appetite and slicing cover it), or fog that one discovery session can burn through. If naming the destination surfaces no fog, there is no map to chart — say so and proceed without one.

## The map

A task in the effort's list on your tracker (`/optional/task-management`), tagged `decision-map`. Its description:

```markdown
## Destination
<what reaching the end looks like — the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes
<domain context; the skills every session should load; standing preferences for this effort>

## Decisions so far
- [<closed ticket name>](link) — <one-line gist of the answer>

## Not yet specified
<in-scope fog you can't ticket yet — see below>

## Out of scope
<work consciously ruled beyond the destination — never graduates>
```

The map is an **index, not a store**: a decision lives in exactly one place — its ticket — and the map gists it and links. Open tickets are not listed in the description; they are the open subtasks, found by query.

Naming the destination is the first act of charting — it fixes the scope, so it's settled before any ticket exists. In everything the requester reads, refer to tickets by **name**, never a bare id.

## Tickets

Each ticket is a **subtask** of the map. Its description is the question — the decision or investigation it resolves, sized to one working session. Each carries one type tag:

- **`research`** — a fact outside the codebase that a decision waits on. Resolved by the discovery moves that already exist: the cited web sweep, `/signals`, a probe script against the channel's API. Findings enter cited, tiered per `evidence.md`.
- **`probe`** — a decision that needs a concrete artifact or data point to react to. Our spike semantics (`framing.md` probe plans, design's spiked rabbit holes): time-boxed, throwaway by name, answers one question. Throwaway UI mockups are banned — a "how should it look" question waits for the production frontend.
- **`requester`** — a question only the requester (or another named human) can answer. Resolved in conversation, under the interview discipline: blast-radius-ranked, free-text, captured verbatim. The agent never answers for the human — a requester ticket without their words is unresolved.
- **`groundwork`** — prerequisite *work* that unblocks a decision: sign up for the service so its API can be judged, provision access, move the data so its shape can be seen. The one type that does rather than decides — and it earns its place by unblocking a decision, not by delivering the destination. The answer records what was done and the facts later tickets depend on (where credentials live, new URLs, row counts).

**Claim** = assign the ticket to yourself, first, before any work — an open unassigned ticket is unclaimed, so concurrent sessions skip claimed ones. **Blocking** = the tracker's native dependency ("waiting on"); a ticket is unblocked when everything it waits on is closed. The **frontier** — what's takeable now — is the open, unblocked, unclaimed subtasks. The API operations for all three live in `/optional/task-management`.

## Fog or ticket

The map is deliberately incomplete: don't chart what you can't yet see. The test is whether you can **state the question precisely now** — not whether you can answer it now.

- **Ticket** when the question is sharp — even if blocked.
- **Not yet specified** when it isn't. Write the suspected question, the area to revisit — as loosely as the view allows. Don't pre-slice fog into ticket-sized pieces: one patch may graduate into several tickets, or none, once the frontier reaches it.

Resolving a ticket clears fog: whatever the answer makes specifiable graduates into fresh tickets, and the graduated patch leaves Not-yet-specified so it lives only as its tickets.

**Out of scope** is different from fog: fog is in-scope but not yet sharp; out-of-scope is work ruled beyond the destination. It never graduates. When an existing ticket turns out to sit past the destination, close it and leave one line in Out of scope — gist, why, link. It stays out of Decisions-so-far, which records only the route walked.

## Sessions

**Charting** (once): name the destination with the requester; then fan out breadth-first over the space to surface the open decisions and what's takeable now; create the map; create the tickets you can state sharply, then wire dependencies in a second pass (tickets need ids before they can reference each other); sketch the rest into Not-yet-specified; fire the `research` tickets as parallel background agents. Charting resolves nothing by hand — it ends there.

**Working** (repeated): load the map description — the low-resolution view, not every ticket body. Take the named ticket, or the first frontier ticket. Claim it. Resolve it, zooming into related closed tickets on demand and loading the skills the Notes name. Record the resolution: the answer as a comment on the ticket, close it, append the one-line gist + link to Decisions-so-far. Then graduate any fog the answer sharpened, and close-out-of-scope anything it exposed as past the destination.

**One claimed ticket per working session** — the map, not the session's memory, is the interface between sessions, and that only holds if every resolution lands on the tracker before the next begins. Two exceptions: research tickets run in parallel as background agents, and a live sitting with the requester may close several `requester` tickets — it's one exchange, and splitting it manufactures touchpoints.

Expect concurrency: other sessions and humans edit the tracker between and during sessions. The claim discipline exists for exactly this.

## Boundaries

- **The map never slices the thinking.** Tickets resolve unknowns that feed framing, ideation, and design — like spikes. The discovery pipeline itself stays whole in its artifacts; decision persistence across sessions is a different axis from partitioning the design.
- **The map is the ledger; the artifacts are the thinking.** A ticket's answer enters discovery artifacts as a citation, same as banked evidence — the discovery doc never restates the map, and the map never absorbs the doc.
- **The decision ledger stays verdict-only.** Map decisions are effort-internal; verdict-shaped outcomes (build / shrink / probe first / solve another way / not now) append to `docs/proposals/DECISIONS.md` as they always do.
