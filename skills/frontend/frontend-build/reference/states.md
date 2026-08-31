# Loading, Empty, Error

Four states ship with every data surface. Three of them are where features quietly go unfinished — the populated case gets built and reviewed, the rest get discovered by users.

The house components already exist; hand-rolling any of them is the finding.

## Loading

- **Tables:** pass `isLoading` to `DataTable`. It renders skeletons matched to the column layout. Don't wrap it in your own spinner.
- **Everything else:** `Skeleton` from `shared/components/ui/skeleton.tsx`, shaped like the final content — same number of lines, same widths, same card frame. A skeleton whose layout differs from the loaded state produces a visible jump; that jump is the defect.
- **Inline / action-scoped:** `Loader2` from lucide-react with `animate-spin`, inside the button that triggered the work, and the button disables while the mutation is pending (`disabled={mutation.isPending}`) — the spinner informs, the disable stops the double submit. A button that fires a mutation and doesn't change state is a hidden affordance.
- **Never a full-page spinner for partial data.** Sections resolve independently — one slow card doesn't blank the page.

## Empty — three different empties, don't conflate them

The distinction matters because the user's next action differs in each case.

**1. Genuinely nothing exists yet** → `EmptyState` (`shared/components/common/EmptyState.tsx`)

```typescript
<EmptyState icon={Package} title={t('products.empty.title')}
            description={t('products.empty.description')}
            action={<Button onClick={onImport}>{t('products.import')}</Button>} />
```

`compact` tightens padding for inline/table-cell empties; a `variant` picks the illustration where a surface has its own motif. A title is required; a description and an action are how the user gets unstuck — an empty state with no next step is a dead end.

**2. Nothing *in this window*** → `DateRangeEmptyBanner`. All primary KPIs zero because of the date filter, not because the account is new. It offers the global custom-range picker so the user can widen the window instead of guessing whether zero is real. Telling a tenant with a year of history that it has "no products" because the range is narrow is the failure this exists to prevent.

**3. Nothing *matching this filter*** → `FilterBanner` above the table (`scope` + `onClear`), so the user can see and drop the filter. Any surface whose tiles or chips act as filters uses this, not a local copy.

Adjacent: a single zero-valued KPI inside a card uses `KpiZeroState` in the card's value slot — the card's own title already names the metric.

**Paginated lists:** `useResetEmptyPage` — acting on the last rows of page 2 can drop the total to one page while the page index stays at 2, resolving empty. Gating the "next" button doesn't prevent it, because no navigation happened. Any paginated surface where rows can be removed needs this.

## Error

- **Mutations:** `toast.error(getErrorMessage(error, fallback))` in `onError`, plus the failure analytics event. The message must say what failed and what to do — "Something went wrong" is not actionable.
- **Queries:** React Query owns retries. Surface a failed query in place with a retry affordance (`refetch` is already returned by the table-data hooks); don't leave a skeleton spinning forever, and don't render an empty state — "no data" and "we couldn't load it" are different facts and the user acts differently on each.
- **Render-time crashes:** `ErrorBoundary` (`shared/components/common/ErrorBoundary.tsx`) — a thrown render doesn't take the app down.
- **Permission denials** are not errors: `PermissionGate` / `NoPermissionDialog`. A 403 rendered as a red toast reads as a bug in the product.

## Success

`SuccessCheck` for completion moments; `ExportSuccessState` for exports (see [api-contract.md](api-contract.md)). Not every success needs a moment — a toast is usually enough.

## Reviewing this

For each data surface in the diff, ask which of these four exist. The common shape of the finding: **populated + loading built, empty and error absent** — or a single `EmptyState` doing duty for all three empties, so a user with a narrow date filter is told their account is empty.
