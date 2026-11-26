#!/usr/bin/env python3
"""Finds questions asked twice, in nearly the same words, in one examination of one witness (same phase: two directs or two
crosses). Usage: nearly.py [--list]. Reports how many there are; --list prints each with its file."""
import re, glob, os, sys, collections
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'JudgeSim', 'Game')
PAT = re.compile(r'\.(direct|cross|redirect)\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')
STOP = set("a an the of to and or in on at for with by is was were are be been did do does you your didn't don't not it that this i he she they".split())
def toks(q):
    q = re.sub(r'\{[^}]*\}', ' X ', q.lower())
    return frozenset(x for x in re.findall(r"[a-z0-9$]+", q) if x not in STOP)
def sim(a, b): return len(a & b) / min(len(a), len(b)) if a and b else 0
# Words that open almost every question ("what did you say/tell/see ...") carry no subject; two questions repeat each other
# only when the words that name the subject (or the answers' content words) overlap.
GEN = set("what say said tell told would then else happen happened find found see saw after before about please jury x who why how when where which also really exactly actually now have has had were are this that".split())
def content(t):
    t = re.sub(r'\{[^}]*\}', ' ', t.lower())
    return frozenset(w for w in re.findall(r"[a-z0-9$]+", t) if len(w) > 2 and w not in GEN and w not in STOP)
def repeats(q1, a1, q2, a2):
    c1, c2 = content(q1), content(q2)
    if len(c1) >= 2 and len(c2) >= 2 and sim(c1, c2) >= 0.75: return True
    d1, d2 = content(a1), content(a2)
    return len(d1) >= 4 and len(d2) >= 4 and sim(d1, d2) >= 0.6
def toks_ok(q1, q2):
    a, b = toks(q1), toks(q2)
    return len(a) >= 2 and len(b) >= 2 and sim(a, b) >= 0.8
found = []
for f in sorted(glob.glob(os.path.join(ROOT, 'Story*.swift')) + glob.glob(os.path.join(ROOT, 'FollowUp*.swift'))):
    t = open(f).read(); run = []; prev = 0
    def check(run):
        by = collections.defaultdict(list)
        for k, q, a in run: by[k].append((q, a))
        for k, qs in by.items():
            seen = []
            for q, a in qs:
                if any(toks_ok(q, x[0]) and repeats(q, a, x[0], x[1]) for x in seen):
                    found.append((os.path.basename(f), k, q))
                seen.append((q, a))
    for m in PAT.finditer(t):
        gap = t[prev:m.start()]
        if prev and (']' in gap or 'exam' in gap.lower() or 'defendant:' in gap): check(run); run = []
        run.append((m.group(1), m.group(2), m.group(3))); prev = m.end()
    check(run)
print(f'NEAR-DUPLICATE QUESTIONS: {len(found)}')
if '--list' in sys.argv:
    for f, k, q in found: print(f'{f} [{k}] {q}')
