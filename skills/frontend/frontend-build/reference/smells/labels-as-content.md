# Smell: Labels as Content

**The mistake:** Treating labels with the same visual weight as the data they describe.

## Why It's Garbage

Labels are scaffolding. They help users understand what they're looking at, then get out of the way. When labels compete with data, users can't scan. They read "Name: Alex" as two equally important pieces of information when really they just want to see "Alex."

## The Pattern

```tsx
// BAD: Labels fighting data
<div className="flex gap-2">
  <span className="font-medium">Order ID:</span>
  <span className="font-medium">#12345</span>
</div>
<div className="flex gap-2">
  <span className="font-medium">Status:</span>
  <span className="font-medium">Pending</span>
</div>
```

The eye bounces between labels and values. Dense, hard to scan.

```tsx
// GOOD: Labels recede, data pops
<div>
  <span className="text-sm text-muted-foreground">Order ID</span>
  <span className="font-medium block">#12345</span>
</div>
<div>
  <span className="text-sm text-muted-foreground">Status</span>
  <Badge>Pending</Badge>
</div>
```

Labels are clearly secondary. Eyes find values immediately.

## Even Better: Skip the Label

If context makes meaning obvious, remove the label entirely.

```tsx
// GOOD: No label needed
<div className="flex items-center gap-2">
  <Package className="icon-sm text-muted-foreground" />
  <span className="font-medium">Blue Widget</span>
  <span className="text-muted-foreground">×3</span>
</div>
```

The icon and layout make it clear this is a product with quantity. No "Product:" or "Qty:" needed.

## When Labels Help

Labels are useful when:
- Data format is ambiguous (is "12345" an ID or quantity?)
- Multiple similar values exist (shipping address vs billing address)
- First-time users need guidance

But even then, make them quiet:
```tsx
<div className="text-xs uppercase tracking-wide text-muted-foreground mb-1">
  Shipping Address
</div>
<div className="font-medium">{address}</div>
```

## Form Fields Are Different

Form labels should be visible but not loud:
```tsx
// Standard form pattern
<FormLabel className="text-sm font-medium">Email</FormLabel>
<Input {...field} />
```

The label is readable but the input field is the focus.

## Table Headers

Table headers are labels. Keep them understated:
```tsx
// BAD: Loud headers
<TableHead className="font-bold text-foreground">Product Name</TableHead>

// GOOD: Headers support, data dominates
<TableHead className="text-muted-foreground font-medium">Product</TableHead>
```

## Check Yourself

1. Cover the labels — can you still understand the data?
2. Are labels using same font-weight as values?
3. Could an icon or layout replace the label?
