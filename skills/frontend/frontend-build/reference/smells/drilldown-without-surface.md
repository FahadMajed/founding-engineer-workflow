# Smell: Drilldown Without a Surface

**The mistake:** A row expands into its parts, and those parts are dropped straight onto the parent's background. Nothing says where the group starts or ends, so five per-entity slices of one row read as five more rows in the feed.

## Why It's Garbage

Expanding is a claim: *these things are inside that thing.* If the revealed content wears the same background as the list it came out of, the claim is never made visually. The reader is left to infer containment from indentation and a chevron they can no longer see, and in a `divide-y` list the divider above the panel is doing the opposite job — it says "new row starts here."

It also loses the close. Rows and their children scroll as one grey field, so the eye can't find the bottom of an open group to collapse it or to keep reading the feed.

## Peers or children — decide first

Not every disclosure needs a surface. The question is what the reveal produces:

- **Continuation → no surface.** "Show 5 more" appends items that are *peers* of the ones already visible. They belong to the same list at the same level. A background would falsely mark them as a different kind of thing.
- **Drilldown → its own surface.** The reveal breaks *one* row into its constituent parts — a summary line into its per-entity slices, a cost line into its entries, an organization into its accounts and users. The content is inside something, so it must look inside something.

## The Pattern

```tsx
// BAD: a start rail is the only containment for a list of child rows
<Reveal open={expanded}>
  <div className="mt-2 space-y-1 border-s-2 border-border ps-4 ms-1">
    {children.map((child) => <ChildRow key={child.id} child={child} />)}
  </div>
</Reveal>
```

A 2px rule can't hold a stack of rows — each child still sits on `bg-card` at the same visual level as the feed's own rows.

```tsx
// GOOD: the panel is a surface one step down from the card it opened on
<Reveal open={expanded}>
  <div className="mt-2 space-y-1 rounded-lg bg-surface-sunken p-3">
    {children.map((child) => <ChildRow key={child.id} child={child} />)}
  </div>
</Reveal>
```

## Use the token, not an opacity

`bg-surface-sunken` exists because `bg-muted/{n}` cannot do this job in light mode. In a typical light theme `--card` is `#ffffff` and `--muted` a near-white tint, so `bg-muted/40` composites to roughly a 2% luminance step — which is no step at all. Dark mode hides the problem: the same opacity over a dark card reads fine, so a panel checked only in dark ships invisible in light.

Define `--surface-sunken` per theme so both give the same *perceived* step, and keep the light value lighter than `--border` so the panel never reads as a solid block. Verify a new surface in **light** mode — it is the one that fails first.

## The Rules

- **One step down the ladder, never up.** A drilldown out of `bg-card` lands on `bg-surface-sunken`. Out of a panel that is already tinted it is already contained — don't nest a second tint (box-in-box, see [border-addiction](border-addiction.md)).
- **Background instead of the border, not beside it.** Adding the surface and keeping `border-s-2` is the border smell with extra steps. Pick the surface.
- **No shadow.** A drilldown is not an overlay — it pushes the page down, it doesn't float over it. Shadows are for dropdowns, popovers and modals ([flat-elevation](flat-elevation.md)).
- **A rail is enough only for a prose annotation.** One paragraph of evidence hanging off one row — a suggestion's rationale, say — reads fine on a rail, because there are no child *rows* to mistake for siblings. The moment the reveal is a list, it needs the surface.
- **Watch the `divide-y` parent.** If the list separates its rows with rules, an unsurfaced panel inherits a divider above it that reads as "next row" — the surface is what breaks that reading.
