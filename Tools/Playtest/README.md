# Headless playtest

Plays a Judge Sim career on Linux with no simulator: every court day, every trial, hearing, and calendar call, decided
in a chosen judging style. Each matter, ruling, judgment, reaction, and news item is written to a text transcript, and
contradictions are flagged as they happen (a FINDINGS list is at the end).

```sh
# Needs Docker. The official Swift image, via Google's mirror of Docker Hub:
docker pull mirror.gcr.io/library/swift:6.0-noble

python3 Tools/Playtest/sync.py   # copies JudgeSim/Game and JudgeSim/Models in, with Apple-only pieces stubbed
docker run --rm -v "$PWD":/src -w /src/Tools/Playtest mirror.gcr.io/library/swift:6.0-noble swift build
docker run --rm -v "$PWD":/src -w /src/Tools/Playtest mirror.gcr.io/library/swift:6.0-noble \
    .build/debug/Playtest 26 mixed /src/playtest.txt        # weeks, style (lenient | harsh | mixed), transcript
```

Automatic checks: time served described as prison, delay stories before a case sat ready on the list, violations
within 60 days of probation starting, failures to appear on far-off trials, unserved arrest orders shown as arrests,
people left in custody past release, past trial dates in the news, unfilled tokens, and doubled phrases.
Add a check in `Harness/main.swift` whenever a new kind of bug turns up.
