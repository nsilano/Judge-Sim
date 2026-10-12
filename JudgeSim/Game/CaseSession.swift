import Foundation
import SwiftUI

/// Tracks the player's progress and rulings through a single case.
final class CaseSession: ObservableObject {
    enum Stage: Int, CaseIterable, Identifiable {
        case briefing, motions, trial, verdict, sentencing, outcome

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .briefing: return "Case File"
            case .motions: return "Pretrial Motions"
            case .trial: return "Trial"
            case .verdict: return "Verdict"
            case .sentencing: return "Sentencing"
            case .outcome: return "Judgment"
            }
        }

        var icon: String {
            switch self {
            case .briefing: return "folder.fill"
            case .motions: return "doc.text.magnifyingglass"
            case .trial: return "person.3.fill"
            case .verdict: return "checkmark.seal.fill"
            case .sentencing: return "scalemass.fill"
            case .outcome: return "building.columns.fill"
            }
        }
    }

    let courtCase: CourtCase
    @Published var stage: Stage = .briefing
    @Published var rulings = Rulings()
    @Published private(set) var outcome: CaseOutcome?

    init(courtCase: CourtCase) {
        self.courtCase = courtCase
    }

    var visibleStages: [Stage] {
        Stage.allCases.filter { $0 != .motions || !courtCase.motions.isEmpty }
    }

    // MARK: Bindings

    func motionBinding(_ motion: Motion) -> Binding<Bool?> {
        Binding(get: { self.rulings.motions[motion.id] },
                set: { self.rulings.motions[motion.id] = $0 })
    }

    func objectionBinding(_ objection: Objection) -> Binding<Bool?> {
        Binding(get: { self.rulings.objections[objection.id] },
                set: { self.rulings.objections[objection.id] = $0 })
    }

    func verdictBinding(_ charge: Charge) -> Binding<Verdict?> {
        Binding(get: { self.rulings.verdicts[charge.id] },
                set: { self.rulings.verdicts[charge.id] = $0 })
    }

    func sentenceBinding(_ charge: Charge, range: SentenceRange) -> Binding<Double> {
        Binding(get: { Double(self.rulings.sentences[charge.id] ?? range.typicalMonths) },
                set: { self.rulings.sentences[charge.id] = Int($0.rounded()) })
    }

    // MARK: State

    var motionsComplete: Bool {
        courtCase.motions.allSatisfy { rulings.motions[$0.id] != nil }
    }

    var pendingObjections: Int {
        courtCase.objections.filter { rulings.objections[$0.id] == nil }.count
    }

    var ethicsPending: Bool {
        courtCase.ethics != nil && rulings.ethicsChoice == nil
    }

    var trialComplete: Bool {
        pendingObjections == 0 && !ethicsPending
    }

    var verdictsComplete: Bool {
        courtCase.charges.allSatisfy { rulings.verdicts[$0.id] != nil }
    }

    var dismissedBySpeedyTrial: Bool {
        courtCase.motions.contains { $0.kind == .dismissSpeedyTrial && (rulings.motions[$0.id] ?? false) }
    }

    func isSuppressed(_ evidence: Evidence) -> Bool {
        rulings.excludedEvidence(in: courtCase).contains(evidence.id)
    }

    /// Each convicted count with the law it was convicted under.
    var convictions: [(charge: Charge, law: Law)] {
        courtCase.charges.compactMap { charge -> (charge: Charge, law: Law)? in
            guard let verdict = rulings.verdicts[charge.id],
                  let law = Scoring.convictedLaw(charge, verdict),
                  law.sentence != nil else { return nil }
            return (charge, law)
        }
    }

    var probationAvailable: Bool {
        let ranges = convictions.compactMap { $0.law.sentence }
        return !ranges.isEmpty && ranges.allSatisfy { $0.probationEligible && !$0.mandatoryMinimum && $0.minMonths == 0 }
    }

    var maxFine: Int {
        convictions.compactMap { $0.law.sentence?.maxFine }.max() ?? 0
    }

    var totalSentence: Int {
        if rulings.probation { return 0 }
        let terms = convictions.map { item -> Int in
            let range = item.law.sentence!
            return rulings.sentences[item.charge.id] ?? range.typicalMonths
        }
        return Scoring.combine(terms, consecutive: rulings.consecutive)
    }

    // MARK: Flow

    func chooseEthics(_ option: EthicsOption) {
        rulings.ethicsChoice = option.id
    }

    func advance() {
        withAnimation(.easeInOut) {
            switch stage {
            case .briefing:
                stage = courtCase.motions.isEmpty ? .trial : .motions
            case .motions:
                if dismissedBySpeedyTrial { finish() } else { stage = .trial }
            case .trial:
                stage = .verdict
            case .verdict:
                if convictions.isEmpty {
                    finish()
                } else {
                    for item in convictions where rulings.sentences[item.charge.id] == nil {
                        rulings.sentences[item.charge.id] = item.law.sentence?.typicalMonths ?? 0
                    }
                    stage = .sentencing
                }
            case .sentencing:
                finish()
            case .outcome:
                break
            }
        }
    }

    private func finish() {
        if !probationAvailable { rulings.probation = false }
        outcome = Scoring.evaluate(courtCase, rulings)
        stage = .outcome
    }
}
