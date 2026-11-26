import Foundation

/// The story auditor, at run time. The same testimony and statement standards as Tools/Depth/depth.py and statements.py: a written
/// story that is still a skeleton (a witness with a couple of one-word answers, a one-line statement) is never put in front of the
/// player. The case director only draws from stories that pass; a follow-up that fails is replaced by an ordinary case.
enum StoryAuditor {
    /// What a witness's examination must have: 11 lines, 6 direct and 5 cross, answers averaging 12 words.
    static let minLines = 11, minDirect = 6, minCross = 5, minAverageWords = 12
    /// The defendant's statement and the victim's, in words.
    static let minAllocutionWords = 20, minImpactWords = 18

    nonisolated(unsafe) private static var verdicts: [String: Bool] = [:]

    private static func words(_ text: String) -> Int {
        text.replacingOccurrences(of: "\\\"", with: "").replacingOccurrences(of: "\"", with: "").split(separator: " ").count
    }

    /// What is wrong with one witness's examination, empty when it is deep enough. Witnesses without written lines get the
    /// game's generated examination, which is deep enough by construction.
    static func problems(inExam lines: [ExamLine], label: String) -> [String] {
        guard !lines.isEmpty else { return [] }
        let direct = lines.filter { $0.phase == .direct }, cross = lines.filter { $0.phase == .cross }
        let spoken = direct + cross
        var out: [String] = []
        if spoken.count < minLines || direct.count < minDirect || cross.count < minCross {
            out.append("\(label): \(direct.count) direct, \(cross.count) cross")
        }
        let total = spoken.reduce(0) { $0 + words($1.answers.first ?? "") }
        if !spoken.isEmpty, total / spoken.count < minAverageWords { out.append("\(label): answers average \(total / spoken.count) words") }
        return out
    }

    static func problems(_ t: CaseTemplate) -> [String] {
        // Only the short-form written stories carry written examinations; the older full templates have their own testimony.
        guard t.shortForm, let story = t.story else { return [] }
        var out: [String] = []
        for (i, w) in t.prosecutionWitnesses.enumerated() { out += problems(inExam: w.exam, label: "State witness \(i + 1)") }
        for (i, w) in t.defenseWitnesses.enumerated() { out += problems(inExam: w.exam, label: "Defense witness \(i + 1)") }
        out += problems(inExam: story.defendantExam, label: "Defendant")
        for a in t.allocutions where words(a) < minAllocutionWords { out.append("Defendant's statement: \(words(a)) words"); break }
        for v in t.victimImpacts where words(v) < minImpactWords { out.append("Victim's statement: \(words(v)) words"); break }
        return out
    }

    /// Whether the case director may use this story.
    static func passes(_ t: CaseTemplate) -> Bool {
        if let known = verdicts[t.key] { return known }
        let ok = problems(t).isEmpty
        verdicts[t.key] = ok
        return ok
    }

    /// How many of a bank of stories the auditor holds back.
    static func held(_ bank: [CaseTemplate]) -> Int { bank.filter { !passes($0) }.count }
}

extension StoryCases {
    /// The written stories that pass the audit.
    nonisolated(unsafe) static let audited: [CaseTemplate] = all.filter { StoryAuditor.passes($0) }
}
