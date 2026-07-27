---
name: design-components
description: Draft the Components design section of a design doc — the outside of each component: modules, service interfaces, and data flow across them — in one pass with a rationale per component, then an agnostic review. The inside of an interface is /design-internals. For big features in the design phase. Use when (1) user says "/design-components", (2) designing how the backend pieces fit for a new feature, (3) writing the Components design section of a docs/design_docs/ doc.
---

# Design Components

You are a senior backend architect. You build deep modules — a small interface hiding the complexity — and you reach for what already exists before writing anything new.

Draft the **Components design** section of `docs/design_docs/{FEATURE}.md`.

You design the **outside** of each component: which components exist, their public interfaces, and how they call each other. The inside of a public interface — computation, state machine, invariants, replay — is the **Internal design** section, drafted by `/design-internals` against the contracts you settle.

First load `docs/standards/DESIGN_DOC_METHOD.md` and run its loop — load context, surface assumptions, draft with rationale, iterate, agnostic review, simple english. Everything below is the components-specific layer.

## Read for this section

- `.claude/skills/build-feature/references/architecture.md` — module structure, factory pattern, service layer.
- `.claude/skills/build-feature/references/new-module-map.md` — the scoping checklist (does this feature need events? crons? permissions?). Walk it.
- `.claude/skills/build-feature/references/events.md` and `crons-and-sync.md` and `permissions.md` — only the ones the checklist says you need.
- The **Data design** + **API design** already drafted (components satisfy the use cases using that data and those contracts) + the discovery doc's flows.
- The closest feature's Components section — precedent for shape and depth.
- House rules (check they still hold): deep modules (if the interface is as complex as the implementation, rethink); reuse repo finders — grep for an existing `findByX` before writing a query; check `src/app/decorators` + helpers before writing retry/backoff/caching; no leaky helpers — domain-specific logic lives on the owning class, not generic utils; a repo the authorization guard injects must register in the auth module (not a separate data module — that's a circular dependency that fails bootstrap); crons run in UTC off the top-of-hour, external API limits are per-account, and a new enum value needs its own `ALTER TYPE ADD VALUE` migration.

## The section covers these, in order

Draft them together in one pass (per the method), not one per turn.

1. **Components & responsibilities** — the modules/services touched or added, one line each.
2. **Interfaces & signatures** — service method signatures, internal DTOs, contracts. Deep modules — small surface. e.g.

   ```ts
   // hides fetch + dedup + compute behind two calls
   class ReportService {
     getOverview(tenantId: number): Promise<ReportOverview>;
     recompute(tenantId: number): Promise<void>;
   }
   ```

3. **Data flow** — how each use case flows *across* the components, start to finish. A sequence diagram where it helps.
4. **Cross-cutting** — events emitted/consumed, crons, guards — only the ones `new-module-map` flagged.
5. **Resilience** — which existing infra each component leans on: driver shape (event vs cron), job tracking, advisory lock scope, the retry/backoff decorators in `app/decorators`. Design new resilience only for a failure mode the infra doesn't already cover.

## What "balanced" means here

- Deep modules — a lot behind a small API. If the interface is nearly as complex as the implementation, it's too shallow.
- Reuse first — an existing finder, service, or decorator beats a new one. Grep before writing.
- No leaky helpers — keep domain logic on the class that owns it.
- Walk the scoping checklist — add an event, cron, or guard only because the feature needs it. Otherwise → **Not now**.
- Thin controllers, logic in services. Keep the external-fetch layer a dumb fetcher.

Over-engineered tells: an abstraction with one caller, a generic helper for domain-specific logic, an event nobody consumes, a cron where an on-demand call would do, re-implementing retry/caching that `app/decorators` already has.

## Output

The Components design section, written into `docs/design_docs/{FEATURE}.md` — then the agnostic review from the method.
