# Deriving the views from the domain

A design that only builds the views the ask names will miss the views the domain demands. The requester's proposal is one hypothesis about surfaces; the domain's own structure — its artifacts, its questions — generates the rest. This file is a derivation method, not a checklist: derive candidates from *this* feature's domain, then disposition each. Hardcoded lists go stale; the method doesn't.

## Method

**1. Inventory the domain's native artifacts.** Every real-world artifact the domain produces or consumes is a view candidate: a statement file, a schedule, a transaction row, a fee table, a price list, a claim form, a packing slip. Ask of each: *who reads this artifact today, outside our product, and for what decision?* If someone opens the raw export CSV to answer a question, that question needs a view — the artifact already proved the demand. (The transactions ledger was sitting inside the statement file all along; the cadence was sitting in the schedule.)

**2. Enumerate the questions each persona asks of the data.** Not features — questions: "how much of my catalog is losing?", "when does money arrive?", "does this number match my bank?", "which item caused it?". Each question has a *shape*, and the shape picks the view.

**3. Map question-shapes to view-shapes.** Recurring shapes (a working library — extend it from the feature's own context; a shape this list doesn't cover is a finding, not an excuse):

| Question shape | View shape |
| --- | --- |
| "What exactly happened, row by row?" | Ledger — the raw records, paginated, searchable |
| "Tell me this one item's story" | Instance narrative — receipt, detail drill |
| "Compare / act across the whole class" | Class table — sortable columns, bulk actions |
| "How much of my X is in state Y?" | Composition — banded distribution, money-weighted |
| "How is it moving over time?" | Trend — series against its own baseline |
| "When does it happen / when is the next one?" | Cadence — rhythm strip, schedule |
| "Does this match the source of truth?" | Reconciliation — stamp, delta, coverage |

**4. Disposition every candidate** — like personas: *build / defer / N-A-because*, recorded in the design. An undispositioned candidate is where "why is there no X view?" comes from a round later. The disposition is judgment (many candidates deserve N/A); the omission of the disposition is the defect.

## Boundaries

- Deriving is not building — the appetite conversation still decides what ships first. The design *sees* the full view surface; the requester slices it.
- Shapes compose with the altitude rules in `design-judgment.md` — a shape earns a place per altitude, not once globally.
- When two shapes seem to fit one question, the question is probably two questions — split it before picking.
