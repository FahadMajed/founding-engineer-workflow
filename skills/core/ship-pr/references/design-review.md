# Design Review

The design-reviewer's rubric. Read it as aim, not replacement, for your own taste: you have read more codebases than any human reviewer — the catalog below gives shared names to what you find, it is a floor, not a ceiling. A finding the catalog doesn't name is still a finding if you can say why it matters. What the doc does forbid is noise — the guardrails are hard rules.

**Design is trade-offs.** There is no one move that fits every problem — that's why most smells below carry an explicit exemption (the boundary outranks the forwarding; the orchestrator is not a god; the facade is not a middle man; incidental similarity is not duplication). When a finding sits on a trade-off, present both sides and recommend — don't decree. A finding that ignores the counter-case it trades against isn't taste, it's dogma.

## Guardrails — hard rules

1. **Only what the diff introduces or worsens.** Pre-existing problems the PR didn't touch are out of scope. At most one, as a note in the review body — never an inline finding.
2. **Rule of three.** Two similar code paths are not duplication yet — flag on the third, or when two copies encode the same *business rule* (those will drift apart and one will be wrong).
3. **Refactor when messy, not before.** No preparatory abstractions for futures that don't exist. Don't create abstractions until you need them — you probably won't.
4. **The move must be smaller than the problem.** A fix that needs a pattern the codebase doesn't have is a discussion for the user, not a PR comment.
5. **Readable beats clever.** A DRY fix that's harder to follow than the duplication loses. Dumb code that works is the house style.
6. **Every finding names its move.** Smell → why it matters → the smallest refactor that fixes it (code when short). No move, no comment.

## What a design finding is

A design finding claims the diff made the system harder to change. Test each candidate against the three symptoms of complexity — if it doesn't cause at least one, drop it:

- **Change amplification** — the next simple change will require touching many places.
- **Cognitive load** — the next reader must hold more in their head than the task requires.
- **Unknown unknowns** — the code hides which places must change; someone will miss one.

## What good looks like here

- **Deep modules.** A module earns its existence by hiding something: a decision, a protocol, a data shape. Simple interface, real work behind it. An interface as wide as its implementation is a paperwork layer.
- **Information hiding.** Each module owns a piece of knowledge (how a provider paginates, how prices round, what "active record" means) and nothing else knows it. When knowledge leaks, changes amplify.
- **Pull complexity downward.** Better for the implementer to sweat than for every caller to. A method with three preconditions the caller must remember is worse than a method that handles them.
- **Define errors out of existence.** Prefer designs where the edge case can't occur (findOrCreate over check-then-insert, idempotent handlers over "don't call twice") to designs that detect and throw.
- **Somewhat general-purpose.** The interface slightly more general than today's one caller; the implementation no more general than today's need. Both extremes are smells (special-casing / speculative generality).
- **This codebase's shape.** Modules cut by domain; controller → service → repository; per-provider behavior inside polymorphic `IntegrationClient`s behind the factory; cross-module effects through events, not reach-ins.

## Pattern adaptation — don't hand-roll what the house already has

The strongest design finding in this codebase: the diff **builds a bespoke version of existing machinery**. Check the diff against this list; the move is always "adopt the pattern", with a pointer to it:

| The diff hand-rolls... | The house pattern |
| --- | --- |
| per-provider `if`/`switch` on provider name | polymorphic method on `IntegrationClient` via the factory |
| delayed, retryable, or fire-later side effects | scheduled events (`build-feature/references/events.md`, `crons-and-sync.md`) |
| periodic/polling work | `@RunEvery` + `SyncType` sync-job tracking |
| "check if exists, then insert" | `findOrCreate` (race-free) |
| home-made mutual exclusion, double-run guards | advisory locks / `runWithRowLock` |
| business-event trail via logs or ad-hoc tables | `AuditRepository` |
| calling another module's service to trigger its reaction | domain event it subscribes to |
| generic utility buried in a feature module | `helper/` folder |
| bespoke pagination, validation, error shapes | house DTO/pagination/error idioms (`build-feature/references/conventions.md`) |

If the pattern genuinely doesn't fit, the PR should say why. Silence about a skipped house pattern is itself the finding.

## Smells catalog

Grouped by what they damage. One line each — you know these; the point is the shared name and the house-specific move.

### Module shape

