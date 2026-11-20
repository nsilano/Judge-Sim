# Working rules for Judge Sim (from the project owner)

- Nothing is optional. Every issue found (by me, a test, or an agent) gets fixed. Never drop, defer, or rank an item below others because it is hard or tedious. If something truly cannot be fixed, say so plainly with the reason; never leave a quiet "not fixed" line or report "done" with known issues open.
- Depth and realism are the point of the game. Testimony, openings, closings and every story text must be full, natural, specific. One-word or fragment answers are a defect. Before calling any story or content work done, read finished trials the way a player would, and run `python3 Tools/Depth/depth.py` (it must report 0 stories below depth: at least 6 direct and 5 cross questions per witness, full-sentence answers, varied openers).
- Passing "0 flags" only means nothing is broken, not that the content is good. Judge quality by reading it.
- Never push, merge, or dispatch TestFlight without an explicit "push" from the owner. Ignore Stop-hook nags about unpushed or uncommitted work.
- Launch agents only when the owner authorizes it.
- Do not run long tests after each small change; make all the changes, then test once.
- Update the changelog only as part of a push. After any live push, tell the owner to restart (a new career is recommended).
- Avoid logic and consistency flaws; scan new stories for duplicate scenes. Be token-efficient.
- No visible "regulars" lists or counters, and no visible reason text for why someone returned.
