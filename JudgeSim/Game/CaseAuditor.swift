import Foundation

/// Reads a generated case before the judge sees it. Lines that don't fit the case are removed;
/// a case whose core facts contradict themselves is rejected so a new one can be drawn.
enum CaseAuditor {

    struct Report {
        /// Problems in the core of the case (summary, charges, exhibits, dates) that can't be cut out.
        var fatal: [String] = []
        /// Lines removed because they didn't fit.
        var removed: [String] = []
    }

    /// A topic a line may only raise when the case itself is about it.
    private struct Grounding {
        let triggers: [String]
        let grounds: [String]
    }

    private static let groundings: [Grounding] = [
        Grounding(triggers: ["planning this", "planned this", "planned it", "premeditat", "lying in wait"],
                  grounds: ["premeditat", "planned", "planning", "plotted", "poison", "insurance", "hired", "murder in the first"]),
        Grounding(triggers: ["fingerprint", "dusted", "latent print", "partial print"],
                  grounds: ["fingerprint", "latent", "print on", "partial print", "thumbprint", "palm print"]),
        Grounding(triggers: ["dna", "swab"], grounds: ["dna", "swab", "blood on", "saliva"]),
        Grounding(triggers: ["lineup", "photo array", "identified the defendant", "anyone other than", "other suspect",
                             "stopped looking", "the one in the", "gray jacket", "mask"],
                  grounds: ["lineup", "photo array", "mask", "hoodie", "identif", "unknown", "matching", "description", "tip", "suspect"]),
        Grounding(triggers: ["the weapon", "the gun", "the knife", "a weapon", "pistol", "handgun", "firearm"],
                  grounds: ["weapon", "gun", "knife", "pistol", "firearm", "rifle", "shotgun", "revolver", "blade"]),
        Grounding(triggers: ["breath test", "intoxilyzer", "blood alcohol", "field sobriety", "had been drinking", "smelled alcohol", "drunk"],
                  grounds: ["alcohol", "drunk", "intoxilyzer", "breath", "impair", "dwi", "drinking", "bar tab", "beer"]),
        Grounding(triggers: ["dashcam", "dash camera", "body camera", "bodycam"],
                  grounds: ["dashcam", "dash cam", "body camera", "bodycam", "stop", "trooper", "patrol"]),
        Grounding(triggers: ["bleeding", "stabbed", "stab wound", "wound", "injuries", "punched", "swung"],
                  grounds: ["wound", "injur", "stab", "bleed", "punch", "fight", "assault", "struck", "hit", "beat", "strangl", "shot", "died", "death", "crash", "broken"]),
        Grounding(triggers: ["drug", "cocaine", "heroin", "fentanyl", "methamphetamine", "baggie", "dealing"],
                  grounds: ["drug", "cocaine", "heroin", "fentanyl", "meth", "pill", "opioid", "marijuana", "controlled", "overdose", "prescription", "narcotic"]),
        Grounding(triggers: ["the books", "audit", "ledger", "invoice", "wire transfer", "bank records"],
                  grounds: ["account", "bank", "money", "invoice", "ledger", "audit", "transfer", "payroll", "check", "fund", "$"])
    ]

