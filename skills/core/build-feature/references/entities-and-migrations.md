# Entities & Migrations

Lookup table for defining persisted data. For reading/writing it at runtime see [data-access.md](data-access.md).

## EntitySchema (not decorators)

Entities are defined with TypeORM `EntitySchema`, not decorator classes. A `<module>.entities.ts` file exports the plain class plus its `EntitySchema`.

Register every schema in the central entities array, then import it into the module via `TypeOrmModule.forFeature([...Schemas])`.

## Column types

- **Enum** — `type: POSTGRES ? 'enum' : 'varchar'`, `enum: MyEnum`. Export `const myList = Object.values(MyEnum)` for class-validator.
- **Money** — `type: 'decimal'` + `precision`/`scale` + `transformer: decimalTransformer` (in the shared transformers helper), so reads come back as numbers, not strings.
- **Encrypted secret** — `transformer: EncryptedStringTransformer` (in the shared encryption helper). AES-256-GCM, `enc:v1:` prefix, key from an env secret. Transparent on read/write; legacy plain values pass through. Use for any token/key/secret column (`accessToken`, `refreshToken`, `apiKey`, `apiSecret`).
- **Flexible config** — `'jsonb'` (queryable) or `'json'`; `'simple-array'` for string lists.
- **Composite uniqueness / invariants** — `indices: [{ columns, unique: true }]` and `checks: [{ name, expression }]`.

## Migrations

File: `migrations/<timestamp>-<PascalDescription>.ts` with `up`/`down` raw SQL.

- Use `IF NOT EXISTS` / `IF EXISTS` so reruns are safe.
- Columns are camelCase and **must be quoted** in SQL (`"tenantId"`).

### Changing an enum

Add a value with Postgres's built-in `ALTER TYPE`, never by recreating the type:

```sql
ALTER TYPE "shipments_status_enum" ADD VALUE IF NOT EXISTS 'ReturnedSellable';
```

- TypeORM names the type `<table>_<column-lowercased>_enum` (e.g. `orders_status_enum`); a few are hand-named (`sync_type`). Confirm the exact name with `\dT` in psql.
- Postgres **can't remove** an enum value — leave `down` empty (recreating the type is risky). Reword rows to another value first if you must drop one.
- A newly added value **can't be referenced in the same transaction** it's added in — use it in a separate, later migration.

## Audit logging

Business mutations record an `AuditLog` via `AuditRepository.createAuditLog`. Enums in the audit entities file:

- **AuditEntityType** — one member per entity that records audit events (e.g. Order, Report, User)
- **AuditAction** — Create, Update, Delete, Settlement, Sync
- **AuditStatus** — Success, Partial, Failed

```typescript
await this.auditRepository.createAuditLog({
  entityType: AuditEntityType.Order,
  action: AuditAction.Create,
  status: AuditStatus.Success,
  entityId: result.id,
});
```
