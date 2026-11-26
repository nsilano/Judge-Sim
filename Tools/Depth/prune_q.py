#!/usr/bin/env python3
"""Removes a repeated question (same phase, same witness, nearly the same words) when the witness keeps the depth floor (6 direct,
5 cross); lists the ones that can't be removed. Usage: prune_q.py [--apply] [--include-followups]"""
import re, glob, os, sys, collections
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'JudgeSim', 'Game')
APPLY = '--apply' in sys.argv
PAT = re.compile(r'\.(direct|cross|redirect)\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')
STOP = set("a an the of to and or in on at for with by is was were are be been did do does you your didn't don't not it that this i he she they".split())
FLOOR = {'direct': 6, 'cross': 5}
def toks(q):
    q = re.sub(r'\{[^}]*\}', ' X ', q.lower())
    return frozenset(x for x in re.findall(r"[a-z0-9$]+", q) if x not in STOP)
def sim(a, b): return len(a & b) / min(len(a), len(b)) if a and b else 0
files = sorted(glob.glob(os.path.join(ROOT, 'Story*.swift')) + (glob.glob(os.path.join(ROOT, 'FollowUp*.swift')) if '--include-followups' in sys.argv else []))
removed = stuck = 0; manual = []
for f in files:
    t = open(f).read(); runs = []; run = []; prev = 0
    for m in PAT.finditer(t):
        gap = t[prev:m.start()]
        if prev and (']' in gap or 'exam' in gap.lower() or 'defendant:' in gap): runs.append(run); run = []
        run.append(m); prev = m.end()
    runs.append(run)
    cuts = []
    for run in runs:
        by = collections.defaultdict(list)
        for m in run: by[m.group(1)].append(m)
        for k, ms in by.items():
            seen = []; count = len(ms)
            for m in ms:
                tq = toks(m.group(2))
                dup = any(len(tq) >= 2 and len(x) >= 2 and sim(tq, x) >= 0.8 for x in seen)
                if dup:
                    if k in FLOOR and count - 1 >= FLOOR[k]:
                        cuts.append(m); count -= 1; continue
                    if k == 'redirect':
                        cuts.append(m); count -= 1; continue
                    manual.append((os.path.basename(f), k, m.group(2))); stuck += 1
                seen.append(tq)
    if cuts and APPLY:
        out = t
        for m in sorted(cuts, key=lambda x: -x.start()):
            s, e = m.start(), m.end()
            # take the comma and space that separate it from the next call, or the one before it for the last call
            if out[e:e + 2] == ', ': e += 2
            elif out[s - 2:s] == ', ': s -= 2
            out = out[:s] + out[e:]
        open(f, 'w').write(out)
    removed += len(cuts)
print(f'removed {removed}; need a rewrite {stuck}')
for f, k, q in manual: print(f'{f} [{k}] {q}')
