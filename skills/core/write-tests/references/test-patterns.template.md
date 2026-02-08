# Test Patterns

## Standard File Structure

```typescript
// Customize imports for your framework
import { /* testing utilities */ } from '{{YOUR_TEST_FRAMEWORK}}';
import { /* factories */ } from '{{YOUR_FACTORY_LOCATION}}';

describe('Feature Name', () => {
  let app: /* your app type */;
  let dataSource: /* your db type */;

  // Repositories
  let itemRepository: /* repository type */;

  // External service spies
  let externalApiSpy: jest.SpyInstance;

  beforeAll(async () => {
    // Setup test module
    // Initialize app
    // Get repositories
  });

  beforeEach(async () => {
    // Clean database state
    // Setup mocks
    externalApiSpy = jest
      .spyOn(ExternalClient.prototype, 'method')
      .mockResolvedValue(expectedResult);
  });

  afterAll(async () => {
    // Teardown
  });

  test('should do something', async () => {
    // ARRANGE
    const item = await itemRepository.save(itemFactory());

    // ACT
    const response = await request.post('/endpoint').send(payload).expect(201);

    // ASSERT
    expect(response.body).toMatchObject({ /* expected */ });
    expect(externalApiSpy).toHaveBeenCalledWith(/* args */);
  });
});
```

## Webhook/Event Testing

```typescript
test('should process webhook and create records', async () => {
  // Setup: Create required entities
  const parent = await parentRepository.save(parentFactory());
  const child = await childRepository.save(
    childFactory({ parentId: parent.id })
  );

  const webhookPayload = {
    id: '123456',
    externalId: child.externalId,
    // ... rest of payload
  };

  await request
    .post('/v1/webhooks')
    .set('content-type', 'application/json')
    .send(webhookPayload)
    .expect(201);

  // Verify records created
  const items = await itemRepository.find();
  expect(items).toHaveLength(1);
  expect(items[0].externalId).toBe('123456');
});
```

## Duplicate/Idempotency Testing

```typescript
test('should return existing record without creating duplicate', async () => {
  // Setup
  const parent = await parentRepository.save(parentFactory());
  const payload = { /* request data */ };

  // First request - creates
  await request.post('/endpoint').send(payload).expect(201);

  // Same request again - returns existing
  await request.post('/endpoint').send(payload).expect(200);

  // Verify only one record
  const count = await repository.count();
  expect(count).toBe(1);
});
```

## Bulk Operations

```typescript
test('should process multiple items in single operation', async () => {
  const items = await Promise.all([
    repository.save(itemFactory({ code: 'A' })),
    repository.save(itemFactory({ code: 'B' })),
    repository.save(itemFactory({ code: 'C' })),
  ]);

  await service.bulkUpdate([
    { code: 'A', quantity: 10 },
    { code: 'B', quantity: 20 },
    { code: 'C', quantity: 30 },
  ]);

  const updated = await repository.find();
  expect(updated.find(p => p.code === 'A').quantity).toBe(10);
  expect(updated.find(p => p.code === 'B').quantity).toBe(20);
  expect(updated.find(p => p.code === 'C').quantity).toBe(30);
});
```

## Error Scenarios

```typescript
describe('when external API fails', () => {
  beforeEach(() => {
    externalApiSpy.mockRejectedValue(new Error('API Error'));
  });

  test('should continue processing other items when one fails', async () => {
    await service.syncAll(parentId);

    // Other operations still processed
    expect(otherApiSpy).toHaveBeenCalled();

    // Audit/log shows partial failure
    const audit = await auditRepository.findOne({
      where: { action: 'Sync', status: 'Partial' },
    });
    expect(audit).toBeDefined();
  });
});

test('should return 400 when required field missing', async () => {
  const invalidPayload = { /* missing required field */ };

  const response = await request
    .post('/endpoint')
    .send(invalidPayload)
    .expect(400);

  expect(response.body.message).toContain('required');
});
```

## Side Effects Verification

Always verify side effects in the same test that triggers them:

```typescript
test('should update status and create audit log', async () => {
  // ACT
  await service.updateStatus(itemId, 'Completed');

  // ASSERT - main result
  const item = await repository.findOne({ where: { id: itemId } });
  expect(item.status).toBe('Completed');

  // ASSERT - side effects
  const audit = await auditRepository.findOne({
    where: { entityType: 'Item', entityId: itemId },
  });
  expect(audit.action).toBe('Update');
  expect(audit.newValue).toContain('Completed');
});
```
