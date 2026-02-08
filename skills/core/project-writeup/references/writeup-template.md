# Write-Up Template

## Feature Write-Up Template

```markdown
# [Feature Name] - [Author]

_Date: [Month Year]_

## The Problem

[2-3 paragraphs. Set up the pain with specifics.]

"Users spent hours daily reconciling data" not "It was inefficient."

## What We Built

[One paragraph. What would you say at standup?]

## How We Got There

[The journey, not step-by-step code. Include dead ends.]

### First Approach: [Name]

[What we tried, why it didn't work]

### The Pivot

[What changed our thinking]

## The Architecture

[Plain language + ASCII diagram. Link to design doc for details.]

┌──────────┐    ┌───────┐    ┌─────────┐
│  Input   │───>│ Queue │───>│ Handler │
└──────────┘    └───────┘    └─────────┘
                                  │
                                  v
                            ┌─────────┐
                            │  Retry  │
                            └─────────┘

## Bugs & Gotchas

### [Bug Title]

**Symptoms:** [What we observed]
**Hunt:** [How we debugged it]
**Root Cause:** [Why it happened]
**Fix:** [What we changed]
**Prevention:** [How to avoid in future]

## What I Learned

### [Lesson 1]: [Title]

[Specific insight with context. Make it transferable.]

## Related

- Design doc: [link]
- Implementation plan: [link]
```

---

## Incident Template

For standalone incident/bug write-ups (no feature context):

```markdown
# [Incident Title] - [Author]

_Date: [When it happened]_

## Impact

[What broke, for how long, who was affected]

## Detection

[How we noticed - alerts? customer report? accident?]

## Timeline

- **[Time]**: [Event]
- **[Time]**: [Event]
- **[Time]**: Resolution

## Investigation

[The debugging journey. What did logs show? What was misleading?]

## Root Cause

[The actual technical reason, with code context]

## Fix

[What we shipped]

## Prevention

[What we changed to prevent recurrence - tests, monitoring, patterns]

## Lessons

[Transferable insights]
```

---

## Section Tips

### "The Problem"

- Start with user pain, not technical debt
- Include numbers if you have them (time wasted, error rates, support tickets)
- Don't over-explain. If context is complex, link to design doc overview

### "How We Got There"

- This is where the story lives
- Dead ends are often more instructive than the solution
- Quote memorable decisions or debates

### "Bugs & Gotchas"

- Be specific: error messages, edge cases, timing
- The debugging journey matters, not just the fix
- Mark severity: "production downtime" vs "caught in staging"

### "What I Learned"

- Think: if I joined a new team building something similar, what would help?
- Think: what would help someone building something similar?
- Include "soft" lessons too: communication, scope creep, estimation
- Be honest about mistakes
