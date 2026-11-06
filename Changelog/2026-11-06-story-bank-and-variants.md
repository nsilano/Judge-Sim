# Release: story bank, variants and fixes (Nov 4 to 6, 2026)

## In one paragraph
The written-case bank grew to **800 stories** with about **690 follow-ups**, and every story can now be told more than one way: **321 alternate tellings** (variants) rewrite the summary, exhibits, testimony and the way the crime happened. A smarter case director keeps careers fresh for years, and several world and sentencing bugs were fixed.

## Numbers
| | |
|---|---|
| Written stories | 800 |
| Variants (alternate tellings) | 321 (1,121 tellings in all) |
| Follow-ups (a defendant returns in new trouble) | about 690 |
| Estimated length of a career before any exact repeat | about 12 game years |

## New
- **Story variants.** A story is told as written the first time it is heard. When it comes back, the game plays a variant the judge has not seen: new headline, summary, exhibits, witness and defendant dialogue, hidden facts and timeline. A variant keeps the story's charge, victim and people, and the original returns only after every telling has been heard.
- **Late-game director.** After 300 different stories have been heard, half of all story draws go to a story that still has an unseen telling. Once every story has been heard, only those come up.
- **Case director and callbacks.** The director scores every candidate story against the career: jail load, backlog, verdict runs, reoffenses, genre and weight fatigue. People from the judge's lenient or no-bond rulings can return in new written cases, and the paper recalls the earlier ruling. A decision journal and a quarterly record recap explain why cases came up.
- **Courtroom jail note.** The trial header shows how long the defendant has been in jail on the case, or how long they were before making bond, so credit for time served is not forgotten.
- **New cases by size.** About 130 short "filler" trials with quick, one-question testimony, and about 670 full-depth trials with a defense witness, a four-point timeline and aggravating or mitigating factors. Every story has a follow-up.

## Fixed
- **Special probation.** Jail days ordered as a condition of probation after a trial are now served up front, with pretrial credit counted, and probation begins on release. Before, the defendant went straight to probation.
- **Duplicate names.** A resident could be charged as a second defendant with the same name. Residents already on a docket are skipped now.
- **Playtest rounds 1 to 3:** exoneration and approval rates, crowding strain, custody-day and jail-credit clamps, bond text, restitution tied to the stated loss, future-dated news, treatment court only for substance cases, departed counsel, docket-number collisions, continuance reasons that fit the charge, retrial chains, absent-witness and outburst incidents, a way back onto the ballot after losing, vacated-conviction wording.
- **Story audit.** 61 duplicate stories and follow-ups were removed. New stories were checked for adult ages, victim flags, timeline order, hidden facts that favor the right side, and no raw gendered wording.

## Tools (for writing more stories)
- `Tools/Stories/`: templates and prompts for small, major and variant stories, a validator (`ingest.py`) with a built-in duplicate scan against the whole bank, and a scene catalog (`scenes.txt`) to paste into a prompt.
- `Tools/Playtest/`: a headless playtest harness. `bank_audit.py` finds near-duplicate stories, `Playtest stories` plays every story and variant once, and `Playtest tellings` checks variant rotation and the late-game preference.
