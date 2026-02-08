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

**Default to library scripts.** Only use MCP when you need a real-time see-think-act loop.

## Project Details

Customize for your project:

```
- Dev server: `{{YOUR_DEV_SERVER}}` (e.g., localhost:3000)
- Check: `lsof -i :{{PORT}} -sTCP:LISTEN`
- Login: {{YOUR_LOGIN_FLOW}}
- Playwright installed as dev dep with Chromium
```

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
