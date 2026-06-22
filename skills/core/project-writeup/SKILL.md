---
name: project-writeup
description: Write technical write-ups for completed features/projects. Use when (1) user asks to document a feature or project, (2) user says "write-up" or "/project-writeup", (3) after completing a significant implementation. Produces factual engineering write-ups that record what was built, how it works, what broke, and what was learned - NOT a duplicate of design docs or implementation plans.
---

# Project Write-Up

Record what we built and why so a teammate or future-AI can reconstruct the decisions without reading the entire PR history.

## What This Is (and Isn't)

**This is:** A factual record of the problem, the build, the bugs, and the lessons.

**This is NOT:** Design doc rehash, implementation plan copy, reference documentation, or a story.

**Audience:** Assume the reader knows the stack (NestJS, TypeORM, Postgres, etc). Skip fundamentals. Focus on decisions, gotchas, and patterns.

## No Drama

The write-up is a record, not a story. Cut anything that exists to build tension or color.

**Cut:**
- Dramatic framing — "the pain", "vivid imagery", "stakes", "the hunt", "the pivot", "the aha moment", "what broke unexpectedly".
- Self-congratulation or self-deprecation — "we shipped it", "it mostly worked", "good enough", "ship it".
- Emotional adjectives — painful, brutal, nightmare, beautiful, elegant, clean.
- Banned words: comprehensive, robust, streamlined, enhanced, optimized, leveraged, addressed, validated, facilitated, solution, ensure, utilize.
- Banned phrases: "In this document...", "It should be noted...", "This comprehensive...".
- Changelog-style commentary — "we discussed X", "this used to do Y", "originally we tried Z then pivoted".

**Keep:**
- Concrete numbers (time, error rates, row counts).
- Symptoms, root causes, fixes — stated plainly.
- Decisions and their reasons.
- Code/SQL/path references where they help a reader find the thing.

If a sentence reads like a blog post hook, rewrite it as a fact.

## Process

### 1. Gather Context

Read (if they exist):
- Design doc, implementation plan
- Git history for the feature branch
- Related task / milestone
- Ask user: bugs encountered, decisions made

### 2. Identify the Facts

Answer (ask user if unclear):
- What was the problem? (state it; do not dramatize)
- What did we build?
- What decisions were non-obvious, and why?
- What broke, and what was the root cause?
- What pattern here applies elsewhere?

### 3. Write the Draft

Follow [references/writeup-template.md](references/writeup-template.md).

### 4. Review Checklist

- [ ] Every sentence is a fact, not a vibe?
- [ ] No banned words / banned phrases?
- [ ] No narrative framing (pain, hunt, pivot, aha)?
- [ ] Bugs include symptom, root cause, fix — no embellishment?
- [ ] Lessons are specific and transferable, not generic advice?
- [ ] No duplication with design doc?

## Output

Write to: `docs/write_ups/[FEATURE_NAME_ALL_CAPS].md`

Header: `# [Feature Name] - [Author]`

## References

- [Template & Section Guide](references/writeup-template.md)
- [Good vs Bad Examples + Style Guide](references/good-vs-bad-examples.md)
