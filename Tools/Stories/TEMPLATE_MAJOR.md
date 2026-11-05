# TEMPLATE: MAJOR CRIME (full-depth trial)

For felonies and serious cases. Full-depth trial: 3 State exhibits, 1-2 defense exhibits, 4 witness questions, 4 defendant questions, a defense witness, a 4-point timeline.

## Prompt to give another model (copy everything in the box)

```
You are writing cases for "Judge Sim", a North Carolina trial-judge game. Write {N} MAJOR criminal cases (felonies or serious misdemeanors) as a JSON array that matches the schema below exactly. Read RULES.md and LAW_IDS.md rules first (pasted below). Each case is a realistic, contested trial with a plausible defense. Every case needs a different scene (place + act). Below is scenes.txt, every case already in the game (law | headline). Your cases must NOT repeat any of those scenes (same place + same act). Choose fresh settings, and also make sure none of your own cases repeat each other.
[paste scenes.txt here]
Rules: use only name tokens ({D} {DL} {V} {D.he} {D.his} {D.him} ...), never real names or raw he/she/his/her. truth_innocent must favor the defendant, truth_guilty must hurt them. Use only the listed evidence kinds and law ids. Output ONLY the JSON array.
Topics to cover: {LIST N IDEAS, e.g. "pharmacy burglary; staged crash insurance fraud; ..."}
[paste RULES.md here]
[paste the schema + example below]
```

## Schema (all fields required unless marked optional)

```json
{
  "key": "camelCaseUniqueKey",
  "category": "violent",
  "headlines": ["Main news-style headline (under 70 chars)", "Second shorter headline"],
  "law": "awdwikisi",
  "spec": "Official charge sentence ending with ', on {DATE}.'",
  "has_victim": true,
  "summary": "3-4 sentences. What happened on {DATE}, who is accused, and what {DL} says.",
  "state_evidence": [
    {"kind": "video", "weight": 3, "title": "Short Name", "detail": "One sentence of what it shows."},
    {"kind": "physical", "weight": 3, "title": "Knife", "detail": "...", "searched": true},
    {"kind": "forensic", "weight": 2, "title": "Medical Report", "detail": "..."}
  ],
  "defense_evidence": [
    {"kind": "statement", "weight": 1, "title": "Lunge", "detail": "{DL} says ..."}
  ],
  "witness_role": "Ferry deckhand",
  "witness_exam": [
    {"side": "direct", "q": "What did you see?", "a": "..."},
    {"side": "direct", "q": "...", "a": "..."},
    {"side": "cross", "q": "...", "a": "..."},
    {"side": "cross", "q": "...", "a": "..."}
  ],
  "theory": {"state": "{D} stabbed a passenger.", "defense": "A defense."},
  "allocution": "What the defendant says if convicted (1 sentence).",
  "truth_guilty": "Hidden fact that hurts {DL}.",
  "truth_innocent": "Hidden fact that HELPS {DL}.",
  "defendant_exam": [
    {"side": "direct", "q": "Did you ...?", "a": "..."},
    {"side": "direct", "q": "...", "a": "..."},
    {"side": "cross", "q": "...", "a": "..."},
    {"side": "cross", "q": "...", "a": "..."}
  ],
  "opening": {"state": "Short.", "defense": "Short."},
  "closing": {"state": "Short.", "defense": "Short."},
  "timeline": [
    {"day": -1, "text": "Earlier event."},
    {"day": 0, "text": "3:10 p.m.: ..."},
    {"day": 0, "text": "3:22 p.m.: ..."},
    {"day": 0, "text": "3:40 p.m.: ..."}
  ],
  "how_identified": "Short phrase: how the defendant was identified.",
  "mood": "divided",
  "victim_impact": "One sentence the victim says at sentencing. (optional if no victim)",
  "aggravating": ["The offense involved a weapon"],
  "mitigating": [],
  "threshold": 7,
  "defense_witness": {"role": "Passenger on the upper deck",
    "exam": [{"side": "direct", "q": "...", "a": "..."}, {"side": "cross", "q": "...", "a": "..."}]},
  "legal_topics": ["selfDefense"]
}
```

