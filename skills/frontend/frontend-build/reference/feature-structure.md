# Feature Structure

Where code goes and what it's called. One feature is the complete reference — `src/features/accounts/` below — and every file in the layout exists there. When you're unsure, open it rather than inventing.

## Layout

```
src/features/{domain}/
├── types/{entity}.types.ts       # API request/response types; re-exported from types/index.ts
├── services/{domain}.service.ts  # static class, one per API surface
├── hooks/use{Entity}.ts          # React Query: key factory + queries + mutations
├── hooks/use{Domain}TableData.ts # pagination + prefetch wrapper
├── components/columns.tsx        # column defs
├── components/{Action}Dialog.tsx # CreateAccountDialog, EditAccountDialog, DeleteAccountDialog
├── config/                       # only when the feature owns static config
├── pages/{Domain}Page.tsx        # composes the above; owns URL state
└── index.ts                      # public surface of the feature
```

Rules that actually get broken:

- **Cross-feature imports go through `shared/` — or a hub feature's barrel.** A component two features need moves to `shared/components/common/`. Reaching into a sibling's *internals* by deep path is the finding.

  The exception is a **hub feature** that owns domain vocabulary other features legitimately speak — `tenant-health`, whose `Band`, `BAND_TONE` and `DimensionPanel` several features consume ([surface-ownership.md](surface-ownership.md)). Moving those to `shared/` would sever a concept from the feature that owns and defines it, and turn `shared/` into a parking lot for every feature's vocabulary. Instead the hub declares a public surface in its `index.ts`, and consumers import from `@/features/tenant-health` — never from a path inside it.

  A leaf feature gets no such exception: if two leaves need the same thing, it belongs in `shared/`.
- **`index.ts` barrels exist at `types/`, `services/`, `hooks/`, and the feature root** — new files get added to the barrel, and consumers import from the barrel, not the deep path.
- **A page composes; it does not fetch.** Data fetching lives in hooks. A `useQuery` call inside a page component is misplaced.
- **A service does not know about React.** No hooks, no toast, no translation inside a service class — those belong in the hook layer.

## File naming

| Thing | Form | Example |
|---|---|---|
| Service file | `{domain}.service.ts` | `accounts.service.ts`, `orders.service.ts` |
| Service class | `{Domain}Service` | `AccountsService` |
| Hook file | `use{Entity}.ts` | `useAccounts.ts` |
| Types file | `{entity}.types.ts` | `account.types.ts`, `permission.types.ts` |
| Component | PascalCase, one component per file | `CreateAccountDialog.tsx` |
| Page | `{Domain}Page.tsx` | `AccountsPage.tsx` |
| Column defs | `columns.tsx` (lowercase — it's defs, not a component) | |

Exports are **named**, not default — except pages consumed by the lazy router. Match the file you're sitting next to.

## Dialog props

Every dialog takes the same shape. Don't invent a variant.

```typescript
{ open: boolean; onOpenChange: (open: boolean) => void; item?: TEntity }
```

| Kind | Pattern | Reference |
|---|---|---|
| Create / Edit | form dialog, React Hook Form + Zod | `accounts/components/AccountDialog.tsx` |
| Delete | confirmation only | `AccountDeleteDialog.tsx` |
| Bulk / Import | multi-step with progress | `products/components/ProductImportDialog.tsx` |

**Confirmation is for what can't be undone.** An action that's cheap to reverse ships as act-then-undo — the toast carries the undo — because a confirmation answered daily stops preventing anything. Where confirmation is right, it names the blast radius in the item's own terms ("Delete Acme and its 3 users"), never a bare "Are you sure?". Either way the confirm button disables while its mutation is pending (`disabled={mutation.isPending}`) — a dialog that stays clickable mid-flight submits twice.

### Long dialogs — the body scrolls, the actions stay put

Any dialog whose content can outgrow the viewport composes three slots from `shared/components/ui/dialog.tsx`:

```tsx
<DialogContent>          {/* flex flex-col, max-h-[85vh], overflow-hidden */}
  <DialogHeader>…</DialogHeader>
  <DialogBody>…</DialogBody>   {/* flex-1 overflow-y-auto min-h-0 — the only scrolling region */}
  <DialogFooter>…</DialogFooter>
</DialogContent>
```

**The mechanism is not `position: sticky`.** `DialogContent` is a capped flex column that hides its own overflow, so header and footer are non-shrinking siblings and only `DialogBody` scrolls. The actions stay visible because nothing else can scroll — there is no `sticky` in any dialog, and adding `sticky bottom-0` to a footer is a redundant fix for a problem the composition already solved.

Findings to write:

- **A dialog that can overflow with no `DialogBody`** — the whole dialog scrolls, so the confirm button leaves the screen and the user has to scroll to act. The tell is a hand-rolled `overflow-y-auto` / `max-h-[…]` on an inner div.
- **A hand-rolled `max-h-[70vh] overflow-y-auto` wrapper inside a dialog** — `DialogBody` already does it, and it does it with `min-h-0` (without which the flex child refuses to shrink and the scroll silently never engages).
- **`DialogBody` stripped of `-mx-6 px-6`** — that bleed makes the scroll region span the dialog's full width so the scrollbar sits at the edge instead of floating inside the padding. Override the class and you get a scrollbar inset by 24px.

A genuinely short dialog — a delete confirmation, a two-field export — needs no `DialogBody`, and adding one is not an improvement. The test is whether the content can grow: a list, a form over ~4 fields, anything rendering N rows.

## Wiring — a feature isn't done until all four exist

A new surface that renders but isn't reachable, or is reachable without a permission check, is unfinished:

1. **Route** — `app/router.tsx`, wrapped in `<PermissionGuard permissions={[...]}>`. A route with no guard is a finding.
2. **Nav** — `shared/utils/navConfig.ts`.
3. **Breadcrumb label** — `shared/components/layout/Breadcrumbs.tsx` config. Breadcrumbs are the return path; a hand-rolled "back to X" link duplicating them is a finding.
4. **Permission** — `features/accounts/config/permissions.config.ts` (`ResourceKey` + actions). A `hasPermission({ resource })` call against a resource that isn't in `PERMISSIONS_CONFIG` silently never passes.

## Lazy loading

Pages are lazy-loaded through the router's `LazyPage` wrapper. A new page added as a static import inflates the initial bundle — follow the surrounding routes.
