# Test Patterns

## Standard File Structure

```typescript
import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken, TypeOrmModule } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import request from 'supertest';

import { entitySchemas } from 'src/entities';
import { ormModule, configModule, cacheModule } from '../test/configs';
import { cleanupTestState, teardownTestApp } from '../test/test-setup';
import { tenantFactory, orderFactory /* ... */ } from '../test/factory';

describe('Feature Name', () => {
  let app: INestApplication;
  let dataSource: DataSource;
  let server: request.SuperTest<request.Test>;

  // Repositories
  let tenantRepository: Repository<Tenant>;
  let orderRepository: OrderRepository;

  // External service spies
  let externalApiSpy: jest.SpyInstance;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ormModule,
        TypeOrmModule.forFeature([...entitySchemas]),
        configModule,
        cacheModule,
        // Feature modules needed
      ],
      providers: [/* providers */],
      controllers: [/* controllers */],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    dataSource = app.get<DataSource>(DataSource);
    tenantRepository = app.get(getRepositoryToken(Tenant));
    // ... other repos
  });

  beforeEach(async () => {
    await cleanupTestState(app, dataSource);
    server = request(app.getHttpServer());

    // Setup external service mocks
    externalApiSpy = jest
      .spyOn(ExternalClient.prototype, 'method')
      .mockResolvedValue(expectedResult);
  });

  afterAll(async () => {
    await teardownTestApp(app, dataSource);
  });

  test('should do something', async () => {
    // ARRANGE
    const tenant = await tenantRepository.save(tenantFactory());

    // ACT
    const response = await server.post('/endpoint').send(payload).expect(201);

    // ASSERT
    expect(response.body).toMatchObject({ /* expected */ });
    expect(externalApiSpy).toHaveBeenCalledWith(/* args */);
  });
});
```

## Webhook Testing

```typescript
test('should process webhook and create records', async () => {
  // Setup: tenant, integration, integrationAccount, and any related records
  const tenant = await tenantRepository.save(tenantFactory());
  const integration = await integrationRepository.create(
    integrationFactory({ name: SupportedIntegration.ProviderA })
  );
  const account = await integrationAccountRepository.save(
    integrationAccountFactory({
      tenantId: tenant.id,
      integrationId: integration.id,
      externalAccountId: '2738',
    })
  );

  const webhookPayload = {
    orderNumber: '123456',
    accountId: 2738, // matches externalAccountId
    // ... rest of payload
  };

  await server
    .post('/v1/orders/webhooks?integration=provider-a')
    .set('host', 'api.provider-a.example.com')
    .send(webhookPayload)
    .expect(201);

  // Verify records created
  const orders = await orderRepository.find();
  expect(orders).toHaveLength(1);
  expect(orders[0].externalOrderId).toBe('123456');
});
```

## Duplicate Request Testing

```typescript
test('should return existing record without creating duplicate', async () => {
  // Setup
  const tenant = await tenantRepository.save(tenantFactory());
  const payload = { /* webhook data */ };

  // First request - creates
  await server.post('/endpoint').send(payload).expect(201);

  // Same request again - returns existing
  await server.post('/endpoint').send(payload).expect(200);

  // Verify only one record
  const count = await repository.count();
  expect(count).toBe(1);
});
```

## Bulk Operations

```typescript
test('should process multiple items in single operation', async () => {
  const orders = await Promise.all([
    orderRepository.createOrder(orderFactory({ sku: 'A' })),
    orderRepository.createOrder(orderFactory({ sku: 'B' })),
    orderRepository.createOrder(orderFactory({ sku: 'C' })),
  ]);

  await service.bulkUpdate([
    { sku: 'A', quantity: 10 },
    { sku: 'B', quantity: 20 },
    { sku: 'C', quantity: 30 },
  ]);

  const updated = await orderRepository.find();
  expect(updated.find(p => p.sku === 'A').quantity).toBe(10);
  expect(updated.find(p => p.sku === 'B').quantity).toBe(20);
  expect(updated.find(p => p.sku === 'C').quantity).toBe(30);
});
```

## Error Scenarios

```typescript
describe('when external API fails', () => {
  beforeEach(() => {
    externalApiSpy.mockRejectedValue(new Error('API Error'));
  });

  test('should continue processing other items when one fails', async () => {
    await service.syncAll(tenantId);

    // Other integrations still processed
    expect(otherApiSpy).toHaveBeenCalled();

    // Audit log shows partial failure
    const audit = await auditRepository.findOne({
      where: { action: 'Sync', status: 'Partial' },
    });
    expect(audit).toBeDefined();
  });
});

test('should return 400 when required field missing', async () => {
  const invalidPayload = { /* missing required field */ };

  const response = await server
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
  await service.updateStatus(orderId, 'Shipped');

  // ASSERT - main result
  const order = await orderRepository.findOne({ where: { id: orderId } });
  expect(order.status).toBe('Shipped');

  // ASSERT - side effects
  const audit = await auditRepository.findOne({
    where: { entityType: 'Order', entityId: orderId },
  });
  expect(audit.action).toBe('Update');
  expect(audit.newValue).toContain('Shipped');
});
```
