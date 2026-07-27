---
name: chrome-verify
description: Verify frontend work visually in Chrome. Use after implementing or modifying UI to take headless screenshots at multiple viewports, read them to analyze visual correctness, and catch issues before the user has to.
---

# Chrome Verification

Two tools — pick based on need:

| Need                              | Tool                      | Context cost           |
| --------------------------------- | ------------------------- | ---------------------- |
| Verify pages look right (default) | Playwright library script | Low — just screenshots |
| Interactive debugging / exploring | Playwright MCP tools      | High — use sparingly   |

**Default to library scripts.** Only use MCP when you need a real-time see-think-act loop (e.g. debugging why a dropdown doesn't open, testing a multi-step flow where you need to react to results).

CRITICAL: if you're using the npm package, run inline Playwright via Bash — write the script to a scratch dir and run it with `node`.

## Project Details

Customize for your project:

```
- Dev server: `{{YOUR_DEV_SERVER}}` (e.g., localhost:3000)
- Check: `lsof -i :{{PORT}} -sTCP:LISTEN`
- Login: {{YOUR_LOGIN_FLOW}} (auto-submit via URL params keeps scripts simple)
- Playwright installed as a dev dep with Chromium. `import { chromium } from 'playwright'`
```

**Ensure data is seeded.** Based on the API/data layer you're verifying, check the dev DB. If there isn't enough data to exercise the cases you need (empty, few, many, edge), it's your responsibility to seed it per scenario before screenshotting.

## Scope the screenshot to the change

A full-page shot at desktop width turns a component defect into a few dozen pixels — misaligned subrows, a stacked currency symbol, and drifted baselines are invisible at that zoom, and the shot gets read as "all good". For every changed component take **both**:

1. **An element screenshot** — `await page.locator('...').screenshot(...)` (or a `clip` region). This renders the component at natural size, filling the frame. Use `deviceScaleFactor: 2` in the browser context for a crisp read on dense components (tables, charts).
2. **One full-page shot** for context and regressions in surrounding UI.

Reading only full pages is how defects survive verification.

## Read as a critic, not for confirmation

Before opening a screenshot, write the defect list you are checking it for — specific to the change: "subrow columns align with the header grid", "currency symbol renders inline before the amount", "the two controls share height and baseline", "long name truncates with tooltip". Then answer each item against the pixels. "Looks good" without named checks is confirmation, not verification — the screenshot only falsifies claims you actually made.

## Where the captures land — the output contract

Scripts go to the scratchpad; **captures go to a stable path in the repo** so a later agent, a later session, or the requester can review them beside the diff without re-shooting:

```
.claude/visual/{feature}/round-{n}/
├── manifest.md
├── {screen}-{state}.png          # full-page context shot
└── {screen}-{component}.png      # element-scoped shot (the one that finds defects)
```

Gitignored — these never enter `main`'s history. `round-1` is the first build; every refinement round gets the next number, so a regression a later round introduced is diffable against the earlier shot. Naming matches `/pr-evidence` (`{screen}-{state}.png`) so PR-time evidence is a **copy of these files, not a re-shoot**.

`manifest.md` is the defect list you already wrote before looking (above), committed to a file instead of held in your head:

```markdown
# {feature} — round {n}
| Shot | Component | Viewport / dir | Read against |
|---|---|---|---|
| orders-populated.png | OrdersTable | 1440 LTR | subrow cols align to header grid; amounts tabular-nums right-aligned; money value renders inline |
| orders-table.png | OrdersTable | 1440 LTR, element @2x | control-bar heights share baseline; no dead space below card |
| orders-empty.png | OrdersTable | 375 RTL | empty copy + action present; logical properties mirror |
```

Two rules that make the manifest worth writing:

- **Every component you changed gets a row.** A changed component with no shot is the thing the next reviewer catches — write the row and shoot it, or state in the row why it has no visual surface.
- **The "read against" column is written before you open the image.** Filled in afterward it is a description of what you saw, which is the confirmation bias this whole protocol exists to break.

## What to Verify

Focus on what's relevant to your change — not everything every time.

**Always check:**

- Does it look correct at desktop and mobile? Nothing overflowing or cut off?
- Does the change match the intent? No regressions in surrounding UI?

**If touching layout/styling:**

- Spacing rhythm consistent (not random padding values)
- Typography hierarchy clear
- Alignment — elements line up, tables/cards are even

**If touching RTL/i18n (if applicable):**

- Switch to RTL language and verify layout mirrors
- Logical properties working (no hardcoded left/right)
- Text reads naturally

**If touching data displays (tables, cards, charts):**

- Loading state (skeletons, spinners)
- Empty state (no data scenario)
- Long content — does text truncate with tooltip? Do numbers fit?

**If touching interactive elements:**

- Click/hover states work
- Disabled states look distinct
- Forms validate and show errors correctly

**Common gotchas:**

- Sidebar collapse behavior on smaller screens
- Sticky table headers/columns on scroll
- Currency/number formatting consistency
- Date formatting consistency
