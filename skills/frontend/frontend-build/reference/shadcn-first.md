# shadcn as Foundation

shadcn is not a component library you consume — it's a starting point you own. The components live in your codebase. You customize them, extend them, compose them.

## The Mindset

**Don't ask "what component should I use?"**
**Ask "what can I build from what we have?"**

You have full creative control. The constraint is consistency, not rigidity.

---

## Discovery: What Do We Have?

Before building, explore:

```bash
# See all UI primitives
ls src/shared/components/ui/

# See custom shared components
ls src/shared/components/common/

# Find how a component is used
grep -r "Badge" src/features/ --include="*.tsx" | head -20

# See component variants
grep -A 20 "variants:" src/shared/components/ui/button.tsx
```

Read the component source. shadcn components are simple — usually under 100 lines. Understand what's there before deciding you need something new.

---

## Extension: Make It Yours

### Add Variants

Components use `cva()` for variants. Add your own:

```tsx
// src/shared/components/ui/badge.tsx
const badgeVariants = cva("...", {
  variants: {
    variant: {
      default: "...",
      secondary: "...",
      destructive: "...",
      success: "bg-green-100 text-green-800 border-green-200", // NEW
      warning: "bg-amber-100 text-amber-800 border-amber-200", // NEW
    },
  },
});
```

Now `<Badge variant="success">` works everywhere.

### Compose for Features

Wrap primitives into feature-specific components:

```tsx
// src/features/orders/components/OrderStatusBadge.tsx
import { Badge, BadgeProps } from "@/shared/components/ui/badge";

const statusConfig = {
  pending: { variant: "warning", label: "Pending" },
  completed: { variant: "success", label: "Completed" },
  cancelled: { variant: "destructive", label: "Cancelled" },
} as const;

export function OrderStatusBadge({ status }: { status: keyof typeof statusConfig }) {
  const config = statusConfig[status];
  return <Badge variant={config.variant}>{config.label}</Badge>;
}
```

The primitive stays clean. The feature gets a semantic component.

### Customize Defaults

If you find yourself overriding the same props everywhere, change the default:

```tsx
// Instead of <Dialog modal={false}> everywhere
// Just change the Dialog component default
```

---

## Installation: Get More From shadcn

If the project has the shadcn MCP configured (`.mcp.json`), use it to explore and install components:

**Preferred: Use MCP tools**
```
# search all available components
search_items_in_registries — fuzzy search by name/description

# Get details about a specific component
shadcn_get_component_details { "component": "accordion" }

# Install a component
shadcn_add_component { "component": "accordion" }
```


**When to install:**
- Need a pattern shadcn already solved (accordion, tabs, carousel, command)
- Building something that could use a shadcn primitive as base
- Don't reinvent — check if shadcn has it first



---

## Creation: When to Build New

Build new only when:
1. Nothing in shadcn fits (checked the full component list)
2. Can't be composed from existing primitives
3. Will be used in 3+ places

If building new:

```tsx
/**
 * StepIndicator — progress through multi-step flows.
 *
 * Why new: shadcn has no stepper, existing libs too heavy.
 * Used in: ImportDialog, OnboardingWizard
 */
export function StepIndicator({ steps, current }: Props) {
  // Follow shadcn patterns:
  // - Use cva() for variants
  // - Accept className prop
  // - Use cn() for merging
}
```

---

## Creative Freedom

You're not constrained to "what shadcn provides." You're empowered by it.

**Examples of creative extension:**
- Combine `Card` + `Badge` + `Button` into a rich action card
- Add animation variants to `Dialog` for different entry effects
- Create a `DataCard` that composes `Card` with built-in loading/empty states
- Build a `StatWidget` from `Card` + typography for dashboards

The goal is a cohesive design system that feels distinct and intentional, built on solid foundations.

---

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Copy-paste component code into features | Import from `shared/components/ui/` |
| Override with `!important` or `!p-0` | Modify the component or create variant |
| Create parallel implementations | Extend the existing component |
| Use inline styles for repeated patterns | Add a variant or utility class |
| Install packages that duplicate shadcn | Check if shadcn has it first |
