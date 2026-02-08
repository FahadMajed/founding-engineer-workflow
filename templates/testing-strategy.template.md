# Testing Strategy

## Philosophy

- E2E + integration tests over unit tests for business logic
- Test behavior, not implementation
- Only mock external APIs, never your own code

## Test Stack

- Framework: {{YOUR_TEST_FRAMEWORK}}
- Database: {{YOUR_TEST_DB_APPROACH}}
- HTTP: {{YOUR_HTTP_TESTING_LIBRARY}}

## Test Naming

**Describe blocks:** Feature names

```typescript
describe('Order Creation', () => {
```

**Nested describes:** Context blocks

```typescript
describe('when webhook received', () => {
describe('when duplicate request', () => {
```

**Test cases:** Complete "it should..." sentences

```typescript
test('should create order when valid data received', async () => {
test('should return existing order without creating duplicate', async () => {
```

## Test Structure

```typescript
test('should do something', async () => {
  // ARRANGE - setup data and state
  const item = await repository.save(itemFactory());

  // ACT - perform the operation
  const response = await request.post('/endpoint').send(payload);

  // ASSERT - verify results
  expect(response.status).toBe(201);
  expect(response.body).toMatchObject({ /* expected */ });
});
```

## Factory Functions

Create realistic test data with overrides:

```typescript
const item = await repository.save(itemFactory({
  isActive: true,
  createdAt: new Date('2024-01-01'),
}));
```

## Mocking Rules

**Mock only external APIs:**

```typescript
jest.spyOn(ExternalClient.prototype, 'method').mockResolvedValue('...');
```

**Never mock:** internal services, repositories, domain logic.

## Test Scenarios

Focus on business logic, skip:

- Auth/authorization (system concern)
- Input validation boilerplate
- Framework mechanics

## Best Practices

- Each test is independent (no shared state)
- Tests document expected behavior
- Failing tests should explain what went wrong
- Clean up test data between runs
