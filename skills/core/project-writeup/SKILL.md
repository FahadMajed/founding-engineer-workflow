---
name: project-writeup
description: Write engaging technical write-ups for completed features/projects. Use when (1) user asks to document a feature or project, (2) user says "write-up" or "/project-writeup", (3) after completing a significant implementation. Creates blog-style engineering write-ups that capture the story, architecture, bugs, and lessons learned - NOT duplicate of design docs or implementation plans.
---

# Project Write-Up

Create technical write-ups for internal team, onboarding, and AI context. Goal: someone reads it and understands WHY we built it this way.

## What This Is (and Isn't)

**This is:** A narrative about what we built, why, what went wrong, and what we learned.

**This is NOT:** Design doc rehash, implementation plan copy, or reference documentation.

**Audience:** Assume reader knows the stack. Don't explain fundamentals. Focus on decisions, gotchas, and patterns.

## Story Spine (Narrative Framework)

Structure the write-up as a story:

```
1. What was the world like before? (the pain)
2. What was the routine problem?
3. What changed? What broke? What triggered the project?
4. What did we try? What failed?
5. What pivots or discoveries happened?
6. What worked? What's the new world?
```

## Process

### 1. Gather Context (CRITICAL)

Read (if they exist):

- Design doc, implementation plan
- Git history for the feature branch
- Ask user: bugs encountered, surprises, decisions made

### 2. Identify the Story

Ask yourself, or if not certain, the user:

- What was painful before this feature?
- What was the "aha moment" in the design?
- What broke unexpectedly?
- What would you do differently?
- What pattern here applies elsewhere?

### 3. Write the Draft

Follow [references/writeup-template.md](references/writeup-template.md).

### 4. Review Checklist

- [ ] Follows Story Spine arc?
- [ ] At least one "I didn't know that" moment?
- [ ] Bugs/gotchas with actual fixes?
- [ ] ASCII diagram for complex flows?
- [ ] No duplication with design doc?

## Output

Write to: `docs/write_ups/[FEATURE_NAME].md`

Header: `# [Feature Name] - [Author]`

## References

- [Template & Section Guide](references/writeup-template.md)
- [Good vs Bad Examples + Style Guide](references/style-guide.md)
