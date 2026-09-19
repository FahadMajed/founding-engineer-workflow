# DISCOVERY.md — the load-bearing document

Written last, composed from the artifacts. Each section carries an **un-fakeable field** — something that cannot be filled without the underlying thinking. Scannable; conceptual UI descriptions; no ASCII mockups.

**Altitude rule — this holds for provenance too.** Evidence is cited at the system level, never at the implementation level: no endpoint paths, table or column names, enum values, token internals, or code identifiers anywhere in a discovery doc — including inside tier stamps, edge cases, and design decisions, where they leak in dressed as rigor. Verification detail that engineering needs lives in the design doc; the discovery doc names the source and date only.
- BAD: "the pool shows one record at −2 (prod `products.total_available_quantity`, 2026-08-25); account health reads it via `product_inventory_planning`; sign-in is `POST /api/v2/users/login {username, password}`."
- GOOD: "the pool shows one record at −2 (production database read, 2026-08-25); account health computes from the same number; sign-in was verified live to accept a plain username/password."

The document opens with a four-line **Consumers block**, so each downstream reader lands on its sections instead of skimming from the top:

```
Consumers: frontend-build → §§8–10, 14 · design-schema / design-api → §§10–11 · outcome review → §§12–13, 16 · everyone → §§1, 4, 7
```

## Sections

1. **Release note** — 4–6 sentences addressed to the actual user (operator / advisor / customer / viewer) in plain language, describing their work once this exists. If it can't be written so that user would care, that's a finding: revisit the verdict, don't polish the prose.
2. **Problem / Opportunity** — the statement (passes the binary test in `framing.md`) plus the incidents it rests on, each with its evidence tier and provenance (source, date, scope).
3. **Evidence & confidence** — table of load-bearing claims → tier → downstream consequence: VALIDATED (T1/T2 covering the affected population — design may build hard dependencies on it) / SUPPORTED (interrogated T3 — build, but instrument it) / ASSUMED (T4/T5 — named test or recorded bet).
4. **Verdict & appetite** — build / shrink / probe first / solve another way / not now, with the reason. Include the **discovery delta**: what changed between the opening ask and this design, and which evidence drove each change. If nothing changed, say so plainly and name the evidence the original ask now rests on — never dress validation as discovery.
5. **Target user & moment** — persona + the exact moment it bites or pays off. **Role disposal line for every persona**: designed-for / out of scope because […] / degraded-and-accepted / N/A. Content rules make the line un-fakeable: an "out of scope because" states what that persona sees or misses when they encounter the surface (or why they never encounter it); "degraded-and-accepted" names the degradation concretely; "N/A" is admissible only for personas who cannot reach the surface (permission-gated), stated as such.
6. **Job & forces** — the struggling moment; push (evidence of the struggle), pull (what this promises), anxiety (what the user fears about switching), habit (the incumbent workaround — spreadsheet, a chat thread, the portal, memory). If habit + anxiety plausibly outweigh push + pull, adoption is the top risk — say so. Format: When [circumstance], I want [job], so I can [outcome].
7. **Solution concept** — the direction, its key insight, **what this design deliberately does NOT do, for whom, and why that's acceptable**, and the strongest rejected alternative steelmanned in its author's own words (from the ideation artifacts, not a weakened restatement).
8. **User flows** — entry → happy path → alternates → recovery. Edge cases domain-first (stale syncs, shared/alias accounts, partial channel data, peak surge, thin-volume accounts); generic empty/error/loading last.
9. **Information architecture** — components with attention level (Primary / Secondary / Tertiary), each passing the decision test (who looks, what decision, what action follows), each screen's cognitive mode (MONITOR/SCAN/DECIDE) and exit action. Include a **cross-cutting capabilities disposition** — for this feature, adopt or N/A-with-reason each: global filters · search · over-time + comparison (only where the data has a real time axis) · pagination · export · breadcrumbs + cross-surface links · empty/loading/error · analytics · i18n. The build inherits this list so the obvious never gets missed; the judgement is made here, in the design.
10. **Key interactions** — inputs, feedback, defaults, confirmations; the recommendation five-pack wherever the system suggests; mobile behavior (what's essential at 375px).
11. **Data requirements** (consumed by the backend API design) — per Primary/Secondary component: fields shown, source channel/sync, acceptable staleness, and null/"not supported" semantics. Conceptual — no schemas.
12. **Design decisions** — each as: "[Decision] — over [rejected alternative], because [reason]; cost accepted: [what we give up]." A decision without a named alternative is a description. Key bets add a falsification line: "we're wrong if we observe […]" — the falsifying observation must be one of the watch signals named in §13 or §16, with a timeframe; a falsification line pointing at a signal nobody is watching re-classifies the claim as ASSUMED (needs a test). This section also carries the **principle-disposition table** from the design phase: each product principle → adopted / exception argued.
13. **Success metrics** — a number + a baseline (or a baseline-capture plan) + the source of truth (which event/query) + when to look. A metric without a baseline is a slogan. Compliance rates ("100% of issues have a resolution logged") may appear only as guardrails; success metrics are outcomes the user or business experiences.
14. **Content notes** — labels, empty states, messages: bilingual-first (does the concept translate, not just the string). Tone per the project's language register rules.
15. **Open questions ledger** — every question raised in any artifact, marked: answered (with the answer) / deferred (with owner) / assumed (with the risk if wrong). A Primary-tier UI element may not depend on an unanswered question.
16. **After shipping** — 2–5 things to watch in usage or ask the operators next cycle; what evidence would confirm or kill this bet; and the **first check date** (≥ 3 weeks post-ship — earlier measures the novelty spike). At ship time the bet is registered as a row in `docs/discovery/outcomes-register.md` (metrics from §13, falsification lines from §12, that check date) — a watch item nobody is scheduled to watch is an untested assumption wearing a section number.

Design rationale lives in section 12, not inlined into component descriptions — the UI builder should read structure, not argumentation.

## Final self-check

Tick each box visibly **with a pointer to the document line that satisfies it** — these are the document-composition fields no earlier gate produced:

- [ ] Consumers block present at the top
- [ ] Discovery delta stated in §4 (or "nothing changed" said plainly with the evidence the ask now rests on)
- [ ] Every §13 metric has number + baseline (or capture plan) + source of truth + when to look
- [ ] Every falsification line points at a §13/§16 watched signal with a timeframe, and §16 names the first check date
- [ ] Role disposal passes the content rules in §5
- [ ] New evidence banked to the ledger; verdict appended to `docs/proposals/DECISIONS.md`
- [ ] Corrections closing line: either "Encoded: {reference file} — BAD/GOOD pair added" or "No generalizing corrections this session"

## Reversal protocol

When direction changes at or after a checkpoint: append a decision record to `03-synthesis.md` (what changed, who decided, why the prior reasoning failed), then re-run the critique gate against the **current** design before finalizing DISCOVERY.md. A critique of a superseded design is worth zero, and the final document must not contain load-bearing decisions that exist in no critiqued artifact.
