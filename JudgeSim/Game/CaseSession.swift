import Foundation
import SwiftUI

/// Tracks the judge's rulings through a single case.
final class CaseSession: ObservableObject {
    enum Stage: Int, CaseIterable, Identifiable {
        case briefing, motions, trial, verdict, sentencing, probation, judgment

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .briefing: return "Case File"
            case .motions: return "Pretrial Motions"
            case .trial: return "Trial"
            case .verdict: return "Verdict"
            case .sentencing: return "Sentencing"
            case .probation: return "Probation Violation"
            case .judgment: return "Judgment"
            }
        }

        var shortTitle: String {
            switch self {
            case .briefing: return "File"
            case .motions: return "Motions"
            case .trial: return "Trial"
            case .verdict: return "Verdict"
            case .sentencing: return "Sentence"
            case .probation: return "Probation"
            case .judgment: return "Done"
            }
        }

        var icon: String {
            switch self {
            case .briefing: return "folder.fill"
            case .motions: return "doc.text.magnifyingglass"
            case .trial: return "person.3.fill"
            case .verdict: return "checkmark.seal.fill"
            case .sentencing: return "scalemass.fill"
            case .probation: return "person.badge.clock.fill"
            case .judgment: return "building.columns.fill"
            }
        }
    }

    let courtCase: CourtCase
    let judgeName: String
    let county: County
    @Published var stage: Stage = .briefing
    @Published var rulings = Rulings()
    @Published private(set) var outcome: CaseOutcome?
    @Published private(set) var transcript: [TranscriptEntry] = []
    @Published private(set) var revealedAggravating: [String] = []
    @Published private(set) var revealedMitigating: [String] = []
    private var askedIDs = Set<String>()
    private var sentencingPrepared = false

    init(courtCase: CourtCase, judgeName: String, county: County) {
        self.courtCase = courtCase
        self.judgeName = judgeName
        self.county = county
    }

    var visibleStages: [Stage] {
        Stage.allCases.filter { stage in
            if rulings.pleaAccepted == true && [Stage.motions, .trial, .verdict].contains(stage) { return false }
            switch stage {
            case .motions: return !courtCase.motions.isEmpty
            case .probation: return courtCase.defendant.probation != nil
            default: return true
            }
        }
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

    func factorBinding(_ factor: String, aggravating: Bool) -> Binding<Bool> {
        Binding(get: {
            aggravating ? self.rulings.foundAggravating.contains(factor) : self.rulings.foundMitigating.contains(factor)
        }, set: { found in
            if aggravating {
                if found { self.rulings.foundAggravating.insert(factor) } else { self.rulings.foundAggravating.remove(factor) }
            } else {
                if found { self.rulings.foundMitigating.insert(factor) } else { self.rulings.foundMitigating.remove(factor) }
            }
        })
    }

    func choice(for unit: SentencingUnit) -> SentenceChoice {
        rulings.sentences[unit.id] ?? Judgment.defaultChoice(for: unit)
    }

    func choiceBinding(for unit: SentencingUnit) -> Binding<SentenceChoice> {
        Binding(get: { self.choice(for: unit) },
                set: { self.rulings.sentences[unit.id] = $0 })
    }

    func setHabitual(_ found: Bool) {
        rulings.habitualFound = found
        rulings.sentences = [:]
    }

    func setMode(_ mode: JudgmentMode) {
        rulings.mode = mode
        rulings.sentences = [:]
    }

    // MARK: Counsel

    func counselName(_ side: Side) -> String { CounselDialogue.name(courtCase, side: side) }

    func counselStyle(_ side: Side) -> CounselStyle { CounselDialogue.style(courtCase, side: side) }

    func availableQuestions(_ side: Side) -> [CounselQuestion] {
        CounselDialogue.questions(courtCase, stage: stage, rulings: rulings, units: units)
            .filter { $0.side == side && !askedIDs.contains($0.id) }
    }

    func entries(for side: Side) -> [TranscriptEntry] {
        transcript.filter { $0.side == side }
    }

    var unaskedCount: Int {
        CounselDialogue.questions(courtCase, stage: stage, rulings: rulings, units: units)
            .filter { !askedIDs.contains($0.id) }.count
    }

    func ask(_ question: CounselQuestion) {
        guard !askedIDs.contains(question.id) else { return }
        askedIDs.insert(question.id)
        transcript.append(TranscriptEntry(side: question.side, speaker: counselName(question.side),
                                          question: question.question, answer: question.answer, reveal: question.reveal))
        switch question.reveal {
        case .mitigating(let factor)?:
            if !mitigatingFactors.contains(factor) { revealedMitigating.append(factor) }
        case .aggravating(let factor)?:
            if !aggravatingFactors.contains(factor) { revealedAggravating.append(factor) }
        case nil:
            break
        }
    }

    var aggravatingFactors: [String] { courtCase.aggravating + revealedAggravating }
    var mitigatingFactors: [String] { courtCase.mitigating + revealedMitigating }

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

    var anyConviction: Bool {
        courtCase.charges.contains { (rulings.verdicts[$0.id] ?? .notGuilty) != .notGuilty }
    }

    var needsHabitualDecision: Bool {
        courtCase.habitualIndicted && Judgment.anyFelonyConviction(courtCase, rulings)
    }

    var units: [SentencingUnit] { Judgment.units(courtCase, rulings) }

    var priorRecord: PriorRecord { Judgment.priorRecord(courtCase, rulings) }

    func isSuppressed(_ evidence: Evidence) -> Bool {
        rulings.excludedEvidence(in: courtCase).contains(evidence.id)
    }

    func allowedRanges(for unit: SentencingUnit) -> [SentenceRangeKind] {
        var ranges: [SentenceRangeKind] = [.presumptive]
        if !rulings.foundMitigating.isEmpty { ranges.insert(.mitigated, at: 0) }
        if !rulings.foundAggravating.isEmpty { ranges.append(.aggravated) }
        return ranges
    }

    var pjcAvailable: Bool { Judgment.pjcAvailable(courtCase, rulings) }
    var conditionalDischargeAvailable: Bool { Judgment.conditionalDischargeAvailable(courtCase, rulings) }
    var anySuspended: Bool { Judgment.anySuspended(courtCase, rulings) }
    var anyIntermediate: Bool { Judgment.anyIntermediate(courtCase, rulings) }
    var anyActive: Bool { Judgment.anyActive(courtCase, rulings) }
    var maxSpecialProbationDays: Int { Judgment.maxSpecialProbationDays(courtCase, rulings) }
    var obligations: [(label: String, amount: Int)] { Judgment.obligations(courtCase, rulings) }
    var asrEligible: Bool { units.contains { Judgment.asrEligible($0, rulings) } }
    var askedAboutASR: Bool { askedIDs.contains("sen.state.asr") }

    /// The judge decides; the only requirement is that every judgment has a disposition.
    var sentencingComplete: Bool {
        if needsHabitualDecision && rulings.habitualFound == nil { return false }
        if rulings.special != .none { return true }
        return units.allSatisfy { Judgment.isComplete(self.choice(for: $0)) }
    }

    var sentencingHint: String? {
        if needsHabitualDecision && rulings.habitualFound == nil { return "Decide whether habitual felon status was proven." }
        if !sentencingComplete { return "Choose a disposition (Active, Intermediate, or Community) for each judgment." }
        return nil
    }

    var legalIssues: [String] { Judgment.legalIssues(courtCase, rulings) }

    // MARK: Plea arrangement

    var pleaPresented: Bool { courtCase.background?.arrangementPresented == true }

    func acceptPlea() {
        guard let lawID = courtCase.background?.arrangementLawID else { return }
        rulings.pleaAccepted = true
        for (index, charge) in courtCase.charges.enumerated() {
            if index == 0 {
                rulings.verdicts[charge.id] = charge.lesserLawID == lawID ? .lesser : .guilty
            } else {
                rulings.verdicts[charge.id] = .notGuilty
                rulings.dismissedByPlea.insert(charge.id)
            }
        }
        prepareSentencing()
        withAnimation(.easeInOut) { stage = .sentencing }
    }

    func rejectPlea() {
        rulings.pleaAccepted = false
    }

    // MARK: Custom conditions

    func addCustomCondition(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        rulings.customConditions.append(trimmed)
    }

    func removeCustomCondition(at index: Int) {
        guard rulings.customConditions.indices.contains(index) else { return }
        rulings.customConditions.remove(at: index)
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
                if dismissedBySpeedyTrial {
                    if courtCase.defendant.probation != nil { stage = .probation } else { finish() }
                } else { stage = .trial }
            case .trial:
                stage = .verdict
            case .verdict:
                if anyConviction {
                    prepareSentencing()
                    stage = .sentencing
                } else if courtCase.defendant.probation != nil {
                    stage = .probation
                } else {
                    finish()
                }
            case .sentencing:
                for unit in units where rulings.sentences[unit.id] == nil {
                    rulings.sentences[unit.id] = Judgment.defaultChoice(for: unit)
                }
                if courtCase.defendant.probation != nil { stage = .probation } else { finish() }
            case .probation:
                finish()
            case .judgment:
                break
            }
        }
    }

    private func prepareSentencing() {
        guard !sentencingPrepared else { return }
        sentencingPrepared = true
        let bg = courtCase.background
        rulings.money.restitution = bg?.restitution ?? 0
        rulings.money.attorneyFees = Judgment.appointedCounsel(courtCase)
    }

    /// Drops conditions that the chosen dispositions don't permit.
    private func normalizeConditions() {
        // Probation conditions only exist if something is suspended; recommendations only if something is active.
        if !anySuspended && rulings.special == .none { rulings.conditions = ProbationConditions() }
        if !anyActive { rulings.recommendations = ActiveRecommendations() }
    }

    private func finish() {
        normalizeConditions()
        outcome = Judgment.evaluate(courtCase, rulings, judgeName: judgeName, county: county, date: courtCase.sessionDate)
        stage = .judgment
    }
}
