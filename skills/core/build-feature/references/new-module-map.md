# New Module Map

Start here. Walk the scoping checklist, then open **only** the domain references your feature touches. The three craft files are read in full every time ([architecture.md](architecture.md), [conventions.md](conventions.md), [data-access.md](data-access.md)); the domain files below are lookup tables — skim the section you need, don't read end to end.

Gold-standard module to copy: pick the most mature CRUD module in the repo and mirror its layout.

## Scoping checklist

Each "yes" pulls in a domain reference.

| If your feature… | Read |
|---|---|
| Persists data | [entities-and-migrations.md](entities-and-migrations.md) |
| Exposes HTTP | [permissions.md](permissions.md) + DTO/pagination/errors in [conventions.md](conventions.md) |
| Other code reacts to it | [events.md](events.md) (emit) |
| Reacts to things elsewhere | [events.md](events.md) (consume) |
| Runs on a schedule | [crons-and-sync.md](crons-and-sync.md) (`@RunEvery`) |
| Has scheduled work that must not overlap / corrupts data on concurrent runs | [crons-and-sync.md](crons-and-sync.md) (`withCronTracking` + advisory lock + `SyncType`) |
| Returns large lists | pagination in [conventions.md](conventions.md) |

## Concern map

| Concern | Read | Anchor to copy |
|---|---|---|
| Entity, schema registration, migration, column types, encryption, audit enums | [entities-and-migrations.md](entities-and-migrations.md) | a `<module>.entities.ts` |
| Permissions + tenant scoping | [permissions.md](permissions.md) | a guarded list controller |
| Emit / consume domain events | [events.md](events.md) | a `<module>.events.ts` |
| Scheduled jobs, cron tracking, sync types, advisory locks | [crons-and-sync.md](crons-and-sync.md) | the sync-job service |
| Repository, queries, transactions, locks | [data-access.md](data-access.md) | a `<module>.repository.ts` |
| DTO, validation, pagination, error shape | [conventions.md](conventions.md) | a `<module>.dto.ts` |
