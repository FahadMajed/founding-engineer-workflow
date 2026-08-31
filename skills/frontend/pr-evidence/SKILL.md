---
name: pr-evidence
description: Capture visual evidence for a PR with frontend work — a screenshot per relevant state (empty, loading, error, populated), a GIF of the key interaction end to end, before/after where behavior changes — from the branch's final state, pushed to the pr-evidence branch and embedded in the PR body. Use when (1) /ship-pr or a workflow skill calls for PR evidence, (2) user asks to attach screenshots/GIFs to a PR, (3) UI code changed after evidence was captured (re-capture). Capture doubles as the last QA pass: the drive is the only time the feature runs end to end.
---

# PR Evidence

The PR gets reviewed by observation, not by reading the diff. Capture what the change looks like and how it behaves — always from the **final state of the branch**.

Project mechanics (dev server + port, login-by-URL, credentials, seeding via the dev DB) are in `/chrome-verify` — follow it. Playwright library scripts from the scratchpad, not MCP. Capture files land in the scratchpad too, then get pushed (below).

## What to capture

**Per affected screen, a screenshot of each state that exists:**

- **empty** — no data; clear/seed via the dev DB per scenario
- **loading** — delay the request: `page.route(url, r => setTimeout(() => r.continue(), 60_000))`, screenshot mid-flight
- **error** — fulfill the route with a 500 and check the UI's error handling while you're at it
- **populated** — realistic seeded data (long names, non-Latin/RTL text, real-looking numbers — not "test 1")

Skip states the screen genuinely doesn't have, and say so in the evidence block.

**One GIF of the key interaction, end to end** — the flow the feature exists for (open dialog → fill → submit → success toast → table updates). Record Playwright video, convert:

```typescript
const context = await browser.newContext({ recordVideo: { dir: outDir, size: { width: 1280, height: 720 } } });
// drive the flow, then await context.close() to flush the video
```

```bash
ffmpeg -y -i flow.webm -vf "fps=8,scale=960:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" -loop 0 flow.gif
# no ffmpeg → brew install ffmpeg
```

**Before/after where behavior changes** — "before" is the PR's base branch, run from a worktree:

```bash
git worktree add ../fe-before {base-branch}
cd ../fe-before && npm install && npm run dev -- --port {{ALT_PORT}}
# capture the same screens/steps against :{{ALT_PORT}}, then:
git worktree remove ../fe-before --force
```

Name files by screen and state: `{screen}-empty.png`, `{screen}-error.png`, `{screen}-before.png` / `{screen}-after.png`, `{flow}.gif`.

## Capture is the last QA pass

Driving the GIF is the only time anyone operates the feature end to end as a user. `/chrome-verify` shoots states, the sweepers read stills, `bug-hunter` reads code — nobody clicks the flow. So treat the drive as QA, not as filming. The findings are free here and expensive after merge.

Read every screenshot (and GIF frames via a couple of extracted stills) before attaching. Wrong state, missing data, broken layout in the evidence = shipping the bug straight to the reviewer.

**Watch the run, not just the frame.** What a still can't show, and the drive hands you for free:

- console errors and failed requests — keep `page.on('console')` and `page.on('requestfailed')` printing for the whole run
- a mutation that lands but leaves the table stale until reload
- a toast that never fires, or fires twice
- a step that needed a retry, a reload, or an extra click nobody would guess
- layout shift and jank as data arrives
- keyboard: the dialog traps focus, Esc closes, Enter submits

Behavior, not pixels — `visual-sweeper` and `/chrome-verify` already reviewed the pixels, and re-litigating them at PR time is a second design review nobody asked for.

**Then split by scope, and say which:**

- **Defect in what this PR changed** → fix it, re-capture, then attach. Evidence is never where a known bug ships from.
- **Defect outside the diff** → report it in the output and leave the PR alone. QA at capture time is not a license to widen the PR.

## Push — the pr-evidence branch

Evidence never merges into main; it lives on an orphan branch, one folder per PR branch (slashes → dashes):

```bash
folder=$(git branch --show-current | tr '/' '-')
git fetch origin pr-evidence && git worktree add ../fe-evidence pr-evidence || {
  git worktree add --detach ../fe-evidence && git -C ../fe-evidence checkout --orphan pr-evidence && git -C ../fe-evidence rm -rf --quiet . || true; }
mkdir -p ../fe-evidence/$folder && cp {captures}/* ../fe-evidence/$folder/
git -C ../fe-evidence add -A && git -C ../fe-evidence commit -m "evidence: $folder" && git -C ../fe-evidence push -u origin pr-evidence
git worktree remove ../fe-evidence
```

## Embed in the PR body

**GitHub cannot inline-render an image from a private repo via a URL.** Its image proxy (camo) fetches `raw.githubusercontent.com` / `blob?raw=true` **unauthenticated** → 404, so a Markdown `![](…)` embed shows a broken icon. If your repo is private, `![](raw…)` never works (it would, on a public repo). Two working paths, in order:

**Default — clickable blob links (scriptable, reliable).** Reviewers with repo access click through to the image in GitHub's file viewer. Durable: the orphan `pr-evidence` branch never moves, so link to the branch (not a SHA) and re-captures serve automatically. Return this block (or `gh pr edit --body` it yourself), with `BASE = https://github.com/{{YOUR_ORG}}/{{YOUR_REPO}}/blob/pr-evidence/{folder}`:

```markdown
## Evidence
| State | Screenshot |
| --- | --- |
| Empty | [empty](BASE/{screen}-empty.png) |
| Loading | [loading](BASE/{screen}-loading.png) |
| Error | [error](BASE/{screen}-error.png) |
| Populated | [populated](BASE/{screen}-populated.png) |

**Key interaction:** [flow GIF](BASE/{flow}.gif)

**Before → after:** [before](BASE/{screen}-before.png) · [after](BASE/{screen}-after.png)

_Not captured: {state} — {screen has no such state / why}_
```

**For inline thumbnails — drag-drop upload (human, browser only).** The one thing GitHub renders inline for a private repo is an **uploaded attachment**: dragging an image into the PR description mints a signed `https://github.com/user-attachments/assets/…` URL that renders as a thumbnail. This is not scriptable (needs the web session, not a PAT). So also **surface the local capture paths** to the caller — a human can drag those files into the PR body to upgrade the links above to thumbnails.

## Re-capture rule

Evidence lies the moment the branch moves. Any commit touching UI code after capture → re-capture the affected shots, overwrite the **same filenames**, push the evidence branch again. The blob links (pinned to the `pr-evidence` branch, not a SHA) then serve the new images. Drag-dropped attachments are frozen copies — they must be re-dragged. Screens added or removed → update the PR body block too.

## Output

Evidence pushed, the markdown block (blob links), the **local capture paths** (so a human can drag them in for inline thumbnails), the list of states not captured with why, and the **QA verdict from the drive** — what broke, what you fixed and re-captured, what you found outside the diff and left. "Clean" is a verdict; silence isn't. `/ship-pr` reads that verdict, so it goes in the output every time.
