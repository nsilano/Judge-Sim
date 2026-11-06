# 2026-11-06 — Playtest fixes (three-agent pass)

Stories
- Corrected charges: the mower and golf-cart cases are now DWI; the fairground swing cases are serious-injury assault, not manslaughter; the watch stabbing is assault with a deadly weapon, not intent to kill.
- Follow-up consistency: the hood-claims and phantom-patient follow-ups keep the original defendant's role; lottery follow-up headline fixed; tracker timeline warning now comes before the eleventh event.

Case director
- Retold stories are counted correctly, so a story no longer returns with the same telling.
- Follow-ups skip recently heard ones and prefer the least heard.
- Early in a career the director chooses from a random slice of the bank, so a restart opens with different cases.

Calendar and court
- A calendar call carried over past a trial no longer brings the tried case back.
- Bond amounts in the Results screen and Records now match the bond set.
- Treatment-court sanctions on felony probationers are county jail, not prison.
- The court always keeps one court day, one trial and one hearing a week.
- Time off can't go past the year's leave; the weekly calendar call never appears empty.
- A split sentence serves at least one month or day before release.
- A misdemeanor probation no longer erases an earlier felony suspended sentence.
- "1 month" and "1 day" now read correctly; reassigning a trial from the calendar asks first.

Not changed (design decisions): arraignment, plea and search-warrant matters stay off because every case is a written story; sentenced misdemeanants remain releasable under jail crowding; the misdemeanor prior-level count is unchanged.
