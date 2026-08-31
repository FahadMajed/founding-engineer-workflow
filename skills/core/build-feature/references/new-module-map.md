# New Module Map

Start here. Walk the scoping checklist, then open **only** the domain references your feature touches. The three craft files are read in full every time ([architecture.md](architecture.md), [conventions.md](conventions.md), [data-access.md](data-access.md)); the domain files below are lookup tables — skim the section you need, don't read end to end.

Gold-standard module to copy: pick the most mature CRUD module in the repo and mirror its layout.

## Scoping checklist

Each "yes" pulls in a domain reference.

| If your feature… | Read |
|---|---|
| Persists data | [entities-and-migrations.md](entities-and-migrations.md) |
| Exposes HTTP | [permissions.md](permissions.md) + DTO/pagination/errors in [conventions.md](conventions.md) |
| Answers a client with a failure a person in the flow can act on | [domain-errors.md](domain-errors.md) (stable code + localized message) |
| Other code reacts to it | [events.md](events.md) (emit) |
| Reacts to things elsewhere | [events.md](events.md) (consume) |
| Runs on a schedule | [crons-and-sync.md](crons-and-sync.md) (`@RunEvery`) |
| Scheduled work with units — per account, per tenant | [crons-and-sync.md](crons-and-sync.md) (`enqueueUnits` + a handler, so a failed unit retries) |
| Scheduled work with no units, or a monotone sweep | [crons-and-sync.md](crons-and-sync.md) (`withCronTracking` + advisory lock + `SyncType`) |
| Runs work inside a queued handler | [queue-error-verdicts.md](queue-error-verdicts.md) (retry / terminal / deferral) |
| Returns large lists | pagination in [conventions.md](conventions.md) |

## Concern map

| Concern | Read | Anchor to copy |
|---|---|---|
| Entity, schema registration, migration, column types, encryption, audit enums | [entities-and-migrations.md](entities-and-migrations.md) | a `<module>.entities.ts` |
| Permissions + tenant scoping | [permissions.md](permissions.md) | a guarded list controller |
| Emit / consume domain events | [events.md](events.md) | a `<module>.events.ts` |
| Scheduled jobs, fan-out units, sync types, advisory locks | [crons-and-sync.md](crons-and-sync.md) | the sync-job service, the shared `enqueueable-events.ts` |
| Repository, queries, transactions, locks | [data-access.md](data-access.md) | a `<module>.repository.ts` |
| DTO, validation, pagination, error shape | [conventions.md](conventions.md) | a `<module>.dto.ts` |
| Stable error codes a client keys off, localized messages | [domain-errors.md](domain-errors.md) | a `<module>.errors.ts` |
| Whether a thrown error retries, gives up, or defers | [queue-error-verdicts.md](queue-error-verdicts.md) | the shared `retryable-error.ts` |
| Base class where only *some* subclasses support an operation | [optional-capabilities.md](optional-capabilities.md) | an adapter with a nullable capability getter |
