# Smell: Separator as Hierarchy

**The mistake:** Joining several distinct kinds of fact into one line with a separator — `·`, `|`, `–`, `/` — and calling it laid out. The separator ends up doing the work that visual hierarchy should. `Trailblazer Tent · 611 units · #8 by sales` staples an identity, a quantity, and a rank into one grey run-on where every fact reads at the same weight and none is scannable.

## Why It's Garbage

Those three facts answer three different questions — *which product?*, *how much sold?*, *how well-ranked?* — and each deserves its own visual role. Flattened behind dots they read as a single muddy string: the eye can't tell where one fact ends and the next begins, so the reader parses word by word instead of at a glance. The dot is a tell — it means the layout step got skipped. It scales badly, too: add a fourth fact and the line just gets longer and greyer.

Separators are fine between *same-kind* fragments that are meant to read as one continuous value — a date range (`Jun 12 – Jun 26`), breadcrumb crumbs, `city, country`. The smell is using them to weld *different types* of data together.

## The Pattern

```tsx
// BAD: three different facts dot-concatenated into one grey line
<p className="text-xs text-muted-foreground">
  {productName} · {units} units · #{rank} by sales
</p>
```

```tsx
// GOOD: each fact gets a role — identity as a mark, metrics as their own stats
<div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs">
  <span className="inline-flex items-center gap-1.5 font-medium text-foreground/80">
    <EntityAvatar name={productName} src={productImageUrl} />  {/* identity: a visual object */}
    {productName}
  </span>
  <span className="inline-flex items-center gap-1 text-foreground/70">
    <Package className="icon-xs" /> {units} units              {/* metric: icon + value */}
  </span>
  <span className="text-muted-foreground">#{rank} by sales</span>  {/* metric: secondary */}
</div>
```

## The Rules

- **Give each kind of fact its own role.** An identity (product, user, account) is a visual object — an avatar, logo, or chip. A metric is an icon + value. A status is a badge. Don't render them all as equal-weight text.
- **Space, don't separate.** Distinct facts read as distinct through whitespace (`gap-x-3`) and differing weight/colour — not a punctuation mark wedged between them.
- **A separator is allowed only between same-kind fragments** that form one continuous value (a date range, `city, country`, breadcrumbs). If the two sides answer different questions, it's the wrong tool.
- **Weight by importance.** The primary datum sits heavier (`text-foreground/70`), the secondary lighter (`text-muted-foreground`). Equal weight is what makes a run-on unreadable.
- **Watch for the fourth fact.** If your instinct on a new datum is "add another `·`", stop — that's the moment to restructure into roles, not extend the string.
