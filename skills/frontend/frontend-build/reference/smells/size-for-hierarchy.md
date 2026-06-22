# Smell: Size for Hierarchy

**The mistake:** Making important things bigger instead of making unimportant things quieter.

## Why It's Garbage

When you inflate primary content, you start a size war. Headers get huge, body text gets big to compensate, everything inflates. The result: a loud, overwhelming UI where nothing feels important because everything is screaming.

## The Pattern

```tsx
// BAD: Inflating primary
<h1 className="text-4xl font-black">Orders</h1>
<p className="text-xl font-bold">Order #12345</p>
<span className="text-lg font-semibold">Pending</span>
```

Everything is big. Where should the eye go?

```tsx
// GOOD: De-emphasizing secondary
<h1 className="text-xl font-semibold">Orders</h1>
<p className="font-medium">#12345</p>
<span className="text-sm text-muted-foreground">Pending</span>
```

Same hierarchy, achieved by making secondary content quieter. The primary stands out by contrast, not by size.

## The Toolkit for De-emphasis

| Technique | How | When |
|-----------|-----|------|
| Muted color | `text-muted-foreground` | Secondary text, metadata |
| Smaller size | `text-sm`, `text-xs` | Supporting info, timestamps |
| Lighter weight | `font-normal` vs `font-medium` | Labels vs values |
| Lower opacity | `text-muted-foreground/70` | Tertiary info, hints |

## Real Examples

**Card header:**
```tsx
// BAD
<CardTitle className="text-2xl font-bold">Product Details</CardTitle>

// GOOD
<CardTitle>Product Details</CardTitle>  // Default size is fine
```

**Stats display:**
```tsx
// BAD: Both numbers screaming
<div className="text-4xl font-bold">1,234</div>
<div className="text-2xl font-bold">Orders</div>

// GOOD: Number pops, label supports
<div className="text-2xl font-semibold">1,234</div>
<div className="text-sm text-muted-foreground">Orders</div>
```

**Table cell:**
```tsx
// BAD: Making important data huge
<span className="text-lg font-bold">{product.name}</span>

// GOOD: Normal size, other columns are quieter
<span className="font-medium">{product.name}</span>
<span className="text-muted-foreground">{product.sku}</span>
```

## Check Yourself

Before making something bigger, ask:
1. Can I make surrounding content quieter instead?
2. If I removed all font-size increases, would hierarchy still exist through weight/color?
3. Is this the ONLY thing that should be prominent in this section?
