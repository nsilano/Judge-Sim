# TEMPLATE: VARIANT (an alternate telling of an existing story)

A variant is the **same case** told another way. When a story comes back in a long career the game switches to a variant the player has not seen: new summary, new exhibits, new testimony, and a different way the crime happened. Charge, victim role, and the kind of people involved stay the same.

## What must stay the same
`variant_of` (the story's key), `law`, `category`, `has_victim`. Everything else must be new:
- **headline** (or `headlines`): a different news headline.
- **A different way it happened:** change the setting, the trigger, the tool, the time of day, how it was discovered, and how the defendant was identified. Do not reuse the original's exhibits, quotes, or amounts.
- **New dialogue:** every witness and defendant answer is worded fresh. No sentence copied from the original.
- Keep the same level of detail as the original (a small story stays small: 2 witness lines, 2 defendant lines; a major story keeps 4+4, a defense witness and a 4-point timeline).
- The hidden facts still work the same way: `truth_innocent` must help the defendant, `truth_guilty` must hurt.
- If `has_victim` is false, use no `{V}` tokens. If it is true, use `{V}`.

## Prompt to give another model
```
You are writing alternate versions ("variants") of existing cases for "Judge Sim", a North Carolina trial-judge game. For each story brief below, write ONE variant: the same charge and kind of crime, but a different scene, different evidence, a different way it was discovered, and entirely new witness and defendant dialogue. Use the same JSON schema as the matching template (small or major), with these changes: add "variant_of" (the story's key) instead of "key"; use the same law, category and has_victim as the brief; the headline must be different. Never copy sentences from the brief. Use name tokens only ({D} {DL} {V} {D.he} {D.his} {D.him} {DATE}), never raw he/she/his/her. Output ONLY a JSON array.
[paste RULES.md]
[paste the small or major schema from TEMPLATE_SMALL.md / TEMPLATE_MAJOR.md]
[paste the output of: python3 ingest.py base key1 key2 ...]
```

## Checking
`python3 ingest.py check variants.json --small` (or without `--small` for major stories). It checks the structure and that the charge and category match the original and the headline is new. Paste the clean JSON back to Claude to generate and register it.

## Example (small)
```json
{
  "variant_of": "christmasLights",
  "category": "property",
  "headline": "Strand of Roof Lights Vanishes During Windstorm Cleanup",
  "law": "misdLarceny",
  "spec": "Took property of {V}, valued at $190, on {DATE}.",
  "has_victim": true,
  "summary": "A neighbor's roof lights came down in a windstorm on {DATE} and were found coiled in {D}'s truck bed. {DL} says {D.he} was helping clean up.",
  "state_evidence": {"kind": "video", "title": "Truck Camera", "detail": "{D} loads the lights into a truck bed."},
  "defense_evidence": {"title": "Cleanup", "detail": "{DL} says {D.he} was clearing storm debris."},
  "witness_role": "Neighbor",
  "witness_exam": [{"side": "direct", "q": "Where were the lights?", "a": "Coiled in {DL}'s truck."}, {"side": "cross", "q": "Did you ask {D.him} to help?", "a": "No."}],
  "theory": {"state": "{D} kept a neighbor's lights.", "defense": "Storm cleanup."},
  "truth_guilty": "{DL} listed the lights for sale online that week.",
  "truth_innocent": "The wind snapped the cord and {DL} texted a photo to the owner.",
  "defendant_exam": [{"side": "direct", "q": "Why take them?", "a": "To clear the street."}, {"side": "cross", "q": "Did you tell anyone?", "a": "I texted."}],
  "timeline": [{"day": 0, "text": "Afternoon: the windstorm."}, {"day": 0, "text": "Evening: the truck."}],
  "mood": "indifferent"
}
```
