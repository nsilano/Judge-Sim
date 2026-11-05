# Outsourcing story writing

Files: `TEMPLATE_MAJOR.md`, `TEMPLATE_SMALL.md` (each has the prompt, schema, follow-up rules and a full example), `RULES.md` (shared rules, paste into the prompt), `LAW_IDS.md` (valid charges).

## Workflow
1. Generate the "already used" list: `python3 ingest.py used > used.txt` (about 1,000 lines; paste only the lines near your topics, or the whole list into a long-context model).
2. Open the right template, copy the prompt box, fill `{N}`, topics and the used list, and paste RULES.md, LAW_IDS.md and the schema. Send to the other model.
3. Ask it for stories first, then a second run for follow-ups (give it the story JSON and say "write one follow-up per story with `source`").
4. Optional self-check: `python3 ingest.py check stories.json` (add `--small` for filler). Fix anything it lists and re-run, or send the errors back to the model.
5. Paste the JSON back to Claude. Claude will convert, scan for duplicates, build, register the batch and commit.
