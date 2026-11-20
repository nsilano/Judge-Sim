#!/usr/bin/env python3
"""Remove near-duplicate question/answer pairs within a witness list (keeps the longer answer).
Prints stories that drop below 6 direct / 5 cross so they can be topped up."""
import re, sys, glob, json
sys.argv = ['x', '--noop']
src = open('Tools/Depth/depth.py').read().replace('\nmain()\n', '\n')
exec(src)
stop = set("the a an of and to in was is it i that this on for with at as be by or from are had have not did do you your we our they their {d} {v} about around over than more some also when what which were been says said does isnt didnt wasnt arent".split())
def kw(s): return set(w for w in re.findall(r"[a-z]+", s.lower().replace("'", "")) if w not in stop and len(w) > 2)
def jac(a, b): return len(a & b) / max(1, len(a | b))
def first(s): return re.split(r'(?<=[.?!])\s+', s.replace('\\"', ''))[0].strip().lower()
ITEM = re.compile(r'\.(direct|cross)\("((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)"\)')
low = []
for p in sorted(glob.glob('JudgeSim/Game/Story*.swift')):
    if 'Aftermath' in p: continue
    text = open(p).read(); changed = False
    for (id_, key, block, i, j) in calls(p):
        newblock = block
        for nm in ('exam', 'defendant', 'defenseExam'):
            seg = arg(block, nm, '[', ']') or ''
            if not seg: continue
            items = [(m.group(1), m.group(2), m.group(3), m.group(0)) for m in ITEM.finditer(seg)]
            drop = set()
            for a in range(len(items)):
                for b in range(a + 1, len(items)):
                    if a in drop or b in drop: continue
                    qj = jac(kw(items[a][1]), kw(items[b][1])); aj = jac(kw(items[a][2]), kw(items[b][2]))
                    if qj >= 0.8 or (qj >= 0.6 and aj >= 0.35) or (qj >= 0.5 and aj >= 0.55) or (first(items[a][2]) == first(items[b][2]) and len(first(items[a][2]).split()) >= 6):
                        # drop the one with the shorter answer
                        d = a if len(items[a][2]) < len(items[b][2]) else b
                        drop.add(d)
            if not drop: continue
            seg2 = seg
            for d in sorted(drop):
                raw = items[d][3]
                seg2 = seg2.replace(raw + ', ', '', 1) if (raw + ', ') in seg2 else seg2.replace(', ' + raw, '', 1) if (', ' + raw) in seg2 else seg2.replace(raw, '', 1)
            newblock = newblock.replace(seg, seg2, 1)
            kinds = [it[0] for k, it in enumerate(items) if k not in drop]
            dn, cn = kinds.count('direct'), kinds.count('cross')
            if dn < 6 or cn < 5: low.append((id_, key, nm, dn, cn))
        if newblock != block:
            text = text.replace(block, newblock, 1); changed = True
    if changed: open(p, 'w').write(text)
json.dump(low, open('/tmp/lowafter.json', 'w'))
print('stories needing top-up after dedupe:', len(low))
