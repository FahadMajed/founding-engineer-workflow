# Single-Tenant Adaptation

Many self-serve customers own exactly one scope entity — one brand, one store, one workspace, one project, whatever the app dimensions by. For them, a scope picker is a question with one answer, a scope column repeats a name they already know, and a one-row "comparison" table is a grid wrapped around a single fact. A scoped surface must treat N=1 as a designed state — like loading, empty, and error — not a degenerate render of the multi-entity layout.

Throughout, **"tenant"** = the dimensioning scope entity, whatever your app calls it.

## The primitive

A scope hook exposes the flag — never recompute it locally:

```ts
const { isSingleTenant, soleTenant } = useScope();
```

- **Universe, not selection.** `isSingleTenant` is keyed on the entities the user can access. Filtering down to one is a different state — name that one `*Selection` (e.g. `isSingleTenantSelection`, keyed on the store's `selectedTenantIds`).
- **Which flag gates an element:** *meaningless at one* (a comparison, ranking, or movers list of a single tenant — wrong to show however scope got there) dies on **either** flag. *Merely redundant at one* (scope labels, scope columns, the picker itself, the page skeleton) dies on **universe only** — under a transient filter the picker is the way back, and a skeleton that stays put lets a user flick between tenants without losing their scanning position. The universe state is permanent identity; a selection is attention, held for seconds.
- **Charts key on a third cardinality: result.** A pie/donut sliced by tenant gates on the rows the data returned (`chartData.length === 1` → a single-slice fallback), because one entity can dominate a period even in a multi-tenant, unfiltered view. So: universe → structure, selection → scoped content, result → comparison shape.
- **Zero is not one.** No tenants routes to empty/onboarding, never to the single-tenant layout.

## Deliberate focus is drill-down, not filter-morphing

When a multi-tenant user wants to live inside one tenant for a while, serve that with an explicit drill-down surface — the expandable-row pattern (row → full-width detail panel), with a visible enter and exit. Inside a drill-down the full single-tenant layout reapplies. Design the expanded one-tenant layout once; a single-tenant account gets it as the page's default state, a multi-tenant user reaches the same layout through the row.

## The adaptations

When `isSingleTenant`:

- **Don't ask** — on a browsing surface, hide scope pickers and filters; scope is implicit. (An auto-select-single-option helper handles forced-choice selects.) **Inside a consequential action dialog** (import, export, delete), don't hide the picker — auto-select the sole tenant and *lock it visible*, so the locked target confirms what the action will touch. The picker earns its place differently by surface: friction while browsing, a safety confirmation before a write.
- **Don't label** — drop scope columns, tags, and grouping headers; the user knows whose data this is. Re-flow the grid so remaining columns absorb the space (a single-column grid variant).
- **Don't compare** — cross-tenant rankings and movers either disappear or re-pivot to the next dimension down (channels, products). Prefer the re-pivot over a hole in the page. A pie of one is a solid disc saying 100% — render a single-slice fallback (total + entity identity) instead; it keeps the chart's exact footprint, so the content transforms while the skeleton stays put. That's the general trick for filter-sensitive surfaces: **adapt inside a stable frame**.
- **Don't tabulate one row** — a table guaranteed one row becomes an expanded detail layout instead.
- **Enjoy the space** — the single-tenant layout is designed, not the multi-tenant one with parts deleted. Spend the reclaimed room on what the multi-tenant grid couldn't afford: inline labels instead of icon-only dots, visible detail instead of tooltip-on-hover, depth on the one tenant.

## Cardinality is not persona

"Self-serve customer ⇒ one tenant" is a correlation, not a rule — keep it out of the code. Layout keys on cardinality (`isSingleTenant`), so a managed account with one tenant gets the same clean layout, and a customer who adds a second tenant graduates to the multi-tenant UI automatically. Genuine workflow and action differences between personas go through roles and permissions (`usePermissions`, `PermissionGate`) — never through a persona flag standing in for layout.
