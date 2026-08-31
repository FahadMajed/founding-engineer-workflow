# Surface Ownership

Three surfaces answer questions *about* the whole account rather than about one part of it. Every other page is a leaf: it answers one question well and leaves those three alone.

This page exists to be read before building a new page, by anyone — the failure it prevents needs no code to explain.

## The division of labour

| Surface | The one question it answers | What that means |
|---|---|---|
| **Home** | *What do I do today?* | Whatever needs a decision right now, across every tenant and channel, ranked by urgency. It is the only page allowed to be about "everything". |
| **Tenant health** | *What needs attention, or is slipping?* | Per tenant, per dimension, with the offending fact and how long it's been that way. The type says it out loud: `Band = 'NeedsAction' \| 'Slipping' \| 'Healthy' \| 'NoSignal'`. |
| **Sync health** | *Is the data I'm looking at current?* | Connections, streams, cadence, inventory drift. Every other page's trustworthiness is this page's subject. |

A leaf page — revenue, orders, products, ads when it lands — answers its own question. Revenue answers *where did the money go*. It does not also answer *what needs attention* or *is the data fresh*.

## The test, before you build

Write down the question your page answers, in one sentence, from the user's side. Then check it against the three above.

- If it **is** one of them, you're extending that surface, not building a page.
- If it **contains** one of them ("…and shows which tenants need attention"), that part belongs to the owner. Link to it.
- If it's genuinely its own question, you're a leaf. Now read the two rules below.

## Rule 1 — consume the vocabulary, never re-answer the question

This is the distinction that matters, and the two halves look similar in a diff.

**Consuming the vocabulary is right.** One concept, one name, per [naming-and-language.md](naming-and-language.md). Revenue does this deliberately:

```ts
import type { Band } from '@/features/tenant-health';
/** Actionable margin bands — the tenant-health vocabulary minus NoSignal. */
export type MarginBand = Exclude<Band, 'NoSignal'>;
```

A margin band and a health band mean the same thing to the reader, so they carry the same name and the same colours (`BAND_TONE`). Inventing `MarginStatus = 'bad' | 'warning' | 'ok'` beside it would be the defect.

**Re-answering the question is wrong.** These are the findings:

- A cross-tenant "needs attention" list on a page that isn't tenant health.
- A sync badge, a "last synced" line, or a staleness warning given visual weight on a leaf page. If the data's freshness is in doubt, that is sync health's subject and its link.
- A leaf page ranking tenants by health rather than by its own measure.
- A second "what should I do today" summary anywhere but home.

The line: **borrow the words, link for the answer.**

## Rule 2 — contribute into the hub instead of imitating it

When a leaf feature genuinely has something a hub should show, it hands the hub a piece to render. It does not rebuild the hub's shell locally.

The worked example is revenue's health dimension. `TenantHealthRevenuePanel` **lives in revenue**, is rendered by **tenant health's** `TenantChartView`, and wraps tenant health's own `DimensionPanel` shell:

```
features/revenue/components/TenantHealthRevenuePanel.tsx   ← revenue owns the content
features/tenant-health/components/TenantChartView.tsx      ← tenant health owns the placement
```

The leaf supplies the data and the panel body; the hub decides where it sits and in what order. Copy that direction. A leaf that renders its own imitation of a hub's layout has forked the hub.

Two seams to keep clean while doing it. The dependency runs **both ways** — the leaf imports the hub's vocabulary, the hub imports the leaf's panel — so every crossing goes through the other's barrel ([feature-structure.md](feature-structure.md) → hub features), never a deep path. And the hub composes its dimensions from a registry it reads, not a chain of `if (revenueDetail && isRevenueEnabled)` blocks; the second contributed dimension is where that pays for itself.

## Home specifically

Home has **two** ways to carry a feature, and they are not equivalent.

**A widget** — a card in home's own layout, like `HomeRevenueWidget`. Frontend-only. Use it for a standing figure the user wants on arrival.

**A tier item** — an entry in `actNow`, `deadlines`, or `watch`. This is **not a frontend change.** `HomeItemKind` and `HomeDeepLinkPage` are closed unions whose header says *"Mirrors `GET /v1/home` — `src/home/endpoints/home.dto.ts` in the backend, field for field"*, and the backend decides the tier — the frontend receives `data.attention` already sorted into `{ actNow, deadlines, watch }`. Adding one means a backend DTO change, emit logic, and a matching union entry in both repos.

While the backend catches up on a new kind, the frontend may inject a shape-complete placeholder in `useHome.ts` — that is the mocked-API convention working as intended ([api-contract.md](api-contract.md)), and it is not the pattern to copy for a launched feature.

**Presence in home is a disposition, not a requirement.** Treat it like the discovery doc's cross-cutting capabilities disposition: adopt with a named tier and a reason, or record N/A with a reason. Never silently skip the question.

The reason it is not a mandate: home has three urgency tiers and an `AllClearCard`. If every feature registers something, `allClear` never fires, and the one property that makes home worth opening — that an empty home means nothing is wrong — is gone. A feature earns a tier only if it produces state that is **tenant-scoped, time-bounded, and actionable today**. Ads overspending on a live campaign qualifies. A settings page does not.

## Three closed unions, two repos

`HomeItemKind`, `HomeDeepLinkPage` and `Dimension` are all closed unions mirrored from the backend. A new hub presence touches all of: the backend DTO, the backend emit path, the frontend union, and the rendering. Plan it as cross-repo work from the start — discovering it at wiring time is how a feature ships with no home presence and no record of deciding against one.

## "Drift" means two different things

Sync health's drift is **inventory** drift — the stock count disagrees with the channel. Revenue's `KeepRateDrift` and fee drift are **money** drift against a trailing baseline. Both are correct in their own domain, and both appear in home's item kinds (`InventoryDrift`, `MarginBleed`).

So an unqualified "drift" on a new surface is ambiguous. Qualify it — inventory drift, fee drift, keep-rate drift — every time.
