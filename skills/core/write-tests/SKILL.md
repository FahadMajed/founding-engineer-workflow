---
name: write-tests
description: Write tests from existing scenarios and implementation. Use after /plan-tests and /build-feature to (1) convert test scenarios to actual tests, (2) detect gaps between scenarios and implementation, (3) run and report results.
---

# Write Tests

Converts test scenarios into actual E2E tests. Runs after `/plan-tests` (creates scenarios) and `/build-feature` (implements code).

## Inputs

1. **Test scenarios doc** from `docs/for_ai/test_scenarios/`
2. **Implemented feature** location (service, controller, module)

## Workflow

1. Read test scenarios doc
2. Read implemented code (service methods, controller endpoints, entities)
3. Detect gaps (see below)
4. Write test file following patterns in `references/test-patterns.md`
5. Run tests: `npm test -- --testPathPattern="file.e2e.spec.ts" --testNamePattern="Suite" --no-coverage 2>&1`
6. Report: pass/fail count, any gaps found

## Test through the contract

Drive every test through the **public surface** — the endpoint, or the public service method named in the design's API / Components sections — and assert on what the contract promises: response shape and status, and persisted state a consumer can observe. Never reach into implementation: private methods, call counts, "was service X called", intermediate values.

The check: if someone refactors the implementation but keeps the contract, your tests stay green. A test that breaks on a pure refactor is testing the wrong thing — rewrite it against the contract.

## Gap Detection

Compare scenarios against implementation. Flag:

| Gap Type | Example |
|----------|---------|
| **Missing implementation** | Scenario says "should retry 3x on failure" but no retry logic exists |
| **Missing test coverage** | Code has error handling not covered by any scenario |
| **Behavior mismatch** | Scenario expects order marked `failed` when inventory insufficient, but implementation marks it `pending` |

Report gaps before writing tests. Ask: proceed anyway, or update scenarios/implementation first?

## Mocking Rules

**Mock only external APIs:**
```typescript
jest.spyOn(ExternalCarrier.prototype, 'getShippingLabelUrl').mockResolvedValue('...');
jest.spyOn(ExternalWarehouse.prototype, 'createOrder').mockResolvedValue('WH123');
```

**Never mock:** internal services, repositories, domain logic.

## Factory Usage

Use factories from `test/factory.ts` with overrides:
```typescript
const owner = await ownerRepository.save(ownerFactory({ isActive: true }));
const item = await itemRepository.createItem(itemFactory({ ownerId: owner.id }));
```

## Naming Conventions

**Describe blocks:** Feature name or endpoint
```typescript
describe('Order Creation', () => {
describe('POST /v1/orders/webhooks', () => {
```

**Nested describe:** Context from scenario
```typescript
describe('when webhook received from an external channel', () => {
describe('when duplicate webhook received', () => {
```

**Test cases:** Match scenario descriptions
```typescript
test('should create order when valid webhook received', async () => {
test('should return existing order without creating duplicate', async () => {
```

Write like a domain expert in a given system would write. do not focus on implementation details, focus on behavior

## Test Consolidation

Before writing, check existing test files for overlap. Merge when:
- Tests share setup AND action
- One test is subset of another
- Multiple aspects can verify in single test

## Output

1. Test file(s) created/updated
2. Test run results
3. Gap report (if any found)

## Final Step: Return the Gap Report

Return the gap report (even when empty) along with the test file paths and run results. Don't spawn a reviewer here — review happens on the PR: `/ship-pr` runs the sweep after your tests are in the diff, and the `bug-hunter` agent takes your gap report as one of its inputs.

## References

- [Test patterns](references/test-patterns.md) - File structure, webhook testing, bulk ops, error scenarios
- `test/factory.ts` - Available factory functions
- If pattern not in test-patterns.md, check similar test in `/test/` folder
