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

### 2. Read Testing Standards (if available)

Check for existing testing strategy docs. Common locations:
- `docs/standards/TESTING_STRATEGY.md`
- `docs/testing/`
- Project README

### 3. Check Existing Examples

Scan for existing test scenario files to match structure and depth.

### 4. Consolidation Pass (Critical)

BEFORE writing scenarios, run this checklist:

- [ ] What test cases are duplicates? Remove.
- [ ] What test cases share setup AND action? Combine into one test with multiple assertions.
- [ ] Can I verify side effects in the same test that causes them? Do it.
- [ ] Each remaining test answers: "What unique scenario am I testing?"

Goal: Minimum tests for maximum confidence.

### 5. Write Scenarios

Focus on **business logic**, skip:

- Auth/authorization (system concern)
- Input validation boilerplate
- Framework mechanics

For each scenario, include:

- Setup (GIVEN): What data/state exists
- Action (WHEN): What operation triggers
- Assertions (THEN): What to verify (DB state, API calls, side effects)

Use describe blocks to group related scenarios.

## Output

Write to: `docs/for_ai/test_scenarios_for_ai/[feature-name]_test_scenarios.md`

Or your project's equivalent location.

Structure:

```markdown
# [Feature] Test Scenarios

## Overview

Brief context on what's being tested and key business rules.

## Test Suite: [Logical Grouping]

### Test: "should [behavior] when [condition]"

In plain English.
**GIVEN:** Setup details
**WHEN:** Action (usually API call)
**THEN:** Assertions
```

## Final Step: QA Review

After writing scenarios, spawn the `qa-reviewer` agent to review for coverage gaps. Pass it:
1. The scenarios doc you just wrote
2. The design doc path

Address critical/important gaps before considering scenarios complete.
