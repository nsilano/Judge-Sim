#!/usr/bin/env python3
"""Validate and convert story JSON written by another model.

  python3 ingest.py check   file.json [--small]       validate only
  python3 ingest.py convert file.json out.py [--small]  validate + write Python data (list named STORIES)
  python3 ingest.py used [law]                          list existing headlines (paste into the prompt's 'already used')
"""
import json, re, sys, glob, os
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
KINDS = {"physical", "forensic", "digital", "document", "statement", "video"}
CATS = {"property", "traffic", "publicOrder", "whiteCollar", "violent", "robbery", "drugs", "family", "cyber"}
MOODS = {"wantsConviction", "sympathetic", "divided", "indifferent"}
TOKEN = re.compile(r"\{(D|DL|V|DATE|PRIORDATE|PRIOR|D\.\w+|V\.\w+)\}")
ALLOWED_PRON = {"he", "He", "his", "His", "him", "Him", "himself", "himself", "she", "She", "her", "Her"}
RAW = re.compile(r"\b(he|she|his|her|him|himself|herself)\b", re.I)

def laws():
    t = open(f"{ROOT}/JudgeSim/Models/LawLibrary.swift").read()
    t = t[:t.index('id: "juryWaiver"')]
    return set(re.findall(r'Law\(id: "(\w+)"', t))

def existing_keys():
    ks = set()
    for f in glob.glob(f"{ROOT}/JudgeSim/Game/StoryCases*.swift") + glob.glob(f"{ROOT}/JudgeSim/Game/FollowUpCases*.swift"):
        ks |= {k.split(".")[-1] for k in re.findall(r'key: "([\w.]+)"', open(f).read())}
    return ks

def strings(d, path=""):
    if isinstance(d, str): yield path, d
    elif isinstance(d, dict):
        for k, v in d.items(): yield from strings(v, f"{path}.{k}")
    elif isinstance(d, list):
        for i, v in enumerate(d): yield from strings(v, f"{path}[{i}]")

def check(d, small, L, taken):
    e = []
    k = d.get("key", "?")
    need = (["key","category","headline","law","spec","has_victim","summary","state_evidence","defense_evidence","witness_role","witness_exam","theory","truth_guilty","truth_innocent","defendant_exam","timeline"] if small else
            ["key","category","headlines","law","spec","has_victim","summary","state_evidence","defense_evidence","witness_role","witness_exam","theory","allocution","truth_guilty","truth_innocent","defendant_exam","opening","closing","timeline","how_identified","mood","threshold"])
    for f in need:
        if f not in d: e.append(f"missing {f}")
    if e: return k, e
    if k in taken: e.append("key already exists")
    if not re.fullmatch(r"[a-z][A-Za-z0-9]+", k): e.append("key must be camelCase letters/digits")
    if d["category"] not in CATS: e.append(f"bad category {d['category']}")
    if d["law"] not in L: e.append(f"unknown law id {d['law']}")
    if d.get("mood", "indifferent") not in MOODS: e.append("bad mood")
    ev = [d["state_evidence"]] if small else d["state_evidence"]
    for x in ev + ([d["defense_evidence"]] if small else d["defense_evidence"]):
        if "kind" in x and x["kind"] not in KINDS: e.append(f"bad evidence kind {x['kind']}")
    for name in ("witness_exam", "defendant_exam"):
        ex = d[name]
        if small and [x.get("side") for x in ex] != ["direct", "cross"]: e.append(f"{name} must be exactly [direct, cross]")
        if not small and len(ex) < 4: e.append(f"{name} needs 4 entries")
        for x in ex:
            if x.get("side") not in ("direct", "cross") or not x.get("q") or not x.get("a"): e.append(f"{name} entry malformed")
    if len(d["timeline"]) < (2 if small else 4): e.append("timeline too short")
    if not small and not (6 <= d["threshold"] <= 9): e.append("threshold must be 6-9")
    if not small:
        w = sum(x.get("weight", 0) for x in d["state_evidence"])
        if w < d["threshold"] - 1: e.append(f"State weight {w} is too low for threshold {d['threshold']}")
    txt = "\n".join(s for p, s in strings(d))
    vic = bool(TOKEN.findall(txt) and re.search(r"\{V(\.\w+)?\}", txt))
    if d["has_victim"] and not vic: e.append("has_victim true but no {V} token")
    if not d["has_victim"] and vic: e.append("has_victim false but {V} token used")
    for p, s in strings(d):
        for m in re.findall(r"\{[^}]*\}", s):
            if not TOKEN.fullmatch(m) or (m.startswith("{D.") or m.startswith("{V.")) and m.split(".")[1][:-1] not in {x.lower() for x in ALLOWED_PRON} | {"He","His","Him","Himself","himself"}:
                e.append(f"bad token {m} at {p}")
        if p.split(".")[-1] not in ("source",) and RAW.search(re.sub(r"\{[^}]*\}", "", s)) and p.split(".")[1] in ("headline","headlines","spec","summary","theory","truth_guilty","truth_innocent","timeline","how_identified","state_evidence","defense_evidence"):
            e.append(f"raw pronoun in {p}: {s[:60]}")
        if "\\" in s: e.append(f"backslash in {p}")
    if "source" in d:
        if d["source"] not in taken: e.append(f"source {d['source']} not found")
        if not d["summary"][:1].islower() and not d["summary"].startswith("{"): e.append("follow-up summary should start lowercase")
    return k, e

