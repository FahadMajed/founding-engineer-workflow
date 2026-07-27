# Smell: Table Column Balance

**The mistake:** In a `DataTable`, marking every numeric column `fitContent` and leaving the name/text column as the *only* flexible one — so that column swallows all the leftover width and the numbers get shoved to the far edge. And/or a numeric column whose **header** and **cell** don't share the same alignment, so the label floats over a number it doesn't sit above.

This is the house table look. Get it wrong once and every table in the feature drifts; the rules below are the pattern so it never needs eyeballing again.

> **Root cause is the primitive, not you.** The `DataTable` advertises `size` and `frozen` as if they *cap* a column, but it renders an **auto-layout** `<table>` (`min-w-full`) where the browser ignores `max-width` on cells whenever the table has to fill width — so the "cap" silently does nothing and a lone flexible column eats the slack. The rules below are the guardrail *until the primitive is fixed*; the durable fix is in `DataTable` itself (a `table-layout: fixed` width model, or a measured distribution pass) so `size` means what it says — that's a larger change touching every table and is tracked separately. Per the house rule, prefer fixing the primitive over asking every consumer to remember the workaround.

## Why It's Garbage

**Auto-layout tables ignore `max-width`.** The `DataTable` renders a plain `<table>` (auto layout) with `min-w-full`. A column with `style="width:280px; max-width:280px"` will still render at 565px if it's the only non-`fitContent` column, because the browser distributes the leftover width to whatever column *can* grow and silently ignores the `max-width`. So a "capped" name column becomes a 280px name + 285px of dead whitespace, and the numeric columns cluster on the right, far from the row they describe. Dumping the slack into an empty trailing spacer is the opposite failure: the numbers squeeze together on the left with a gap on the right.

**A header that doesn't match its cell reads as broken** even when each is internally fine. A right-aligned column of numbers under a start-aligned header, or a header with a sort control whose alignment differs from the value below it, makes the column look misregistered.

## The Pattern

```tsx
// BAD: name is the only flexible column → it absorbs all slack (renders ~565px),
// numerics get pushed to the edge; header align not pinned to the cell.
{ id: 'product', meta: { frozen: true }, size: 280, ... }          // "cap" the table ignores
{ id: 'gmv',  meta: { fitContent: true, className: 'text-end' }, header: () => <span>GMV</span>, ... }
{ id: 'fees', meta: { fitContent: true, className: 'text-end' }, ... }
// … every numeric fitContent → product is the lone slack sink
```

```tsx
// GOOD: numeric columns are NOT fitContent → they share the leftover width and
// spread evenly; the name column caps; header + cell alignment come from one meta.
{ id: 'product', size: 280, meta: { frozen: true }, ... }          // stays ~280, others take the slack
{ id: 'gmv',  meta: { className: 'text-end' }, header: () => <SortHead align="end" .../>,
  cell: ({ row }) => <Money amount={row.original.gmv} className="tabular-nums" /> }
{ id: 'fees', meta: { className: 'text-end' }, ... }
// category / status / any categorical column: start-aligned, fitContent is fine (it's tight by nature)
```

The frozen name column caps at its `size`; the numeric columns, being non-`fitContent`, each claim an equal share of the remaining width and spread to fill it — no hog, no dead spacer, no horizontal scroll. `meta.className` is applied to **both** the header cell and the body cell, so alignment is defined once and can't drift apart.

## The Rules

- **Exactly one flexible text column, capped.** The name/label column gets an explicit `size` (+ `frozen` if it should stay visible on horizontal scroll). Never leave it as the only non-`fitContent` column with the numerics all `fitContent` — it will absorb every pixel of slack regardless of its `max-width`.
- **Numeric columns are not `fitContent`.** Drop `fitContent` on the measures so they share the leftover width and spread evenly across it. `fitContent` is for genuinely tight columns (a checkbox, an expander chevron, a stack of logos), not for the money columns.
- **Header alignment is the cell's alignment — set it once in `meta.className`.** `meta.className` lands on the header cell *and* the body cell, so `text-end` there aligns both. Numeric/measure columns: `text-end` + `tabular-nums` on the value. Text/categorical columns (name, category, status): start-aligned. A header aligned differently from its cell is the smell.
- **Never soak slack with an empty spacer column.** It fixes the cap but squeezes the data into the corner with a dead gap. Let the real numeric columns spread instead.
- **No horizontal scroll from the fix.** After capping the name and spreading the numerics, the table should exactly fill its container (measure `scrollWidth <= clientWidth`). A `size: 9999` sink or a fixed-width spacer forces overflow — that's the fix gone wrong.

## Check Yourself

1. Is the name/text column a sane width, with the numeric columns spread across the rest — not clustered at one edge with whitespace on the other? (Inspect: the name column's rendered width ≈ its `size`, numerics roughly equal.)
2. For every measure column, does the header sit directly over its values — same right edge? (Measure `header.right === cell.right`, or squint: the label's end aligns with the digits.)
3. Numerics `text-end` + `tabular-nums`; categorical columns start-aligned; header and cell never disagree.
4. No horizontal scrollbar introduced by column sizing (`scrollWidth <= clientWidth`).
