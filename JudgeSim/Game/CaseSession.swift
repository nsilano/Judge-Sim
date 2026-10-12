import Foundation
import SwiftUI

/// Where a continued case left off.
struct CaseSnapshot: Codable, Hashable {
    var stage: Int
    var rulings: Rulings
    var revealedAggravating: [String] = []
    var revealedMitigating: [String] = []
}

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
    /// Set when the chosen sentence is harsher than the plea arrangement and the court must address G.S. 15A-1024.
    @Published var pendingPleaDeparture: String?
    /// What happened when the court told the defendant about the departure.
    @Published private(set) var pleaWithdrawalNote: String?
    private var askedIDs = Set<String>()
    private var sentencingPrepared = false

    init(courtCase: CourtCase, judgeName: String, county: County, resume: CaseSnapshot? = nil) {
        self.courtCase = courtCase
        self.judgeName = judgeName
        self.county = county
        if let resume {
            rulings = resume.rulings
            stage = Stage(rawValue: resume.stage) ?? .briefing
            sentencingPrepared = stage.rawValue >= Stage.sentencing.rawValue
            revealedAggravating = resume.revealedAggravating
            revealedMitigating = resume.revealedMitigating
            // The probation may have ended while the case was continued; pick up at the step before it.
            if stage == .probation && courtCase.defendant.probation == nil {
                stage = anyConviction ? .sentencing : .verdict
            }
        }
    }

    /// Everything needed to pick the case back up after a continuance.
    var snapshot: CaseSnapshot {
        CaseSnapshot(stage: stage == .judgment ? Stage.sentencing.rawValue : stage.rawValue, rulings: rulings,
                     revealedAggravating: revealedAggravating, revealedMitigating: revealedMitigating)
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

    /// Every question at this stage, asked or not (used to answer typed questions offline).
    func allQuestions(_ side: Side) -> [CounselQuestion] {
        CounselDialogue.questions(courtCase, stage: stage, rulings: rulings, units: units).filter { $0.side == side }
    }

    func brief(for side: Side, compact: Bool) -> String {
        CounselBrief.make(for: courtCase, side: side, stage: stage, rulings: rulings, units: units, compact: compact)
    }

    func heldBackFactor(for side: Side) -> CounselReveal? {
        guard stage == .sentencing, let bg = courtCase.background else { return nil }
        if side == .prosecution, let factor = bg.hiddenAggravator, !aggravatingFactors.contains(factor) { return .aggravating(factor) }
        if side == .defense, let factor = bg.hiddenMitigator, !mitigatingFactors.contains(factor) { return .mitigating(factor) }
        return nil
    }

    func record(side: Side, question: String, answer: String, reveal: CounselReveal?) {
        transcript.append(TranscriptEntry(side: side, speaker: counselName(side), question: question, answer: answer, reveal: reveal))
        switch reveal {
        case .mitigating(let factor)?:
            if !mitigatingFactors.contains(factor) { revealedMitigating.append(factor) }
        case .aggravating(let factor)?:
            if !aggravatingFactors.contains(factor) { revealedAggravating.append(factor) }
        case nil:
            break
        }
        if let preset = allQuestions(side).first(where: { $0.answer == answer }) { askedIDs.insert(preset.id) }
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

    /// The State has rested once every objection during its witnesses is ruled on.
    var stateRested: Bool {
        courtCase.objections.filter { obj in courtCase.witnesses.first { $0.id == obj.witnessID }?.calledBy == .prosecution }
            .allSatisfy { rulings.objections[$0.id] != nil }
    }

    var halftimeComplete: Bool {
        courtCase.charges.allSatisfy { rulings.halftime[$0.id] != nil }
    }

    func halftimeBinding(_ charge: Charge) -> Binding<HalftimeRuling?> {
        Binding(get: { self.rulings.halftime[charge.id] },
                set: { self.rulings.halftime[charge.id] = $0 })
    }

    var testimonyDecided: Bool {
        courtCase.defendantTestimony == nil || rulings.defendantTestifies != nil
    }

    func adviseRightToTestify() {
        rulings.defendantTestifies = courtCase.background?.willTestify ?? false
    }

    var trialComplete: Bool {
        pendingObjections == 0 && !ethicsPending && halftimeComplete && testimonyDecided
    }

    /// Verdict choices left open after the motion to dismiss.
    func verdictOptions(_ charge: Charge) -> [Verdict] {
        switch rulings.halftime[charge.id] {
        case .dismiss?: return [.notGuilty]
        case .lesserOnly?: return [.lesser, .notGuilty]
        default: return charge.lesserLawID == nil ? [.guilty, .notGuilty] : [.guilty, .lesser, .notGuilty]
        }
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
        if rulings.pleaAccepted == true && courtCase.background?.arrangementHabitual != nil { return false }
        return courtCase.habitualIndicted && Judgment.anyFelonyConviction(courtCase, rulings)
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

    // MARK: Questions from the bench (N.C. R. Evid. 614(b))

    @Published private(set) var witnessTranscripts: [UUID: [TranscriptEntry]] = [:]

    func witnessTranscript(for witness: Witness) -> [TranscriptEntry] {
        witnessTranscripts[witness.id] ?? []
    }

    /// What a witness knows: their testimony, their role, and the outline of the case. Never what really happened.
    func witnessBrief(_ witness: Witness, compact: Bool) -> String {
        let c = courtCase
        let limit = compact ? 140 : 1_000
        var lines = [
            "You are \(witness.name), \(witness.role), a witness called by the \(witness.calledBy == .prosecution ? "State" : "defense") in \(c.caption) in Hollis County Superior Court, North Carolina.",
            "The judge is now asking you questions directly from the bench, as North Carolina Rule of Evidence 614 allows. Answer as this witness: first person, plain speech, one to three sentences, addressing the judge as \"Your Honor.\"",
            "You know only what this witness would know: your own testimony below, and what someone in your role would know about the case. If you don't know, say so. Don't invent new evidence or change your story. Stay consistent with your testimony, including anything conceded on cross. Never mention being an AI or a game, and use no stage directions.",
            "",
            "CASE: \(CounselBrief.clip(c.summary, limit * 2))",
            "YOUR TESTIMONY SO FAR:"
        ]
        let exchanges = witness.exchanges ?? witness.direct.map { TestimonyExchange(phase: .direct, examiner: witness.calledBy, question: "", answer: $0) }
        for e in exchanges.prefix(compact ? 10 : 30) {
            lines.append(e.question.isEmpty ? "- \(CounselBrief.clip(e.answer, limit))" : "Q: \(e.question) A: \(CounselBrief.clip(e.answer, limit))")
        }
        if Testimony.isOfficial(witness.role), let report = c.investigation {
            lines.append("WHAT YOU KNOW OF THE INVESTIGATION: \(report.howIdentified) Steps not taken: \(report.notDone.joined(separator: " "))")
            if !compact {
                lines.append("Timeline: " + report.timeline.map { "\($0.when): \($0.what)" }.joined(separator: " | "))
            }
        }
        return lines.joined(separator: "\n")
    }

    /// Ask a witness a question from the bench. Returns an error message if the answer couldn't be produced.
    @MainActor
    func askWitness(_ question: String, witness: Witness) async -> String? {
        let engine = AISettings.shared.activeEngine
        let history = witnessTranscript(for: witness).map { (question: $0.question, answer: $0.answer) }
        var answer: String
        if engine == .offline {
            let options = (witness.exchanges ?? []).enumerated().map { index, e in
                CounselQuestion(id: "w\(index)", side: witness.calledBy, question: e.question.isEmpty ? e.answer : e.question, answer: e.answer)
            }
            answer = OfflineCounsel.answer(question, from: options, style: .methodical).0
        } else {
            do {
                let reply = engine == .onDevice
                    ? try await OnDeviceCounsel.reply(instructions: witnessBrief(witness, compact: true), history: history, question: question)
                    : try await ClaudeClient.counselReply(system: witnessBrief(witness, compact: false), history: history, question: question)
                answer = reply.answer
            } catch OnDeviceCounsel.Failure.guardrail {
                answer = "Your Honor, I'm not comfortable answering that."
            } catch ClaudeError.refusal {
                answer = "Your Honor, I'm not comfortable answering that."
            } catch {
                return error.localizedDescription
            }
        }
        var list = witnessTranscripts[witness.id] ?? []
        list.append(TranscriptEntry(side: witness.calledBy, speaker: witness.name, question: question, answer: answer, reveal: nil))
        witnessTranscripts[witness.id] = list
        return nil
    }

    /// One line telling the judge what this screen needs.
    var nextStep: String? {
        switch stage {
        case .briefing:
            if pleaPresented && rulings.pleaAccepted == nil && !rulings.pleaWithdrawn { return "Take the plea or reject it." }
            return courtCase.motions.isEmpty ? "Read the file, then start the trial." : "Read the file, then hear the pretrial motions."
        case .motions:
            let left = courtCase.motions.filter { rulings.motions[$0.id] == nil }.count
            return left == 0 ? "Go on to trial." : "Grant or deny \(left) motion\(left == 1 ? "" : "s")."
        case .trial:
            var parts: [String] = []
            if ethicsPending { parts.append("respond to the matter outside the courtroom") }
            if pendingObjections > 0 { parts.append("rule on \(pendingObjections) objection\(pendingObjections == 1 ? "" : "s")") }
            if stateRested && !halftimeComplete { parts.append("rule on the motion to dismiss") }
            if halftimeComplete && !testimonyDecided { parts.append("advise the defendant on testifying") }
            return parts.isEmpty ? "Close the evidence and decide the verdict." : parts.joined(separator: ", ").capitalizedFirst + "."
        case .verdict:
            let decided = courtCase.charges.filter { rulings.verdicts[$0.id] != nil }.count
            return decided == courtCase.charges.count ? "Announce the verdict." : "Decide each count (\(decided) of \(courtCase.charges.count) done)."
        case .sentencing:
            return sentencingHint ?? "Work through the steps, then enter judgment."
        case .probation:
            return rulings.probationDecision == nil ? "Decide what to do about the probation violation." : "Enter the order."
        case .judgment:
            return nil
        }
    }

    // MARK: Plea arrangement

    var pleaPresented: Bool { courtCase.background?.arrangementPresented == true }

    /// The statutory maximum the defendant faces on the plea, for the colloquy (G.S. 15A-1022(a)(6)).
    var pleaMaximumText: String {
        guard let lawID = courtCase.background?.arrangementLawID else { return "the maximum allowed by law" }
        let law = LawLibrary.law(lawID)
        guard var cls = law.ncClass else { return "the maximum allowed by law" }
        if courtCase.background?.arrangementHabitual == true && cls.isFelony { cls = StructuredSentencing.habitualClass(for: cls) }
        if cls == .A { return "life imprisonment without parole" }
        if let cell = StructuredSentencing.felonyCell(cls, level: priorRecord.felonyLevel) {
            let top = cell.aggravated?.high ?? cell.presumptive.high
            let max = StructuredSentencing.maximum(forMinimum: top, cls: cls)
            return "\(top) to \(max) months in prison" + (cls == .B1 && priorRecord.felonyLevel >= 5 ? ", or life without parole" : "")
        }
        if let cell = StructuredSentencing.misdemeanorCell(cls, level: priorRecord.misdemeanorLevel) {
            return "\(cell.maxDays) days in jail" + (cls.maxFine.map { " and a fine of up to \(SentenceFormat.dollars($0))" } ?? "")
        }
        return "the maximum allowed by law"
    }

    func acceptPlea(kind: PleaKind = .guilty) {
        guard let lawID = courtCase.background?.arrangementLawID else { return }
        rulings.pleaAccepted = true
        rulings.pleaKind = kind
        if let admitted = courtCase.background?.arrangementHabitual {
            rulings.habitualFound = admitted
        }
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

    /// The court tells the defendant it will not follow the arrangement; the defendant decides whether to withdraw.
    func informDefendantOfDeparture() {
        pendingPleaDeparture = nil
        var rng = SeededRNG(seed: courtCase.seed ^ 0x1024)
        let withdraws = rng.chance(courtCase.truth.actuallyGuilty ? 0.45 : 0.75)
        if withdraws {
            pleaWithdrawalNote = "After conferring with counsel, \(courtCase.defendant.lastName) withdrew the plea. The case will be tried."
            rulings.pleaAccepted = false
            rulings.pleaWithdrawn = true
            rulings.verdicts = [:]
            rulings.dismissedByPlea = []
            rulings.sentences = [:]
            rulings.habitualFound = nil
            rulings.pleaDepartureDisclosed = nil
            withAnimation(.easeInOut) { stage = courtCase.motions.isEmpty ? .trial : .motions }
        } else {
            pleaWithdrawalNote = "\(courtCase.defendant.lastName) chose to stand on the plea and accept the court's sentence."
            rulings.pleaDepartureDisclosed = true
            advance()
        }
    }

    /// Enters the harsher sentence without offering withdrawal.
    func enterDepartureWithoutNotice() {
        pendingPleaDeparture = nil
        rulings.pleaDepartureDisclosed = false
        advance()
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
                for charge in courtCase.charges where rulings.halftime[charge.id] == .dismiss {
                    rulings.verdicts[charge.id] = .notGuilty
                }
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
                if rulings.pleaDepartureDisclosed == nil, let departure = Judgment.pleaDeparture(courtCase, rulings) {
                    pendingPleaDeparture = departure
                    return
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
