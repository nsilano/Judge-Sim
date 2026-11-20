#!/usr/bin/env python3
"""Apply testimony rewrites to SmallCases stories.
Usage: apply.py batch.json [--dry]
batch.json: list of {"id": "StoryCasesAT.swift#7", "exam": [["d"|"c", question, answer], ...], "defendant": [...],
  "defenseExam": [...] (only for stories that already have a defense witness), "openings": [state, defense], "closings": [state, defense]}
Answers are plain text (no surrounding quotes); the tool wraps them in quotes. Refuses the whole batch on any problem."""
import sys, re, json, os, glob
sys.argv_saved = sys.argv; _a = sys.argv[1:]
sys.argv = ['depth.py', '--noop']
src = open(os.path.join(os.path.dirname(__file__), 'depth.py')).read().replace('\nmain()\n', '\n')
exec(src)
CORPUS = {}
BAD = re.compile(r"\b(he|she|his|her|hers|him|himself|herself|man|woman|men|women|boy|girl|wife|husband|mother|father|son|daughter|brother|sister)\b", re.I)
TOK = re.compile(r'\{([^}]*)\}')
OKT = {'D', 'DL', 'V', 'DATE', 'D.he', 'D.his', 'D.him', 'D.himself', 'V.he', 'V.his', 'V.him', 'D.He', 'D.His', 'V.He', 'V.His'}
def esc(s): return s.replace('\\', '\\\\').replace('"', '\\"')
def line(l): return f'.{"direct" if l[0] == "d" else "cross"}("{esc(l[1])}", "\\"{esc(l[2])}\\"")'

def validate(e, block):
    probs = []; hasv = not re.search(r'\bvictim:\s*false', block)
    texts = []
    for name in ('exam', 'defendant', 'defenseExam'):
        L = e.get(name)
        if name == 'defenseExam' and L is None:
            if re.search(r'\bdefenseExam:\s*\[\s*\.', block): probs.append('story has a defense witness; defenseExam required')
            continue
        if name == 'defenseExam' and not re.search(r'\bdefenseRole:', block): probs.append('no defense witness to give defenseExam to'); continue
        if not L: probs.append(f'{name} missing'); continue
        d = sum(1 for l in L if l[0] == 'd'); c = sum(1 for l in L if l[0] == 'c')
        if any(l[0] not in ('d', 'c') or len(l) != 3 for l in L): probs.append(f'{name}: lines must be [d|c, q, a]')
        else:
            if len(L) < MIN['lines'] or d < MIN['direct'] or c < MIN['cross']: probs.append(f'{name}: need >= 6 direct and 5 cross, got {d}/{c}')
            avg = sum(wc(l[2]) for l in L) / len(L)
            if avg < MIN['avg']: probs.append(f'{name}: answers avg {avg:.1f} words, need >= {MIN["avg"]}')
            # direct comes before cross
            kinds = ''.join(l[0] for l in L)
            if 'cd' in kinds: probs.append(f'{name}: all direct lines must come before the cross lines')
            texts += [t for l in L for t in l[1:]]
    for name in ('openings', 'closings'):
        v = e.get(name)
        if v is None:
            cur = [unesc('"' + x + '"') for x in strings(arg(block, name, '(', ')') or '')[:2]]
            if len(cur) == 2: e[name] = cur; v = cur
        if not v or len(v) != 2: probs.append(f'{name} must be [state, defense]'); continue
        if min(wc(x) for x in v) < MIN['opening']: probs.append(f'{name}: each side needs >= {MIN["opening"]} words')
        texts += list(v)
    for name in ('exam', 'defendant', 'defenseExam'):
        for l in (e.get(name) or []):
            if len(l) == 3 and l[2].strip().lower().startswith("that's what {d}"): probs.append(f"{name}: do not open answers with \"That's what {{D}}...\"")
    for name in ('openings', 'closings'):
        v = e.get(name)
        if v and len(v) == 2 and v[1].strip().lower().startswith('the defense will show'): probs.append(f'{name}: do not start the defense text with "The defense will show"')
    for t in texts:
        for tk in TOK.findall(t):
            if tk not in OKT: probs.append(f'bad token {{{tk}}}')
        if BAD.findall(TOK.sub('', t)): probs.append(f'raw gendered word in: {t[:70]}')
        if not hasv and '{V' in t: probs.append(f'V token in a story without a victim: {t[:60]}')
        if re.search(r'\{[A-Z]+\.[a-z]+\}.*\{[A-Z]+\.[A-Z][a-z]+\}', '') : pass
    # Filler: a sentence that already appears in 3 or more other stories is boilerplate, not testimony.
    for x in set(sentences(block_new(e))):
        if CORPUS.get(x, 0) - (1 if x in e.get('_own', ()) else 0) >= 3: probs.append(f'boilerplate sentence (already in {CORPUS[x]} stories): "{x[:70]}"'); break
    return probs

def block_new(e):
    # a synthetic block holding the proposed text, for the same sentence extraction depth.py uses
    def ls(L): return '[' + ', '.join(f'.{"direct" if l[0] == "d" else "cross"}("{esc(l[1])}", "{esc(l[2])}")' for l in (L or []) if len(l) == 3) + ']'
    return ('exam: ' + ls(e.get('exam')) + ', defendant: ' + ls(e.get('defendant')) + ', defenseExam: ' + ls(e.get('defenseExam'))
            + ', openings: (' + ', '.join('"' + esc(x) + '"' for x in e.get('openings', [])) + '), closings: (' + ', '.join('"' + esc(x) + '"' for x in e.get('closings', [])) + ')')

