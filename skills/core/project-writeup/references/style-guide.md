# Good vs Bad Examples

## Style Guide

**Voice:** Like explaining to a smart coworker over coffee. Casual but technical.

### Banned Phrases

- "In this document, we will explore..."
- "It should be noted that..."
- "This comprehensive solution..."
- Passive voice overuse
- Wall-of-text paragraphs

## Opening Paragraphs

### Bad

> This document describes the implementation of the data synchronization feature. The feature was developed to address requirements outlined in the design document. It includes webhook handling, database updates, and API integration.

_Why it's bad:_ Reads like a spec. No hook, no tension, no reason to keep reading.

### Good

> Every morning, Sarah would spend 45 minutes comparing spreadsheets. Order IDs that existed in one system but not another. Inventory counts that never matched. By the time she finished reconciling, three new orders had already fallen through the cracks.

_Why it's good:_ Specific pain, vivid imagery, clear stakes.

---

## Explaining Architecture

### Bad

> The system uses a microservices architecture with event-driven communication. The OrderService publishes events to the queue, which are consumed by the SyncService. The SyncService uses the Repository pattern for data access and implements retry logic with exponential backoff.

_Why it's bad:_ Lists technologies without explaining why they matter or how they connect.

### Good

> Orders come in bursts. Black Friday, flash sales, viral moments. Our original sync would choke - one slow API call would block everything behind it.
>
> So we decoupled. Orders drop into a queue. Workers pull them one at a time. If an order fails, it goes back in the queue with a delay. The system self-heals.

_Why it's good:_ Explains the problem that drove the architecture, not just what the architecture is.

---

## Describing Bugs

### Bad

> We encountered an issue with transaction handling. The fix involved modifying the database context to use isolated transactions.

_Why it's bad:_ No context, no symptoms, no learning. Could apply to anything.

### Good

> **The Bug:** After deploying on Tuesday, inventory updates started failing silently. Operations went through, but counts stayed frozen.
>
> **The Hunt:** Logs showed successful updates, but the database showed unchanged values. We added more logging. Still "success." Then I noticed the timestamp pattern - failures clustered around high-traffic periods.
>
> **Root Cause:** Our transaction context was bleeding. When Operation A's transaction started, Operation B's update would accidentally join it. When A rolled back, B's update vanished too - even though B succeeded.
>
> **The Fix:** Separate contexts for each operation. Each domain gets its own transaction boundary.
>
> **Lesson:** When debugging "impossible" states, check if operations that should be independent are accidentally coupled through shared context.

_Why it's good:_ Tells a story with symptoms, investigation, revelation, and takeaway.

---

## Lessons Learned

### Bad

> Key learnings:
>
> - Use proper error handling
> - Write tests before deployment
> - Consider edge cases
> - Document your code

_Why it's bad:_ Generic advice that applies to everything. No specificity.

### Good

> **Lesson: Idempotency isn't optional when external events are involved**
>
> External systems will send the same event multiple times. Sometimes 3 times in a row. Sometimes 6 hours apart. Our first version assumed events were unique - we'd process an item, then process it again, creating duplicates.
>
> The fix was simple (check if item exists before creating), but the lesson was broader: any external trigger should be assumed to fire multiple times. We now treat event handlers like PUT requests - calling them twice should have the same effect as calling them once.

_Why it's good:_ Specific scenario, specific failure, transferable principle.

---

## Overall Tone

### Bad

> The implementation successfully addressed all requirements as specified in the PRD. The architecture follows industry best practices and provides a scalable foundation for future enhancements. Comprehensive testing was performed to validate the solution.

_Why it's bad:_ Corporate speak. Says nothing while sounding like something.

### Good

> We shipped it. It mostly worked. The sync took three tries to get right, and we discovered a timezone bug two weeks later that was quietly miscounting items. But users stopped losing data, and the 2-hour daily reconciliation dropped to a 5-minute spot check. Good enough. Ship it.

_Why it's good:_ Honest, specific, human.
