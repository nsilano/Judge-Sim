# TEMPLATE: SMALL / FILLER CRIME (quick trial)

Short "filler episode" cases: misdemeanors and minor felonies. One State exhibit, one defense exhibit, **one question each way** for the witness and for the defendant. Keep every string tiny to save tokens.

## Prompt to give another model (copy everything in the box)

```
You are writing cases for "Judge Sim", a North Carolina trial-judge game. Write {N} SMALL, quick-trial criminal cases (petty theft, shoplifting, vandalism, small fraud, noise, minor traffic, trespass, false reports, misdemeanor drugs, neighbor disputes) as a JSON array matching the schema below exactly. They are short filler episodes: one State exhibit, one defense exhibit, two witness questions, two defendant questions, a 2-3 line timeline. Everything must be consistent and logical. Each case needs a different scene (place + act). Below is scenes.txt, every case already in the game (law | headline). Your cases must NOT repeat any of those scenes (same place + same act). Choose fresh settings, and also make sure none of your own cases repeat each other.
[paste scenes.txt here]
Rules: use only name tokens ({D} {DL} {V} {D.he} {D.his} {D.him} ...), never real names or raw he/she/his/her. truth_innocent must favor the defendant, truth_guilty must hurt them. Use only the listed evidence kinds and law ids. Output ONLY the JSON array.
Topics: {LIST N IDEAS}
[paste RULES.md here]
[paste the schema below]
```

## Schema

```json
{
  "key": "camelCaseUniqueKey",
  "category": "property",
  "headline": "Under 70 chars, news style",
  "law": "misdLarceny",
  "spec": "Official charge sentence ending ', on {DATE}.'",
  "has_victim": true,
  "summary": "1-2 sentences: what happened on {DATE} and what {DL} says.",
  "state_evidence": {"kind": "video", "title": "Doorbell Camera", "detail": "One sentence."},
  "defense_evidence": {"title": "Short Name", "detail": "{DL} says ..."},
  "witness_role": "Neighbor",
  "witness_exam": [
    {"side": "direct", "q": "What was taken?", "a": "The lights."},
    {"side": "cross", "q": "Value?", "a": "$190."}
  ],
  "theory": {"state": "{D} took lights.", "defense": "A mistake."},
  "truth_guilty": "Fact that hurts {DL}.",
  "truth_innocent": "Fact that HELPS {DL}.",
  "defendant_exam": [
    {"side": "direct", "q": "Did you take them?", "a": "Yes."},
    {"side": "cross", "q": "Why?", "a": "Thought trash."}
  ],
  "timeline": [
    {"day": 0, "text": "Evening: the lights are on."},
    {"day": 0, "text": "11 p.m.: they come down."}
  ],
  "mood": "indifferent"
}
```

Field notes:
- `witness_exam` and `defendant_exam`: exactly **2 entries each: first `direct`, second `cross`**.
- `state_evidence.kind` from the six allowed kinds; add `"searched": true` only if found in a search.
- 2-3 timeline entries, in time order.
- `mood` defaults to `indifferent`.
- Amounts must be small and match the law (misdemeanor-sized).

## Follow-up (small)

Same schema plus:
1. `"source": "keyOfTheEarlierStory"` and a **new unique key**.
2. `summary` begins lowercase and continues "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, ..." (the game adds the prefix). Describe a NEW offense on a different scene, not a copy of the earlier one.
3. Headline reads like a repeat ("... Again").

## Full example

```json
[{
  "key": "christmasLights",
  "category": "property",
  "headline": "Man Takes Neighbor's Rooftop Christmas Lights",
  "law": "misdLarceny",
  "spec": "Took property of {V}, valued at $190, on {DATE}.",
  "has_victim": true,
  "summary": "{D} unplugged and took $190 in roof lights from a neighbor's house on {DATE}. {DL} says they looked abandoned.",
  "state_evidence": {"kind": "video", "title": "Doorbell Camera", "detail": "{D} pulls the lights off the eave."},
  "defense_evidence": {"title": "Thought Trash", "detail": "{DL} says they looked abandoned."},
  "witness_role": "Neighbor",
  "witness_exam": [
    {"side": "direct", "q": "What was taken?", "a": "The lights."},
    {"side": "cross", "q": "Value?", "a": "$190."}
  ],
  "theory": {"state": "{D} took lights.", "defense": "A mistake."},
  "truth_guilty": "They were still plugged in.",
  "truth_innocent": "Half the string was already down from a storm.",
  "defendant_exam": [
    {"side": "direct", "q": "Did you take them?", "a": "Yes."},
    {"side": "cross", "q": "Why?", "a": "Thought trash."}
  ],
  "timeline": [
    {"day": 0, "text": "Evening: the lights are on."},
    {"day": 0, "text": "11 p.m.: they come down."}
  ],
  "mood": "indifferent"
}]
```
