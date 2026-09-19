---
name: visual-review
description: Build verified, interactive visual explainers for code under review — artifacts where the reviewer operates the behavior instead of reading about it, plus Mermaid sequence diagrams derived from the codebase. Use when (1) the user asks to visualize or explain a method, flow, module, or PR ("explain X in an artifact", "visualize this", "diagram this flow", "how does X route/decide"), (2) a review needs behavior made visible — routing decisions, state transitions, before/after semantics, (3) the user asks for a sequence diagram of how services call each other.
---

# Visual review

The failure mode this skill exists to prevent: asking "how do I present this information?" and producing a document with styled boxes. The right question is "what does this code *do* — and can I make the reviewer do it?"

**Not this skill:** rendering a **design doc** at its gate — that's `/visual-gate`. The split is what's rendered, not when: this skill renders behavior and runs on both sides of the code (sdlc step 3 uses it to diagram the Existing Solution before any exists). The two compose — a design whose core is a decision engine gets a visual-gate page for the whole doc, linking a visual-review artifact from its Internal design block. Build the interactive one once.

## The approach

**1. Name the subject's essential verb, and make the centerpiece perform it.**
Every piece of code worth visualizing has one verb at its core — it routes, pools, retries, reconciles, escalates, expires. The centerpiece of the page is that verb happening live, driven by the reviewer. A router: send a request through and watch it choose. An aggregation: watch quantities pool and dilute as membership changes. A retry policy: let time run and watch attempts space out. A reconciliation: watch two sides converge, or fail to.
The test that you derived rather than defaulted: if the same centerpiece would work for a different verb, it isn't the subject's — start over.

**2. Write the reviewer's doubts before writing any layout.**
The reader is making a decision — merge, trust, deploy. List the doubts standing between them and it: *does the sibling survive? did the untouched integration's behavior change? what happens when the same input arrives twice?* Each doubt becomes exactly one element — a scenario, a toggle, a panel — and each element exists to retire exactly one doubt. Anything that retires none is decoration; a doubt with no element is the gap the review will fall into.
This is also how scenarios are chosen: not coverage, but the worry-cases — the edge that motivated the change, the case that must not change, the duplicate.

**3. Turn assertions into operations, and operations into evidence.**
A sentence claiming behavior is the weakest form; the reviewer running the behavior is stronger; the run being *checkable* is strongest. Concretely: scenarios are real production cases (a record id the reviewer recognizes buys trust for the whole page); "the old code would have…" is a toggle showing the behavioral diff, not a sentence; and nothing ships unverified (contract below).

**Failure test before publishing:** if the page could be flattened into a Word doc without losing anything, it's a document wearing a UI. Return to move 1.

## Recurring embodiments

The moves above tend to produce: a live state panel (the touched rows before → after, untouched neighbors visibly untouched), a downstream-effects log (what fires, who consumes it), exhaustive tables below the fold for what is enumerable rather than narrative, and — when the story is call choreography across services — a Mermaid sequence diagram whose participants and guards come from the code, validated with the Mermaid tool when connected. Standalone diagrams go out as `.mmd` via SendUserFile `display: render`; inside an artifact, embed pre-rendered SVG.

Palette comes from your product's design tokens (the CSS custom properties in your frontend repo), both themes derived from them. Semantic color is structure — one hue per route, one family for entity states, apart from the accent.

## Harness facts

- Artifact CSP blocks all external requests: inline everything, pre-render Mermaid, no CDN fonts or scripts.
- Viewers arrive via `prefers-color-scheme` *and* a toggle stamping `data-theme` on the root — define tokens on `:root`, redefine under the media query and both `:root[data-theme=…]` selectors so the toggle wins in both directions.
- Republishing the same file path keeps the artifact URL across iterations.

## Verification contract — hard invariant

The Browser pane may be unavailable; verify headless with Playwright from any repo that has it. Collect console + page errors, exercise every interactive element, screenshot both themes (`emulateMedia`), assert zero body horizontal overflow — and **read the screenshots**: label collisions and clipped text exist only visually. Publish only after this passes.
