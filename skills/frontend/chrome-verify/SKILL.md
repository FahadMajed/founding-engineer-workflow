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

## Running in a cloud session (no local stack)

A cloud session starts with the frontend repo cloned and nothing else — no
`node_modules`, no database, no backend. The section above assumes a developer
laptop where those already exist. **Do not fall back to mocking the API and
screenshotting components in isolation** — that is not evidence of the page. Build
the stack; it takes about fifteen minutes, and every step below is a real gotcha.

The single thing that will waste your afternoon: **the container's environment is
pre-populated with production values, and both the backend and Vite prefer it over
your `.env` files.** `dotenv.config()` does not override an existing `process.env`,
and Vite's `loadEnv` lets `process.env` win over `.env.*`. So `DB_HOST` silently
points at the production database — the backend then hangs for exactly
`connectionTimeoutMillis` and reports "Connection terminated due to connection
timeout" — and the API base URL points at the production API. Override both on the
command line. Never point a local run at either.

```bash
# 1. Frontend deps
npm ci

# 2. Postgres — installed but not running
pg_ctlcluster 16 main start
su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '{{DEV_DB_PASSWORD}}';\" -c 'CREATE DATABASE {{DEV_DB_NAME}};'"

# 3. Backend (grant the repo to the session first, then clone; generous timeout)
git clone --depth 1 https://github.com/{{YOUR_ORG}}/{{YOUR_BACKEND_REPO}} /workspace/backend
cd /workspace/backend && npm ci

# 4. Real data — a dump ships in the backend repo
PGPASSWORD={{DEV_DB_PASSWORD}} psql -h 127.0.0.1 -U postgres -d {{DEV_DB_NAME}} -f {{PATH_TO_DB_DUMP}}
#    (extension errors for a hosted-Postgres flavour you don't run locally are harmless)

# 5. Migrations — MUST be one transaction per migration. The default (`-t all`)
#    dies on "unsafe use of new value ... of enum type": one migration adds an
#    enum value and a later one uses it, which Postgres forbids in a single tx.
NODE_ENV=dev npx ts-node ./node_modules/typeorm/cli migration:run -d ./src/app/data-source.ts -t each

# 6. The dev env file (DB_*, JWT + refresh secrets, API key, OAuth secret, cache off)
#    then start it — overriding the injected production DB_HOST:
DB_HOST=127.0.0.1 DB_PORT=5432 DB_USERNAME=postgres DB_PASSWORD={{DEV_DB_PASSWORD}} \
  DB_NAME={{DEV_DB_NAME}} NODE_ENV=dev npx nest start
```

`PORT` is also pre-set in the container, and the bootstrap reads
`process.env.PORT ?? {{DEFAULT_API_PORT}}` — so check where it actually landed
instead of assuming.

Sign-in needs a password you know. The dump's hashes are real, so mint one:

```bash
node -e "require('bcryptjs').hash('LocalDev123!',10).then(console.log)"   # in the backend repo
PGPASSWORD={{DEV_DB_PASSWORD}} psql -h 127.0.0.1 -U postgres -d {{DEV_DB_NAME}} \
  -c "UPDATE users SET \"passwordHash\"='<hash>' WHERE id=<an admin user's id>;"
```

Then the frontend, pointed at the local backend with the third-party keys blanked:

```bash
VITE_API_BASE_URL=http://localhost:{{API_PORT}}/v1 VITE_ENV=dev VITE_ERROR_REPORTING_DSN= VITE_PAYMENTS_KEY= \
  npx vite --mode development --port {{PORT}} --strictPort
```

Driving it from Playwright:

- **There is no login-by-URL.** The login page reads `?email=` to prefill and
  nothing else — fill both fields and click submit.
- **Pick the tenant with a URL param** that the global-filters URL sync reads
  straight into the store. Driving the scope picker is slower and flakier.
- **`storageState` is per origin, port included.** A before/after comparison across
  two dev servers needs a separate sign-in per port.
- **External assets are blocked** — logos served from third-party CDNs render as
  their empty fallback. Say so in the manifest rather than re-shooting.
- For a **before/after**, worktree the PR's parent commit, not the default branch:
  the local default-branch ref can be stale, and `HEAD~1` is exactly the state
  without your change. Symlink `node_modules` from the main checkout instead of
  installing twice.

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
