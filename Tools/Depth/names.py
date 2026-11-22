#!/usr/bin/env python3
"""Stops testimony from using the defendant's full name in every sentence.
Usage: names.py [--apply] [--answers-only]   (dry run by default; prints counts and samples)
Run --apply ONCE on committed text: the question rule counts from the start of each examination, so a second run would convert more.
Rules (story testimony in JudgeSim/Game/Story*.swift and FollowUp*.swift):
 - Answers: the first {D} in an answer stays; a later one becomes a pronoun ({D.he}, {D.him}, {D.his}) when the sentence and the one
   before it name no one else, otherwise it stays.
 - Camera and video answers that start with a bare "{D} <verb>ing ..." get "It shows " in front so they are full sentences.
 - Questions: after the first question that names the defendant in a witness's examination, later ones say "the defendant"
   (every third keeps the name)."""
import re, glob, os, sys, random
APPLY = '--apply' in sys.argv
ANSWERS_ONLY = '--answers-only' in sys.argv
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'JudgeSim', 'Game')
PAT = re.compile(r'\.(direct|cross|redirect)\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')
OTHER = re.compile(r'\{(?!D\}|D\.|DL\}|DATE\})[A-Z]')   # a token naming someone else
SUBJ = re.compile(r"(?:^|[.!?]\s+|\\\"|,\s+|\b(?:that|and|but|when|as|while|because|if|so|until|before|after|since|though|then|once|say|think|believe|know|guess|feel|doubt|remember|recall|noticed|mean|tell|suppose|says|said|what|who|how|where|which|why|whether|why|since|though|although|unless|like)\s+)$", re.I)
VERB = re.compile(r"^(?:was|were|had|has|did|didn't|didn’t|never|said|told|pulled|ran|came|went|stayed|looked|seemed|kept|took|made|got|gave|put|stood|walked|asked|opened|left|turned|started|stopped|tried|wanted|knew|wasn't|wouldn't|couldn't|hadn't|can|could|would|will|is|are|began|looks|seems|did|signed|paid|called|admitted|denied|answered|replied|agreed|apologized|shouted|yelled|grabbed|swung|struck|hit|threw|dropped|picked|held|reached|pointed|handed|stood|sat)\b")
OBJ_PREV = re.compile(r"\b(?:to|told|asked|with|from|remove|removed|walked|handed|gave|saw|heard|let|stopped|arrested|grabbed|held|followed|watched|called|ordered|warned|showed|for|at|behind|against|toward|towards|about|after|beside|near|escorted|drove|took|stopped|restrained|released|searched|questioned|interviewed|asked)\s+$")
OBJ_NEXT = re.compile(r"^(?:[.,;:!?\\]|\s+(?:to|that|from|into|out|back|in|by|and|or|but|for|at|on|up|down|away|if|before|after|again|home|outside|inside|there|here|what|why|how|whether|about|with|when|while|during|so|because|until|since|over|around|near|last|all|every|this|that|toward|towards|through|across|off|onto|upon|where|who|which|as|than|then|once|twice|enter|leave|get|go|do|say)\b|$)")
STOP = re.compile(r"^(?:and|or|but|who|whose|from|of|in|at|on|with|to|the|a|an|for|by|as|than|then|v\.?)\b")
VERBISH = re.compile(r"(?:ed|saw|took|gave|heard|hire|know|knew|met|told|let|hit|held|found|left|caught|trust|believe|see|help|watch|meet|find|call|ask|tell|stop|follow|pay|hurt|push|shove|grab|pull|drop|bring|take|give|get|got|put|keep|kept|send|sent|show|lend|lent|leave|sell|sold)\s+$")
AMBIG = re.compile(r"\b(?:someone|anyone|somebody|anybody|person|man|woman|men|women|boy|girl|kid|kids|they|them|officer|officers|nurse|guard|deputy|neighbor|neighbour|driver|clerk|manager|owner|friend|customer|employee|teacher|mother|father|wife|husband|brother|sister|son|daughter|trooper|detective|witness|victim|caller|cashier|worker|supervisor|boss|landlord|tenant|agent|passenger|passengers|group|people)\b", re.I)
CAM_Q = re.compile(r"camera|video|footage|recording|clip|tape|photo", re.I)

