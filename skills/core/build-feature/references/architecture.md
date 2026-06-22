# Architecture

How modules and services are structured.

## Module Structure

**Pattern A: Simple modules**

```
module_name/
├── module_name.controller.ts
├── module_name.entities.ts
├── module_name.module.ts
├── module_name.repository.ts
└── module_name.service.ts
```

**Pattern B: Complex modules**

```
module_name/
├── data/
│   └── repositories/
├── domain/
│   ├── module_name.entities.ts
│   └── services/
├── endpoints/
│   └── endpoint_name/
│       ├── endpoint.controller.ts
│       └── endpoint.dto.ts
└── module_name.module.ts
```

## Factory Pattern Usage With Polymorphism

Abstract client with provider-specific implementations — one per external integration.

```typescript
// Factory creates appropriate client
@Injectable()
export class IntegrationClientFactory {
  getClient(options: {
    integrationAccount: IntegrationAccount;
  }): IntegrationClient {
    switch (integration.name) {
      case 'ProviderA':
        return new ProviderA(credentials, this.repo);
      case 'ProviderB':
        return new ProviderB(credentials);
      // ...
    }
  }
}

// Abstract base
export abstract class IntegrationClient {
  abstract syncData(): Promise<void>;
  abstract getOrders(dateRange: DateRange): Promise<Order[]>;
}

// Implementation
export class ProviderA extends IntegrationClient {
  async syncData() {
    /* ProviderA-specific */
  }
}
```

## Service Layer Rules

1. **No logging in services** - Rethrow errors, global filter logs them
2. **Named parameters** for 2+ args: `createOrder(request: CreateOrderRequest)` (see [conventions.md](conventions.md))
3. **Audit logging** for business events via `AuditRepository` (enums in [entities-and-migrations.md](entities-and-migrations.md))

```typescript
try {
  const result = await this.performOperation();
  await this.auditRepository.createAuditLog({
    entityType: AuditEntityType.Order,
    action: AuditAction.Create,
    status: AuditStatus.Success,
    entityId: result.id,
  });
  return result;
} catch (error) {
  // Audit failure if needed or some logic, then rethrow
  throw error;
}
```
