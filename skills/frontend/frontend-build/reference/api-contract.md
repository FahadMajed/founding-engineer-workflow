# API Contract

What the frontend may assume about a request and response — and, when building ahead of the backend, what shape it is *committing the backend to*.

## Read one real endpoint before writing a new one

The contract is not designed here; it is matched. Open the nearest existing service and copy its envelope, its param names, its pagination, its error shape. `features/accounts/services/accounts.service.ts` is the plain case; `features/orders/services/orders-export.ts` is the export case.

## Pagination

The list envelope is `{ items, pagination: { page, limit, total, totalPages } }`, with flat `page`/`limit`/`total` fields on older endpoints. Consumers **never** read either directly:

```typescript
import { extractPagination } from '@/shared/types/pagination.types';
const pg = extractPagination(data, { page: params.page, limit: params.limit });
```

`extractPagination` absorbs both formats. Reading `data.pagination.totalPages` inline is the finding — it breaks on the endpoints that return flat fields.

Page size defaults come from `DEFAULT_PAGE_SIZE` in `shared/constants/pagination`, not a local literal.

## Request side — model it, don't skip it

A method whose endpoint takes filters, sort keys, a date range, or pagination **declares those parameters** and returns the matching envelope. Filters go in `params` (query string), bodies in the second argument:

```typescript
apiClient.get<AccountsListResponse>('/accounts', { params });
apiClient.post<OrderExportResponse>('export/orders', undefined, { params: {...} });
```

- **Tenant scoping is `tenantIds`** — the house param name. Not `tenants`, not `tenantId` for a multi-value filter.
- A visible control whose value never reaches the service is a latent bug. Shown ⇒ wired.
- **Channels are sent as ids, not names** — see [composite-identity.md](composite-identity.md).

## Exports are async and emailed — not client-built blobs

This is the trap that gets invented most often. The house pattern:

```typescript
export interface OrderExportResponse { success: boolean }

static async exportOrders(request: OrderExportRequest): Promise<OrderExportResponse> {
  const response = await apiClient.post<OrderExportResponse>('export/orders', undefined, { params: {...} });
  return response.data;
}
```

`POST export/{thing}` with filters as query params, returning `{ success }`. The backend builds the workbook and **emails it**. The UI then renders `ExportSuccessState` with `deliveryMethod="email"` (`shared/components/common/ExportSuccessState.tsx`).

The endpoints follow one shape: `export/orders`, `export/products`, `export/listings`, `export/reports`, `export/period-comparison`, `export/purchase-orders`.

Never: a client-side blob/CSV assembled in the browser, or an imagined signed download URL. If a genuinely synchronous download is needed, that is a backend decision to raise, not a shape to guess — and `ExportSuccessState` already has a `deliveryMethod="download"` variant for when it is agreed.

## Errors

`api-client` transforms failures into `ApiError` (`message`, `status`, `code?`, `details?`) and single-flights token refresh on 401. Consumers extract text with `getErrorMessage(error, fallback)` — never `error.message` directly, never digging into `error.response.data` (`ApiError` is a plain `Error` subclass; there is no `.response`).

**The API answers in the language we ask for.** `api-client` sends `Accept-Language` from `i18n.language` on every request, so a server message reads in the same language as the screen it lands on — the person's choice in the app, never the browser's preference.

**A coded failure is worded here, not echoed.** Where the backend gives a failure a stable `code`, the codes are camelCase *because they are i18n keys* — so the screen derives the key and there is no map to maintain:

```ts
const ERROR_KEYS = 'channelAccounts.dialog.connect';
const key = code && /^[A-Za-z0-9_]+$/.test(code) ? code : null;
return t(key ? `${ERROR_KEYS}.${key}` : `${ERROR_KEYS}.connectFailed`, {
  defaultValue: t(`${ERROR_KEYS}.connectFailed`),
});
```

Two rules that are not optional. **Sanitize the code before using it as a key** — it arrives from the server, and a dotted value walks out of the namespace into some unrelated string. **Always give a `defaultValue`** — a code with no string yet must fall back to the feature's generic failure, never render the raw key and never pass the server's own text through, which may name internals.

Exemplar: `features/channel-accounts/utils/connect-error.ts`.

**Do not write a code→key map.** Its two failure modes both render a real sentence, so neither looks broken: reading the code off the wrong property kills every message at once, and one entry pointing at a key from another step gives a fluent answer to the wrong question. Deriving the key removes the place either can live. When a mapping does exist, check it by triggering the failure, never by reading it.

## Building against a mock — the shapes are the contract

A mocked service is production code with the API layer stubbed. Only the **values** get replaced when the backend lands; the types, method signatures, and response shapes are what the backend implements.

- **Shape-complete, not value-complete.** Every field the real response must carry is present and typed, even if mock values repeat.
- **Every state gets a shape** — empty, loading, error, plus the domain's real ones (pending reconciliation, no-signal-per-channel, optional fields present *and* absent, account-level vs per-item rows). A state with no shape is a state the backend won't know to return.
- **Never hardcode a value the backend must compute.** A derived field (trailing average, reconciliation delta, aggregate) is typed and given a plausible mock number, so the design doc records that the backend computes it.
- **Mock at the scale being signed** — the tenant with thousands of SKUs, the account with dozens of records. A surface that only works at demo volume should fail in the demo, not at onboarding.
- Mark each stub `// TODO: Replace with real API`.
- **A speculative comment is the tell you guessed** ("the real API may hand back a signed URL instead"). Go read the existing endpoint instead.

At frontend sign-off, the mock types + service signatures are extracted to `docs/discovery/{feature}/contract-draft.md` for the backend design doc to consume. The backend owns the final contract; the frontend adapts at wiring time.
