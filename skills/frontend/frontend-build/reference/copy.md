# Copy

Every string a user reads, in every configured locale. This is the rubric `copy-sweeper` reviews against.

Copy is the one layer whose author is structurally the worst reviewer of it: you know what you meant, so you read your own label as clear. That is the same reason `visual-sweeper` exists, applied to text.

## Who reads this screen

Not only your own staff. An operator running accounts for customers, a managed customer inside their own account, a self-serve owner running it themselves — owner, e-commerce manager, ops or finance staff, even a freelancer they hired. Write for the role in front of the screen, never for the employer, and never for the engineer who built it.

## No design leakage

Copy states **the user's fact and next action**. It never narrates the system's rationale, mechanism, or design principle.

| Leakage | The user's fact |
|---|---|
| "Balances auto-resolve to one window" | "Covers 1–15 March" |
| "Aggregated per-item across the scope" | "Totals for all 412 products" |
| "No accounts in your current scope" | "No accounts match your filters" |

Interpretation aids stay — a stamp, a caveat, a unit, a date qualifier all help the reader act. What goes is designer-to-reviewer commentary that survived into the product.

The tell-tale vocabulary: *scope, aggregate, instance, per-item, envelope, payload, dedup, auto-resolve, upsert, idempotent*, and any sentence explaining **why the system does it this way** rather than **what is true**.

`scope` deserves its own note: as product vocabulary a user recognizes ("Inventory scope", "View scope") it is fine. As a stand-in for *filters* or *selection* in a sentence, it is leakage. Judge it per string; don't blanket-replace.

## The label test

For every label, subline, helper text and tooltip: **would the reader act or interpret differently without it?** If not, cut it. A subline restating the title in other words costs a line of the reader's attention and returns nothing.

## Clarity without dumbing down

Keep the real domain term — keep-rate, settlement, drift, band. Renaming a real concept to something vague makes the screen friendlier and the user less able to talk to anyone else about it.

But don't assume the term is known. Give it a **lightweight in-place gloss on its primary use**: a tooltip, a one-line subtitle, an info affordance. A safe place to learn it, not a reworded label.

A domain term with nowhere on the screen to learn it is the gap — that's the finding, and the fix is the gloss, not the rename.

## Every locale, and they must agree

Keys must exist in **every** configured locale file — `verify-feature.mjs` hard-fails on a missing one. That check proves a key *exists*; it cannot prove the translation **says what the primary language says**. Nothing mechanical can. So:

- Read the locale pair together for every key the diff adds. A stale translation left over from an earlier wording, one that drops a qualifier ("net" or "before fees" vanishing), or a label describing an older version of the control are all invisible to the script and to the builder.
- A number, unit, currency or date inside an interpolated string must carry the same meaning in every locale.

Register rules for the second locale — the influences to draw on, the banned forms, the calqued constructions borrowed from English — live in [i18n-rtl.md](i18n-rtl.md). The mechanical ones warn in `verify-feature.mjs`; the register judgment does not automate.

**Grepping a non-Latin script needs word boundaries.** A script without case, where roots recur as substrings, produces false hits from any bare substring search — the root of "in progress" also sits inside "commercial", and a one-letter prefix matches a dozen unrelated words. Anchor on whitespace or string start, and read the hit in context before calling it a violation.

## Currency, numbers, dates

- Money renders through `Money`, never a hardcoded currency code or symbol inside a string.
- Don't bake a number or a unit into a translation where interpolation belongs — it breaks pluralization and it strands the other locales when the primary one changes.
- Relative time comes from `formatTimeAgo()`; it is already i18n-aware.

## Writing the finding

Quote the current string, name what a reader would wrongly conclude from it, and **give the replacement text** — in every locale that's wrong. A copy finding without proposed wording is an opinion; with it, it's a one-line fix.