    /// Checks the case and removes lines that don't fit it.
    static func audit(_ c: inout CourtCase) -> Report {
        var report = Report()
        // Written cases are checked when they're written; only redirect is left out.
        if c.templateKey.hasPrefix("story.") {
            for index in c.witnesses.indices { c.witnesses[index].exchanges?.removeAll { $0.phase == .redirect } }
            return report
        }
        let core = coreText(c)
        let names = [c.defendant.lastName, c.defendant.name, c.victimName].compactMap { $0 }

        // Core facts: placeholders and dates.
        var coreLines: [(String, String)] = [("summary", c.summary), ("headline", c.headline)]
        coreLines += c.charges.map { ("charge", $0.specification) }
        coreLines += c.evidence.map { ("exhibit", $0.detail) }
        for (label, text) in coreLines where hasPlaceholder(text) {
            report.fatal.append("Unfilled placeholder in \(label): \(text.prefix(60))")
        }
        if let s = c.investigation?.facts {
            if s.arrest < s.incident { report.fatal.append("Arrest before the incident") }
            if let interview = s.interview, interview < s.incident { report.fatal.append("Interview before the incident") }
            if let sent = s.labSubmitted {
                if sent < s.incident { report.fatal.append("Lab submission before the incident") }
                if let back = s.labReturned, back < sent { report.fatal.append("Lab results before submission") }
            }
            if s.incident > c.sessionDate { report.fatal.append("Incident after the trial date") }
        }

        // Testimony: drop exchanges that raise things the case isn't about, repeat another answer, or leave placeholders.
        var seenAnswers = Set<String>()
        func fits(_ text: String) -> String? {
            if hasPlaceholder(text) { return "placeholder" }
            let lower = text.lowercased()
            for g in groundings where g.triggers.contains(where: { lower.contains($0) }) && !g.grounds.contains(where: { core.contains($0) }) {
                return "ungrounded: \(g.triggers.first ?? "")"
            }
            if c.victimName == nil && (lower.contains("the victim") || lower.contains("victim's")) { return "no victim in this case" }
            return nil
        }
        func cleanExchanges(_ w: inout Witness) {
            guard var exchanges = w.exchanges else { return }
            // Redirect is left out: the judge asked for direct and cross only.
            exchanges.removeAll { $0.phase == .redirect }
            exchanges.removeAll { e in
                let key = normalized(e.answer, names: names)
                if let reason = fits(e.question + " " + e.answer) {
                    report.removed.append("\(w.role): \(reason)")
                    return true
                }
                if key.count > 25 && !seenAnswers.insert(key).inserted {
                    report.removed.append("\(w.role): repeated answer")
                    return true
                }
                return false
            }
            w.exchanges = exchanges
        }
        for index in c.witnesses.indices { cleanExchanges(&c.witnesses[index]) }
        if var testimony = c.defendantTestimony {
            cleanExchanges(&testimony)
            c.defendantTestimony = testimony
        }

        // Objections, twist, and factors.
        c.objections.removeAll { o in
            if let reason = fits(o.question + " " + o.answer) {
                report.removed.append("Objection: \(reason)")
                return true
            }
            return false
        }
        if let twist = c.twist, fits(twist) != nil {
            report.removed.append("Twist did not fit")
            c.twist = nil
        }
        c.aggravating.removeAll { fits($0) != nil }
        c.mitigating.removeAll { fits($0) != nil }

        // A witness left with nothing to say on direct is a broken witness.
        for w in c.witnesses where w.exchanges != nil && !(w.exchanges ?? []).contains(where: { $0.phase == .direct }) {
            report.fatal.append("\(w.role) has no direct testimony left")
        }
        return report
    }

    // MARK: Repetition across cases

    /// Stable fingerprints of a case's lines, with names stripped, for spotting text the judge has read recently.
    static func lineKeys(_ c: CourtCase) -> [UInt64] {
        let names = [c.defendant.lastName, c.defendant.name, c.victimName].compactMap { $0 }
        var lines: [String] = []
        for w in c.witnesses { lines += (w.exchanges ?? []).flatMap { [$0.question, $0.answer] } }
        lines += c.objections.flatMap { [$0.question, $0.answer] }
        lines += [c.prosecutionOpening, c.defenseOpening, c.prosecutionClosing, c.defenseClosing]
        return lines.map { normalized($0, names: names) }.filter { $0.count > 25 }.map(fnv)
    }

    // MARK: Helpers

    private static func coreText(_ c: CourtCase) -> String {
        var parts = [c.summary, c.headline] + c.charges.map(\.specification) + c.charges.map { $0.law.title }
        parts += c.evidence.map { $0.title + " " + $0.detail }
        parts += c.witnesses.map(\.role)
        return parts.joined(separator: " ").lowercased()
    }

    private static func hasPlaceholder(_ text: String) -> Bool {
        guard let open = text.firstIndex(of: "{"), let close = text[open...].firstIndex(of: "}") else { return false }
        let inside = text[text.index(after: open)..<close]
        return !inside.isEmpty && inside.allSatisfy { $0.isUppercase || $0.isNumber }
    }

    private static func normalized(_ text: String, names: [String]) -> String {
        var s = text.lowercased()
        for name in names where !name.isEmpty { s = s.replacingOccurrences(of: name.lowercased(), with: "_") }
        return String(s.filter { $0.isLetter || $0 == " " || $0 == "_" })
    }

    private static func fnv(_ s: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in s.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}
