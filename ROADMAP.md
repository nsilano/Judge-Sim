# Roadmap

Things we have discussed and want to add but have not started. When one is started it moves to the changelog entry that ships it. Everything written follows the depth and realism rules in CLAUDE.md. New saved data must load old saves.

## Waiting on new game systems
- **Jury trials and jury selection.** Every trial today is a bench trial. A jury mode would need a juror pool with strikes and biases, a juror who knows a witness, and verdicts that depend on who is seated. The judge's side of selection is already written and rated in `CourtProceedings.swift` (challenges for cause, Batson, prejudged and distressed jurors, hardship, a juror who knows a witness) but switched off: re-enable the commented line in `CalendarCalls.make` when jury trials exist.

## Waiting on new or edited case content
- **Hard calls.** New cases where the law points one way and the facts another: a technically valid search that feels wrong, a mandatory sentence that fits badly, a sympathetic defendant with a clear violation. The player has to choose between the law and the outcome, and the reaction (lawyers, press, appeals) shows which they chose. Needs new written cases, each with its own testimony and rulings.
- **Evidence that develops before trial.** The case changes between the first look and the trial: a suppression ruling that removes an exhibit, a late lab result, a witness who recants or changes their account, a new witness. Needs a case that can change after it is built, plus edits to existing story data so testimony and the briefing follow the change.
- **Co-defendants.** Two or more defendants in linked cases: one takes a deal and testifies against the other, a joint trial or a severance motion, shared facts and conflicting stories, a conflict of interest for a shared lawyer. Needs linked case data and new stories written for both sides.

## Notes
- `GAME_IDEAS.md` holds the original brainstorm and the three build phases (ruling memory and adapting lawyers, recurring cast, track records, staff, fallout, victim reactions, jail capacity, bias checks, ethics, plea mechanics).
