# Smell: Competing Emphasis

**The mistake:** Multiple elements fighting to be the most important thing.

## Why It's Garbage

When everything is emphasized, nothing is. Users don't know where to look. The interface feels chaotic, demanding attention everywhere at once. Decision fatigue sets in before any action is taken.

## The Pattern

```tsx
// BAD: Everything demanding attention
<div className="flex items-center gap-4">
  <Badge className="bg-red-500 text-white font-bold">URGENT</Badge>
  <h2 className="text-2xl font-bold text-primary">Important Order</h2>
  <Button variant="destructive" className="font-bold">Cancel Now</Button>
  <Button className="bg-green-500 font-bold">Approve</Button>
  <span className="text-orange-500 font-bold animate-pulse">Action Required!</span>
</div>
```

Five things competing. Where should the user look?

```tsx
// GOOD: Clear primary action
<div className="flex items-center gap-4">
  <Badge variant="outline">Urgent</Badge>
  <h2 className="font-medium">Order #12345</h2>
  <div className="ms-auto flex gap-2">
    <Button variant="outline">Cancel</Button>
    <Button>Approve</Button>
  </div>
</div>
```

One primary action (Approve). Everything else supports it.

## The Rule of One

In any visual group, there should be **one** primary element:
- One primary button
- One bold headline
- One colored accent

Everything else is secondary.

## Button Hierarchy

```tsx
// BAD: Two primary buttons
<div className="flex gap-2">
  <Button>Save</Button>
  <Button>Submit</Button>
</div>

// GOOD: Clear primary and secondary
<div className="flex gap-2">
  <Button variant="outline">Save Draft</Button>
  <Button>Submit</Button>
</div>
```

Only one button should be filled/primary. Others are outline or ghost.

## Text Hierarchy

```tsx
// BAD: Multiple bold elements
<div>
  <h2 className="font-bold">Product Name</h2>
  <p className="font-bold text-primary">$199.00</p>
  <p className="font-bold text-green-500">In Stock</p>
</div>

// GOOD: One emphasis per level
<div>
  <h2 className="font-semibold">Product Name</h2>
  <p className="font-medium">$199.00</p>
  <p className="text-sm text-muted-foreground">In Stock</p>
</div>
```

## Color Emphasis

Color draws attention. Use sparingly:

```tsx
// BAD: Rainbow of emphasis
<div className="flex gap-2">
  <Badge className="bg-red-500">Error</Badge>
  <Badge className="bg-yellow-500">Warning</Badge>
  <Badge className="bg-green-500">Success</Badge>
  <Badge className="bg-blue-500">Info</Badge>
</div>

// GOOD: Color where it matters
<div className="flex gap-2">
  <Badge variant="destructive">3 Errors</Badge>
  <Badge variant="outline">2 Warnings</Badge>
</div>
```

Only use color for the most important status. Others can be muted.

## Animation as Emphasis

Animation is the loudest emphasis. Use extremely sparingly:

```tsx
// BAD: Multiple animated elements
<div>
  <span className="animate-pulse">New!</span>
  <Button className="animate-bounce">Click me</Button>
  <Badge className="animate-ping">Alert</Badge>
</div>

// GOOD: Animation for critical alerts only
<div className="relative">
  <BellIcon />
  {hasUnread && (
    <span className="absolute top-0 end-0 w-2 h-2 bg-destructive rounded-full" />
  )}
</div>
```

If it moves, it should be genuinely urgent.

## Check Yourself

1. Count the bold/colored/large elements in each section — more than one?
2. How many primary buttons are visible at once?
3. Is anything animated that isn't critically time-sensitive?
4. If you squint, does one thing stand out or many?
