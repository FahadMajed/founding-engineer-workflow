# Smell: Spacing by Feel

**The mistake:** Using arbitrary spacing values instead of a consistent scale.

## Why It's Garbage

Random spacing feels amateur. Your eye notices the inconsistency even if you can't articulate why. When `mt-3` is next to `mb-5` is next to `py-7`, the rhythm is broken. The UI feels cobbled together rather than designed.

## The System

Tailwind has a built-in scale. Use it:

| Value | Pixels | Use For |
|-------|--------|---------|
| `1` | 4px | Tight inline spacing |
| `2` | 8px | Related elements (icon + text) |
| `3` | 12px | Form field gaps |
| `4` | 16px | Standard content gaps |
| `6` | 24px | Section spacing |
| `8` | 32px | Major section breaks |
| `12` | 48px | Page-level separation |

Stick to these. Avoid `5`, `7`, `9`, `10`, `11` — they break the rhythm.

## The Pattern

```tsx
// BAD: Random values
<div className="p-5">
  <h2 className="mb-3">Title</h2>
  <p className="mb-7">Description</p>
  <div className="mt-5 space-y-3">
    <div className="p-3">Item</div>
    <div className="p-5">Item</div>  // Why different?
  </div>
</div>
```

Why `p-5`? Why `mb-7`? No reason — it was "what looked right."

```tsx
// GOOD: Consistent scale
<div className="p-4">
  <h2 className="mb-2">Title</h2>
  <p className="mb-4">Description</p>
  <div className="mt-4 space-y-2">
    <div className="p-3">Item</div>
    <div className="p-3">Item</div>
  </div>
</div>
```

Consistent rhythm. Everything relates to the base scale.

## Common Spacing Patterns

**Card content:**
```tsx
<Card className="p-4">        // or p-6 for more breathing room
  <div className="space-y-4"> // consistent gaps
```

**Form fields:**
```tsx
<form className="space-y-4">  // between fields
  <div className="space-y-2"> // label to input
```

**List items:**
```tsx
<div className="divide-y">
  <div className="py-3">      // consistent vertical padding
```

**Button groups:**
```tsx
<div className="flex gap-2">  // tight
<div className="flex gap-3">  // standard
```

**Sections:**
```tsx
<div className="space-y-6">   // between major sections
<div className="space-y-8">   // page-level breaks
```

## Relationship Rule

Spacing should reflect relationships:
- **Closer** = more related
- **Further** = less related

```tsx
// GOOD: Spacing shows relationships
<div className="space-y-6">
  {/* First group - items close together */}
  <div className="space-y-2">
    <h3 className="font-medium">Shipping</h3>
    <p className="text-sm text-muted-foreground">{address}</p>
  </div>

  {/* Second group - separated from first */}
  <div className="space-y-2">
    <h3 className="font-medium">Payment</h3>
    <p className="text-sm text-muted-foreground">{method}</p>
  </div>
</div>
```

The `space-y-6` between groups is larger than `space-y-2` within groups. This shows they're separate sections.

## Double Spacing: fighting a container that already spaces its children

A container that owns its internal rhythm — a flex/grid with `gap-*`, a `space-y-*` wrapper, or a component like `Card` (`flex flex-col gap-6`) — **already puts space between its children**. Adding padding or margin to a child to tune that same gap doesn't replace the container's spacing; it stacks on top of it.

`Card` is the trap. It spaces header→content with its own `gap-6` (24px). So:

```tsx
// BAD: gap-6 (24px, from the Card) + pt-6 (24px) = 48px below the header/divider
<Card>
  <CardHeader className="border-b">…</CardHeader>
  <CardContent className="pt-6">…</CardContent>
</Card>

// GOOD: let the Card's gap-6 be the single source of that spacing
<Card>
  <CardHeader className="border-b">…</CardHeader>
  <CardContent>…</CardContent>
</Card>
```

