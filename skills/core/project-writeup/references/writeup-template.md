# Write-Up Template

State facts. No narrative framing. No dramatic adjectives. No "the pain / the hunt / the pivot" arc.

## Feature Write-Up Template

```markdown
# [Feature Name] - [Author]

_Date: [Month Year]_

## Problem

[2-3 paragraphs. State what was wrong with concrete numbers where possible.]

"Operators spent ~30 min/day reconciling orders across three external systems." Not "It was painful."

## What We Built

[One paragraph. Plain description, no marketing tone.]

## Approach

[How it works. Include alternatives considered only if the choice was non-obvious — and only state the reason, not the deliberation.]

### [Alternative considered, if any]

[Approach name. Why it was not used.]

## Architecture

[Plain language + ASCII diagram. Link to design doc for details.]

┌──────────┐    ┌───────┐    ┌─────────┐
│ Webhook  │───>│ Queue │───>│ Handler │
└──────────┘    └───────┘    └─────────┘
                                  │
                                  v
                            ┌─────────┐
                            │  Retry  │
                            └─────────┘

## Bugs & Gotchas

### [Bug Title]

**Symptom:** [What was observed. Concrete.]
**Root Cause:** [Why it happened.]
**Fix:** [What changed. File / function reference if useful.]
**Prevention:** [Test, monitor, pattern that prevents recurrence.]

## Lessons

### [Lesson Title]

[Specific, transferable insight. State the rule and the reason. No reflection on feelings.]

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

[What broke, for how long, who was affected. Numbers.]

## Detection

[How it was noticed - alert, customer report, internal check.]

## Timeline

- **[Time]**: [Event]
- **[Time]**: [Event]
- **[Time]**: Resolution

## Root Cause

[Technical reason, with code/config reference.]

## Fix

[What shipped.]

## Prevention

[Tests, monitors, patterns added.]

## Lessons

[Transferable insights. Specific.]
```

---

## Section Tips

### "Problem"

- Start with what was wrong, in numbers if available (time, error rate, ticket count).
- No user-pain monologue. State the condition; the reader infers the cost.
- Link to design doc for deeper context instead of restating it.

### "Approach"

- Describe the chosen design. State why for the non-obvious parts.
- Mention alternatives only if knowing they were rejected helps a future reader. Do not narrate the deliberation.

### "Bugs & Gotchas"

- Symptom, root cause, fix, prevention. Four lines is enough for most.
- Include error messages, edge cases, affected scope.
- Severity if relevant: "production downtime 14 min", "caught in staging".

### "Lessons"

- One rule per lesson. Specific enough that a reader can apply it.
- Include the reason behind the rule.
- No generic advice ("write tests", "handle errors"). If a lesson would apply to any project, drop it.
