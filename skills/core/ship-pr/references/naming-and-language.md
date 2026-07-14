# Naming & Language

The conventions-reviewer's rubric for what code says. Same contract as the design rubric: this aims your taste, it doesn't cap it — flag what misleads even if no rule below names it, and drop anything that's taste rather than clarity.

Names are the cheapest design act with the highest leverage: a reader meets the name a hundred times and the implementation once. A name that requires opening the implementation is a shallow-module symptom wearing letters.

## The domain vocabulary

One name per concept — the code's name, not a synonym. Before coining any term, grep the entities: the concept probably exists.

**Customize this section for your product** — list your ubiquitous language so the reviewer can catch synonyms and drift. Give each core entity one canonical name and the relationships between them:

```
- {{ROOT_ENTITY}} — the top-level owner everything scopes to. If it isn't scoped to it, ask why.
- {{TENANT_ENTITY}} — {{WHAT_IT_IS}}; owned by {{ROOT_ENTITY}}.
- {{INTEGRATION_ENTITY}} — the external system/provider. {{INTEGRATION_ACCOUNT_ENTITY}} — one tenant's presence/credentials on one integration.
- {{CATALOG_ENTITY}} — the source record. {{PROJECTION_ENTITY}} — that record as it exists on one integration. Never blur these two.
- {{DOMAIN_FAMILY_1}} — the {{...}} family of entities.
- {{DOMAIN_FAMILY_2}} — the operating family (audit log, sync jobs, scheduled events, ...).
```

Flag: an invented synonym (a second word for a concept that already has a canonical name), one concept under two names inside a diff, a mechanism name where a domain name exists (a `DataProcessor` that is really a publisher). New concepts should extend a family the way its siblings do (a `{{X}}Threshold` sits next to `{{X}}`).

## The system metaphor

**Customize the metaphor for your product.** The system models {{YOUR_DOMAIN}}; its modules read like {{YOUR_DOMAIN}}'s real divisions of work. A name a domain expert describing their workday wouldn't recognize is suspect — for domain-facing code. Infra code (locks, queues, auth plumbing) is exempt; it speaks infra.

## How to name things

- **Name the intent, not the mechanism.** `publishRecord`, not `processRecordData`. If the honest name would be vague (`handleStuff`, `processItems`), the design is vague — file it as a naming finding and say the cause is structural.
- **Methods promise exactly what they do.** `get{Entity}ById` throws or returns — it doesn't secretly create; that's `findOrCreate`. Side effects belong in the name (`syncAndPersist`, not `sync` that also writes).
- **House verb set first**: `create/update/get/delete{Entity}` for CRUD; the business's own verbs where they exist — publish, sync, fulfill, reconcile, onboard, cancel. Don't coin `retrieve`/`fetch`/`load` variants of `get`.
- **Booleans**: `is/has/can + condition`, positive form — `isActive`, never `isNotDeleted`. Same for flags in DTOs.
- **Pairs stay symmetric**: start/stop, open/close, add/remove, publish/unpublish — not add/delete.
- **Length follows scope.** A three-line loop may use `item`; an exported symbol spells everything out (`integrationAccountId`, no shortening). No abbreviations except domain-established ones (SKU, PO, OTP, and whatever your domain has standardized on).
- **Weasel words are unmade decisions**: `Manager`, `Helper` (outside `helper/`), `Util`, `Processor`, `Info`, `Data`, and `Handler` (except where it IS the pattern — event/webhook handlers). Each hides "I didn't decide where this logic lives." The finding is the decision, the rename falls out of it.
- **Mechanical conventions** (from your coding-standards doc — check, don't rethink): PascalCase singular entities, snake_case_plural tables, camelCase columns, `{entityName}Id` FKs, enums named as the question they answer (`PaymentStatus`, `FulfillmentModel`).

## Writing the finding

Every rename proposal includes the exact new name and what the current one misleads a reader into believing. If the wrong name traces to wrong structure, say "naming symptom, structural cause" — the design-reviewer owns the structure; don't double-report.
