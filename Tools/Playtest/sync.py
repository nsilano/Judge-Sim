#!/usr/bin/env python3
"""Copies the game engine into Sources/Playtest for a Linux build, stubbing what only Apple platforms have."""
import os, re, shutil, sys

here = os.path.dirname(os.path.abspath(__file__))
app = os.path.join(here, "..", "..", "JudgeSim")
out = os.path.join(here, "Sources", "Playtest")
shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)

for folder in ("Game", "Models"):
    for name in sorted(os.listdir(os.path.join(app, folder))):
        if not name.endswith(".swift"):
            continue
        text = open(os.path.join(app, folder, name)).read()
        text = re.sub(r"^import (SwiftUI|Combine|UIKit|Security)\s*$", "", text, flags=re.M)
        if name == "AICounsel.swift":
            text = text.replace("import Foundation", "import Foundation\n#if canImport(FoundationNetworking)\nimport FoundationNetworking\n#endif", 1)
            # The keychain is Apple-only; the harness keeps keys in memory.
            start = text.index("enum Keychain {")
            depth, i = 0, start
            while True:
                if text[i] == "{": depth += 1
                elif text[i] == "}":
                    depth -= 1
                    if depth == 0: break
                i += 1
            text = text[:start] + "enum Keychain {\n    static var store: [String: String] = [:]\n    static func write(_ value: String, account: String) { store[account] = value }\n    static func read(_ account: String) -> String? { store[account] }\n    static func delete(_ account: String) { store[account] = nil }\n}" + text[i + 1:]
        if name == "CaseGenerator.swift":
            # The harness builds every written case directly to scan its text.
            text = text.replace("private static func build(", "static func build(").replace("private enum Band {", "enum Band {")
        open(os.path.join(out, name), "w").write(text)

for name in os.listdir(os.path.join(here, "Harness")):
    shutil.copy(os.path.join(here, "Harness", name), out)
print("synced", len(os.listdir(out)), "files")
