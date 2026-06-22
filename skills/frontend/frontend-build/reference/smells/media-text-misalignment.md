# Smell: Media Adrift from Text

**The mistake:** Placing an image, logo, or avatar beside a text block without binding it to that text — wrong size, wrong alignment, or sized for text that isn't there. The media floats in dead space instead of reading as one unit with the text.

## Why It's Garbage

A thumbnail next to a name + subtitle is supposed to read as "this item." When the image is too small for the two-line block, it sits centered in a pool of empty space — detached, accidental-looking. When it's sized assuming the subtitle is always present, the row falls apart the moment that line is null. When a neighbor can squeeze it, it distorts on the first narrow screen. Each one makes a tidy list look unkempt.

## The Pattern

```tsx
// BAD: 24px thumbnail next to a two-line block — floats in dead space
<div className="flex items-center gap-2">
  <Thumbnail src={item.image} size="xs" />      {/* 24px */}
  <div className="min-w-0">
    <div className="truncate">{item.name}</div>
    <div className="text-xs text-muted-foreground">{item.subtitle}</div>
  </div>
</div>
```

```tsx
// GOOD: media sized to the block it sits in, centered, shrink-proof
<div className="flex items-center gap-2 min-w-0">
  <Thumbnail src={item.image} size="sm" />      {/* 40px ≈ two text lines */}
  <div className="min-w-0">
    <div className="truncate">{item.name}</div>
    {item.subtitle && <div className="text-xs text-muted-foreground truncate">{item.subtitle}</div>}
  </div>
</div>
```

## The Rules

- **Center against the text** — `items-center`. The media stays aligned whatever the text height resolves to (one line or two).
- **Size to the block, not the longest case** — a thumbnail beside a two-line block (name + subtitle) is ~`sm` (40px); beside one line it's smaller. Never leave the media shorter than its text with dead space around it.
- **Design for the secondary line being absent** — the subtitle (metadata, region, timestamp) is often null. Render it only when it has a value, and make sure the row reads right with one line *or* two. Don't size or space as if the text is always there.
- **Shrink-proof the media** — `shrink-0` so flex pressure squeezes the text (which truncates via `min-w-0` + `truncate`), never the image.
- **Match scale across a surface** — a thumbnail and a secondary badge image in a table row should echo the same elements in the list or cards beside it, not each panel inventing its own size.

## Check Yourself

1. If the subtitle were null, would this row still look intentional?
2. Is the media roughly as tall as the text block beside it — or floating in empty space?
3. At 375px, does the image hold its size while the text truncates?
4. Does this thumbnail/logo match the size used for the same element elsewhere on the page?