def unesc(a):
    a = a.replace('\\"', '"').replace('\\\\', '\\')
    return a[1:-1] if len(a) >= 2 and a[0] == '"' and a[-1] == '"' else a

def plain_lines(src):
    return [['d' if k == 'direct' else 'c', unesc(q), unesc(a)] for k, q, a in lines_of(src)]

def apply_subs(e):
    # "sub": [[old, new], ...] replaces text inside any answer, opening or closing of the entry's final lists.
    for old, new in e.get('sub', []):
        hit = False
        for name in ('exam', 'defendant', 'defenseExam'):
            for l in (e.get(name) or []):
                if old in l[2]: l[2] = l[2].replace(old, new); hit = True
                if old in l[1]: l[1] = l[1].replace(old, new); hit = True
        for name in ('openings', 'closings'):
            v = e.get(name)
            if v:
                for i, t in enumerate(v):
                    if old in t: v[i] = t.replace(old, new); hit = True
        if not hit: e.setdefault('_subfail', []).append(old)

def merge_adds(e, block):
    # exam_add / defendant_add / defenseExam_add append to what is already there (directs stay before crosses).
    for name in ('exam', 'defendant', 'defenseExam'):
        add = e.get(name + '_add')
        if add is None: continue
        base = plain_lines(arg(block, name))
        front = [['d'] + list(x[1:]) for x in add if x[0] == 'D']   # kind "D": a direct question that goes first (an introduction)
        rest = [list(x) for x in add if x[0] != 'D']
        allv = front + base + rest
        e[name] = [l for l in allv if l[0] == 'd'] + [l for l in allv if l[0] == 'c']

def replace_arg(block, name, new, open_c, close_c):
    m = re.search(r'(?<![A-Za-z])' + name + r':\s*' + re.escape(open_c), block)
    if not m: return None
    i = m.end() - 1; j = balanced(block, i, open_c, close_c)
    return block[:i] + new + block[j + 1:]

def main():
    batch = json.load(open(_a[0])); dry = '--dry' in _a
    index = {}
    global CORPUS
    CORPUS = {}
    for f in sorted(glob.glob(os.path.join(GAME, 'StoryCases*.swift')) + glob.glob(os.path.join(GAME, 'StoryVariants*.swift'))):
        for _id, _k, b, _i, _j in calls(f):
            for x in set(sentences(b)): CORPUS[x] = CORPUS.get(x, 0) + 1
    for f in sorted(glob.glob(os.path.join(GAME, 'StoryCases*.swift')) + glob.glob(os.path.join(GAME, 'StoryVariants*.swift'))):
        for _id, key, block, i, j in calls(f): index[_id] = (f, key, block)
    problems = []; byfile = {}
    for e in batch:
        if e.get('id') not in index: problems.append(f'{e.get("id")}: unknown id'); continue
        f, key, block = index[e['id']]
        merge_adds(e, block)
        # existing lines must be loaded before subs so they can be edited
        for name in ('exam', 'defendant', 'defenseExam'):
            if e.get(name) is None and (name + '_add') not in e and e.get('sub') and arg(block, name):
                e[name] = plain_lines(arg(block, name))
        for name in ('openings', 'closings'):
            if e.get(name) is None and e.get('sub'):
                cur = [unesc('"' + x + '"') for x in strings(arg(block, name, '(', ')') or '')[:2]]
                if len(cur) == 2: e[name] = cur
        apply_subs(e)
        for old in e.get('_subfail', []): problems.append(f'{e["id"]}: sub text not found: {old[:50]}')
        e['_own'] = set(sentences(block))
        for p in validate(e, block): problems.append(f'{e["id"]} {key}: {p}')
        byfile.setdefault(f, []).append(e)
    if problems:
        print('\n'.join(problems)); print(f'REFUSED: {len(problems)} problems; nothing written'); sys.exit(1)
    if dry: print(f'OK (dry): {len(batch)} stories'); return
    for f, es in byfile.items():
        s = open(f).read()
        for e in es:
            # locate the current block again (earlier edits in this file move offsets)
            cur = {i_: (k, b, i, j) for i_, k, b, i, j in calls(f)}
            # calls() reads from disk; re-read after each write
            _, b, i, j = cur[e['id']]
            nb = b
            for name, key2 in (('exam', 'exam'), ('defendant', 'defendant'), ('defenseExam', 'defenseExam')):
                if name in e and e[name] is not None:
                    nb = replace_arg(nb, name, '[' + ', '.join(line(l) for l in e[name]) + ']', '[', ']') or nb
            for name in ('openings', 'closings'):
                v = e[name]; nb = replace_arg(nb, name, '("' + esc(v[0]) + '", "' + esc(v[1]) + '")', '(', ')') or nb
            s = open(f).read(); s = s[:i] + nb + s[j + 1:]; open(f, 'w').write(s)
    print(f'APPLIED {len(batch)} stories')
if __name__ == '__main__':
    import fcntl
    with open('/tmp/depth_apply.lock', 'w') as _lk:
        fcntl.flock(_lk, fcntl.LOCK_EX)   # one apply at a time, so concurrent agents never clobber a file
        main()
