---
name: write-tests
description: Write tests from existing scenarios and implementation. Use after /plan-tests and /build-feature to (1) convert test scenarios to actual tests, (2) detect gaps between scenarios and implementation, (3) run and report results.
---

# Write Tests

Converts test scenarios into actual tests. Runs after `/plan-tests` (creates scenarios) and `/build-feature` (implements code).

## Inputs

1. **Test scenarios doc** from test scenarios location
2. **Implemented feature** location (service, controller, module)

## Workflow

1. Read test scenarios doc
2. Read implemented code (service methods, controller endpoints, entities)
3. Detect gaps (see below)
4. Write test file following patterns in `references/test-patterns.template.md`
5. Run tests
6. Report: pass/fail count, any gaps found

## Gap Detection

Compare scenarios against implementation. Flag:

| Gap Type                   | Example                                                                                          |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
| **Missing implementation** | Scenario says "should retry 3x on failure" but no retry logic exists                            |
| **Missing test coverage**  | Code has error handling not covered by any scenario                                              |
| **Behavior mismatch**      | Scenario expects order marked `failed` when inventory insufficient, but implementation marks it `pending` |

Report gaps before writing tests. Ask: proceed anyway, or update scenarios/implementation first?

## Mocking Rules

**Mock only external APIs:**
```typescript
jest.spyOn(ExternalClient.prototype, 'method').mockResolvedValue('...');
```

**Never mock:** internal services, repositories, domain logic.

## Factory Usage

Use factories with overrides:
```typescript
const item = await repository.save(itemFactory({ isActive: true }));
```

## Naming Conventions

**Describe blocks:** Feature name or endpoint
```typescript
describe('Order Creation', () => {
describe('POST /v1/orders', () => {
```

**Nested describe:** Context from scenario
```typescript
describe('when valid data received', () => {
describe('when duplicate request received', () => {
```

**Test cases:** Match scenario descriptions
```typescript
test('should create order when valid data received', async () => {
test('should return existing order without creating duplicate', async () => {
```

## Test Consolidation

Before writing, check existing test files for overlap. Merge when:
- Tests share setup AND action
- One test is subset of another
- Multiple aspects can verify in single test

## Output

1. Test file(s) created/updated
2. Test run results
3. Gap report (if any found)

## Final Step: Code Review

After tests pass, spawn the `code-reviewer` agent to review the implementation + test code. It will check:
- Bugs and logic errors
- Pattern violations (against CLAUDE.md and coding-patterns)
- Code quality issues

Address critical/important issues before considering the feature ready for PR.
