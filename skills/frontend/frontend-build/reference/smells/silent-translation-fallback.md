# Smell: Silent Translation Fallback

**The mistake:** A `t()` key that doesn't exist in the locale files. Nothing errors — i18next returns the fallback, so the second locale quietly renders the primary language forever.

## Why It's Garbage

Every other i18n mistake announces itself. This one doesn't. `t('channels.northMarket', 'North Market')` on a missing key renders **North Market** — a plausible-looking string, in the wrong language, on every screen that touches it. Nobody files a bug because nothing looks broken; it just looks untranslated, and untranslated reads as unfinished.

It ships exactly this way: the channel names live under `header.*`, twenty call sites ask for `channels.*`, and every channel label across four features renders in the primary language for months.

## The Two Shapes

**Static key, wrong or missing.** Caught by the verification script.

```tsx
t('listings.proceedsPerUnit')   // locale still says `clearedPerUnit` → renders the raw key
```

**Dynamic key, dead prefix.** The dangerous one — a literal prefix plus an interpolated leaf. If the *prefix* isn't an object in the locale file, every lookup under it falls back at once.

```tsx
t(`channels.${name.toLowerCase()}`, name)   // no `channels` namespace → always the fallback
```

The fallback argument is what hides it. Without it you'd see `channels.northmarket` on screen and fix it in a minute.

## The Rule

- **One key per concept, in one namespace.** A concept spelled in two namespaces will drift, and the dead one is invisible. Channel names live in `common.channels` — not `header`, not `saleChannels`.
- **Shared vocabulary goes in a shared namespace** (`common`, `errors`, `validation`, `time`, `export`, `navigation`), not copied into a feature.
- **Keep the literal prefix visible** — `` t(`common.channels.${name}`) ``, never a helper that assembles the string. The verification script finds dynamic keys by their literal prefix; hide it and the key is unreachable to tooling.
- **A fallback argument is for unknown data, not for missing keys.** It's right for `` t(`common.channels.${name}`, name) `` because a new channel can appear before its translation does. It is never a reason to skip adding the key.

## Check Yourself

```bash
node scripts/verify-feature.mjs <feature>
```

The script owns three checks, and exits non-zero on any miss: static keys resolve, every dynamic prefix is a real object in the locale file, and the locales match key-for-key (plural-category differences exempt).

Then the part no script can do: **switch the app to the second locale and read the screen.** A key that resolves to a primary-language string passes every check above. If a label reads the same in both locales and it isn't a proper name, it's this smell.