def convert(d, small):
    ev = lambda x, w: tuple([x["kind"], w, x["title"], x["detail"]] + (["search"] if x.get("searched") else []))
    ex = lambda L: [("d" if x["side"] == "direct" else "c", x["q"], x["a"]) for x in L]
    pre = "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, " if "source" in d else ""
    if small:
        out = dict(k=d["key"], cat=d["category"], h=[d["headline"]], law=d["law"], spec=d["spec"], ages=(18, 60), v=d["has_victim"],
                   sum=pre + d["summary"], st=[ev(d["state_evidence"], 3)],
                   df=[("statement", 1, d["defense_evidence"]["title"], d["defense_evidence"]["detail"])], role=d["witness_role"],
                   ex=ex(d["witness_exam"]), th=(d["theory"]["state"], d["theory"]["defense"]), al="I'm sorry.",
                   tr=(d["truth_guilty"], d["truth_innocent"]), de=ex(d["defendant_exam"]),
                   op=(d["theory"]["state"], d["theory"]["defense"]), cl=(d["theory"]["state"], d["theory"]["defense"]),
                   tl=[(x["day"], x["text"]) for x in d["timeline"]], ident=d["state_evidence"]["title"], mood=d.get("mood", "indifferent"))
    else:
        out = dict(k=d["key"], cat=d["category"], h=d["headlines"], law=d["law"], spec=d["spec"], ages=(18, 60), v=d["has_victim"],
                   sum=pre + d["summary"], st=[ev(x, x["weight"]) for x in d["state_evidence"]],
                   df=[ev(x, x.get("weight", 1)) for x in d["defense_evidence"]], role=d["witness_role"], ex=ex(d["witness_exam"]),
                   th=(d["theory"]["state"], d["theory"]["defense"]), al=d["allocution"], tr=(d["truth_guilty"], d["truth_innocent"]),
                   de=ex(d["defendant_exam"]), op=(d["opening"]["state"], d["opening"]["defense"]), cl=(d["closing"]["state"], d["closing"]["defense"]),
                   tl=[(x["day"], x["text"]) for x in d["timeline"]], ident=d["how_identified"], mood=d["mood"], thr=d["threshold"])
        if d.get("victim_impact"): out["imp"] = d["victim_impact"]
        if d.get("aggravating"): out["ag"] = d["aggravating"]
        if d.get("mitigating"): out["mi"] = d["mitigating"]
        if d.get("defense_witness"): out["drole"] = d["defense_witness"]["role"]; out["dex"] = ex(d["defense_witness"]["exam"])
        if d.get("legal_topics"): out["doc"] = d["legal_topics"]
    if "source" in d: out["s"] = d["source"]
    return out

def used(law=None):
    for f in sorted(glob.glob(f"{ROOT}/JudgeSim/Game/StoryCases*.swift")):
        t = open(f).read()
        for m in re.finditer(r'key: "(?:\w+\.)?(\w+)".*?headlines: \["([^"]+)"', t, re.S):
            print(f"{m.group(1)}: {m.group(2)}")

def main():
    a = sys.argv[1:]
    if not a: print(__doc__); return
    if a[0] == "used": used(); return
    small = "--small" in a
    path = a[1]
    data = json.load(open(path))
    L, taken = laws(), existing_keys()
    bad = 0
    seen = set()
    for d in data:
        k, e = check(d, small, L, taken | seen)
        seen.add(k)
        for x in e: print(f"{k}: {x}"); bad += 1
    print(f"{len(data)} cases, {bad} problems")
    if a[0] == "convert" and bad == 0:
        out = a[2]
        open(out, "w").write("STORIES = " + repr([convert(d, small) for d in data]) + "\n")
        print("wrote", out)
    sys.exit(1 if bad else 0)
main()
