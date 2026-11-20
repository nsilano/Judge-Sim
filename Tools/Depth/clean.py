#!/usr/bin/env python3
"""Mechanical cleanup: strip filler sentences (sentence reused in 5+ stories), drop the "That's what {D}..." answer opener
sentence, and vary "The defense will show" openers. Leaves anything it cannot fix cleanly for hand work. Usage: clean.py [--dry]"""
import sys, re, os, glob, collections
sys.argv_saved = sys.argv
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
_argv = sys.argv; sys.argv = ['apply.py']
import importlib.util
spec = importlib.util.spec_from_file_location('applymod', os.path.join(here, 'apply.py')); A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)
sys.argv = _argv
GAME = A.GAME

def unesc(a):
    a = a.replace('\\"', '"').replace('\\\\', '\\')
    return a[1:-1] if len(a) >= 2 and a[0] == '"' and a[-1] == '"' else a

def plain_lines(src):
    return [['d' if k == 'direct' else 'c', unesc(q), unesc(a)] for k, q, a in A.lines_of(src)]

SPLIT = re.compile(r'(?<=[.!?])\s+')
VARY = ["Jurors will hear that", "The defense evidence will establish that", "By the end of this trial, the proof will show that",
        "The defense will present evidence that", "The defense witnesses will explain that", "Listen for the defense evidence, which will show that",
        "The defense case is that", "Weigh the defense proof, which will show that"]
VARY_NOUN = ["The defense will present", "Jurors will also see", "The defense evidence includes", "The defense will point you to"]

def fix_text(t, boiler):
    parts = SPLIT.split(t.strip())
    kept = [p for p in parts if p.strip().lower() not in boiler]
    return ' '.join(kept).strip() if kept else t

def fix_answer(a, boiler):
    a = fix_text(a, boiler)
    parts = SPLIT.split(a)
    if len(parts) > 1 and re.match(r"that's what \{d\}", parts[0].strip().lower()) and len(' '.join(parts[1:]).split()) >= 8:
        a = ' '.join(parts[1:])
    return a

def fix_defense_opener(t, n):
    m = re.match(r'(?i)the defense will show (that |a |an |the |how |why )?(.*)', t, re.S)
    if not m: return t
    lead = (m.group(1) or '').lower().strip(); rest = m.group(2)
    if lead == 'that':
        return VARY[n % len(VARY)] + ' ' + rest
    return VARY_NOUN[n % len(VARY_NOUN)] + ' ' + (m.group(1) or '') + rest

def main():
    dry = '--dry' in sys.argv
    files = sorted(glob.glob(os.path.join(GAME, 'StoryCases*.swift')) + glob.glob(os.path.join(GAME, 'StoryVariants*.swift')))
    where = collections.defaultdict(set)
    for f in files:
        for _id, k, b, _i, _j in A.calls(f):
            for x in set(A.sentences(b)): where[x].add(_id)
    boiler = {x for x, ids in where.items() if len(ids) >= 5}
    changed = 0; n = 0
    for f in files:
        for _id, k, b, i, j in list(A.calls(f)):
            n += 1; nb = b; touched = False
            for name in ('exam', 'defendant', 'defenseExam'):
                src = A.arg(nb, name)
                if not src: continue
                L = plain_lines(src)
                new = [[kd, q, fix_answer(a, boiler)] for kd, q, a in L]
                if new != L:
                    nb = A.replace_arg(nb, name, '[' + ', '.join(A.line(l) for l in new) + ']', '[', ']'); touched = True
            for name in ('openings', 'closings'):
                src = A.arg(nb, name, '(', ')')
                if not src: continue
                v = [unesc('"' + x + '"') for x in A.strings(src)[:2]]
                if len(v) < 2: continue
                new = [fix_text(v[0], boiler), fix_defense_opener(fix_text(v[1], boiler), n)]
                if new != v:
                    nb = A.replace_arg(nb, name, '("' + A.esc(new[0]) + '", "' + A.esc(new[1]) + '")', '(', ')'); touched = True
            if touched:
                changed += 1
                if not dry:
                    s = open(f).read(); cur = {i_: (b_, ii, jj) for i_, k_, b_, ii, jj in A.calls(f)}
                    _, ii, jj = cur[_id]; open(f, 'w').write(s[:ii] + nb + s[jj + 1:])
    print(('would change' if dry else 'changed'), changed, 'of', n, 'stories')
main()
