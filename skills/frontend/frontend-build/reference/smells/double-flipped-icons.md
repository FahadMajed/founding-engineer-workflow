# Smell: Double-Flipped Icons

**The mistake:** Mirroring a directional icon for RTL in the component, when the global stylesheet already mirrors it. Two flips cancel — the arrow points the wrong way in the RTL locale.

## Why It's Garbage

The flip is global and invisible at the call site, so the fix looks like the bug. Someone sees a chevron pointing the wrong way in RTL, "fixes" it with a language check, and now it's wrong in the other direction — or wrong only when expanded. A whole feature's drill-in chevrons and pager arrows can ship backwards this way, one plausible-looking fix at a time.

## The Rule

`src/index.css` mirrors the horizontal lucide icons under `[dir="rtl"]` — `.lucide-chevron-left/right`, `.lucide-arrow-left/right`, `.lucide-chevrons-left/right`. Vertical and diagonal icons (`chevron-down`, `arrow-up-right`) are deliberately left alone so rotations and trend indicators still read correctly.

**Write the LTR icon. Let the CSS mirror it.** Prev is `ChevronLeft`, next and drill-in are `ChevronRight`, back is `ArrowLeft` — in both locales.

```tsx
// BAD — flipped twice, points the wrong way in RTL
const NextIcon = isRtl ? ChevronLeft : ChevronRight;
<NextIcon className="icon-sm" />

// GOOD
<ChevronRight className="icon-sm" />
```

## The Second Form: Rotating a Mirrored Icon

Tailwind v4 compiles `rotate-90` to the `rotate` property, which the spec applies **after** `transform` — so it composes with the RTL `scaleX(-1)` instead of replacing it. A rotated `chevron-right` lands 180° off in RTL: an expanded row's caret points **up**.

Never put `rotate-*` on an icon in that CSS list. Rotating carets use `ChevronDown`, which isn't mirrored:

```tsx
// BAD — chevron-right + rotate: the caret points up when expanded in RTL
<ChevronRight className={cn('icon-sm transition-transform', isOpen && 'rotate-90')} />

// GOOD — the house pattern (the data table, collapsible sections, expandable rows)
<ChevronDown className={cn('icon-sm transition-transform', !isOpen && '-rotate-90 rtl:rotate-90')} />
```

## Check Yourself

```bash
# locale-conditional directional icons — should return nothing
grep -rnE "(isRtl|isRTL|language === '[a-z]{2}')\s*\?\s*[A-Z][A-Za-z]*(Left|Right|Arrow|Chevron)" src

# rotate on an auto-mirrored icon
grep -rn -A3 "<Chevron\(Left\|Right\)\|<Arrow\(Left\|Right\)" src --include=*.tsx | grep rotate
```

The direction hook is for things Tailwind can't express — a popover `side`, chart direction, JS positioning. Reaching for it to pick an icon means the CSS already handled it.
