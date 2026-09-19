# Composite Identity

The highest-stakes correctness rule in the frontend. Get it wrong and a bulk write silently hits a second region's listings.

## The fact

Some entities look like they have a name-shaped identity and don't. A sales channel exists **per region**: the same marketplace in two countries is two distinct `(channel + region)` entities with **different `channelId`s**. `shared/utils/channel-display.ts` says it in its own header: "each channel row is a distinct (channel + region) entity."

So a bare channel-name string is **not an identity**. It collapses two regions into one.

## The rule

**Never key on the name. Key on `channelId`.** Carry `region` / `countryCode` alongside, for display only. The channel type already carries both — the features that consume it are the pattern to match.

## The general form

Channels are the instance with money attached, but the rule isn't about channels: **when an entity's real identity is a composite, never key on the half that happens to be readable.** A SKU is `(tenantId, sku)`, not `sku`. A metric bucket is `(metric, currency)`, not `metric`. A person is an id, not an email. The readable half is the one everybody recognizes, which is exactly why it ends up as the `Record` key.

The test, applied to any value you're about to key on: **could two rows in the same list legitimately carry this value?** If yes, it is a label, not a key.

## Where it actually breaks

**Writes and updates — the worst case.** A bulk reprice sent as `channels: [name]` hits *both* regions' listings. Send `channelId`s, or listing ids. The reprice **sheet** is the safe shape to copy: it carries `listingId`, so region is recoverable by joining listing → channel.

**Aggregations, maps, dedup — the quiet case.** Each of these merges or mis-splits regions:

```typescript
new Set(channels.map(c => c.name))            // two regions of one marketplace → one entry
Record<channelName, Metrics>                  // the second region overwrites the first
channels.find(c => c.name === marketplace)    // returns whichever sorted first
groupBy(rows, r => r.channelName)             // two countries' money in one bucket
```

If a `Set`, a `Record` key, a `find`, a `groupBy`, or a join key is a channel **name**, that is the finding — regardless of whether the current data happens to have one region.

## Display is the only place names belong

Render through the shared helpers, never a hand-rolled capitalizer:

- `getMultiRegionChannels(accounts)` — the set of channel names appearing in more than one region in scope. Compute it once from the connected accounts across `useScope()`; `shared/hooks/useMultiRegionChannels.ts` wraps this.
- `getRegionIndicator(name, region, countryCode, multiRegionSet)` — the flag, or `''`.
- `formatChannelLabel(channel, multiRegionSet, translatedName?)` — the full label.
- `ChannelLabel` / `ChannelLogo` in `shared/components/common/` for the rendered forms.

The UX rule those encode: **a region indicator appears only when the same channel exists in more than one region in scope.** A flag on a channel that's single-region in the account is noise. Don't hardcode flags, and don't append region codes yourself.

## Reviewing it

Grep the diff for names used as identity:

```bash
git diff {base}...HEAD | grep -nE '\.name ===|\[[a-zA-Z]*[Nn]ame\]|by[A-Z][a-zA-Z]*\[|groupBy\([^)]*\.name'
```

A hit is not automatically a defect — a label, a logo lookup, or a translation key legitimately takes the name. The question is always: **is this name being used to decide, aggregate, or write?** If yes, it needs the id.
