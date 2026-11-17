# Known issues not yet fixed

Remaining from the playtest agents (Nov 2026). Items are removed as they are fixed.

## Content still to fix
- 212 variants (batches A, B, C, 15 in K, 2 in R) are thinner than their originals and need rebuilding as full cases. The list and the standard are in Tools/Stories/VARIANTS_TO_BEEF_UP.md.

## Design or tuning calls (left as they are)
- Murder trials are rare (0 to 2 per 120 weeks) because of the murder limit and pacing rules; raising it is a pacing decision.
- The director's county-state weighting changes little compared with the frequency table and genre rotation.
- Each story has at most one variant, so the original returns on the third hearing (more variants would fix it). About 40% of draws end in a plea at calendar call.
- Class 3 misdemeanor "0 days" is correct (fine only, G.S. 15A-1340.23(d)); probation on it shows as a departure.

## Not fixed
- Sentenced misdemeanants can be released under jail crowding; the sheriff notice and strain use different headcounts.
- The State asks implausible bond amounts in a few cases (for example $30,000 for a no-record computer charge); some rulings offered do not match what the State "agrees" to.
- A defendant with a public defender can also post through a bondsman.
- Occupation conflicts between a defendant's header and some story text.
- Merged probation (misdemeanor plus earlier felony) revocation can leave the person in "jail" with PRS pending.
- A conditional-discharge defendant can get a "3-day CRV" with no sentence to credit.
- Restitution amounts out of scale for some small cases; offense names lowercased wholesale ("schedule ii").
- Bond revoked on a new arrest with no later hearing in a few cases; probation-violation jail stays have no booking entry in the timeline.
- Callback news may name the wrong release type.
- Plea at the start of trial (acceptPlea) was never exercised in headless runs.
