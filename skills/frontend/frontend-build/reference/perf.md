# Performance

What the interface costs the user to run — requests waited on, renders burned, kilobytes shipped. This is the rubric `perf-sweeper` reviews against.

Perf failures ship because they're invisible at dev scale: the mock has 12 rows, the dev machine is fast, the dev network is local. Every rule here prices against the real scale the build already mocks at — the largest real account's catalog, the months-deep orders table — and against the three units a finding is stated in: **requests per interaction, renders per input, kilobytes per chunk**. "Feels slow" is not a finding; a count is.

There are no budgets in this file, on purpose. A budget number frozen here drifts; the bar is the delta you can demonstrate against what the app already does — the neighbouring page that paints in one round-trip, the chunk sizes the current build prints, the render count the current state placement produces.

## What this file does not own

Reference-governed patterns stay with their references, and `conventions-sweeper` reviews those: lazy routes ([feature-structure.md](feature-structure.md) → Lazy loading), store selector form and effect-derived state ([state.md](state.md)), the prefetching table-data hook ([data-layer.md](data-layer.md)), motion property rules (`docs/motion-guidelines.md`). This file owns the costs no reference names. Pagination/virtualization *presence* on repeating surfaces is the builder's own §2B/§4 checklist; this file owns whether the chosen mechanism survives the real cardinality.

## The network — requests per interaction

- **Waterfalls.** A query gated on another query's result (`enabled: !!a.data`) when it doesn't consume that result — or consumes only a datum already available without it (an id already in the URL, or in the global filter store) — serializes two round-trips into one spinner. `enabled` chains are for real data dependencies (an id you genuinely don't have yet); independence runs in parallel. The page shell paints on layout data, not on the slowest query — one query stalling the whole page behind a full-screen spinner is the same finding one level up.
- **Refetch storms from key identity.** A query key holding an inline object or array literal gets a new identity every render, and every render becomes a refetch. Keys go through the feature's key factory with stable primitives (that shape is [data-layer.md](data-layer.md)'s rule; the storm is what breaking it costs).
- **Freshness overrides.** The client default already keeps queries fresh for a set window — read `src/lib/queryClient.ts` for the current value rather than trusting this sentence. A local `staleTime: 0`, `refetchOnWindowFocus: true`, or `refetchInterval` is a claim that this data needs to be fresher than everything else in the app; without a stated freshness requirement it's a cost with no buyer. Never flag a *missing* `staleTime` — the default covers it.
- **Fetching a list to show a number.** A count, a badge, an "N need attention" chip fetched by pulling the rows and measuring `length` moves the table across the wire to throw it away. Counts come from an endpoint that counts.
- **Client-side pagination of a server-sized set.** Fetching all rows and slicing in JS caps the answer at whatever the API's page ceiling is and pays the whole transfer on first paint. Paginate where the rows live.

## Renders — renders per input

- **Hot derivations in the render body.** Sorting, grouping, or mapping over the rows array inline in JSX re-runs per render. The bar is cost × frequency: a `.map` over one page of rows is fine; a group-and-sum over thousands of rows in a component that re-renders per keystroke is the finding. `useMemo` the derivation on the data it reads (columns already have this rule in CLAUDE.md).
- **Keystroke-frequency state placed page-wide.** Search input state on the page component re-renders the page — table, charts, toolbar — per keystroke. Keep the keystroke local (or debounced into the URL state); the page re-renders on the *committed* value.
- **Unstable props into a memoized child.** An inline object/array/handler prop re-created per render defeats a child's `memo`. Two verifications before this posts: the child actually is memoized (read it), and the parent actually re-renders at input frequency. An unstable prop into an unmemoized child changes nothing and is not a finding.
- **Store reads wider than the need.** Whole-store destructuring re-renders on every unrelated change — [state.md](state.md) names the selector rule; what it costs is a page that re-renders on someone else's filter.

## Volume — the largest real account

- **Every repeating surface is priced at its table's real size**, not the mock's. Server pagination is the default answer. For a surface that legitimately holds the whole set client-side, `DataTable` has opt-in row virtualization (`virtualizeRows`) — a list that can exceed a few hundred rendered rows either paginates, virtualizes, or states why not.
- **Charts get aggregated series, not raw rows.** Recharts redraws every point per render; a per-day series over years, or a per-item series over a whole catalog, gets bucketed before it reaches the chart. (Embedded charts already run `isAnimationActive={false}` per §2B.)
- **Images at the size they render.** An image component's size prop sets the rendered box, not the transfer — the full-resolution `src` downloads either way. A repeating surface full of original-resolution images pays megabytes for thumbnails; the remedy is at the source (a resized/thumbnail URL where the API offers one) plus lazy loading and explicit dimensions, not the size prop.

