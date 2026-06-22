# Permissions & Tenant Scoping

Lookup table — skim the section for the concern you're wiring.

## Guard stack (global, runs in order)

Every route passes through these unless it opts out. Registered as `APP_GUARD` in the app module.

1. `AuthenticationGuard` — validates the JWT, attaches the user
2. `AuthorizationGuard` — enforces `@Permissions`
3. `TenantOwnershipGuard` — enforces tenant scope

Bypass auth entirely: `@PublicEndpoint()` (the public-endpoint decorator).

## Guarding a route

`@Permissions({ resource, action })` — import from the authorization guard. The guard checks the user has a `ScopedPermission` whose `action` column equals `${resource}.${action}` (e.g. `'orders.list'`). Permission rows live in `scoped_permissions`.

```typescript
@Get('orders')
@Permissions({ resource: Resource.orders, action: Action.list })
```

## Resource

The scoped-permission entity. Enum keys are camelCase; **wire values are kebab-case strings** (e.g. `creditNotes = 'credit-notes'`).

```
users, organizations, orders, reports, settings, audit, exports,
notifications, invoices, credit-notes
```

Adding a new resource: add a member here. No migration — permissions are rows in `scoped_permissions.action` as `'{resource}.{action}'`.

## Action

Reuse an existing verb; don't invent new ones.

```
read, list, create, update, delete, export,
import, sync, publish, unpublish, issue, send
```

## Current user + tenant scoping

`@CurrentUser()` (the current-user decorator) injects `AuthenticatedUser` (also exported from the authorization guard). The guard fills `user.tenantIds` from the user's role + scoped permissions. It can be `undefined` — that means **all tenants** (admin roles).

When the caller doesn't pass explicit `tenantIds`, fall back to `user.tenantIds` and filter queries by it:

```typescript
const tenantIds = query.tenantIds ?? user.tenantIds;
```

Anchor: a guarded list controller.

### `undefined` means ALL tenants — never coerce it to `[]`

`user.tenantIds` carries three cases — keep them distinct end to end:

- `undefined` → **all tenants** (admin roles, and elevated roles with `*` scope when an "include all" flag is set).
- empty array → a caller scoped to **no** tenants → reads **nothing**.
- populated array → exactly those tenants.

Controllers pass the value straight through — never coerce it to `[]`, which throws away the `undefined` signal:

```typescript
return this.service.getX(user.tenantIds, …);   // not `user.tenantIds ?? []`
```

Repositories apply the tenant scope through `scopeByTenant` / `tenantScopeParam` (the shared tenant-scope helper), which keep the three cases apart:

```typescript
// QueryBuilder filter
scopeByTenant(qb, 'order.tenantId', tenantIds);

// raw SQL gated on `($n::int[] IS NULL OR col = ANY($n))`
const tenantIdsParam = tenantScopeParam(tenantIds);
```

Never hand-roll the filter as `if (tenantIds?.length) { …tenantId IN (tenantIds) }` — collapsing an empty scope into "all tenants" leaks every tenant's rows to a caller scoped to none. A guardrail spec fails the build if the idiom reappears in a repository. (Distinct from the id-lookup empty guard in [data-access.md](data-access.md), where `if (!ids.length) return []` is about avoiding invalid `IN ()` SQL, not tenant scope.)