def sentences_before(a, pos):
    head = a[:pos]
    parts = re.split(r'(?<=[.!?])\s+', head)
    return parts[-2:] if len(parts) >= 2 else parts

def fix_answer(q, a, skip_first=False):
    # a is the Swift string contents: \"...\"
    changes = 0
    # fragment: a bare {D} + -ing verb at the start of a camera answer
    m = re.match(r'^(\\")\{D\} ([a-z]+ing)\b', a)
    if m and CAM_Q.search(q):
        a = a[:2] + 'It shows ' + a[2:]; changes += 1
    elif m:
        ql = q.lower()
        lead = ('It showed ' if re.search(r'\bdid\b', ql) else 'It shows ') if re.search(r'record|film|capture|dashcam|camera|video|footage', ql) else 'I saw ' if re.match(r'what (?:did|do) you (?:see|saw)', ql) else 'I found ' if re.match(r'what did you find', ql) else 'It showed ' if re.search(r'\bshow(?:ed)?\b', ql) and re.search(r'\bdid\b', ql) else 'It shows ' if re.search(r'\bshows?\b', ql) else 'I saw ' if re.search(r'\b(?:see|saw|witness)\b', ql) else None
        if lead:
            a = a[:2] + lead + a[2:]; changes += 1
        else:
            print('UNFIXED FRAGMENT:', q[:80], a[:90])
    a0 = a
    idxs = [m.start() for m in re.finditer(r"\{D\}", a)]
    out, last, n = [], 0, 0
    if skip_first and OTHER.search(q):
        return a, changes
    for i in idxs:
        n += 1
        if n == 1 and not skip_first:
            continue
        sent = sentences_before(a, i + 3)
        window = ' '.join(sent)
        if OTHER.search(window) or re.search(r"\{DL\}|\{DF\}", window): 
            continue
        prev, nxt = a[:i], a[i + 3:]
        cur = re.split(r'(?<=[.!?])\s+', a[:i] + ' ' + a[i:])
        here = ' '.join(re.split(r'(?<=[.!?])\s+', a[:i])[-1:]) + ' ' + re.split(r'(?<=[.!?])\s+', a[i:])[0]
        if AMBIG.search(here):
            continue
        poss = nxt.startswith("'s ") or nxt.startswith("’s ")
        if poss:
            out.append((i, i + 5, '{D.his}')); continue
        if SUBJ.search(prev) and nxt.startswith(' ') and re.match(r"^[a-z][a-z']*", nxt.lstrip()) and not STOP.match(nxt.lstrip()):
            cap = bool(re.search(r"(?:^|[.!?]\s+|\\\")$", prev))
            out.append((i, i + 3, '{D.He}' if cap else '{D.he}')); continue
        if (OBJ_PREV.search(prev) or VERBISH.search(prev)) and (OBJ_NEXT.match(nxt) or re.match(r'^\s+(?:again|too|anymore|either|twice|like)\b', nxt)):
            out.append((i, i + 3, '{D.him}')); continue
    # In a later answer every mention changes or none does, so one answer never mixes the name and a pronoun.
    if skip_first and len(out) < len(idxs):
        return a0, changes
    for s, e, rep in reversed(out):
        a = a[:s] + rep + a[e:]; changes += 1
    return a, changes

def fix_question(q, run_state):
    if '{D}' not in q:
        return q, 0
    run_state['n'] += 1
    if run_state['n'] == 1:
        return q, 0
    if run_state['n'] % 3 == 0:
        return q, 0
    if q.count('{D}') > 1:
        return q, 0
    new = q
    if new.startswith('{D}'):
        new = 'The defendant' + new[3:] if False else new   # leave a question that starts with the name
        if new == q: return q, 0
    new = new.replace("{D}'s", "the defendant's").replace("{D}’s", "the defendant’s").replace('{D}', 'the defendant')
    return new, 1

