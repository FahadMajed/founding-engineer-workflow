---
name: plan-tests
description: Create test scenarios from design docs BEFORE implementation. Use when (1) given a design doc and asked to plan tests, (2) user says "plan tests" or "/plan-tests", (3) preparing test coverage for a new feature, (4) reviewing a design for testability gaps. Outputs GIVEN/WHEN/THEN scenarios to catch edge cases and missing requirements before code is written.
---

# Plan Tests

Create test scenarios from a design doc. This runs BEFORE implementation - think about testing independently from how the feature will be built.

## Why Independence Matters

Testing that follows implementation just validates what was built. Testing that precedes implementation catches:

- Edge cases the implementation would miss
- Missing requirements in the design
- Assumptions that need validation

## Input

Design doc path from user.

## Process

### 1. Read the Design Doc

Understand the business requirements and user flows. Focus on WHAT the system should do, not HOW.

### 2. Read Testing Standards

Check `docs/standards/TESTING_STRATEGY.md` for:

- The test pyramid you follow
- E2E with a real database
- Test behavior, not implementation
- Only mock external APIs

### 3. Check Existing Examples

Scan `docs/for_ai/test_scenarios/` for structure and depth. Open the closest existing scenarios file for the expected specificity level.

### 4. Consolidation Gate (run twice)

Run once now against your candidate list; run again after drafting, when the real overlaps are visible. Most merges only show up on the second pass.

- Duplicates → remove.
- Tests that share setup AND action and vary only in data → collapse into ONE test with a case table / transition matrix. (Seven enter/exit combinations become one matrix test, not seven.)
- Side effects (events, jobs, audit rows) → assert in the test that causes them, not a separate test.
- For each surviving test, answer in one line: "What does this cover that no other test does?" Can't answer crisply → merge or cut.

Goal: minimum tests for maximum confidence. A test has a maintenance cost; spend it only on a distinct behavior.

### 5. Write Scenarios

Focus on **business logic**, skip:

- Auth/authorization (system concern)
- Input validation boilerplate
- Framework mechanics
- Infrastructure primitives (advisory locks, retries, transactions, DI wiring) — unless we wrote custom logic on top
- Non-features: never assert the system does nothing because a feature is absent
- Pure persistence / cascade mechanics — unless they encode a real business rule

For each scenario, include:

- Setup (GIVEN): What data/state exists
- Action (WHEN): What operation triggers
- Assertions (THEN): What to verify (DB state, API calls, side effects)

Use describe blocks to group related scenarios.

**Name every test for the behavior, never the mechanism.** The title says what the system does for someone; the GIVEN/THEN may name tables, columns, and events.

Banned in a title: table/column names, class or method names, mechanism verbs (insert, upsert, append, write row, emit). This is the "should save to database" anti-pattern.

- Bad:  should append a row to the history table when the recompute crosses the day boundary
- Good: should record one entry per day in the 30-day history and leave earlier days intact

## Output

Write to: `docs/for_ai/test_scenarios/[feature-name]_test_scenarios.md`

Structure:

```markdown
# [Feature] Test Scenarios

## Overview

Brief context on what's being tested and key business rules.

## Test Suite: [Logical Grouping]

### Test: "should [behavior] when [condition]"

In plain english.
**GIVEN:** Setup details
**WHEN:** Action (usually api call)
**THEN:** Assertions

## Assumptions & Open Questions

Anything the design doc left unspecified that you had to assume.
```

Two rules while writing:

- Tag each assertion mentally: stated (in the doc), inferred (you reasoned it), or unspecified (doc is silent). Stated → assert freely. Inferred → assert, note the basis. Unspecified → do NOT invent an authoritative answer; record it under Assumptions & Open Questions and pick a labeled assumption for the test.
- A test's title must match its own THEN. If the title says "Healthy" and the assertion says "Slipping", one is wrong.

## Final Step: QA Review, then prune

Spawn the `qa-reviewer` agent. Pass it (1) the scenarios doc, (2) the design doc path.

The reviewer finds only *coverage gaps* — its bias is to add. After it returns:
1. Treat each gap as a candidate, not a command. Add it only if it's a distinct behavior; if it's a variant, fold it into an existing test as a case.
2. Re-run the Consolidation Gate over the new total. Adding N gaps should not grow the suite by N tests.

Done when every surviving test answers "what does this cover that no other does?" and every title names a behavior.
