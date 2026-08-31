# Naming & Language

The rubric for what frontend code *says*. A reader meets a name a hundred times and the implementation once, so a name that requires opening the file is the cheapest defect to fix and the most expensive to leave.

This aims taste, it doesn't cap it — flag what misleads even where no rule below names it, and drop anything that's preference rather than clarity.

## The domain vocabulary

**One name per concept — the backend's name.** The frontend and the API describe the same business; a concept renamed at the boundary means every future reader translates. Before coining a term, grep `src/features/*/types/`.

**Customize this block for your product**, matching the backend's list entity for entity:

```
- {{ROOT_ENTITY}} — the top-level owner everything scopes to. If it isn't scoped to it, ask why.
- {{TENANT_ENTITY}} — {{WHAT_IT_IS}}; owned by {{ROOT_ENTITY}}. The unit the app dimensions by.
- {{INTEGRATION_ENTITY}} — the external system/provider. {{INTEGRATION_ACCOUNT_ENTITY}} — one tenant's presence/credentials on one integration.
- {{CATALOG_ENTITY}} — the source record. {{PROJECTION_ENTITY}} — that record as it exists on one integration. Never blur these two.
- {{DOMAIN_FAMILY_1}} — the fulfillment family of entities.
- {{DOMAIN_FAMILY_2}} — the operating family (audit log, sync jobs, scheduled events, ...).
```

Flag: an invented synonym (a second word for a concept that already has a canonical name), one concept under two names inside a diff, a mechanism name where a domain name exists.

> This block is mirrored from the backend's canonical copy at `.claude/skills/ship-pr/references/naming-and-language.md` so a frontend-only checkout still has it. That file is the source of truth — if they disagree, it wins, and the drift is itself worth reporting.

Know the repo's live exceptions before flagging: a folder whose name reads like a synonym may be a genuinely different concept — a supplier-side purchase-order surface is not a second word for the tenant entity.

The shared utils carry the corrected vocabulary — `getChannelColor()`, `getChannelLogoUrl()`, `ChannelLogo` — so a new helper prefixed with a synonym is drift, not precedent, no matter what older prose calls it.

## Vendor names stay at the edge

A third party's name is an implementation fact, not a domain concept. It belongs in three places: the **enum/union value** that identifies the integration, the **component or module that exists only to speak to that vendor** (`{{Vendor}}ConnectFlow`, a `{{Vendor}}` install page), and the **label the user reads** — which lives in the locale files, so the vendor name sits in translation, not in code.

Everywhere else it is a leak. Flag it on service methods, shared types, props, hooks, query keys, and route paths — anything a second vendor of the same kind would have to reuse.

- BAD: `WarehouseService.discover{{Vendor}}Hubs()` · `Discover{{Vendor}}HubsResponse` · `{{Vendor}}Hub` · `use{{Vendor}}Hubs()`
- GOOD: `WarehouseService.discoverWarehouse()` · `DiscoverWarehouseResponse` · `WarehouseLocation` · `useWarehouseLocations()`

The test: could a second vendor of the same kind reuse this surface unchanged? A vendor-specific *component* is fine — that is the edge, and the place the vendor's quirks are supposed to live. A vendor-specific *contract* is the leak, and it doesn't stay local: a type named for one vendor pins the backend's endpoint and DTO to that name too.

## Frontend-specific naming

- **Hooks** — `use{Entity}` for data (`useUsers`, `useOrders`), `use{Domain}TableData` for the pagination wrapper, `use{Thing}` for behavior (`useLanguage`, `usePermissions`). Never `get`/`fetch` prefixes on a hook.
- **Services** — `{Domain}Service` class, `{domain}.service.ts` file. Methods use the house verb set: `create/update/get/delete{Entity}`, plus the business's own verbs where they exist — publish, sync, reconcile, onboard, cancel, export. Don't coin `retrieve`/`load` variants of `get`.
- **Methods promise exactly what they do.** `getUserById` throws or returns; it doesn't create — that's `findOrCreate`. Side effects belong in the name.
- **Booleans** — `is/has/can + condition`, positive form: `isActive`, never `isNotDeleted`. Same in props and DTOs.
- **Cardinality flags** — `isSingleTenant` is the tenant universe; selection cardinality is `*Selection`. Blurring them is a behavior bug, not a naming nit.
- **Components** — PascalCase, named for what it *is* (`AccountDialog`, `ChannelLabel`), not for where it sits (`RightPanel`) or how it was built (`WrapperDiv`).
- **Props** — the dialog contract is `{ open, onOpenChange, item? }`; handlers are `on{Event}`, the value they take is not renamed per component.
- **Query keys** — `{domain}Keys`, matching the domain in the service name.
- **Pairs stay symmetric** — start/stop, open/close, add/remove, publish/unpublish. Not add/delete.
- **Length follows scope.** A three-line `.map()` may use `item`; an exported symbol spells it out — `integrationAccountId`, no shortening. No abbreviations except domain-established ones (SKU, PO, OTP, and whatever your domain has standardized on).
- **Weasel words are unmade decisions**: `Manager`, `Helper` (outside a `helper/` file), `Util`, `Processor`, `Info`, `Data`, `Wrapper`. Each hides "I didn't decide where this lives." The finding is the decision; the rename falls out of it.

## The system metaphor

**Customize the metaphor for your product.** The app models {{YOUR_DOMAIN}}; its features read like {{YOUR_DOMAIN}}'s real divisions of work. A name {{PRIMARY_USER}} describing their workday wouldn't recognize is suspect in domain-facing code. Infra code (the api-client, cookie helpers, the motion tokens) is exempt — it speaks infra.

Remember who reads the *screen*: not only your own staff. A customer, a finance hire, or a self-serve owner reads the same labels. Keep the real domain term (keep-rate, settlement, drift, band) — don't vague it down — but give it a lightweight in-place gloss on its primary use.

## Writing the finding

Every rename proposal carries **the exact new name** and what the current one misleads a reader into believing. If the wrong name traces to wrong structure, say "naming symptom, structural cause" — don't double-report it as both.
