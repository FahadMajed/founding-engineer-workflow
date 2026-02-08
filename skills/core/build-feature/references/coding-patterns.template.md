# Coding Patterns

Codebase-specific patterns. Customize this for your project.

## Entity/Model Pattern

Describe how your project defines data models:

```
{{YOUR_ENTITY_PATTERN}}

Example:
- Decorator-based (TypeORM decorators, Prisma)
- Schema-based (TypeORM EntitySchema, Mongoose schemas)
- Plain classes with validation
```

## Repository/Data Access Pattern

Describe your data access layer:

```
{{YOUR_REPOSITORY_PATTERN}}

Example:
- Custom repository classes
- Direct ORM usage
- Repository pattern with abstraction
```

Key methods your base repository provides:
- `{{METHOD_1}}` - description
- `{{METHOD_2}}` - description

## Module/Feature Structure

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
│   ├── entities/
│   └── services/
├── endpoints/
│   └── endpoint_name/
│       ├── endpoint.controller.ts
│       └── endpoint.dto.ts
└── module_name.module.ts
```

## Factory Pattern (if applicable)

For polymorphic behavior (e.g., multiple integrations):

```typescript
// Factory creates appropriate client
@Injectable()
export class {{YourFactory}} {
  getClient(options: { type: string }): {{YourAbstractClient}} {
    switch (type) {
      case 'TypeA':
        return new TypeAClient(credentials);
      case 'TypeB':
        return new TypeBClient(credentials);
    }
  }
}

// Abstract base
export abstract class {{YourAbstractClient}} {
  abstract doOperation(): Promise<void>;
}
```

## Service Layer Rules

1. **Error handling:** {{YOUR_ERROR_HANDLING_PATTERN}}
2. **Parameter style:** Named parameters for 3+ args
3. **Logging:** {{YOUR_LOGGING_PATTERN}}
4. **Auditing:** {{YOUR_AUDIT_PATTERN}}

## Concurrency Handling (if applicable)

For operations where concurrent execution corrupts data:

```
{{YOUR_LOCKING_PATTERN}}

Examples:
- Advisory locks
- Row-level locking
- Optimistic concurrency
- Distributed locks
```

## Naming Conventions

- **Entity classes**: {{YOUR_ENTITY_NAMING}} (e.g., PascalCase singular)
- **Table names**: {{YOUR_TABLE_NAMING}} (e.g., snake_case plural)
- **Foreign keys**: {{YOUR_FK_NAMING}} (e.g., entityNameId)
- **Booleans**: {{YOUR_BOOL_NAMING}} (e.g., isCondition)
- **Methods**: {{YOUR_METHOD_NAMING}} (e.g., createEntity, getEntityById)

## Documentation Style

When to add JSDoc/comments:
- {{WHEN_TO_DOCUMENT}}

When to skip:
- {{WHEN_NOT_TO_DOCUMENT}}

```typescript
// Good: caller learns something useful
/** Syncs data. TypeA is async (queue), TypeB is sync. Fails silently per item. */

// Bad: restates the signature
/** Gets item by ID @param id - item ID @returns item */
```

## Shared Logic

Where to put reusable code:
- {{YOUR_SHARED_CODE_LOCATION}}
