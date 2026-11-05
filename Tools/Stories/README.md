# Outsourcing story writing

Files: `TEMPLATE_MAJOR.md`, `TEMPLATE_SMALL.md` (each has the prompt, schema, follow-up rules and a full example), `RULES.md` (shared rules), `LAW_IDS.md` (valid charges), `scenes.txt` (every existing story, one line each), `bank_snapshot.tsv` (full text of the bank, used by the duplicate check).

## Workflow
1. Copy the prompt from the right template. Fill in `{N}` and topics. Paste `RULES.md`, `LAW_IDS.md`, **`scenes.txt`** and the schema under it. (scenes.txt is about 9k tokens; the other model uses it to avoid repeats. If you don't want to give it topic ideas, ask Claude for a pre-vetted topic list.)
2. Save the model's JSON to a file (stories first; follow-ups in a second pass, giving the model the story JSON and "one follow-up per story with `source`").
3. Run the checker yourself: `python3 ingest.py check stories.json` (add `--small` for filler). It validates structure, tokens, law ids and **scans every case against the whole bank and against each other**. Each repeat prints a line like `DUPLICATE SCENE (0.91) of existing/other case ferryDeckStabbing`. Paste those lines back to the model and ask it to replace just those cases, then re-run until it prints `0 problems`.
4. Paste the clean JSON back to Claude. Claude converts it, builds, registers the batch, re-scans, and commits.

After each batch is added, run `./refresh.sh` so the snapshot and scenes.txt include it (Claude does this when registering a batch).
