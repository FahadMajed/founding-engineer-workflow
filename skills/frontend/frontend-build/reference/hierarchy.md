# Hierarchy

How to decide what stands out. The failure modes live in the smell files — [size-for-hierarchy](smells/size-for-hierarchy.md), [labels-as-content](smells/labels-as-content.md), [competing-emphasis](smells/competing-emphasis.md). This file is the positive version: the ladder to place things on.

## The one rule everything else follows

**Hierarchy is made by quieting the secondary, not by inflating the primary.** Inflating starts a size war: the header grows, body text grows to compensate, and nothing reads as important because everything is loud.

## The ladder

Decide each piece of text's rung before styling it. Three rungs per section is usually enough; a fourth means the section is doing two jobs.

| Rung | Role | Typical treatment |
|---|---|---|
| **Primary** | the datum the user came for — the number, the name, the status | default `text-foreground`, `font-medium` / `font-semibold`, default or one step up in size |
| **Secondary** | supporting facts that qualify the primary — a subtitle, a count, a channel | `text-sm text-muted-foreground` |
| **Tertiary** | labels, timestamps, hints, units | `text-xs text-muted-foreground`, or `/70` for genuine background |

Labels sit **below** the data they describe, always. A label at the same weight as its value makes the reader work out which is which — and in a metric card the label is the part they already know.

## Semantic tokens, not raw colours

`text-foreground`, `text-muted-foreground`, `bg-card`, `bg-muted`, `border-border`, `text-destructive`. Never a hex or a raw palette step (`text-gray-500`) — the tokens are what make light and dark, and any future theme, hold together.

Colour carries **meaning**, not emphasis. `text-destructive` means bad, not "important". A value's colour and its sign must agree — a red cell reading "+12%" is a defect, not a style choice.

## One loud thing per section

Per section, exactly one element earns the loudest treatment. Two competing means neither wins. A page with three primary buttons has no primary button.

When something new needs to stand out, the first move is to quiet its neighbours — not to raise it.

## Numbers

Numerics right-align with `tabular-nums` so digits line up down a column. In a `DataTable` that's `meta: { className: 'text-end tabular-nums' }`, and the header takes the same alignment so it sits over its values. `AnimatedNumber` for values that change in view; `Money` for currency, always.

Scale a number's prominence to the decision it drives, not to its digit count. A hero figure repeated as a chart segment and again as a list row is one datum worn three ways — pick the one view that earns the space.

## Density

This is an operator's tool, used all day on wide screens. Dense is correct; cramped is not. Space comes from the Tailwind scale (4, 6, 8, 12, 16, 24, 32, 48) applied at the container via `gap-*` / `space-y-*` — not per-child margins, which double up against the container's own spacing (`Card` already brings `gap-6`/`py-6`, and `verify-feature.mjs` hard-fails on `pt-`/`py-` added to `CardHeader`/`CardContent`).

Grouping is hierarchy too: related things sit closer to each other than to the next group. Reach for spacing and background before a border — see [border-addiction](smells/border-addiction.md).
