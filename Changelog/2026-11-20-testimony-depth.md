# 2026-11-20 Deeper testimony in every story

Start a new career after installing this build, and restart the app.

- Every story's witnesses (the State witness, the defendant, and any defense witness) now give full, specific testimony: at least 6 direct and 5 cross questions each, with full-sentence answers, in all 1,483 stories and alternate tellings. About 300 stories were rewritten in earlier batches, about 120 more of the thinnest tellings (StoryVariants U, V, W and X) were rewritten from scratch this round, and roughly 350 witnesses that came up short were topped up with new, case-specific questions.
- Opening statements and closing arguments were rewritten for those tellings so both sides tell the story in full.
- Duplicate questions inside a witness's list were removed, and stock phrasing ("I should have", "I am sorry", "I feel ...", the "Tell the jury about ..." openers) was varied so witnesses sound less alike.
- The transcript view on the trial screen no longer indents each phase's questions far from the card's edge: a plain header with a chevron replaces the disclosure group.
- Tools: `Tools/Depth/depth.py` (the depth gate), `apply.py`, `show.py`, `clean.py`, `dedupe.py` and `vary.py` are in the repo for authoring and checking testimony.