## Weight — kilobytes per chunk

- **Measured, never guessed.** `npm run build` prints every chunk with its size — and a weight claim is a **delta**: build the base ref and the head, and quote both numbers for the chunk that grew (a single build's absolute sizes mostly restate weight the change didn't add). No build output, no finding.
- **A heavy dependency loads where it's used, not where it's imported.** The house precedent: an animation library stays confined to the one lazy-loaded showpiece that needs it. A new dependency imported at module top of a shared or eagerly-loaded file ships to every visitor of every page; import it inside the lazy page that needs it, or dynamic-`import()` it at the interaction that needs it.
- **Barrel imports that drag a feature across chunks.** Importing one util through another feature's barrel can pull that feature's pages into your chunk. The build output shows it; the fix is importing the module directly or lifting the shared thing into `shared/`.

## Instruments — real users and real requests

Reading the source predicts the cost; two instruments confirm it against reality. Both are the perf-sweeper's tools, and a builder can reach for them too.

**{{YOUR_ANALYTICS}} — what real users pay, and where.** Queried however your analytics tool is queried in this project (read-only; if the project captures more than one surface, filter to the app's). Two queries matter here, in whatever query language your tool speaks:

- *Traffic weights* — which routes real users actually hit, so findings are weighted by exposure (a waterfall on the most-visited route outranks the same defect on an admin page):

  ```sql
  SELECT normalize_route(path) AS route,
         count() AS pageviews, count(DISTINCT user_id) AS users
  FROM pageview_events
  WHERE timestamp > now() - INTERVAL 14 DAY
  GROUP BY route ORDER BY pageviews DESC LIMIT 50
  ```

  Normalizing collapses id segments (`/orders/8412` → `/orders/:id`) so one route isn't scattered across a thousand rows.

- *Web vitals* — probe before trusting: count the web-vitals events over the same window. Capture usually depends on a client init option plus a project-side toggle, so it is off until someone turns it on; zero rows means NOT CAPTURED — report that plainly (whether to enable it is the requester's call). Non-zero rows → p75 of LCP and INP per route, grouped by the same normalized route.

  Analytics is inert on localhost and in DEV — this data is production-only. If no custom event carries a duration today, note it: when building a long-running flow (import, bulk apply, export), a `duration_ms` property on its existing `analytics.*` event is the cheapest operation-latency telemetry there is — it slots into the status/properties convention unchanged.

**Playwright — count the requests instead of inferring them.** Counting is honest at dev scale (a waterfall is a waterfall whether the table has 12 rows or 4,000); timing at dev scale is not — never report dev-mode milliseconds. Against the chrome-verify rig (dev server + login mechanics per `.claude/skills/chrome-verify/SKILL.md`; a stored auth state reuses a real session instead of logging in per run):

```js
const reqs = [];
page.on('request', (r) => reqs.push({ url: r.url(), method: r.method() }));
await page.goto('http://localhost:{{PORT}}/<route>?tenantId=<id>', { waitUntil: 'networkidle' });
const api = reqs.filter((r) => r.url.includes('/v1/'));   // isolate backend calls from bundler/HMR/assets
```

Requests per load, then per interaction (clear `reqs`, click, count again). Sequencing shows the waterfall: an API request that starts only after another finishes, when neither needs the other's response, is the finding — now proved, not inferred.

## Measurement discipline

Before writing any finding, establish the two facts that make it real:

1. **The cardinality** — what bounds the set (the page size, the account's catalog size, the query's limit). Read the code that bounds it or name the real-world scale. Bounded-small clears the code: nothing over a set capped at a dozen is worth a finding.
2. **The frequency** — per page load, per keystroke, per poll tick? A cost paid once at mount is a different finding from the same cost paid per input, and usually no finding at all.

The finding then states the arithmetic: "this fires N requests per page change", "this re-renders M rows per keystroke", "this adds K kB to the entry chunk". A finding that can't fill in its numbers isn't ready to post.
