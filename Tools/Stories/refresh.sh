#!/bin/sh
# Re-dump the bank and rebuild scenes.txt. Run after new batches are added (needs the Tools/Playtest build).
set -e
cd "$(dirname "$0")/../Playtest"
docker run --rm -v "$(cd ../..; pwd)":/src -w /src/Tools/Playtest mirror.gcr.io/library/swift:6.0-noble \
  sh -c 'swift build >/dev/null && .build/debug/Playtest bank /src/Tools/Stories/bank_snapshot.tsv'
git checkout playtest.txt 2>/dev/null || true
cd ../Stories && python3 ingest.py scenes > scenes.txt && wc -l scenes.txt
