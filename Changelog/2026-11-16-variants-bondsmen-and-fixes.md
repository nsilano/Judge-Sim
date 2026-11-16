# 2026-11-16 — Variants, bondsman underwriting, State positions, and a round of fixes

## New content
- 378 more story variants (50 real-case stories, 100 older stories, and 228 more older stories). 698 of the 850 stories now have an alternate telling. 152 stories still have none.
- 152 more follow-ups: a second follow-up for 50 older stories, and a first follow-up (with aftermath news) for 102 stories that had none. 889 follow-ups in all.
- A variant that writes no extra counts keeps the original story's (for example the death count in a hit-and-run), so the victim's fate and charges stay the same case.

## Returning defendants and pacing
- Follow-ups that were queued for someone still serving a sentence are no longer lost: they come back after release. A follow-up that can't be built one day waits for the next.
- Written follow-ups come a little sooner and more often (higher chance, shorter delays and indictment lag); the random reoffense roll is a little higher.
- General follow-ups now match what the person was convicted of before (a theft follows a theft, a drug charge a drug charge).
- The "prefer an unseen telling" rule starts after 40 different stories instead of 300.
- Murder-level stories are drawn a bit more often (the one-murder-at-a-time rule is unchanged), and the director reacts more strongly to runs of verdicts and reoffenses.
- Smaller fixes: restitution on minor offenses is scaled down; appointed-attorney fees aren't billed to someone who could put thousands toward bond; the sheriff's crowding notices and the crowding strain use the same jail count; probation-violation jail stays are logged as bookings; follow-up closing arguments no longer repeat their openings.

## New engines
- **Bondsman underwriting:** whether a bail bondsman writes a bond now depends on charge severity, record, repeat offenses, missed court dates, ties and income, the size of the bond and the fee money on hand. It also sets the fee (10, 12 or 15 percent) and the most a bondsman will write. When one refuses, the bond card says why.
- **State positions at bond reductions:** the State's stance follows from what it asked at the first appearance, the charge, felony record and missed court dates, so it no longer opposes something it already agreed to. A bond hearing now starts the six-week cooldown on bond-reduction motions. Misdemeanors are no longer offered pleas at arraignment.

## Fixes
- **Special probation (split sentences):** served in the county jail, never a prison commitment or a state-bed wait; the jail days are credited if probation is later revoked; a plea split starts probation at release, runs 18 months from release, and respects the one-fourth cap (the offered jail days too).
- **Reassigned cases:** the other judge's outcome now goes on the defendant's record (appearance, conviction) and ends their custody.
- **Continuances:** the count no longer resets after a hold or ruling; State objections now fit the actual charge and evidence; continuance evidence only offers follow-up that fits the story (cameras and location records for cases with a scene, bank records for money cases, lab and expert review only with forensic evidence).
- **Calendar and bonds:** missed-court matters keep the real bond (so the doubled bond is right), no repeat missed-court matter within four weeks, "bond set at" instead of "doubled" for unsecured bonds, arraignment waiting list matches the "five weeks" the card says, docket numbers use the arrest year, plea cards no longer say "first offense" for defendants with priors, week-in-review numbers follow the calendar after an away week, bond statuses and news name the right release.
- **Probation:** no-contact conditions end when probation ends; early termination doesn't free someone mid-confinement; short criminal-contempt jail terms are jail, not prison.
- **News and text:** investigation news names the right crime; search-warrant news and warrants only when they fit the charge; about 600 aftermath items no longer repeat the headline; expunction news names the petitioner and promises nothing the game doesn't do; the mayor's-call item no longer claims a pending trial; new-trial motions read as sentences; reactions no longer call a jail sentence served by credit "probation".
- **Stories:** civilians no longer testify under the case detective's name; follow-ups keep the earlier victim; sensible age ranges on the new cases; dollar amounts in testimony match the case file; the pet-sitter case is larceny, not burglary; a doubled word in a headline; several older stories' dates, weekdays and details.
