# Founding Engineer Workflow

A feature development workflow for people who build, who think about problems before solutions, about user needs before technologies, about shipping fast while maintaining quality.

## Who This Is For

**Founding engineers, solo builders, or teams where one person owns a feature from user problem to production.**

This workflow assumes:

- You understand the user, you design, you build, you test, you ship
- No designer, no QA, no product manager — just you (and AI as your assistant)
- You want velocity AND quality, not one at the expense of the other

**Not for:** Junior devs learning the basics, or orgs with strict role separation.

## The Philosophy

This isn't just about process — it's about a better way to build.

**Advantages of single-owner development:**

1. **Velocity** — No handoffs, no tickets, no "waiting on design," no alignment meetings
2. **One mind** — No translation loss. The person who understood the user problem writes the code
3. **Ownership** — You built it, you own it. When it breaks, you know exactly where
4. **Business understanding** — You're not implementing a spec. You understand _why_
5. **Coherence** — Features built by one mind feel unified, not stitched together

**Trade-offs to acknowledge:**

- You trade specialist depth for generalist speed
- Same brain = same blind spots
- Doesn't scale past ~2 features in parallel

## The Workflow

```
[UX Discovery → Demo] → Design Doc → Analyze → [Plan Tests ∥ Build] → Write Tests → Review → Ship → Document
```

## Quick Start

### 1. Copy skills to your project

```bash
cp -r skills/core/* your-project/.claude/skills/
cp -r skills/frontend/* your-project/.claude/skills/  # if you have frontend
```

### 2. Customize for your stack

Edit the reference files:

- `skills/build-feature/references/coding-patterns.template.md`
- `skills/write-tests/references/test-patterns.template.md`

Replace `{{PLACEHOLDERS}}` with your patterns.

### 3. Create your CLAUDE.md

Copy `templates/CLAUDE.md.template` to your project root as `CLAUDE.md`. Fill in your stack, commands, and rules.

## Skills Reference

### Core Skills

| Skill                | Purpose                                                            |
| -------------------- | ------------------------------------------------------------------ |
| `/ux-discovery`      | Deep UX thinking before building. Outputs structured discovery doc |
| `/ux-discovery-lite` | Lightweight version for small features                             |
| `/analyze-design`    | Find gaps in design docs before implementation                     |
| `/plan-tests`        | Create test scenarios from design (before code exists)             |
| `/build-feature`     | Implement features following codebase patterns                     |
| `/write-tests`       | Convert scenarios to tests, detect gaps                            |
| `/project-writeup`   | Document the story, architecture, learnings                        |

### Frontend Skills

| Skill             | Purpose                               |
| ----------------- | ------------------------------------- |
| `/frontend-build` | Build polished UI from discovery docs |
| `/chrome-verify`  | Visual verification with screenshots  |

### Optional Skills (templates)

| Template              | Purpose                           |
| --------------------- | --------------------------------- |
| `local-testing`       | Test endpoints with auto-auth     |
| `debug-errors`        | Investigate production errors     |
| `task-management`     | Integrate with ClickUp/Linear/etc |
| `resolve-pr-comments` | Address code review feedback      |

## File Structure

```
your-project/
├── .claude/
│   └── skills/
│       ├── ux-discovery/
│       ├── analyze-design/
│       ├── plan-tests/
│       ├── build-feature/
│       │   └── references/coding-patterns.md  # Your patterns
│       ├── write-tests/
│       │   └── references/test-patterns.md    # Your patterns
│       └── project-writeup/
├── docs/
│   ├── discovery/           # UX discovery outputs
│   ├── design_docs/         # Design documents
│   └── for_ai/
│       └── test_scenarios/  # Test scenario files
├── scripts/
│   ├── start-worktrees.sh
│   ├── merge-worktrees.sh
│   └── end-worktrees.sh
└── CLAUDE.md                # Your project context
```

## Related

- [LIFECYCLE.md](LIFECYCLE.md) — Full workflow documentation
- [PHILOSOPHY.md](PHILOSOPHY.md) — Engineering principles

## License

MIT