The inverse fails silently: `CardHeader className="pb-3"` reads like it sets the header→content gap, but `gap-6` (24px) is larger than `pb-3` (12px), so the flex gap wins and the `pb-3` does nothing. Either way you've stopped controlling the spacing you think you're controlling.

The rule: **to change spacing a container provides, change the container's `gap`/`space-y` — not padding on the children.** Same test for any `gap`/`space-y` parent: before adding margin/padding to a child, check whether the parent is already spacing it.

### The same stack at the bottom edge: unbalanced padding

The Card's `py-6` pads **both** the top and the bottom (24px each). A full-bleed footer band — pagination, actions, a `border-t` toolbar rendered as the last child of `CardContent p-0` — carries its **own** vertical padding, which then stacks *under* the Card's `pb-6`. The bottom ends up heavier than the top, and the footer's full-width border reads as if it should sit flush against the card's rounded corner while a dead strip sits below it.

```tsx
// BAD: below the arrows = footer py-3 (12px) + Card pb-6 (24px) = ~36px,
//      while the top is just the Card's pt-6 (24px). Bottom-heavy, lopsided.
<Card>                                  {/* py-6 */}
  <CardHeader>…</CardHeader>
  <CardContent className="p-0">
    …rows…
    <div className="border-t px-4 py-3">…pagination…</div>   {/* full-bleed footer */}
  </CardContent>
</Card>

// GOOD: a full-bleed footer is the bottom edge — drop the card's bottom padding
//       so the footer's own py-3 is the only space, flush to the rounded corner.
<Card className="pb-0">
  …
    <div className="border-t px-4 py-3">…pagination…</div>
</Card>
```

The invariant: **a card's top and bottom padding read balanced.** A full-bleed footer with its own padding shouldn't sit above the card's bottom padding — either it's flush (`pb-0`) or it isn't full-bleed.

### Dead space in a stretched card

When cards share an equal-height row — a grid's default `items-stretch`, or `lg:grid-cols-2` beside a taller sibling — the shorter card is stretched taller than its content. **What fills the extra height is a decision; make it on purpose.** The three defaults are all smells:

- **Block flow** (do nothing) top-packs the content and leaves a void at the bottom.
- **Reflex `justify-center`** floats the content with equal voids above and below — unanchored, and the padding stops matching the content's natural reading.
- **`items-start`** (opting out of stretch) kills the void but leaves a stubby card mismatched against its tall neighbour.

The right fix depends on the content shape:

```tsx
// Content with natural bookends (label/heading on top, note/footer on bottom):
// distribute — bookends pin to the edges, the middle shares the rest.
// The gap-3 is a floor so it doesn't collapse when the card is at natural height.
<CardContent className="flex flex-1 flex-col justify-between gap-3">
  <div>…caption / label…</div>       {/* top */}
  <p className="text-3xl font-bold">…amount…</p>
  <StatusStamp />
  <p>…footnote…</p>                   {/* bottom */}
</CardContent>

// A single tight block with no bookends: centering IS right — or the layout
// shouldn't force this card to equal height at all (items-start on the row).
```

The invariant: **a stretched card's content fills its height on purpose.** If a card shows a vertical void its content doesn't own, either the content should distribute to fill it (bookended content) or the layout shouldn't stretch the card (a single block).

## Check Yourself

1. Are you using values outside the scale (5, 7, 9, 10, 11)?
2. Do similar elements have identical spacing?
3. Does spacing increase as you move between larger logical groups?
4. Are you adding padding/margin to a child of a `gap-*`/`space-y-*` container (incl. `Card`, `gap-6`) to set spacing the container already provides? Change the container instead.
5. Do the card's top and bottom padding read balanced? Is a full-bleed footer (pagination, actions) sitting above the card's bottom padding instead of flush (`pb-0`)?
6. In an equal-height row, does a shorter card top-pack (bottom void) or float (centered voids)? Bookended content distributes (`justify-between`) to fill; a single block centers or opts out of stretch.
