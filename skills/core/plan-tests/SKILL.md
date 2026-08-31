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

Derive your scenarios from the **Use Cases** and **Business Rules** — that's what the system does for someone.

The **Internal design** section is written for the implementer. It sharpens scenarios you derived from behavior; it never generates one of its own. Step 7 governs what it may and may not contribute.

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

### 5. Mock Gate (run twice, same passes as the Consolidation Gate)

A stub is fuel for a scenario, never its subject. For every scenario whose GIVEN stubs an external service, ask: **if the THEN comes out wrong, whose code is wrong — ours or the stub's?**

- **Ours decides → keep it.** The stub hands over a payload; our logic makes a call someone can observe. "Two tenants come back on a shared integration account → an alias account exists for each." "The SKU isn't in our catalog → the listing is skipped and the sync job counts it." "The channel read throws → the other tenant still syncs and the failure lands on the job."
- **The stub decides → cut it.** You hand-wrote the payload, so the assertion reads your own fixture back. "Mock returns sale price 49.90 → `listing.salePrice` is 49.90" proves the fake matches the mapper, not that the mapper matches the third party. Only a live call catches a renamed field. (Same call `/fix-bug` makes on adapter fixes.)

Other signals the scenario is testing the stub:

- The GIVEN needs three or more stubs to stand up → it's testing wiring.
- The THEN asserts what we *sent* the external service ("called with `lastUpdatedAt` = last sync time"). Keep only when that request is itself a business rule — an incremental window, an idempotency key — and say so in the scenario. Otherwise it's a call-args change detector.
- The stub is one of our own services or repositories → never. Re-aim at the outermost external boundary (the client/adapter method) or drop the scenario. One exception: when the logic under test lives *inside* the adapter — a reject-code classification, a lifecycle mapping — stubbing the adapter method would mock the code under test, so the boundary drops to the transport. Keep the scenario if our logic still authors the THEN, but note that the fixture is now a hand-written third party (its routes, its envelope, its field names): the payload *shape* is unproven no matter how many cases you add, so it goes in the Verification Plan.

**Where the survivors live.** Group them under the suite of the service that *consumes* the third party — the syncing service, the pricing service, the health recompute. Concretely: a `describe` block added to that service's existing spec, not a new spec file named for the vendor or the fix. A file called `{{vendor}}-receipt-reject-classification.e2e.spec.ts` is the tell — it has to restage the whole world the existing spec already stages, and nothing in it belongs to the vendor rather than to receiving. A feature being external-service-heavy is not a reason for a big external test suite: test count tracks the decisions our code makes, not the third party's API surface.

**Cut ≠ unverified.** When the risk is real but only a live call can catch it — a field name, an auth flow, a pagination cursor, whether the third party reports inbound quantities in a namespace our SKUs share — plan the verification instead of a test:

- A read-only probe script in `scripts/`, the `verify-*.ts` shape: hits the live API for one real account, prints PASS/FAIL per probe, writes nothing. `scripts/verify-inbound-mapping.ts` is the model.
- `/call-api` for a one-off check against the third party, or for the flow end-to-end against a running server.

Record each one in the doc's Verification Plan (see Output) with the risk, the check, and how to run it. Unwritten, the next session backfills a fabricated-payload test and calls the risk covered.

### 6. Write Scenarios

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
- Assertions (THEN): What to verify (response shape, DB state, side effects). An outbound call to an external service counts only under the Mock Gate's rule — the request itself has to be the business rule.

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

## Verification Plan (not tests)

Risks a test can't reach, and how each is checked instead.

| Risk | Check | Run |
| --- | --- | --- |
| [what breaks silently if we're wrong] | [what the probe compares] | `scripts/verify-x.ts` / `/call-api` |

## Assumptions & Open Questions

Anything the design doc left unspecified that you had to assume.
```

Drop the Verification Plan section when the feature touches no external service. Never leave it as a placeholder for work a test already covers.

Two rules while writing:

- Tag each assertion mentally: stated (in the doc), inferred (you reasoned it), or unspecified (doc is silent). Stated → assert freely. Inferred → assert, note the basis. Unspecified → do NOT invent an authoritative answer; record it under Assumptions & Open Questions and pick a labeled assumption for the test.
- A test's title must match its own THEN. If the title says "Healthy" and the assertion says "Slipping", one is wrong.

### 7. Internal design — values, never scenarios

Its structure is the implementation's structure. A scenario list shaped like it is a list that tests the build instead of the behavior — the thing this skill exists to prevent. So it acts on the scenarios you already have. Two uses only:

1. **Pin the boundary values.** Your scenario says "below the sample-size floor"; that section says 20 orders in 30d. Same for window edges (inclusive or exclusive), rounding, timezone, and which rule wins when two disagree. Vague scenario → exact scenario.
2. **Completeness.** Does it name an observable edge you missed — 0 vs null, a replay, a precedence conflict? Add a scenario. Add it because a user can observe it, not because the section lists it.

Hard limits:

- **No test may name an internal collaborator**, assert a step ran in a given order, or check config read timing. Not observable through the API or the persisted row → not a scenario. (Same rule as the banned title terms above.)
- **Not handled** is a stop sign. Never write a test asserting the system does something the design deliberately excluded.
- If a value there contradicts Business Rules, that's a design-doc defect. Raise it; don't quietly test one of them.

## Final Step: QA Review, then prune

Spawn the `qa-reviewer` agent. Pass it (1) the scenarios doc, (2) the design doc path.

The reviewer finds only *coverage gaps* — its bias is to add. After it returns:
1. Treat each gap as a candidate, not a command. Add it only if it's a distinct behavior; if it's a variant, fold it into an existing test as a case.
2. Re-run the Consolidation Gate over the new total. Adding N gaps should not grow the suite by N tests.
3. Re-run the Mock Gate over anything it added. A gap that can only be covered by an assertion the stub authors goes to the Verification Plan, not the suite — the reviewer reads the design, not this rule.

Done when every surviving test answers "what does this cover that no other does?" and every title names a behavior.
