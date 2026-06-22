# Smell: Icon Inconsistency

**The mistake:** Mixed icon sizes, stroke weights, and styles in the same UI.

## Why It's Garbage

Icons are visual vocabulary. When that vocabulary is inconsistent — some icons thick, some thin, some 16px, some 24px, some filled, some outlined — the UI feels cobbled together from different kits. It signals carelessness.

## The System

Use the defined icon utilities:

| Class | Size | Use For |
|-------|------|---------|
| `icon-xs` | 12px | Inline indicators, badges |
| `icon-sm` | 16px | Buttons, form fields, table cells |
| `icon-md` | 20px | Default for most UI |
| `icon-lg` | 24px | Card headers, empty states |
| `icon-xl` | 32px | Hero sections, large empty states |

## The Pattern

```tsx
// BAD: Random icon sizes
<div className="flex items-center gap-2">
  <Package size={18} />
  <span>Products</span>
  <ChevronRight size={14} />
</div>

<div className="flex items-center gap-2">
  <ShoppingCart className="w-6 h-6" />
  <span>Orders</span>
  <ChevronRight className="w-4 h-4" />
</div>
```

Different sizing approaches, arbitrary values.

```tsx
// GOOD: Consistent system
<div className="flex items-center gap-2">
  <Package className="icon-sm" />
  <span>Products</span>
  <ChevronRight className="icon-sm" />
</div>

<div className="flex items-center gap-2">
  <ShoppingCart className="icon-sm" />
  <span>Orders</span>
  <ChevronRight className="icon-sm" />
</div>
```

Same size class, consistent feel.

## Icon + Text Alignment

Icons should align with text baseline, not float randomly:

```tsx
// Standard pattern: icons same height as text line
<div className="flex items-center gap-2">
  <Package className="icon-sm" />
  <span className="text-sm">View products</span>
</div>

// For buttons
<Button>
  <Plus className="icon-sm me-2" />
  Add Product
</Button>
```

## Icon Color

Icons should match their context:

```tsx
// Muted icons for secondary actions
<Button variant="ghost">
  <Settings className="icon-sm text-muted-foreground" />
</Button>

// Icons inherit button text color in primary actions
<Button>
  <Plus className="icon-sm me-2" />  {/* Inherits white from button */}
  Add
</Button>

// Semantic colors for status
<div className="text-destructive">
  <AlertCircle className="icon-sm" />  {/* Inherits red */}
</div>
```

## Stroke Weight

Lucide icons have consistent stroke weight by default. Don't mix with other icon sets that have different weights.

```tsx
// BAD: Mixed icon sources
import { FaShoppingCart } from 'react-icons/fa';  // FontAwesome - heavier
import { Package } from 'lucide-react';            // Lucide - lighter

// GOOD: One icon family
import { ShoppingCart, Package } from 'lucide-react';
```

## Common Contexts

| Context | Icon Size | Example |
|---------|-----------|---------|
| Table row actions | `icon-sm` | Edit, Delete buttons |
| Button with text | `icon-sm` | `<Plus /> Add Product` |
| Button icon-only | `icon-md` | Action menu trigger |
| Sidebar nav | `icon-md` | Navigation items |
| Card header | `icon-lg` | Feature icon |
| Empty state | `icon-xl` | Illustration replacement |
| Badge indicator | `icon-xs` | Status dot |

## Check Yourself

1. Are all icons from the same family (lucide-react)?
2. Are you using `icon-*` classes instead of arbitrary sizes?
3. Do similar contexts use the same icon size?
4. Do icons align with adjacent text?
