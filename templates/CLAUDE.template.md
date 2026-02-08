# CLAUDE.md

{{YOUR_STACK}} backend for {{YOUR_PRODUCT_DESCRIPTION}}.

## Quick Context

{{BRIEF_DESCRIPTION_OF_WHAT_YOUR_PRODUCT_DOES}}

## What We Handle

- **{{CAPABILITY_1}}** — {{DESCRIPTION}}
- **{{CAPABILITY_2}}** — {{DESCRIPTION}}
- **{{CAPABILITY_3}}** — {{DESCRIPTION}}

## Task Types

**Specific instructions** ("change X to Y", "add field Z to entity") → Just do it.

**Outcome-focused** ("implement feature X", "fix this bug") → Investigate first. Read existing code. Follow existing patterns. Ask if uncertain.

## Commands

```bash
# Run specific test file
{{YOUR_TEST_COMMAND}}

# Database access
{{YOUR_DB_COMMAND}}

# Build/lint
{{YOUR_BUILD_COMMAND}}
{{YOUR_LINT_COMMAND}}
```

## Leverage Linux

Before looping, making repeated calls, or heavy operations, think: can one command do this? Git, curl, find, xargs, jq — these handle bulk operations in one shot. Fewer calls = fewer tokens.

## Rules

1. **Never assume** - Read the code before changing it. Query the schema before writing queries.
2. **Never invent patterns** - Find how we already do it, then do it the same way.
3. **Never half-finish** - Complete the task or say what's left.
4. **No comment spam** - Only comment non-obvious business logic.
5. **No over-engineering** - Solve what's asked, nothing more.

## Writing Tone

Write like you're texting a coworker. Direct. Normal words.

**Bad:** "I've successfully implemented a comprehensive solution that addresses the validation requirements."

**Good:** "Added validation. Checks for empty fields and invalid emails."

**Banned words:** comprehensive, robust, streamlined, enhanced, optimized, leveraged, addressed, validated, facilitated, solution, ensure, utilize.

**Use instead:** complete, strong, simple, better, improved, used, fixed, checked, built, make sure, use.

## When Stuck

1. Check existing similar code first
2. Ask me - don't guess

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
