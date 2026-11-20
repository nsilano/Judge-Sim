#!/usr/bin/env python3
"""Reduce stock phrasing in story testimony: varies the 'Tell the jury ...' opening questions,
the 'How do you feel ...' questions, and the 'I feel X.' leading answers. Deterministic (hash of position)."""
import re, glob, hashlib, sys

def pick(seed, options):
    h = int(hashlib.md5(seed.encode()).hexdigest(), 16)
    return options[h % len(options)]

def vary_tell(q, seed):
    m = re.fullmatch(r'Tell the jury about your work as (an? .+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['What do you do as %s?', 'Describe your work as %s.', 'What does your work as %s involve?',
                           'How would you describe your job as %s?', 'Please explain your role as %s.', 'What are your duties as %s?',
                           'Tell us about your work as %s.', 'Walk the jury through your work as %s.']) % x
    m = re.fullmatch(r'Tell the jury about your (.+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Describe your %s for the jury.', 'What can you tell us about your %s?', 'Please tell us about your %s.',
                           'Tell us about your %s.', 'Tell the jury about your %s.', 'Please describe your %s.']) % x
    m = re.fullmatch(r'Tell the jury about the (.+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Describe the %s for the jury.', 'What can you tell us about the %s?', 'Describe the %s in your own words.',
                           'Tell us about the %s.', 'Tell the jury about the %s.']) % x
    m = re.fullmatch(r'Tell the jury how (you .+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Explain to the jury how %s.', 'Walk us through how %s.', 'Tell us how %s.', 'Tell the jury how %s.']) % x
    m = re.fullmatch(r'Tell the jury what (you .+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Describe what %s.', 'Walk us through what %s.', 'Tell us what %s.', 'Tell the jury what %s.']) % x
    m = re.fullmatch(r'Tell the jury why (you .+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Explain to the jury why %s.', 'Tell us why %s.', 'Tell the jury why %s.']) % x
    m = re.fullmatch(r'Tell the jury what happened (.+)\.', q)
    if m:
        x = m.group(1)
        return pick(seed, ['Describe what happened %s.', 'Walk us through what happened %s.', 'Tell us what happened %s.']) % x
    return q

def vary_feel_q(q, seed):
    m = re.fullmatch(r'How do you feel about (.+)\?', q)
    if not m: return q
    x = m.group(1)
    return pick(seed, ['How do you feel about %s?', 'Looking back, how do you feel about %s?', 'How has this affected you?',
                       'What has %s been like for you?', 'How are you handling %s now?']) % x if False else \
           pick(seed, ['How do you feel about %s?', 'Looking back, how do you feel about %s?', 'How has this affected you?',
                       'How are you coping with what happened?']) .replace('%s', x)

def vary_feel_a(a, seed):
    m = re.match(r'I feel (\w+(?: and \w+)?)\.( .*)?$', a, re.S)
    if not m: return a
    adj, rest = m.group(1), m.group(2) or ''
    cap = adj[0].upper() + adj[1:]
    lead = pick(seed, ['I feel %s.' % adj, 'Honestly, I feel %s.' % adj, 'Right now I feel %s.' % adj,
                       '%s, more than anything.' % cap, 'I am %s.' % adj, 'Mostly I feel %s.' % adj,
                       'If I am honest, I feel %s.' % adj, 'I would say I feel %s.' % adj, 'Lately I feel %s.' % adj,
                       'The word for it is %s.' % adj])
    return lead + rest

STOCK = {
 'I should have.': ['I should have.', 'That is on me.', 'In hindsight, yes.', 'I know I should have.', 'I own that.', 'I wish I had.', 'I should have, yes.'],
 'I am sorry.': ['I am sorry.', 'I apologize.', 'I truly am sorry.', 'I am deeply sorry.', 'I am so sorry.', 'I feel awful about it.'],
 "I'm sorry.": ["I'm sorry.", 'I apologize.', 'I am truly sorry.', "I'm so sorry."],
 'I regret it.': ['I regret it.', 'I regret it deeply.', 'I regret that.', 'I regret it a lot.'],
 'I will agree with that.': ['I will agree with that.', 'That is fair.', 'I agree with that.', 'I cannot argue.'],
 'I will say that.': ['I will say that.', 'That much is true.', 'I will give you that.', 'That is accurate.'],
 'I know how it looks.': ['I know how it looks.', 'I see how it looks.', 'I understand how it looks.', 'It looks bad, I know.'],
 'I know how that looks.': ['I know how that looks.', 'I see how that looks.', 'I realize how that looks.', 'That looks bad, I know.'],
 'I know how it sounds.': ['I know how it sounds.', 'I realize how that sounds.', 'I hear how that sounds.', 'It sounds bad, I know.'],
}
def vary_stock(a, seed):
    out = a
    for k, opts in STOCK.items():
        idx = 0
        while True:
            i = out.find(k, idx)
            if i < 0: break
            ok_l = (i == 0 or out[i-1] == ' ' or out[i-2:i] == '\\"')
            ok_r = (i + len(k) == len(out) or out[i+len(k)] in ' ')
            if ok_l and ok_r:
                new = pick(seed + k + str(i), opts)
                out = out[:i] + new + out[i+len(k):]
                idx = i + len(new)
            else:
                idx = i + len(k)
    return out

def process(path):
    t = open(path).read(); n = [0, 0, 0]
    def rq(m):
        kind, q, a = m.group(1), m.group(2), m.group(3)
        seed = path + str(m.start())
        q2 = q
        if kind == 'direct':
            q2 = vary_tell(q2, seed); q2 = vary_feel_q(q2, seed + 'f')
        a2 = a
        if q.startswith('How do you feel'):
            inner = a[2:-2] if a.startswith('\\"') and a.endswith('\\"') else None
            if inner is not None:
                new = vary_feel_a(inner, seed + 'a')
                a2 = '\\"' + new + '\\"'
        if a2.startswith('\\"') and a2.endswith('\\"'):
            a3 = '\\"' + vary_stock(a2[2:-2], seed + 's') + '\\"'
            if a3 != a2: n[2] += 1
            a2 = a3
        if q2 != q: n[0] += 1
        if a2 != a: n[1] += 1
        return '.%s("%s", "%s")' % (kind, q2, a2)
    t2 = re.sub(r'\.(direct|cross)\("((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)"\)', rq, t)
    if t2 != t: open(path, 'w').write(t2)
    return n

if __name__ == '__main__':
    tot = [0, 0, 0]
    for p in sorted(glob.glob('JudgeSim/Game/Story*.swift')):
        r = process(p); tot = [a + b for a, b in zip(tot, r)]
    print('questions varied', tot[0], 'feel answers varied', tot[1], 'stock phrases varied', tot[2])
