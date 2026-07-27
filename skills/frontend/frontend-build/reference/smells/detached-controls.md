# Smell: Detached Controls

**The mistake:** A titled section's controls — search, sort, filters, export, a view switcher — live in a **separate band from the title** instead of in the section's header. The title goes in `CardHeader`; the controls become the first child of `CardContent`. Between them sits the card's `gap-6` (24px) of dead space, and the control band, right-aligned and alone, reads as stranded.

## Why It's Garbage

The controls belong to the section — they act on what the title names. Splitting them into a band below the title breaks that bond: the eye sees a floating heading, then a void, then a lone toolbar. A `justify-end` bar with only a sort toggle has an empty left half; a pagination `justify-between` with a short count has a marooned pair of arrows. Every one of these is the section's own spacing turned into emptiness.

## The Fix: controls go in the header band, beside the title

Put the controls in the same band as the title. The house pattern is `CardHeader` (or the section's first band) as a `justify-between` row — title on the left, controls on the right — so there is no gap-6 void and no orphaned bar.

```tsx
// BAD: title in the header, controls stranded in the body, gap-6 void between
<Card>
  <CardHeader><CardTitle>Records in this range</CardTitle></CardHeader>
  <CardContent className="p-0">
    <div className="flex justify-end px-4 py-2">…sort…</div>   {/* detached, empty left */}
    …rows…
  </CardContent>
</Card>

// GOOD: one header band owns title + controls; body starts right after
<Card className="gap-0 overflow-hidden py-0">
  <div className="flex items-center justify-between gap-4 border-b px-4 py-3">
    <CardTitle>…</CardTitle>
    …sort…
  </div>
  …rows…
</Card>
```

When a component renders its own list + toolbar + footer, let it **own its card** (pass `title`/`description` as props) rather than being wrapped in a page-level `CardHeader` + `CardContent p-0`. One band, one owner.

## Layout inside the band depends on control width

Co-locating with the title does **not** mean cramming everything into the title's row:

- **Compact control** (a sort toggle, a small segmented switch) → inline beside the title, `justify-between`.
- **Width-hungry control** (a search input that wants `flex-1`) → its **own row directly below the title**, tight (`space-y-3`), still inside the header band above the divider. Forcing a full-width search into the title row collapses it to an unusable nub.

```tsx
// Width-hungry: title on top, the wide control on its own row beneath it
<div className="space-y-3 border-b px-4 py-3">
  <h3 className="text-base font-semibold">Records in this range</h3>
  <div className="flex items-center gap-2">
    <div className="relative flex-1"><Search/><Input className="ps-9" /></div>
    <Button>Export</Button>
  </div>
</div>
```

## The Test

If you're about to render a toolbar (search / sort / filter / export / pagination) as the **first or last child of `CardContent`**, stop — it belongs in the section's header band with the title. Then pick the layout by the widest control: compact ones sit beside the title, a full-width one drops to its own row beneath it.
