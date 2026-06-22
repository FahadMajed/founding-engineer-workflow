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

## Check Yourself

1. Are you using values outside the scale (5, 7, 9, 10, 11)?
2. Do similar elements have identical spacing?
3. Does spacing increase as you move between larger logical groups?
