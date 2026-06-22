# Smell: Hidden Affordances

**The mistake:** Interactive elements that don't look interactive.

## Why It's Garbage

Users shouldn't have to guess what's clickable. When buttons look like text, cards look static, or icons look decorative, users miss functionality or hesitate to interact. The UI feels broken or untrustworthy.

## The Pattern

```tsx
// BAD: Clickable but looks like text
<span onClick={handleEdit} className="text-sm">
  Edit
</span>

// BAD: Card that's clickable but no visual cue
<Card onClick={() => navigate(`/orders/${id}`)}>
  <CardContent>Order #12345</CardContent>
</Card>

// BAD: Icon action with no button treatment
<Settings onClick={openSettings} className="icon-md" />
```

Users hover randomly hoping to discover what's interactive.

```tsx
// GOOD: Clear button
<Button variant="ghost" size="sm" onClick={handleEdit}>
  Edit
</Button>

// GOOD: Card with hover state
<Card
  onClick={() => navigate(`/orders/${id}`)}
  className="cursor-pointer hover:shadow-card-hover transition-shadow"
>
  <CardContent>Order #12345</CardContent>
</Card>

// GOOD: Icon with button wrapper
<Button variant="ghost" size="icon" onClick={openSettings}>
  <Settings className="icon-md" />
</Button>
```

## Affordance Checklist

Every interactive element needs at least one signal:

| Signal | How | When |
|--------|-----|------|
| Cursor | `cursor-pointer` | Always for non-button clickables |
| Hover state | Background/shadow change | Cards, rows, custom elements |
| Color | `text-primary` or distinct color | Links, text buttons |
| Underline | `underline` or `hover:underline` | Inline text links |
| Shape | Button/pill shape | Primary actions |
| Icon | Chevron, arrow, external link icon | Navigation hints |

## Common Violations

### 1. Ghost Buttons Gone Too Far

```tsx
// BAD: Invisible button
<button className="text-sm text-muted-foreground">
  Cancel
</button>

// GOOD: Ghost but visible
<Button variant="ghost">Cancel</Button>
```

### 2. Clickable Table Rows

```tsx
// BAD: Row is clickable but looks static
<TableRow onClick={() => viewOrder(id)}>
  <TableCell>{orderNumber}</TableCell>
</TableRow>

// GOOD: Hover state signals interactivity
<TableRow
  onClick={() => viewOrder(id)}
  className="cursor-pointer hover:bg-muted/50"
>
  <TableCell>{orderNumber}</TableCell>
</TableRow>
```

### 3. Icon-Only Actions

```tsx
// BAD: Naked icon
<Trash2 onClick={onDelete} className="icon-sm text-destructive" />

// GOOD: Icon in button context
<Button variant="ghost" size="icon" onClick={onDelete}>
  <Trash2 className="icon-sm text-destructive" />
</Button>

// ALSO GOOD: With tooltip for clarity
<Tooltip>
  <TooltipTrigger asChild>
    <Button variant="ghost" size="icon" onClick={onDelete}>
      <Trash2 className="icon-sm" />
    </Button>
  </TooltipTrigger>
  <TooltipContent>Delete</TooltipContent>
</Tooltip>
```

### 4. Links Without Distinction

```tsx
// BAD: Link looks like regular text
<a href="/terms" className="text-sm">Terms of Service</a>

// GOOD: Link is visually distinct
<a href="/terms" className="text-sm text-primary hover:underline">
  Terms of Service
</a>

// ALSO GOOD: Using the Link component
<Link to="/terms" className="text-sm text-primary hover:underline">
  Terms of Service
</Link>
```

### 5. Disabled States

```tsx
// BAD: Disabled looks the same as enabled
<Button disabled>Submit</Button>  // If styling is missing

// GOOD: Clear disabled state (shadcn handles this, but custom elements need it)
<div
  className={cn(
    "p-3 rounded",
    disabled
      ? "opacity-50 cursor-not-allowed"
      : "cursor-pointer hover:bg-muted"
  )}
>
  Custom interactive element
</div>
```

## The Hover Test

Hover over every element in your UI. Ask:
1. Can I tell this is clickable before I hover?
2. Does something change when I hover?
3. If nothing changes, should this be interactive?

## Check Yourself

1. Every `onClick` has a corresponding visual affordance
2. Clickable cards/rows have `cursor-pointer` and hover state
3. Icon actions are wrapped in `Button` or have clear interactive styling
4. Links are visually distinct from surrounding text
5. Disabled elements look different from enabled ones
