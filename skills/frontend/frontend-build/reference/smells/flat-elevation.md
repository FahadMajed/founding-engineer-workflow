# Smell: Flat Elevation

**The mistake:** Everything at the same visual level, no shadows, no depth.

## Why It's Garbage

Flat UIs feel lifeless. When a dropdown opens, it should feel "above" the page. When a card holds content, it should feel slightly lifted. Without elevation, interactive elements don't feel interactive, and layered UIs feel broken.

## The Elevation System

We have three shadow tokens. Use them:

| Token | Elevation | Use For |
|-------|-----------|---------|
| `shadow-card` | Low | Cards, panels, resting state |
| `shadow-card-hover` | Medium | Hover states, active cards |
| `shadow-elevated` | High | Dropdowns, popovers, modals |

## The Pattern

```tsx
// BAD: Flat dropdown
<div className="absolute top-full bg-card border rounded">
  <div>Option 1</div>
  <div>Option 2</div>
</div>
```

The dropdown is technically above the content, but it doesn't *feel* above it.

```tsx
// GOOD: Elevated dropdown
<div className="absolute top-full bg-card rounded-lg shadow-elevated">
  <div>Option 1</div>
  <div>Option 2</div>
</div>
```

Now it feels like it's floating. Users intuitively understand it's a temporary layer.

## When to Use Each Level

### Low Elevation (`shadow-card`)

Resting cards that hold content:

```tsx
<Card className="shadow-card">
  <CardContent>
    Passive content container
  </CardContent>
</Card>
```

### Medium Elevation (`shadow-card-hover`)

Interactive elements getting attention:

```tsx
<Card className="shadow-card hover:shadow-card-hover transition-shadow">
  Clickable card
</Card>
```

### High Elevation (`shadow-elevated`)

Anything that overlays the page:

```tsx
// Dropdown menus
<DropdownMenuContent className="shadow-elevated">

// Popovers
<PopoverContent className="shadow-elevated">

// Dialogs (usually handled by component)
<DialogContent className="shadow-elevated">
```

## Interactive Elevation Change

Elevation should change on interaction to show responsiveness:

```tsx
// Card that lifts on hover
<Card className="shadow-card hover:shadow-card-hover transition-shadow cursor-pointer">
  Click to open details
</Card>

// Already elevated things don't need to lift more
<PopoverContent className="shadow-elevated">
  {/* Don't add hover shadow here */}
</PopoverContent>
```

## Stacking Order

Higher elevation = higher z-index. The system should feel like:

1. **Base page** — background, main content (no shadow)
2. **Cards** — lifted slightly (`shadow-card`)
3. **Active elements** — hovered cards, focused inputs (`shadow-card-hover`)
4. **Overlays** — dropdowns, popovers (`shadow-elevated`)
5. **Modals** — dialogs, alerts (max elevation)

## Don't Overdo It

Not everything needs a shadow:

```tsx
// BAD: Shadow on everything
<div className="shadow-card">
  <div className="shadow-card">
    <button className="shadow-card">
      Shadow overload
    </button>
  </div>
</div>

// GOOD: Shadow at the container level
<Card className="shadow-card">
  <CardContent>
    <button>Clean</button>
  </CardContent>
</Card>
```

## Check Yourself

1. Do dropdowns/popovers have `shadow-elevated`?
2. Do cards have `shadow-card` (or none if inside another card)?
3. Do interactive cards lift on hover?
4. Is there a clear visual stacking order?
