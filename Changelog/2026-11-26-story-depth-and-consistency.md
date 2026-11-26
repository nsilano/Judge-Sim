# 2026-11-26 Deeper testimony in every story, consistent stories, and read-aloud

Restart the app after installing. A new career is recommended so every new story, opening and closing shows up from the start.

- **Every story now has full testimony.** The depth check used to skip the stories built as returning-defendant follow-ups. Now all 2,371 stories have at least 6 direct and 5 cross questions for each witness, in full sentences with varied openers. About 87 thin follow-ups and 13 base stories were expanded.
- **About 550 new openings and closings** written by hand for the follow-up stories, so the lawyers' speeches name the facts of the case instead of repeating stock lines. Stock sentences that appeared in five or more stories were rewritten.
- **Contradictions fixed.** Witnesses, defendants and officers no longer disagree inside a story: whether a notice was signed, whether a receipt exists, what a recording says, what a trailer carried, whether a clock was off, who was at the scene, and more. About 50 answers that only echoed the question were rewritten.
- **Scenes fit the case.**
  - Undercover drug buys have an arrest-team officer and an "undercover buy" scene instead of a house call.
  - Trespass cases read as trespass, not shoplifting, and the arrival scene no longer claims the person had not left or that there was a sign.
  - An officer names the defendant at the scene when the victim knows them (neighbor, tenant, banned from the bar, and so on).
  - Written stories that give a clock time without minutes ("4 p.m.") now use it, so an afternoon event no longer has a 4 a.m. arrival.
  - A business victim (a bakery, a bar, a church) gets a business name, and an "owned by" victim is the owner witness.
- **Read-aloud.** A button on testimony, openings and closings, the case file and the calendar reads the text aloud with the phone's built-in voices. Each speaker keeps one voice. Speed and varied voices are in Settings.
- **Tools.** `Tools/Depth/depth.py` now checks follow-up stories too; new checks `nearly.py` (near-duplicate questions), `statements.py` (sentencing statements) and an expanded `names.py`.

Checks run before release: 0 of 2,371 stories below depth, 0 name or statement defects, a 60-week test game and a run of all 1,703 written cases with 0 flags.
