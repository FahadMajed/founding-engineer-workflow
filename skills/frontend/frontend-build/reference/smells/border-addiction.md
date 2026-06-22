# Smell: Border Addiction

**The mistake:** Using borders to separate every element.

## Why It's Garbage

Borders add visual weight. Every border is a line your eye has to process. When everything has borders, the UI feels heavy, cluttered, and old-fashioned. The content gets trapped in boxes instead of breathing.

## The Pattern

```tsx
// BAD: Borders everywhere
<div className="border rounded-lg p-4">
  <div className="border-b pb-2 mb-2">
    <span className="font-medium">Header</span>
  </div>
  <div className="border rounded p-2 mb-2">
    <span>Item 1</span>
  </div>
  <div className="border rounded p-2 mb-2">
    <span>Item 2</span>
  </div>
  <div className="border-t pt-2 mt-2">
    <Button>Action</Button>
  </div>
</div>
```

Boxes inside boxes. Heavy, cramped, noisy.

## Alternatives to Borders

### 1. Spacing

Let whitespace do the work:

```tsx
// GOOD: Space separates
<div className="space-y-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

### 2. Background Color

Different backgrounds create visual groups:

```tsx
// GOOD: Background differentiates
<div className="bg-card rounded-lg p-4">
  <div className="bg-muted rounded p-3">
    Highlighted section
  </div>
</div>
```

### 3. Shadows

Shadows create depth without hard edges:

```tsx
// GOOD: Shadow creates separation
<div className="shadow-card rounded-lg p-4">
  Content feels elevated
</div>
```

### 4. Different Typography

Visual hierarchy through text treatment:

```tsx
// GOOD: Type creates groups
<div>
  <h3 className="font-semibold mb-2">Section Title</h3>
  <p className="text-muted-foreground">Supporting content</p>
</div>
```

## When Borders Work

Borders are appropriate for:
- **Form inputs** — need clear boundaries for interaction
- **Tables** — structured data benefits from grid lines (use `divide-y` not per-cell borders)
- **Intentional separation** — when you really need a hard line between sections

```tsx
// Good border use: table rows
<div className="divide-y">
  {items.map(item => (
    <div key={item.id} className="py-3">{item.name}</div>
  ))}
</div>
```

## The Redesign

Before:
```tsx
<Card className="border">
  <CardHeader className="border-b">
    <CardTitle>Orders</CardTitle>
  </CardHeader>
  <CardContent>
    <div className="border rounded p-2">Order 1</div>
    <div className="border rounded p-2 mt-2">Order 2</div>
  </CardContent>
  <CardFooter className="border-t">
    <Button>View All</Button>
  </CardFooter>
</Card>
```

After:
```tsx
<Card>
  <CardHeader>
    <CardTitle>Orders</CardTitle>
  </CardHeader>
  <CardContent className="space-y-2">
    <div className="bg-muted/50 rounded-lg p-3">Order 1</div>
    <div className="bg-muted/50 rounded-lg p-3">Order 2</div>
  </CardContent>
  <CardFooter>
    <Button>View All</Button>
  </CardFooter>
</Card>
```

Card already has border. Inner borders removed, background color groups items.

## Check Yourself

For every border you add, ask:
1. Could spacing alone separate these elements?
2. Would a subtle background work better?
3. Does this border actually help comprehension?
