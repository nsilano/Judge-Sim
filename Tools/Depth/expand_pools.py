#!/usr/bin/env python3
"""Adds lines to fixed lists in the game's Swift code.
Usage: expand_pools.py additions.py [--dry]
additions.py defines ADDITIONS = [(file, anchor, [new line, ...]), ...]. The anchor is the start of the list's FIRST line
(after its opening quote) and must be unique in the file. New lines are raw text: \\(var) interpolation is kept, a bare double
quote is escaped. Nothing is changed unless every anchor is found exactly once and the list is made only of string literals."""
import sys, os, re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'JudgeSim', 'Game')

def scan(t, k):
    depth = 1; instr = False; esc = False; p = k
    while p < len(t) and depth > 0:
        c = t[p]
        if instr:
            if esc: esc = False
            elif c == '\\':
                if t[p + 1] == '(':
                    d = 1; q = p + 2
                    while d > 0:
                        if t[q] == '(': d += 1
                        elif t[q] == ')': d -= 1
                        q += 1
                    p = q; continue
                esc = True
            elif c == '"': instr = False
        else:
            if c == '"': instr = True
            elif c == '[': depth += 1
            elif c == ']':
                depth -= 1
                if depth == 0: return p
        p += 1
    return -1

def literal(text):
    out = ''
    i = 0
    while i < len(text):
        c = text[i]
        if c == '\\' and i + 1 < len(text): out += text[i:i + 2]; i += 2; continue
        out += '\\"' if c == '"' else c
        i += 1
    return '"' + out + '"'

def main():
    ns = {}
    exec(open(sys.argv[1]).read(), ns)
    dry = '--dry' in sys.argv
    byfile = {}
    for item in ns['ADDITIONS']:
        f, anchor, lines = item[:3]
        byfile.setdefault(f, []).append((anchor, lines, item[3] if len(item) > 3 else None))
    added = 0; bad = []
    for f, items in byfile.items():
        path = os.path.join(ROOT, f)
        t = open(path).read()
        edits = []
        for anchor, lines, which in items:
            needle = '"' + anchor
            n = t.count(needle)
            if which is None and n != 1: bad.append(f'{f}: anchor found {n} times: {anchor[:60]}'); continue
            if which is not None and n < which: bad.append(f'{f}: anchor occurrence {which} missing: {anchor[:60]}'); continue
            at = -1
            for _ in range(which or 1): at = t.index(needle, at + 1)
            # the list's opening bracket sits just before the first element
            b = t.rfind('[', 0, at)
            if b < 0 or t[b + 1:at].strip() != '': bad.append(f'{f}: not the first line of a list: {anchor[:60]}'); continue
            end = scan(t, b + 1)
            if end < 0: bad.append(f'{f}: list never closes: {anchor[:60]}'); continue
            inner = t[b + 1:end]
            if re.search(r'^\s*(?!")\S', inner.replace('\n', '\n'), re.M) and False: pass
            edits.append((end, lines, anchor))
        for end, lines, anchor in sorted(edits, reverse=True):
            # keep the existing indentation of the closing line
            ls = t.rfind('\n', 0, end) + 1
            indent = re.match(r'\s*', t[ls:end]).group(0) if t[ls:end].strip() == '' else ''
            body = ',\n'.join((indent or '    ') + literal(x) for x in lines) if indent else ', ' + ', '.join(literal(x) for x in lines)
            if indent:
                head = t[:end].rstrip()
                sep = '' if head.endswith(',') else ','
                t = head + sep + '\n' + body + '\n' + indent + t[end:]
            else:
                head = t[:end].rstrip()
                sep = '' if head.endswith(',') else ','
                t = head + sep + ' ' + ', '.join(literal(x) for x in lines) + t[end:]
            added += len(lines)
        if not bad and not dry: open(path, 'w').write(t)
    for b in bad: print('PROBLEM', b)
    print(('DRY ' if dry else '') + f'{added} lines added to {sum(len(v) for v in byfile.values())} lists' + ('; nothing written because of problems' if bad else ''))
    sys.exit(1 if bad else 0)

main()
