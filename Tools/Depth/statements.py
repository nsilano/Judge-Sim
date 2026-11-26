#!/usr/bin/env python3
"""Depth gate for the sentencing statements: each story's defendant allocution and victim impact statement.
Defect = fewer than 20 words (allocution) / 18 words (impact), fewer than two sentences, or an exact repeat of another story's.
Usage: statements.py [--list] [file-substring ...]"""
import re, glob, sys, collections, os
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'JudgeSim', 'Game')
args = [a for a in sys.argv[1:] if not a.startswith('--')]
listing = '--list' in sys.argv
rows = []
for f in sorted(glob.glob(root + '/Story*.swift') + glob.glob(root + '/FollowUp*.swift')):
    t = open(f).read(); name = os.path.basename(f)
    for m in re.finditer(r'key: "([^"]+)"', t):
        end = t.find('key: "', m.end()); end = len(t) if end < 0 else end
        blk = t[m.end():end]
        for field, minw in (('allocution', 20), ('impact', 18)):
            for fm in re.finditer(r'\b' + field + r': "((?:[^"\\]|\\.)*)"', blk):
                rows.append((name, m.group(1), field, fm.group(1).replace('\\"', '"'), minw))
        for field, label, minw in (('allocutions', 'allocution', 20), ('victimImpacts', 'impact', 18)):
            for fm in re.finditer(r'\b' + field + r': \[(.*?)\],?\n', blk):
                for item in re.findall(r'"((?:[^"\\]|\\.)*)"', fm.group(1)):
                    rows.append((name, m.group(1), label, item.replace('\\"', '"'), minw))
seen = collections.Counter((r[2], r[3]) for r in rows)
bad = []
for name, key, field, text, minw in rows:
    words = len(text.split()); sentences = len(re.findall(r'[.!?]["”]?(\s|$)', text))
    why = []
    if words < minw: why.append('short(%d)' % words)
    if sentences < 2: why.append('one sentence')
    if seen[(field, text)] > 1: why.append('repeated x%d' % seen[(field, text)])
    if why and (not args or any(a in name for a in args)):
        bad.append((name, key, field, ','.join(why)))
if listing:
    for b in bad: print(*b)
print('STATEMENTS: %d defects in %d allocutions/impacts' % (len(bad), len(rows)))
sys.exit(1 if bad else 0)
