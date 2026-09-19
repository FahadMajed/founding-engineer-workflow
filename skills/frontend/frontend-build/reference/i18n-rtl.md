# i18n & RTL

Every user-facing string is translated, and every layout works in both directions. Both are mechanically checkable in part — `node scripts/verify-feature.mjs <feature>` hard-fails on any `t()` key missing from a locale file.

## Keys

- `useTranslation()` for all user-facing text. A hardcoded string in JSX is the finding.
- **Add to every locale.** One file per locale under `src/locales/` — the primary language and the second locale carry the same key set. A key in one and not the other fails the script.
- **Namespace = the feature**, camelCase: `accounts`, `tenantHealth`, `catalogMapping`, `periodComparison`, `creditNotes`, `syncStatus`. Kebab-case namespaces don't get added.
- Shared namespaces to reuse rather than duplicate into a feature: `common`, `errors`, `validation`, `time`, `export`, `navigation`.
- Dynamic key maps (`` t(`orders.status.${status}`) ``) are picked up by the verify script when the top segment is a known namespace — keep the literal prefix visible so it can be found.
- Bilingual **data** fields (not UI text) use `useTranslatedField()` from `shared/utils/utils.ts`.
- **A missing key doesn't error — it renders the fallback**, so the second locale quietly shows the primary language. One concept, one key, one namespace; shared vocabulary (channel names → `common.channels`) goes in `common`, never copied into a feature. The audit has to cover static keys *and* dynamic prefixes and exit non-zero on a miss — a check that only reads literal `t('…')` calls passes a screen that is half-untranslated. See [silent-translation-fallback](smells/silent-translation-fallback.md).

## Register — decided once, written down

Each locale has a register, and it lives next to the strings. "Sounds natural" is not a rule anyone can apply or review; a short table of banned constructions is.

Choose the language's own clear, precise, dignified register: strong verbs, clean structure, no filler. Never weak colloquial phrasing, never archaic.

Then name the constructions that keep leaking in, each a finding on sight. They are almost always **calques** — English structure carried word-for-word into a language that has its own way of saying it. The shapes that recur:

| Don't | Do | Why |
|---|---|---|
| a participle or noun phrase for a progress state ("in loading") | the language's active verb | the participle is the English gerund wearing local words |
| a light verb + verbal noun for a completed action ("was done saving") | the real past tense | periphrasis where the language has a single word |
| a preposition calqued from English "as" ("as a report", "as cancelled") | the language's own construction | grammatical in English, wrong here — the surest tell of a machine-translated string |

Keep the list to the three or four entries people actually break, and review it like code.

## RTL

Use **logical properties** everywhere. Physical ones break the right-to-left layout silently — nothing errors, the layout is just wrong:

| Never | Always |
|---|---|
| `pl-*` `pr-*` | `ps-*` `pe-*` |
| `ml-*` `mr-*` | `ms-*` `me-*` |
| `left-*` `right-*` | `start-*` `end-*` |
| `text-left` `text-right` | `text-start` `text-end` |
| `border-l` `border-r` | `border-s` `border-e` |
| `rounded-l-*` `rounded-r-*` | `rounded-s-*` `rounded-e-*` |

`useLanguage()` is only for cases Tailwind can't express: dynamic JS positioning, a conditional `side` prop on a popover, chart direction (`useChartDirection`). Reaching for it to pick between `pl-4` and `pr-4` means the logical property was the answer.

**Directional icons mirror themselves.** `index.css` flips `chevron-left/right`, `arrow-left/right` and `chevrons-left/right` under `[dir="rtl"]`. Write the LTR icon — prev is `ChevronLeft`, next and drill-in are `ChevronRight` — in every language; `isRTL ? ChevronLeft : ChevronRight` flips it twice and points it backwards. And never put `rotate-*` on one of those icons: Tailwind v4's `rotate` applies after `transform`, so a rotated chevron lands 180° off in the RTL locale. Rotating carets use `ChevronDown` + `-rotate-90 rtl:rotate-90`. See [double-flipped-icons](smells/double-flipped-icons.md).

Grep the diff — this is cheap and catches most of it:

```bash
git diff {base}...HEAD | grep -nE '\+.*\b(pl|pr|ml|mr)-[0-9]|\+.*(text-left|text-right)|\+.*\b(left|right)-[0-9]'
```

## Currency

Always the `Money` component (`shared/components/common/Money.tsx`). A hardcoded currency code, a symbol pasted into a string, or a manually formatted amount is the finding.

```typescript
import Money from '@/shared/components/common/Money';
<Money amount={price} className="text-sm" />
```

## Numbers and dates

- **Numerals follow the locale**, through the shared formatter (`Money`, `formatNumber`). A locale may render a different digit set; hand-substituting glyphs into a string defeats `tabular-nums` alignment and can't be parsed back.
- `date-fns`, plus `formatTimeAgo()` from `shared/utils/utils.ts` for relative time (it's i18n-aware). Don't hand-roll relative time, and don't format dates with `toLocaleDateString` inline — the locale won't follow the app's language.

## Copy

The reader may not be internal staff — a customer, a finance hire, or a self-serve owner reads the same screen. Keep the real domain term, give it an in-place gloss. And copy never narrates the system's own mechanics ("auto-resolves", "one record, one window"); it states the user's fact and next action. Grep the strings you added for designer-speak before calling it done — this check fails silently. See [copy.md](copy.md).
