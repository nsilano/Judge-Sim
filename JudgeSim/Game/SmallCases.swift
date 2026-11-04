import Foundation

/// A compact way to write an everyday case: one State witness, an optional defense witness, a three-beat timeline,
/// sentencing factors, and the public's mood. The shorter form keeps petty-crime stories cheap to write without
/// dropping the parts the trial needs.
enum SmallCases {
    static func make(key: String, category: LawCategory, headlines: [String], law: String, threshold: Int = 5, spec: String,
                     ages: ClosedRange<Int>, victim: Bool, summary: String, state: [EvidenceSeed], defense: [EvidenceSeed],
                     role: String, exam: [ExamLine], defenseRole: String? = nil, defenseExam: [ExamLine] = [],
                     theory: (String, String), allocution: String, truths: (String, String), defendant: [ExamLine],
                     openings: (String, String), closings: (String, String), timeline: [(Int, String)], identified: String,
                     notDone: [String] = [], aggravating: [String] = [], mitigating: [String] = [],
                     mood: PublicMood = .indifferent, impact: String? = nil, doctrines: [String] = ["burdenOfProof"],
                     genders: [String: Gender] = [:]) -> CaseTemplate {
        let civilian = FollowUpCases.isCivilianRole(role)
        var defenseWitnesses: [WitnessSeed] = []
        if let defenseRole {
            defenseWitnesses = [WitnessSeed(name: nil, role: defenseRole, direct: [], cross: [], weight: 1, lay: true, exam: defenseExam)]
        }
        return CaseTemplate(
            key: key, category: category, headlines: headlines, primaryLaw: law, lesserLaw: nil,
            threshold: threshold, lesserThreshold: 0, specification: spec,
            ageRange: ages, occupations: [], hasVictim: victim, summaries: [summary],
            prosecutionEvidence: state, defenseEvidence: defense,
            prosecutionWitnesses: [WitnessSeed(name: FollowUpCases.witnessName(for: role), role: role, direct: [], cross: [], weight: 2, lay: civilian, exam: exam)],
            defenseWitnesses: defenseWitnesses,
            prosecutionTheory: [theory.0], defenseTheory: [theory.1],
            aggravating: aggravating, mitigating: mitigating.isEmpty ? ["The defendant has accepted responsibility"] : mitigating,
            victimImpacts: impact.map { [$0] } ?? [], allocutions: [allocution],
            guiltyTruths: [truths.0], innocentTruths: [truths.1], moods: [mood], doctrines: doctrines,
            story: StoryExtras(timeline: timeline, howIdentified: identified, notDone: notDone, defendantExam: defendant,
                               prosecutionOpening: openings.0, defenseOpening: openings.1,
                               prosecutionClosing: closings.0, defenseClosing: closings.1, genders: genders)
        )
    }
}