- **Shallow module** — interface ≈ implementation; callers must understand internals. *Move:* deepen (hide more behind the same surface) or inline into the caller.
- **Pass-through method / middle man** — a layer that forwards with nothing added. *Move:* delete the layer or give it its real job — **but the module boundary wins**: never "fix" a pass-through by sending outsiders past the boundary (that's insider trading, a worse trade). A same-module `service → own repository` forward that IS the module's public surface is the price of the boundary; flag it only when the whole service is forwards — then the real smell is a shallow module and the fix is depth (pull real logic in), not deletion. Cross-module forwards (A's service just relaying B's) are the true middle man — cut A out. **Orchestrators and facades are exempt:** a coordinator whose lines are all delegations is not a middle man — sequencing, cron/sync-job ownership, locking, and partial-failure handling are its real job; a facade offering one simple surface over several services is depth, not forwarding.
- **Wrong layer** — controller doing service work, service composing queries, repository holding business rules. *Move:* push logic where neighboring features keep it.
- **God service** — one class that *implements* several domains' rules in its own body; every feature request lands there. It is rarely named `DataManager` — a domain-named service can be one: an `InventorySyncService` whose body computes replenishment, reconciles stock, applies decrements, and formats integration pushes still feels legitimate while it grows. Detection: describing what it honestly does needs "and"; a cluster of methods shares state the rest never touches; it changes for unrelated reasons. *Move:* **extract a service named by the domain concept hiding inside it** — the replenishment cluster becomes `ReplenishmentService`. The extraction is right only when the new name is a real domain word the business would say; `InventoryHelper` is the same god in a smaller coat.
  **The orchestrator exemption:** knowing *that* things happen is not knowing *how*. The same `InventorySyncService` running replenishment → reconciliation → decrements → integration pushes on a cron is healthy **when it delegates each to its focused service** — it owns the crons, sync jobs, ordering, locking, and partial-failure handling; the domain rules live elsewhere. The test: could you change how replenishment is computed without touching this class? Yes → orchestrator, leave it. No → the god is back. Facades get the same pass: one simple surface over several services is deep-module behavior, not a smell.
- **Information leakage** — raw entities crossing an endpoint boundary, query/ORM details visible above the repository, two modules both knowing one format. *Move:* pick the single owner; seal the boundary like neighboring endpoints do.
- **Insider trading** — a module reading another module's repository/internals instead of its interface or events. *Move:* go through the owning module's surface. (Never the "fix" for a pass-through — the boundary outranks the forwarding.)
- **Temporal decomposition** — modules/methods cut by execution order (`step1`, `then`, `finalize`) instead of by knowledge. *Move:* regroup around what each part knows.

### Knowledge & duplication

- **Duplicated knowledge** — one business rule, two homes; a change will miss one. *Move:* one home, callers share it. Incidental similarity (looks alike, means different things) stays as is.
- **Feature envy** — a method interrogating another module's data more than its own. *Move:* move the method to the data.
- **Data clump** — the same 3 params traveling together everywhere. *Move:* name the concept they form; the codebase likely already has the type.
- **Primitive obsession** — bare strings/numbers where an enum or type exists (statuses, provider names, lock ids, money). *Move:* the existing type — never invent a parallel one.
- **Shotgun surgery** — this PR edited 4+ files for one behavior change. Usually not fixable in-PR; *move:* review-body note as a signal on the module cut.

### Logic & flow

- **Long method** — several jobs in one body, readable only with a finger on the screen. *Move:* extract by job, named by intent (a good extraction kills a comment).
- **Deep nesting** — arrow-shaped code. *Move:* guard clauses, early returns.
- **Special-case accretion** — an `if` ladder growing per case where the codebase handles cases by polymorphism or lookup. *Move:* the table or the subclass, per Pattern adaptation.
- **Message chain / train wreck** — `a.getB().getC().doIt()` welds the caller to three structures. *Move:* ask the nearest owner for what you actually want.
- **Boolean flag argument** — `sync(true, false)`; call sites unreadable, method does two things. *Move:* named params object (house rule at 3+ args) or two methods.
- **Hidden shared state** — module-level mutables, statics carrying request state, singletons coupling callers invisibly. *Move:* pass state explicitly or scope it properly.

### Elements

- **Speculative generality** — one-implementation interfaces, unset config, hooks for callers that don't exist. *Move:* delete; the abstraction may return with its second case.
- **Dead code** — unreachable branches, unused exports, params nothing passes — introduced by this diff. *Move:* delete.
- **Comment as deodorant** — prose explaining what a rename or extraction would make self-evident. *Move:* the rename/extraction; delete the comment.

## Writing the finding

Smell name (or your own, named honestly) → the complexity symptom it causes → the smallest move → code when short. Rank by leverage, post at most 5. If a bad name is the symptom of a structure problem, it's one finding here (structure), not one here and one in conventions.
