# Shared rules (both templates)

**Output:** one JSON array, nothing else. Stories go in one file, follow-ups in another.

**Categories:** property, traffic, publicOrder, whiteCollar, violent, robbery, drugs, family, cyber
**Evidence kinds (only these):** physical, forensic, digital, document, statement, video
**Moods:** wantsConviction, sympathetic, divided, indifferent
**Law:** use an id from LAW_IDS.md exactly. Pick the charge the facts really support.

## Name tokens (never write names or raw he/she/his/her/him)
| Token | Means |
|---|---|
| `{D}` | defendant's full name |
| `{DL}` | defendant's last name (e.g. "Mr. Hale") |
| `{V}` | victim's name (only if the story has a victim) |
| `{D.he}` `{D.He}` `{D.his}` `{D.him}` `{D.himself}` | defendant pronouns |
| `{V.he}` `{V.His}` `{V.him}` ... | victim pronouns |
| `{DATE}` | the offense date |
| `{PRIORDATE}` `{PRIOR}` | follow-ups only: date and offense of the defendant's earlier case |

Do not write "the man", "the woman", "he", "she", "his", "her" about the defendant or victim. A headline may say "Man" or "Woman" only when it must; third parties (a friend, a cousin) may use normal pronouns.

## Logic rules
1. **Consistency:** every fact (amounts, times, places, who saw what) must agree across summary, exhibits, testimony and timeline.
2. **Two possible truths:** `truth_guilty` and `truth_innocent` are hidden facts the game reveals depending on which way the case goes. `truth_innocent` must **favor the defendant** (a fact that supports their story). `truth_guilty` must hurt them. Never put a fact that hurts the defendant in `truth_innocent`.
3. **Contested, not obvious:** the defense story must be plausible, not absurd, and must not contradict the State's best exhibit with certainty.
4. **No victim?** Set `has_victim: false` and use no `{V}` tokens anywhere (drugs, DWI, weapons, false reports, etc.).
5. **Age:** defendant is an adult. Don't mention an age.
6. **Realistic scale:** amounts, sentences, injuries and tools must match the charge. Keep small crimes small.
7. **Timeline:** `day_offset` 0 = offense day, negative = earlier days, positive = later. Events in time order. Never cross midnight within day 0 unless the text says so.
8. **Unique scenes:** no two stories may share the same place + act. Same law is fine, same scene is not. Check the "already used" list the user gives you.
9. **No raw quotes inside strings** other than normal apostrophes; escape any double quotes.
10. **Short sentences.** Plain words. No fancy names.