Field notes:
- `weight` 1-3: how convincing the exhibit is (3 = strongest). State has at least two weight-3 or one 3 and one 2; total State weight should land near `threshold` or a bit above if the case is strong.
- `threshold` 6-9: how much State weight is needed to prove guilt. Easy cases 6, hard/contested 8-9.
- `searched: true` on a physical/forensic exhibit found by a warrant or search (can be challenged).
- `aggravating` / `mitigating` phrases (use these when they fit): "The offense involved a weapon", "The offense involved a firearm", "The offense was committed for pecuniary gain", "The defendant took advantage of a position of trust or confidence", "The victim was particularly vulnerable", "The defendant was impaired at the time of the offense", "The victim was a law enforcement officer performing official duties", "The defendant has accepted responsibility", "The defendant acted under strong provocation".
- `legal_topics` (optional, pick 0-3): selfDefense, imperfectSelfDefense, defenseOfOthers, mistakeOfFact, searchSeizure, burdenOfProof, lesserIncluded, intoxication, alibi, entrapment, necessity, duress, insanity, hearsay, relevance, chainOfCustody, eyewitnessID, miranda.
- Keep every string to one or two sentences. Questions end in "?". Answers are short.

## Follow-up (major) — a second case about the SAME defendant later

Same schema plus two changes:
1. Add `"source": "keyOfTheEarlierStory"` and a **new unique key**.
2. `summary` begins lowercase and continues the sentence "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, ..." (the game adds that prefix). It describes a NEW offense on a different scene. Add one truth/exam point that refers to the prior case (e.g. "{DL} had a prior case in this court."). Follow-ups may use `defense_witness` or skip it, and may have shorter exams (2 direct + 2 cross is fine).
Headlines for follow-ups should read like a repeat: "... Again", "Defendant From Earlier Case ...".

## Full example

```json
[{
  "key": "ferryDeckStabbing",
  "category": "violent",
  "headlines": ["Passenger Stabbed on Ferry Deck During Crossing", "Suspect Detained at the Dock"],
  "law": "awdwikisi",
  "spec": "Assaulted {V} with a knife, inflicting serious injury, on {DATE}.",
  "has_victim": true,
  "summary": "{V} was stabbed once in the side on the open deck of a ferry on {DATE} during a twenty-minute crossing. Crew held {D} at the dock. A folding knife was found in a life-vest bin. {DL} says {V} lunged first after an argument over a seat.",
  "state_evidence": [
    {"kind": "statement", "weight": 3, "title": "Deckhand", "detail": "{D} was bent over {V} when the deckhand arrived."},
    {"kind": "physical", "weight": 3, "title": "Knife", "detail": "Folding knife in a life-vest bin with {V}'s blood.", "searched": true},
    {"kind": "forensic", "weight": 2, "title": "Medical Report", "detail": "One wound, four inches deep, no organ damage."}
  ],
  "defense_evidence": [{"kind": "statement", "weight": 1, "title": "Lunge", "detail": "{DL} says {V} lunged first."}],
  "witness_role": "Ferry deckhand",
  "witness_exam": [
    {"side": "direct", "q": "What did you see?", "a": "{DL} over {V} with blood on {D.his} hand."},
    {"side": "direct", "q": "Where was the knife?", "a": "A life-vest bin."},
    {"side": "cross", "q": "Did you see the start?", "a": "No."},
    {"side": "cross", "q": "Did {V} have anything in hand?", "a": "A coffee cup, I think."}
  ],
  "theory": {"state": "{D} stabbed a passenger.", "defense": "A defense."},
  "allocution": "I never meant to hurt anyone.",
  "truth_guilty": "{DL}'s prints are on the knife handle.",
  "truth_innocent": "{V} had thrown a cup at {DL} first.",
  "defendant_exam": [
    {"side": "direct", "q": "Did you stab {V}?", "a": "I swung to keep {V} away."},
    {"side": "direct", "q": "Why carry a knife?", "a": "Work."},
    {"side": "cross", "q": "Why hide it?", "a": "Panic."},
    {"side": "cross", "q": "A cup is not a weapon.", "a": "It hit my face."}
  ],
  "opening": {"state": "A knife and a hidden blade.", "defense": "A lunge."},
  "closing": {"state": "The bin.", "defense": "The cup."},
  "timeline": [
    {"day": -1, "text": "A seat argument begins at the dock."},
    {"day": 0, "text": "3:10 p.m.: the crossing starts."},
    {"day": 0, "text": "3:22 p.m.: {V} is cut."},
    {"day": 0, "text": "3:40 p.m.: {DL} is held at the dock."}
  ],
  "how_identified": "A deckhand and a knife.",
  "mood": "divided",
  "victim_impact": "I still can't lift my arm.",
  "aggravating": ["The offense involved a weapon"],
  "mitigating": [],
  "threshold": 7,
  "defense_witness": {"role": "Passenger on the upper deck",
    "exam": [{"side": "direct", "q": "What did you see?", "a": "{V} threw something first."},
             {"side": "cross", "q": "Clearly?", "a": "From above."}]},
  "legal_topics": ["selfDefense", "imperfectSelfDefense"]
}]
```
