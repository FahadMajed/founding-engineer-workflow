# Code Map

Start here for anything below the pixels. The design smells cover what a screen *looks like*; these cover what the code *is* — structure, naming, data layer, contract.

Gold-standard feature to copy: the most complete CRUD feature in the repo — `src/features/accounts/` in this map's examples. Read-heavy with rich URL filters + export: `src/features/orders/`. Hierarchical drill-down: whichever feature nests a parent entity over its children.

Read in full every time: [feature-structure.md](feature-structure.md), [naming-and-language.md](naming-and-language.md). The rest are lookup tables — open the section you need.

## Scoping checklist

Each "yes" pulls in a reference.

| If the diff… | Read |
|---|---|
| **Adds a new page, or a summary/status/attention surface on an existing one** | [surface-ownership.md](surface-ownership.md) — read it *before* building; which question your page answers decides what belongs on it |
| Adds or changes a service method | [data-layer.md](data-layer.md) + [api-contract.md](api-contract.md) |
| Adds a React Query hook | [data-layer.md](data-layer.md) (key factory, invalidation) |
| Mutates server state | [data-layer.md](data-layer.md) (analytics on success *and* failure) |
| Holds any page-level state (tabs, filters, pagination, selected view) | [state.md](state.md) |
| Touches a channel, an integration, or anything whose real identity is a composite | [composite-identity.md](composite-identity.md) — **highest-stakes rule in the repo** |
| Adds user-facing text | [i18n-rtl.md](i18n-rtl.md) (keys, register, RTL) + [copy.md](copy.md) (what the words say) |
| Is scope-dimensioned (a tenant filter, a tenant column, per-tenant rows) | [single-tenant.md](single-tenant.md) |
| Swaps content in place — tab, view toggle, lens, filter-driven panel | `docs/motion-guidelines.md` (your project) → Switching between states (a keyed `FadeIn`, never a hard swap) |
| Adds hover / focus / press feedback, or any animation | `docs/motion-guidelines.md` (your project) → Interaction feedback + Rules |
| Fetches on a chain, polls, renders a growable list, computes over rows, or adds a dependency | [perf.md](perf.md) — what it costs the user, priced in numbers. `perf-sweeper`'s lane, outside the conventions contract |
| Renders loading / empty / error | [states.md](states.md) |
| Sets type scale, weight, or colour for emphasis | [hierarchy.md](hierarchy.md) |
| Creates a component | [shadcn-first.md](shadcn-first.md) |
| Mocks an API ahead of the backend | [api-contract.md](api-contract.md) (a mock is not licence to invent the contract) |

## Concern map

| Concern | Read | Anchor to copy |
|---|---|---|
| Which surface owns which question — home / tenant health / sync health vs a leaf page | [surface-ownership.md](surface-ownership.md) | the panel a leaf feature contributes *to* the hub, rather than re-answering it in place; `reference/smells/drilldown-without-surface.md` |
| Folder layout, file naming, what goes where | [feature-structure.md](feature-structure.md) | `src/features/accounts/` |
| Static service class, request params, response envelope | [data-layer.md](data-layer.md) | `features/accounts/services/accounts.service.ts` |
| Query key factory, mutation invalidation, analytics | [data-layer.md](data-layer.md) | `features/accounts/hooks/useAccounts.ts` |
| Pagination + prefetch hook | [data-layer.md](data-layer.md) | `features/accounts/hooks/useAccountsTableData.ts` |
| URL state, global filters, Zustand vs useState | [state.md](state.md) | `features/accounts/pages/AccountsPage.tsx`, `shared/store/globalStore.ts` |
| Domain vocabulary, hook/component/flag naming | [naming-and-language.md](naming-and-language.md) | `shared/hooks/useScope.ts` |
| Composite identity, region, display labels | [composite-identity.md](composite-identity.md) | `shared/utils/channel-display.ts` |
| Request/response shape, export endpoints, pagination envelope | [api-contract.md](api-contract.md) | `features/orders/services/orders-export.ts` |
| Translation keys, every configured locale, logical properties | [i18n-rtl.md](i18n-rtl.md) | `src/locales/*.json`, `reference/smells/silent-translation-fallback.md`, `reference/smells/double-flipped-icons.md` |
| What the words say — leakage, labels, glossing, cross-locale agreement | [copy.md](copy.md) | reviewed by `copy-sweeper` |
| Runtime cost — waterfalls, refetch storms, renders per input, volume, chunk weight | [perf.md](perf.md) | reviewed by `perf-sweeper` |
| Loading / empty / error / zero | [states.md](states.md) | `shared/components/common/EmptyState.tsx` |
| Emphasis, weight, muted text | [hierarchy.md](hierarchy.md) | `reference/smells/size-for-hierarchy.md` |
| Motion — entrances, state switches, interaction feedback, timing tokens | `docs/motion-guidelines.md` (your project) | `shared/components/motion/`, `shared/utils/motion.ts` |
| Route + nav + breadcrumb + permission wiring | [feature-structure.md](feature-structure.md) | `app/router.tsx`, `shared/utils/navConfig.ts` |

## What is already mechanical — don't re-derive it by eye

`node scripts/verify-feature.mjs <feature>` decides these; read its output instead of re-checking:

- every `t()` key exists in **every** configured locale file (hard fail)
- register warnings on the feature's own strings in the second locale — the progressive-tense and calqued forms on its denylist (warn). It proves a key *exists* in each locale; it cannot prove the translation means what the primary language means — that's [copy.md](copy.md)
- no `pt-`/`py-` on `CardHeader`/`CardContent` (hard fail — stacks with `Card`'s own `gap-6`/`py-6`)
- feature has mutations but no analytics events (warn)
- off-scale spacing `5/7/9/10/11` (warn)

A warning is not skippable: fix it, or justify it in the same breath.
