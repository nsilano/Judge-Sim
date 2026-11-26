#!/usr/bin/env python3
"""Testimony-depth gate for written stories (SmallCases.make calls).
Usage: depth.py [files...]  (default: all StoryCases*/StoryVariants*.swift). Prints failing stories; exit 1 if any."""
import re, sys, glob, os, collections
GAME = os.path.join(os.path.dirname(__file__), '..', '..', 'JudgeSim', 'Game')

def balanced(s, i, open_c, close_c):
    depth = 0; j = i; instr = False
    while j < len(s):
        c = s[j]
        if instr:
            if c == '\\': j += 2; continue
            if c == '"': instr = False
        else:
            if c == '"': instr = True
            elif c == open_c: depth += 1
            elif c == close_c:
                depth -= 1
                if depth == 0: return j
        j += 1
    return -1

def arg(block, name, open_c='[', close_c=']'):
    m = re.search(r'\b' + name + r':\s*' + re.escape(open_c), block)
    if not m: return None
    i = m.end() - 1
    j = balanced(block, i, open_c, close_c)
    return block[i:j + 1] if j > 0 else None

def strings(s):
    return [x for x in re.findall(r'"((?:[^"\\]|\\.)*)"', s)]

def wc(t): return len(re.sub(r'\\"', '', t).split())

def lines_of(exam_src):
    # each .direct("q", "a") / .cross("q", "a") -> (kind, q, a)
    out = []
    for m in re.finditer(r'\.(direct|cross)\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*"((?:[^"\\]|\\.)*)"\s*\)', exam_src or ''):
        out.append((m.group(1), m.group(2), m.group(3)))
    return out

BOILER = set()
MIN = dict(lines=11, direct=6, cross=5, avg=12, opening=22, closing=22)

def sentences(block):
    txt = []
    for name in ('exam', 'defendant', 'defenseExam'): txt += [l[2] for l in lines_of(arg(block, name))]
    for name in ('openings', 'closings'): txt += strings(arg(block, name, '(', ')') or '')
    out = []
    for t in txt:
        for sent in re.split(r'(?<=[.!?])\s+', t.replace('\\"', '')):
            x = sent.strip().lower()
            if len(x.split()) >= 6: out.append(x)
    return out

def check(block):
    probs = []
    bad = [x for x in set(sentences(block)) if x in BOILER]
    if bad: probs.append(f'boilerplate sentence reused across stories: "{bad[0][:60]}"')
    for name in ('exam', 'defendant') + (('defenseExam',) if re.search(r'\bdefenseExam:', block) else ()):
        L = lines_of(arg(block, name))
        if not L: probs.append(f'{name}: none'); continue
        d = sum(1 for l in L if l[0] == 'direct'); c = len(L) - d
        avg = sum(wc(l[2]) for l in L) / len(L)
        if len(L) < MIN['lines'] or d < MIN['direct'] or c < MIN['cross']: probs.append(f'{name}: {d} direct/{c} cross')
        if avg < MIN['avg']: probs.append(f'{name}: answers avg {avg:.0f} words')
    for name in ('exam', 'defendant', 'defenseExam'):
        for l in lines_of(arg(block, name)):
            if l[2].replace('\\"', '').strip().lower().startswith("that's what {d}"): probs.append(f"{name}: formulaic answer opener \"That's what {{D}}...\""); break
    for name, mn in (('openings', MIN['opening']), ('closings', MIN['closing'])):
        a = arg(block, name, '(', ')')
        s = strings(a or '')
        if len(s) < 2: probs.append(f'{name}: missing'); continue
        if s[1].strip().lower().startswith('the defense will show'): probs.append(f'{name}: formulaic defense opener "The defense will show"')
        if min(wc(x) for x in s[:2]) < mn: probs.append(f'{name}: {min(wc(x) for x in s[:2])} words')
    return probs

def stories(path):
    """Yields (key, block) for every SmallCases.make call in the file, in order."""
    for _id, key, block, _i, _j in calls(path): yield key, block

def calls(path):
    s = open(path).read(); n = 0
    for m in re.finditer(r'(?:SmallCases\.make|\bfollowUp)\(', s):
        i = m.end() - 1; j = balanced(s, i, '(', ')')
        if j < 0: continue
        block = s[i:j + 1]
        k = re.search(r'key:\s*"([A-Za-z0-9.]+)"', block)
        if not k: continue
        n += 1
        yield f'{os.path.basename(path)}#{n}', k.group(1), block, i, j

def main():
    if len(sys.argv) > 2 and sys.argv[1] == '--show':
        # depth.py --show File.swift [id ...]: print the raw blocks (id header, key) for the ids (default all).
        path = sys.argv[2]; want = set(sys.argv[3:])
        for _id, key, block, _i, _j in calls(os.path.join(GAME, path)):
            if not want or _id in want: print(f'=== {_id} {key}\n{block}\n')
        return
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(GAME, 'StoryCases*.swift')) + glob.glob(os.path.join(GAME, 'StoryVariants*.swift')) + glob.glob(os.path.join(GAME, 'FollowUpCases*.swift')))
    # Any sentence used in 5+ different stories is filler, not testimony.
    where = collections.defaultdict(set)
    for f in sorted(glob.glob(os.path.join(GAME, 'StoryCases*.swift')) + glob.glob(os.path.join(GAME, 'StoryVariants*.swift')) + glob.glob(os.path.join(GAME, 'FollowUpCases*.swift'))):
        for _id, _k, b, _i, _j in calls(f):
            for x in set(sentences(b)): where[x].add(_id)
    BOILER.update(x for x, ids in where.items() if len(ids) >= 5)
    total = bad = 0; per = collections.Counter()
    for f in files:
        for _id, key, block, _i, _j in calls(f):
            total += 1
            p = check(block)
            if p:
                bad += 1; per[os.path.basename(f)] += 1
                print(f'{_id} {key}: ' + '; '.join(p))
    print(f'SUMMARY {bad} of {total} stories below depth', file=sys.stderr)
    if '--by-file' in os.environ.get('DEPTH_OPTS', ''):
        for f, n in per.most_common(): print(f, n, file=sys.stderr)
    import subprocess
    st = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'statements.py'), '--list'], capture_output=True, text=True)
    sys.stdout.write(st.stdout)
    print(st.stdout.strip().split('\n')[-1].replace('STATEMENTS:', 'SENTENCING STATEMENTS:'), file=sys.stderr)
    sys.exit(1 if (bad or st.returncode) else 0)
main()
