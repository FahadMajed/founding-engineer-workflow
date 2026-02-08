---
name: analyze-design
description: Find gaps in design docs. Use when reviewing requirements, specs, or PRDs before implementation. Identifies missing edge cases, unclear business rules, and scenarios the design should address but doesn't.
---

# Analyze Design

Input: Design doc path
Output: Prioritized list of gaps, missing scenarios, edge cases

## Process

1. Read the design doc completely
2. Understand what system is being designed and its business context
3. Identify what's missing or unclear:
   - Edge cases not addressed
   - Error scenarios without handling
   - Business rules that are ambiguous
   - Assumptions needing validation
   - User flows with gaps

## Output Format

Group findings by priority:

### Critical (blocks user or causes data issues)

- [Gap]: [Why it matters]

### High (bad UX or business logic holes)

- [Gap]: [Why it matters]

### Medium (should address before shipping)

- [Gap]: [Why it matters]

### Low (nice to clarify)

- [Gap]: [Why it matters]

## What to Look For

**Business Logic Gaps**

- What happens when X fails?
- What if user does Y before Z?
- How does this interact with existing feature A?
- What are the boundaries/limits?

**Data & State**

- Invalid or missing input handling
- Partial failures mid-process
- State transitions that aren't covered

**User Experience**

- Confusing flows
- Confusing namings
- Edge states
- Wrong/unnecessary feature
- Good feature, wrong approach

## Not In Scope

- Implementation suggestions
- Code structure opinions
- Technical feasibility
- Rewriting the design

## Example Gap

Bad: "Missing error handling"
Good: "No defined behavior when payment succeeds but order creation fails. User could be charged without receiving order confirmation."
