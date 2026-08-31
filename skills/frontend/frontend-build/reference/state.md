# State

Five places state can live. Picking the wrong one is the most common structural finding in a frontend diff, because the wrong choice still works locally — it fails as "I can't share this link" or "the filter reset when I came back".

| Need | Solution | Anchor |
|---|---|---|
| Server data | React Query | `features/*/hooks/use*.ts` |
| Page state — tabs, filters, pagination, selected view, search | **nuqs** | `features/accounts/pages/AccountsPage.tsx` |
| Global UI state | Zustand | `shared/store/globalStore.ts` |
| Feature-specific global | Zustand | `shared/store/scopeStore.ts` |
| Auth / user | Zustand + localStorage | `features/auth/store/authStore.ts` |
| Local component | `useState` | dialog open, hovered row, selected item within a dialog |

## nuqs is the default for anything a page owns

```typescript
const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
const [search, setSearch] = useQueryState('search', parseAsString);
const [roles, setRoles] = useQueryState('role', parseAsArrayOf(parseAsString).withDefault(['all']));
```

- **`useState` for a tab, a filter, a page number, or a chosen view is the finding.** A view you can't link to is a view you can't share — and the state dies on refresh and on back-navigation.
- `useState` is right for state with no meaning outside the moment: dialog open/closed, which row is hovered, form draft inside a dialog (React Hook Form owns that anyway).
- The page reads URL state and passes plain values down. Hooks take params, not setters — a `use{Domain}TableData` that imports nuqs has absorbed the page's job.

## Global header filters — configured, consumed, threaded

Tenant / channel / date filters live in the app header and are driven by `PAGE_UI_CONFIGS` in `shared/store/globalStore.ts`. A page does **not** render its own tenant or date picker.

Every page:

1. **Has its own config key** in `PAGE_UI_CONFIGS` declaring exactly the filters its capability uses (`showDateRangePicker`, `showChannelFilter`, `showTenantFilter`, `showComparePeriodPicker`, `showCategoryFilter`, `showTierFilter`, and `excludedChannelGroups` where a group doesn't apply).
2. **Announces itself** — `const setCurrentPage = useGlobalStore((s) => s.setCurrentPage)` in an effect. Reusing a parent's key shows the child filters that don't apply to it.
3. **Threads visible filters into the service call.** Shown ⇒ wired. A filter rendered but not passed is a latent bug that only surfaces later, when nobody remembers it was never connected.

Follow the depth pattern: a list shows the full set; a detail drops the dimension it has fixed (no tenant filter on a single-tenant page); the deepest drill turns them off entirely when it locks its own window.

## Zustand — for state that is genuinely global

Three stores exist. Adding a fourth needs a reason that isn't "it was convenient":

- `globalStore.ts` — page UI config, breadcrumb labels, header filter surface
- `scopeStore.ts` — tenant scope and selection
- `scopeSettingsStore.ts` — scope settings read by `api-client`

Use `useGlobalStore((s) => s.thing)` selector form, not whole-store destructuring — the latter re-renders on every unrelated change.

## The single-tenant scope is one pick, shared and persisted

Surfaces that operate *inside* one tenant — channel accounts, warehouse accounts, sync health, catalog mapping — share a single pick: `scopeStore.selectedTenantId`, read through **`useSelectedTenant()`**. It is persisted to localStorage and mirrored to `?tenantId=` by `GlobalFiltersUrlSync`, so the pick survives navigation, a reload, and a deep link, and the user is asked once instead of once per page.

- **A page-local `useQueryState('somethingTenantId')` is the finding.** It looks like ordinary page state and reads like nuqs done right, but it makes an island: the user re-picks the same tenant on arrival, and a deep link into that page speaks a param no other page understands. Use the hook; the URL addressability you'd reach for nuqs to get is already there.
- **The hook drops a pick the tenant universe no longer contains** (another user in the same browser, a deactivated tenant, a narrowed scope setting), so the page falls back to "choose a tenant" instead of querying a tenant that isn't there. Never read `selectedTenantId` off the store directly to skip that check.
- Distinct from `selectedTenantIds`, the global multi-tenant **filter** — that one is attention held for a moment, so it stays session-scoped, along with the date range. Scope persists; filters don't.

## Derived state is derived, not stored

A value computable from server data + URL state is computed (`useMemo` where cost justifies it), never mirrored into `useState` and synced with an effect. A `useEffect` whose only job is `setX(derive(y))` is the finding.

Special case with teeth: **tenant cardinality**. `useScope()` exposes `isSingleTenant` / `soleTenant` off the tenant *universe*. Recomputing a count locally, or keying off the filtered selection, flips the page into single-tenant mode when a user filters to one tenant. Name selection-cardinality flags `*Selection` so the two never blur. See [single-tenant.md](single-tenant.md).
