# Game ideas

The forward-looking list is in ROADMAP.md. This file is the original brainstorm and the three build phases.

Brainstormed Nov 2026. Items are removed or moved to a changelog entry as they ship.

## Planned (no new or edited case content needed)
Rough order, each phase playable on its own.

1. **Foundation**
   - **Judge's ruling record and adapting lawyers.** Log each ruling against what each side asked (bond amount and type by charge and class, plea outcomes, continuances granted and why, sentence versus the State's ask), with a rolling window that fades old rulings. The State shades its asks toward what the judge tends to grant, never below what the law and the charge justify; the defense asks for what has tended to be approved. Lawyers occasionally say so in their own voices. No visible counters.
   - **Recurring cast of lawyers.** A saved roster of named prosecutors and defense attorneys with styles (bargains early, never pleads violent cases, files constantly), handed to cases so the same people return.
   - **Lawyer track records.** Candor, reliability and results over time, so a judge learns whose asks to weigh.
   - **Courtroom staff.** A clerk, bailiff and court reporter with occasional events (a calendar mix-up, a missing file, a juror problem).
2. **World and consequences**
   - **Delayed fallout.** Widen the paper's and the court's follow-through when a release or plea goes wrong weeks later, and connect it to later lawyer behavior.
   - **Victim and family reactions** at bond, plea and sentencing, by offense type.
   - **Jail capacity in the asks.** The State asks for less jail time when the jail is full.
   - **Bias checks.** Lawyers challenge inconsistency across similar rulings (needs the ruling record).
   - **Ethics situations.** A lawyer known socially, an ex parte contact, a recusal question: events with choices and consequences.
3. **Mechanics**
   - **Plea mechanics.** Built as calendar matters (`CourtProceedings.swift`): Alford plea, medication, immigration warning, hesitation, mismatched terms, withdrawal before sentencing, interpreter.
   - **Jury selection (switched off, future feature).** The scenarios are written and rated (`CourtProceedings.swift`, jury part: challenges for cause, Batson, prejudged and distressed jurors, hardship, a juror who knows a witness) but are not put on the calendar, because every trial in the game is a bench trial. Turn them on (the commented line in `CalendarCalls.make`) when the game adds jury trials: a pool with strikes and biases, a juror who knows a witness, and verdicts that depend on who is seated.

## Deferred: needs new cases or edits to existing ones
- **Hard calls.** New cases where the law points one way and the facts another.
- **Evidence that develops before trial.** A suppression ruling, a late lab result, a witness who recants; needs a changing case state and edits to story data.
- **Co-defendants.** Linked cases with deals, cooperating testimony and shared facts; needs new data and new stories.

## Notes
- New saved data must load old saves; features that depend on case generation show fully only in a new career.
- Everything written follows the depth and realism rules in CLAUDE.md.
