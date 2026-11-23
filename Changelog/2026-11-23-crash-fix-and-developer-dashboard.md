# 2026-11-23 A freeze that got the game closed by iOS, fixed, and a developer dashboard

Restart the app after installing. No new career is needed; your career is untouched.

- **The game no longer freezes for seconds on a tap in a long career.** A crash log showed iOS closing the game because the screen was frozen for more than 10 seconds (the "scene-update watchdog"), while the game was building new cases and searching text. Three causes were fixed:
  - **Filling names and pronouns into text** was the biggest cost. Every line of every case was checked against about 100 possible swaps, twice. Each line is now read once. Building a case went from 56 ms to 14 ms.
  - **Saving** turned the whole career into text on the main thread after almost every action, 68 ms each and growing with the career. It now happens in the background, repeated saves merge into one, and the last one is finished when you leave the app.
  - **Pattern searches** used the system's slow matcher, which rebuilds the pattern on every call. A cached matcher replaces it.
  - A game day now averages 36 ms instead of 157 ms. A 156-week test game takes 46 seconds instead of 37 minutes, and the 1,703-case story validator takes 27 seconds instead of about 15 minutes.
- **A developer dashboard for crashes** (Settings, Developer dashboard). It shows the build, the device, how much memory iOS will still give the game, the career's size, every save file, the last 30 things the game did, and every crash report it has caught. It records the game's own error output and uncaught exceptions, and collects the crash reports iOS keeps for the app. "Share everything" and "Copy everything" send it all in one piece; "Test crash capture" closes the game on purpose to check that it works.
- **Timing tools.** `Tools/Playtest` now prints how long each step of a game day takes, and which text searches repeat most.
