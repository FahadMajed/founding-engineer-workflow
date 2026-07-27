# Smell: Messy Alignment

**The mistake:** Laying out a row of heterogeneous elements (name, badge, amount, action) with `justify-between` or loose `gap` instead of fixed columns — so the fields drift horizontally from row to row and nothing lines up vertically.

## Why It's Garbage

When a list has four conceptual columns (name, status, amount, action) but each row's widths are driven by content, the human eye can't scan vertically. The status badge jumps left on short names, the amount column wiggles, the action link floats. It reads as "thrown together" even when each row is internally consistent. A proper grid makes the data scannable in both directions — across one row and down one column.

## The Pattern

```tsx
// BAD: flex + justify-between — columns drift with content width
<div className="flex items-center justify-between py-3">
  <span className="font-medium">{item.name}</span>
  <Badge variant="outline">Active</Badge>
  <span className="tabular-nums">{item.amount}</span>
  <Link>Manage →</Link>
</div>
```

Each row's "columns" are wherever the content happens to end. Short name → badge drifts left. Long name → badge and amount get pushed right. Nothing aligns across rows.

```tsx
// GOOD: CSS grid with explicit columns — everything snaps
<div className="grid grid-cols-[1fr_auto_auto_auto] items-center gap-4 py-3">
  <span className="font-medium truncate">{item.name}</span>
  <Badge variant="outline">Active</Badge>
  <span className="text-end tabular-nums">{item.amount}</span>
  <Link>Manage →</Link>
</div>
```

Every row shares the same column tracks. Names truncate in their lane, badges stack vertically, amounts right-align in a fixed-width column, actions sit flush.

## The Rules

- **Use `grid` for repeating rows with 2+ distinct fields** — `flex` + `justify-between` only works for two-element rows (label + value). Three or more fields need explicit column tracks.
- **`1fr` for the stretchy column, `auto` for the rest** — let one column (usually the name/label) absorb extra space while fixed-content columns stay tight.
- **Right-align numeric columns** — `text-end tabular-nums` so digits stack cleanly. Currency, counts, percentages — all right-aligned.
- **`truncate` + `min-w-0` on the stretchy column — and `min-w-0` on every flex ancestor above it** — so long content clips instead of blowing out the grid and pushing neighbors off-screen. `min-w-0` on the truncating column alone is not enough; see [The `min-w-0` chain](#the-min-w-0-chain).
- **Same grid template for every row** — if header and body rows use different column definitions, they'll misalign. Share the template via a parent grid or a shared class.
- **Expanded subrows share the parent's grid** — content rendered under a row (`renderSubComponent`, accordion detail) that shows the same columns must align to the table's actual column tracks. Hardcoded widths (`w-28`, `w-16`) look aligned in one dataset and drift the moment a column resizes — derive the layout from the same template the header uses.
- **Consistent gap, not mixed padding** — `gap-4` on the grid, not `px-2` on one cell and `px-4` on another.

## The `min-w-0` chain

`truncate` only fires when the element resolves to a bounded width. Inside flex, a flex item defaults to `min-width: auto` — it refuses to shrink below its content's intrinsic size. One long unbroken string then expands the item past its container and `truncate` never clips. The fix is `min-w-0` on the flex item.

The catch: this has to hold for **every flex item on the chain** from the truncating element up to the first width-bounded ancestor. One link without `min-w-0` and the whole chain leaks — even if the column you're staring at has both `truncate` and `min-w-0`.

```
Card (bounded) → Header (flex) → Trigger (flex flex-1)   ← missing min-w-0 here
   → row (flex-1 min-w-0) → text col (min-w-0) → name (truncate)   ← all correct, still overflows
```

The column did everything right; the break was two levels up, so it looked innocent.

**Shared/shadcn flex primitives are the usual culprit.** Wrappers you nest inside — `AccordionTrigger`, `DialogHeader`, card headers, any generated `flex`/`flex-1` container — routinely ship *without* `min-w-0` because their stock content never truncates. The moment you put a `truncate` column inside one, that primitive becomes the broken link. Fix it in the primitive (it's the correct default and benefits every future consumer), not with a hack in the feature.

**RTL makes the symptom sneaky.** LTR text (a product name, a SKU) in an RTL container overflows toward the *left* and clips its *start* — `Acme Longboard…` shows as `me Longboard…`. It reads like a data-truncation bug, not a layout bug, so trace the flex chain before you suspect the string.

## When Flex Is Still Fine

- **Two-element rows** — label + value, title + action. `justify-between` handles this cleanly.
- **Single-axis layouts** — a row of tags, a button group, breadcrumbs. No columnar alignment needed across siblings.
- **Wrapping content** — `flex-wrap` for tag clouds or chip groups where columnar alignment is meaningless.

The test: if you have 3+ distinct fields AND the rows repeat, reach for `grid`.

## In Tables (DataTable)

The DataTable component already handles column alignment — that's what tables do. The smell appears when you build a **list** that is semantically a table but uses flex divs. If the data is tabular (same fields per row, sortable, paginated), use `DataTable`. If it's a simpler card-style list with a few inline fields, use `grid`.

## Check Yourself

1. Do badges / amounts / actions in adjacent rows line up vertically? Squint at the list — if things wiggle, you have the smell.
2. Are you using `justify-between` with 3+ children? That's almost always wrong.
3. Does the stretchy column have `truncate` + `min-w-0` — **and does every flex ancestor above it, up to the bounded container, also have `min-w-0`?** Walk the chain, including shared/shadcn wrappers (`AccordionTrigger`, `DialogHeader`, …) you didn't write. One missing link and one long name breaks the whole layout.
4. Are numeric values right-aligned with `tabular-nums`? Proportional digits misalign on every row.