tot = {'a': 0, 'q': 0, 'files': 0}
samples = []
for f in sorted(glob.glob(os.path.join(ROOT, 'Story*.swift')) + glob.glob(os.path.join(ROOT, 'FollowUp*.swift'))):
    text = open(f).read()
    out, last = [], 0
    run = {'n': 0}
    prev_end = 0
    changed = 0
    for m in PAT.finditer(text):
        gap = text[prev_end:m.start()]
        if prev_end and (']' in gap or 'exam' in gap.lower() or 'defendant:' in gap or 'witness' in gap.lower()):
            run = {'n': 0}
        prev_end = m.end()
        q, a = m.group(2), m.group(3)
        nq, cq = fix_question(q, run) if (m.group(1) != 'redirect' and not ANSWERS_ONLY) else (q, 0)
        later = run.get('intro', False)
        na, ca = fix_answer(q, a, skip_first=later)
        if '{D}' in a or '{D.' in a: run['intro'] = True
        if cq or ca:
            changed += 1
            tot['q'] += cq; tot['a'] += ca
            if len(samples) < 400 and (ca or cq) : samples.append((os.path.basename(f), q, nq, a, na))
            out.append(text[last:m.start()]); last = m.end()
            out.append(f'.{m.group(1)}("{nq}", "{na}")')
    if changed:
        tot['files'] += 1
        if APPLY:
            out.append(text[last:])
            open(f, 'w').write(''.join(out))
print(tot)
random.seed(3)
for fn, q, nq, a, na in random.sample(samples, min(18, len(samples))):
    print('---', fn)
    if q != nq: print('Q:', q, '\n  ->', nq)
    if a != na: print('A:', a[:200], '\n  ->', na[:200])

# ---- finishing step: python3 Tools/Depth/names.py --finish [--apply]
# Whatever full names are left in a witness's answers after the first one become the last name (State's witnesses) or the first
# name (defense witnesses, who are usually friends, neighbors or relatives). The defendant's own testimony is left alone.
if '--finish' in sys.argv:
    KEY = re.compile(r'\b(exam|defenseExam|defendant)\s*:\s*\[')
    fin = {'a': 0, 'files': 0}
    samples2 = []
    for f in sorted(glob.glob(os.path.join(ROOT, 'Story*.swift')) + glob.glob(os.path.join(ROOT, 'FollowUp*.swift'))):
        text = open(f).read()
        keys = [(k.start(), k.group(1)) for k in KEY.finditer(text)]
        out, last, run_key, seen, prev_end, changed = [], 0, None, False, 0, 0
        for m in PAT.finditer(text):
            gap = text[prev_end:m.start()]
            if prev_end == 0 or ']' in gap or KEY.search(gap):
                kk = [k for pos, k in keys if pos <= m.start()]
                run_key = kk[-1] if kk else None
                seen = False
            prev_end = m.end()
            if run_key in (None, 'defendant'):
                continue
            a = m.group(3)
            if '{D}' not in a:
                continue
            token = '{DF}' if run_key == 'defenseExam' else '{DL}'
            parts = a.split('{D}')
            if seen:
                na = token.join(parts)
            else:
                na = parts[0] + '{D}' + token.join(parts[1:])
                seen = True
            if na != a:
                fin['a'] += 1; changed += 1
                if len(samples2) < 300: samples2.append((os.path.basename(f), run_key, a, na))
                out.append(text[last:m.start()]); last = m.end()
                out.append(f'.{m.group(1)}("{m.group(2)}", "{na}")')
        if changed:
            fin['files'] += 1
            if APPLY:
                out.append(text[last:])
                open(f, 'w').write(''.join(out))
    print('FINISH', fin)
    random.seed(9)
    for fn, k, a, na in random.sample(samples2, min(14, len(samples2))):
        print('---', fn, k); print('  ', a[:210]); print('->', na[:210])
