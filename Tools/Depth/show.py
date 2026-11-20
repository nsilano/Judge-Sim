#!/usr/bin/env python3
"""Compact view for rewriting: show.py <File.swift> <n> [<n> ...]   (n = the number after # in the id)"""
import sys, os, re
_a = sys.argv[1:]; sys.argv = ['x']
here = os.path.dirname(os.path.abspath(__file__))
import importlib.util
spec = importlib.util.spec_from_file_location('applymod', os.path.join(here, 'apply.py')); A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)
f = _a[0]; want = {f'{f}#{n}' for n in _a[1:]}
def val(b, name):
    m = re.search(r'\b' + name + r':\s*"((?:[^"\\]|\\.)*)"', b); return A.unesc('"' + m.group(1) + '"') if m else ''
for _id, key, b, _i, _j in A.calls(os.path.join(A.GAME, f)):
    if _id not in want: continue
    ev = re.findall(r'E\(\.\w+,\s*\d+,\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)', b)
    print(f'=== {_id} {key} victim={"no" if re.search(r"victim:\s*false", b) else "yes"} role={val(b,"role")} defenseRole={val(b,"defenseRole") or "-"}')
    print('NEEDS:', '; '.join(A.check(b)) or 'ok')
    print('SUM:', val(b, 'summary'))
    print('EXH:', ' | '.join(f'{t}: {d}' for t, d in ev))
    print('THEORY:', ' / '.join(A.strings(A.arg(b, 'theory', '(', ')') or '')), '| TRUTHS:', ' / '.join(A.strings(A.arg(b, 'truths', '(', ')') or '')))
    print('TIME:', ' '.join(A.strings(A.arg(b, 'timeline') or '')), '| IDENT:', val(b, 'identified'))
    for name in ('exam', 'defendant', 'defenseExam'):
        L = A.plain_lines(A.arg(b, name))
        if L: print(f'{name.upper()} ({sum(1 for l in L if l[0]=="d")}d/{sum(1 for l in L if l[0]=="c")}c):', ' || '.join(f'{l[0]}:{l[1][:70]} -> {" ".join(l[2].split()[:9])}' for l in L))
    op = A.strings(A.arg(b, 'openings', '(', ')') or ''); cl = A.strings(A.arg(b, 'closings', '(', ')') or '')
    print('OPEN:', ' || '.join(x[:90] for x in op), '| CLOSE:', ' || '.join(x[:90] for x in cl))
    print()
