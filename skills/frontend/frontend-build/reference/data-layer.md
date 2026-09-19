# Data Layer

Services, React Query hooks, mutations, analytics. Anchors: `features/accounts/services/accounts.service.ts`, `features/accounts/hooks/useAccounts.ts`, `features/accounts/hooks/useAccountsTableData.ts`.

## Services — static classes over `apiClient`

```typescript
import apiClient from '@/lib/api-client';

export class AccountsService {
  static async getAccounts(params?: { page?: number; limit?: number; search?: string }) {
    const response = await apiClient.get<AccountsListResponse>('/accounts', { params });
    return response.data;
  }
}
```

- **Always `apiClient`** (`@/lib/api-client`) — never a bare `axios` call or `fetch`. The client owns baseURL, auth header, token refresh (single-flight on 401), and error transformation into `ApiError`. Bypassing it means a request that doesn't refresh its token and doesn't surface a usable error.
- **Static methods, no instances.** No `new AccountsService()`.
- **No React inside a service** — no hooks, no `toast`, no `t()`. The hook layer owns those.
- **The service returns `response.data`**, not the Axios response. Callers never see `.data.data`.
- **Declare the request shape you actually send.** A method whose endpoint takes filters/sort/pagination declares those params — see [api-contract.md](api-contract.md).

## Query key factory — one per hook file

Every hook file exports a `{domain}Keys` object. The hierarchical form is the full version; smaller features use a subset of the same shape.

```typescript
export const accountsKeys = {
  all: ['accounts'] as const,
  lists: () => [...accountsKeys.all, 'list'] as const,
  list: (params?: ListParams) => [...accountsKeys.lists(), params] as const,
  details: () => [...accountsKeys.all, 'detail'] as const,
  detail: (id: number) => [...accountsKeys.details(), id] as const,
};
```

- **`as const` on every level** — without it the key widens to `string[]` and prefix invalidation stops type-checking.
- **Nest through the parent** (`[...accountsKeys.lists(), params]`), never re-type the root string. A hand-built `['accounts', 'list', params]` array inside a component is the finding — it silently misses invalidation.
- **Params are part of the key**, so a filter change refetches.

## Mutations — the five-part `onSuccess`

Every mutation does all of these. A missing one is a finding:

```typescript
return useMutation({
  mutationFn: (data: CreateAccountRequest) => AccountsService.createAccount(data),
  onSuccess: (response) => {
    queryClient.invalidateQueries({ queryKey: accountsKeys.lists() });      // 1. invalidate
    toast.success(response.message ?? t('accounts.accountCreated'));        // 2. tell the user
    analytics.accountCreated();                                             // 3. track success
  },
  onError: (error: unknown) => {
    const errorMessage = getErrorMessage(error, 'Failed to create account'); // 4. extract
    toast.error(errorMessage);
    analytics.accountCreateFailed(errorMessage);                             // 5. track failure
  },
});
```

- **`getErrorMessage(error, fallback)`** from `@/lib/api-client` — never `error.message` directly, never `(error as any).response.data.message`. It already handles `ApiError`, raw `AxiosError`, and array-valued messages.
- **Invalidate the list, and the detail when you touched one** — `useUpdateAccount` also `setQueryData(accountsKeys.detail(id), updated)` to seed the cache instead of forcing a refetch.
- **Success text prefers the server's `message`** when the endpoint returns one, falling back to a translation key.

## Analytics — both paths, always

Every state-changing server action fires an event on **success and failure**, via the `analytics` helper in `lib/analytics.ts`.

- **Method naming:** `{thing}{Verb}` / `{thing}{Verb}Failed` — `accountCreated` / `accountCreateFailed`, `productUpdated` / `productUpdateFailed`. The failure method takes the reason string.
- **Event naming:** the pair shares one `category:object_action` name and splits on `status` — `accountCreated` and `accountCreateFailed` both send `account:create`, with `status: 'success'` / `status: 'failure'`. The object is dropped from the action when the category already names it (`account:create`, not `account:account_create`); it's spelled out when the category covers several (`ads:campaign_create` beside `ads:item_add`). The method is what the caller reads; the event is what the analysis groups by. A runtime value never enters the name — it's a property.
- Only `lib/analytics.ts` names an event, and only `lib/analytics-client.ts` — the single module that talks to your analytics tool — captures one. A component calling `track()` or the vendor client's `capture()` directly drops the envelope; `verify-feature.mjs` fails on it.
- Covers `useMutation` (`onSuccess`/`onError`) **and** raw `async` service-call handlers — log after the `await`, `try/catch` + re-throw on failure.
- Adding a mutation means adding the matching `analytics.*` methods. `node scripts/verify-feature.mjs <feature>` warns when a feature has mutations and no analytics; that warning is the floor, not the spec — it can't tell whether *every* mutation is covered.
- **Exempt:** trivial read-state toggles (mark seen/unread) and purely client-side/localStorage state.

## Table data hooks

`use{Domain}TableData` wraps the query hook and owns pagination mechanics. It returns a flat, table-ready shape — not the raw response:

```typescript
return { data: data?.accounts ?? [], isLoading, error, page, limit, total,
         hasNextPage, prefetchNextPage, prefetchPreviousPage, refetch };
```

- **`extractPagination(data, fallback)`** from `@/shared/types/pagination.types` — the response envelope varies by endpoint, and this normalizes it. Reading `data.pagination.totalPages` directly is the finding.
- **Prefetch both directions** with `staleTime: 5 * 60 * 1000`, keyed through the factory.
- The hook takes plain params, not the nuqs setters — the page owns URL state ([state.md](state.md)).

## Loading and error surfacing

- Skeletons: `DataTable` renders them from the `isLoading` prop — pass it, don't hand-roll.
- Errors: toast for user feedback; React Query owns retries. See [states.md](states.md).
