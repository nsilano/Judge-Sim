#!/usr/bin/env python3
"""Duplicate scanner for the written-case bank.

  Playtest bank bank.tsv            # dump every story and follow-up (from the harness)
  python3 bank_audit.py bank.tsv                      # report near-duplicate stories and follow-ups across the bank
  python3 bank_audit.py bank.tsv --new key1,key2,...  # only pairs involving these new keys
  python3 bank_audit.py bank.tsv --probe "restaurant owner skims tip jar"   # nearest existing cases to an idea

Two cases are flagged when their headline, charge wording and summary describe the same scenario (same kind of
crime in the same kind of place with the same kind of act). The same law on its own is fine; the same scene is not.
"""
import sys, re, math, collections

STOP = set("""a an and are as at be been but by for from had has have he her his i in into is it its of on or she that the their them they this to was were which with who whom will would after before over under while than then there these those not no""".split())
GENERIC = set("""judge court deputy deputies detective sheriff office county police officer officers case state defendant defendants charged charge arrested arrest told said says say claims claim found find report reported reports later earlier day days week weeks month months year years night morning afternoon evening p.m. a.m. one two three four five six seven eight nine ten first second another again new old time times man woman someone person people""".split())

def load(path):
    rows = []
    for line in open(path, encoding="utf-8"):
        p = line.rstrip("\n").split("\t")
        if len(p) < 6: continue
        rows.append(dict(key=p[0], law=p[1], cat=p[2], head=p[3], spec=p[4], summ=p[5], role=p[6] if len(p) > 6 else "", ident=p[7] if len(p) > 7 else ""))
    return rows

def tokens(text):
    text = re.sub(r"\{[^}]*\}", " ", text.lower())
    text = re.sub(r"\$[\d,]+", " ", text)
    words = re.findall(r"[a-z][a-z'\-]+", text)
    out = []
    for w in words:
        w = w.strip("'-")
        if len(w) < 3 or w in STOP or w in GENERIC: continue
        # crude stemming so "pries", "pried", "prying" meet
        for suf in ("ing", "ied", "ies", "ed", "es", "s"):
            if w.endswith(suf) and len(w) - len(suf) >= 4:
                w = w[: -len(suf)] + ("y" if suf in ("ied", "ies") else "")
                break
        out.append(w)
    return out

def vectors(rows):
    docs = []
    for r in rows:
        # The headline and the charge carry the scenario; the summary adds detail at half weight.
        toks = tokens(r["head"]) * 3 + tokens(r["spec"]) * 2 + tokens(r["summ"]) + tokens(r["role"]) + tokens(r["ident"])
        docs.append(collections.Counter(toks))
    df = collections.Counter()
    for d in docs:
        for w in d: df[w] += 1
    n = len(docs)
    vecs = []
    for d in docs:
        v = {w: (1 + math.log(c)) * math.log((n + 1) / (df[w] + 1)) for w, c in d.items()}
        norm = math.sqrt(sum(x * x for x in v.values())) or 1
        vecs.append({w: x / norm for w, x in v.items()})
    return vecs, df

def cos(a, b):
    if len(a) > len(b): a, b = b, a
    return sum(x * b.get(w, 0) for w, x in a.items())

def shared(a, b, df, k=6):
    common = [(w, a[w] * b[w]) for w in a if w in b]
    return [w for w, _ in sorted(common, key=lambda t: -t[1])[:k]]

def is_follow(r): return ".followup." in r["key"] or r["key"].startswith("story.followup")

def main():
    if len(sys.argv) < 2: print(__doc__); return
    rows = load(sys.argv[1])
    vecs, df = vectors(rows)
    args = sys.argv[2:]
    if "--probe" in args:
        text = args[args.index("--probe") + 1]
        probe = collections.Counter(tokens(text))
        n = len(rows)
        v = {w: (1 + math.log(c)) * math.log((n + 1) / (df.get(w, 0) + 1)) for w, c in probe.items()}
        norm = math.sqrt(sum(x * x for x in v.values())) or 1
        v = {w: x / norm for w, x in v.items()}
        scored = sorted(((cos(v, vec), i) for i, vec in enumerate(vecs)), reverse=True)[:6]
        for s, i in scored:
            r = rows[i]; print(f"{s:.2f}  {r['key']:40} {r['law']:18} {r['head'][:80]}")
        return
    only = set(args[args.index("--new") + 1].split(",")) if "--new" in args else None
    threshold = float(args[args.index("--min") + 1]) if "--min" in args else 0.40
    pairs = []
    for i in range(len(rows)):
        for j in range(i + 1, len(rows)):
            a, b = rows[i], rows[j]
            if is_follow(a) != is_follow(b): continue
            if only is not None and a["key"] not in only and b["key"] not in only: continue
            s = cos(vecs[i], vecs[j])
            # The same law makes a match likelier to be a true repeat; a different law needs more overlap.
            bar = threshold if a["law"] == b["law"] else threshold + 0.12
            if s >= bar: pairs.append((s, i, j))
    pairs.sort(reverse=True)
    print(f"{len(rows)} cases scanned; {len(pairs)} possible duplicates")
    for s, i, j in pairs:
        a, b = rows[i], rows[j]
        print(f"\n{s:.2f}  {a['key']}  <->  {b['key']}   ({a['law']} / {b['law']})")
        print(f"   A: {a['head'][:100]}")
        print(f"   B: {b['head'][:100]}")
        print("   shared: " + ", ".join(shared(vecs[i], vecs[j], df)))

main()
