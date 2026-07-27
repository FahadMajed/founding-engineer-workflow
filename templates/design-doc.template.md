# Design Doc Template

The task is to create a **software design document** that merges business alignment, pragmatic execution, and deep technical detail.  
Follow the structure and section names below, if you find a new section/ modification is suitable, please feel free to do so.
For each section:

- Write clearly, concretely, and concisely.
- Use evidence (metrics, tickets, research) when possible.
- Provide enough detail so another engineer could implement the design without guessing.
- Make trade-offs explicit.
- Include measurable outcomes (KPIs, SLOs, acceptance criteria).

## Project Title

- **Links:** <Tickets, ADRs, diagrams, dashboards, repos>

---

## Overview

Write 1–3 paragraphs summarizing:

- What we are building
- Why it's valuable to users and the business
- Roughly how we'll approach it
- Scope at a high level (what's in / out)
- The current state and its pain points
- Who is impacted
- Evidence (tickets, metrics, research)

---

## Existing Solution

Document the current baseline. How does this work today?

---

## Use Cases

### Business Rules

List the general business rules that these use cases will follow or assume. Details above what the use cases specify.

### Use Case: {{Name}}

**Primary actor(s):**
**Preconditions:**
**Trigger:**
**Main success scenario (steps):**
**Extensions/alternate flows:**
**Postconditions/Acceptance Criteria:**
**Notable deltas vs existing (if modified):**

---

## Alternative Solutions

List 1–2 alternatives considered:

- Pros/cons of each
- Effort, cost, risk, reversibility
- Why chosen or rejected

---

## Open Questions

Any open issues, contentious decisions, suggested future work. The "known unknowns".

---

## Feature Design

### Data Design

Explain how data is modeled and managed:

- Entities, keys, important fields
- Schema diffs
- Database constraints and checks
- Indices and access patterns
- Migration and backfill plan

---

### API Design

Document all contracts:

- Endpoints
- Request/response schemas
- Possible domain errors
- Map interfaces to the relevant use-cases

---

### Components Design

The **outside** — how the pieces fit:

- Major components and responsibilities
- Public interfaces and signatures
- Data flow across components — a sequence diagram where it helps
- Cross-cutting: events, crons, guards (only what the feature needs)

---

### Internal Design

The **inside** of those interfaces — include only when the feature computes a persisted/judged value, has a lifecycle, can run the same work twice, has rules that can disagree, or has a window. Otherwise write `N/A — CRUD over existing entities` and move on.

- Internal collaborators — private classes, one line + signature each
- State machine — transition table, terminal and illegal transitions (where state exists)
- Computations — formulas, thresholds with units, rounding, tie-breaks, precedence when two rules disagree
- Edge semantics — 0 vs null vs empty, below-floor, empty set
- Invariants — what must always hold, especially where a break is silent
- Failure & replay — idempotency, dedup key, what a re-run over the same window produces
- Time & windows — which clock/timezone, edges inclusive or exclusive, late-arriving rows
- Not handled — the deliberate internal non-handling, one line each

---

## Implementation Details

What to consider when implementing:

- Frontend/UX considerations
- Backend/database/API details
- Small details that should be considered/mitigated

---

## Assumptions and Dependencies

List:

- Assumptions with confidence and fallback plan
- Dependencies on external services, APIs, teams, or vendors

---

## Milestones

List major tasks with calendar dates (manage through your task-tracking tool). For each:

- Name
- Description
- Date
- Dependencies

---

## Glossary

Define key domain terms, acronyms, and jargon.

| Term | Meaning |
| ---- | ------- |
|      |         |
