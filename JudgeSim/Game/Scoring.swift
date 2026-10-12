import Foundation

enum Verdict: String, Codable, Hashable {
    case guilty, lesser, notGuilty
}

/// Everything the player decided during a case.
struct Rulings {
    var motions: [UUID: Bool] = [:]       // true = granted
    var objections: [UUID: Bool] = [:]    // true = sustained
    var verdicts: [UUID: Verdict] = [:]
    var sentences: [UUID: Int] = [:]      // months, per charge
    var probation = false
    var fine = 0
    var consecutive = false
    var ethicsChoice: UUID?

    func excludedEvidence(in courtCase: CourtCase) -> Set<UUID> {
        Set(courtCase.motions.compactMap { motion in
            (motions[motion.id] ?? false) ? motion.targetEvidenceID : nil
        })
    }
}

struct RulingReview: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let yourRuling: String
    let correct: Bool
    let explanation: String
    let doctrineID: String?
}

struct VerdictLine: Identifiable, Hashable {
    let id = UUID()
    let count: Int
    let chargeTitle: String
    let verdictLabel: String
    let sound: Bool
    let explanation: String
}

enum AppealResult: Hashable {
    case none(String)
    case affirmed
    case affirmedHarmless
    case reversed(String)
    case sentenceVacated(String)
    case dismissalReversed

    var label: String {
        switch self {
        case .none: return "No appeal"
        case .affirmed: return "Affirmed on appeal"
        case .affirmedHarmless: return "Affirmed (harmless error)"
        case .reversed: return "Reversed on appeal"
        case .sentenceVacated: return "Sentence vacated"
        case .dismissalReversed: return "Dismissal reversed"
        }
    }

    var detail: String {
        switch self {
        case .none(let why): return why
        case .affirmed: return "The Court of Appeals found no reversible error and affirmed the judgment."
        case .affirmedHarmless: return "The Court of Appeals found you made errors, but the remaining admissible evidence was strong enough that they couldn't have changed the outcome."
        case .reversed(let why): return why
        case .sentenceVacated(let why): return why
        case .dismissalReversed: return "The State appealed your dismissal. The Court of Appeals found no speedy-trial violation and reinstated the charges before another judge."
        }
    }

    var isBad: Bool {
        switch self {
        case .reversed, .sentenceVacated, .dismissalReversed: return true
        default: return false
        }
    }
}

struct CaseOutcome {
    var headline: String
    var grade: String
    var score: Int
    var dismissed: Bool
    var reviews: [RulingReview]
    var verdictLines: [VerdictLine]
    var convicted: Bool
    var appeal: AppealResult
    var sentenceSummary: String?
    var sentenceAssessment: String?
    var truthGuilty: Bool
    var truthText: String
    var epilogue: String
    var publicReaction: String
    var integrityDelta: Int
    var approvalDelta: Int
    var ethicsResult: String?
}

enum Scoring {

    // MARK: Case strength

    static func strength(_ c: CourtCase, excluded: Set<UUID>, admitted: (Objection) -> Bool) -> Int {
        var s = 0
        for e in c.evidence where !excluded.contains(e.id) {
            s += e.side == .prosecution ? e.weight : -e.weight
        }
        for w in c.witnesses {
            s += w.calledBy == .prosecution ? w.weight : -w.weight
        }
        for o in c.objections where admitted(o) {
            s += o.weightIfAdmitted
        }
        return s
    }

    /// The strength of the case as a correct judge would have heard it.
    static func properStrength(_ c: CourtCase) -> Int {
        let excluded = Set(c.motions.compactMap { $0.shouldGrant ? $0.targetEvidenceID : nil })
        return strength(c, excluded: excluded) { !$0.shouldSustain }
    }

    /// The strength of the case as this player actually heard it.
    static func ruledStrength(_ c: CourtCase, _ r: Rulings) -> Int {
        strength(c, excluded: r.excludedEvidence(in: c)) { !(r.objections[$0.id] ?? false) }
    }

    static func isAcceptable(_ verdict: Verdict, charge: Charge, strength s: Int) -> Bool {
        switch verdict {
        case .guilty:
            return s >= charge.threshold - 1
        case .lesser:
            guard charge.lesserLawID != nil else { return false }
            return s >= charge.lesserThreshold - 1 && s <= charge.threshold + 2
        case .notGuilty:
            let floor = charge.lesserLawID == nil ? charge.threshold : charge.lesserThreshold
            return s <= floor + 1
        }
    }

    static func assessment(charge: Charge, strength s: Int) -> String {
        let floor = charge.lesserLawID == nil ? charge.threshold : charge.lesserThreshold
        if s >= charge.threshold + 2 {
            return "The admissible evidence proved this charge beyond a reasonable doubt."
        } else if s >= charge.threshold - 1 {
            return "A close case on this charge. Reasonable judges could differ."
        } else if charge.lesserLawID != nil && s >= floor - 1 {
            return "The evidence supported the lesser offense (\(charge.lesserLaw?.title ?? "lesser offense")), but not the greater charge."
        } else if s >= floor - 1 {
            return "A close case. Reasonable judges could differ."
        } else {
            return "The admissible evidence fell short of proof beyond a reasonable doubt."
        }
    }

    // MARK: Sentencing

    static func guideline(for range: SentenceRange, in c: CourtCase) -> Int {
        let ceiling = min(range.maxMonths, max(range.typicalMonths * 3, range.minMonths + 24))
        let span = Double(max(1, ceiling - range.minMonths))
        var g = Double(range.typicalMonths)
        g += Double(c.aggravating.count - c.mitigating.count) * 0.12 * span
        g += Double(min(c.defendant.priorRecord.count, 3)) * 0.08 * span
        return min(range.maxMonths, max(range.minMonths, Int(g.rounded())))
    }

    static func convictedLaw(_ charge: Charge, _ verdict: Verdict) -> Law? {
        switch verdict {
        case .guilty: return charge.law
        case .lesser: return charge.lesserLaw
        case .notGuilty: return nil
        }
    }

    /// Combines per-count terms: concurrent terms run together, consecutive terms stack.
    static func combine(_ terms: [Int], consecutive: Bool) -> Int {
        guard let longest = terms.max() else { return 0 }
        if terms.contains(where: { $0 >= SentenceRange.life }) { return SentenceRange.life }
        return consecutive ? min(SentenceRange.life, terms.reduce(0, +)) : longest
    }

    // MARK: Full evaluation

    static func evaluate(_ c: CourtCase, _ r: Rulings) -> CaseOutcome {
        var reviews: [RulingReview] = []
        var integrity = 0
        var approval = 0
        var points = 0
        var possible = 0

        // Motions
        var dismissedBySpeedyTrial = false
        var dismissalWasCorrect = false
        for motion in c.motions {
            let granted = r.motions[motion.id] ?? false
            let correct = granted == motion.shouldGrant
            reviews.append(RulingReview(title: motion.kind.title,
                                        yourRuling: granted ? "Granted" : "Denied",
                                        correct: correct, explanation: motion.explanation,
                                        doctrineID: motion.doctrineIDs.first))
            integrity += correct ? 2 : -4
            possible += 2
            points += correct ? 2 : 0
            if motion.kind == .dismissSpeedyTrial && granted {
                dismissedBySpeedyTrial = true
                dismissalWasCorrect = correct
            }
        }

        // Ethics
        var ethicsResult: String?
        if let ethics = c.ethics, let choiceID = r.ethicsChoice,
           let choice = ethics.options.first(where: { $0.id == choiceID }) {
            integrity += choice.integrity
            approval += choice.approval
            possible += 2
            points += choice.isProper ? 2 : 0
            ethicsResult = choice.result
            let proper = ethics.options.first(where: { $0.isProper })?.label ?? ""
            reviews.append(RulingReview(title: "Ethics: \(ethics.title)", yourRuling: choice.label, correct: choice.isProper,
                                        explanation: choice.isProper ? "That's what the Code of Judicial Conduct requires." : "The proper course: \(proper).",
                                        doctrineID: ethics.doctrineID))
        }

        let truthGuilty = c.truth.actuallyGuilty
        let mediaFactor = [0.6, 1.0, 1.5][max(0, min(2, c.mediaAttention - 1))]

        if dismissedBySpeedyTrial {
            let appeal: AppealResult = dismissalWasCorrect
                ? .none("Dismissal with prejudice for a speedy-trial violation is final.")
                : .dismissalReversed
            if !dismissalWasCorrect { integrity -= 6 }
            let reaction: String
            switch c.mood {
            case .wantsConviction:
                approval += Int(-6 * mediaFactor)
                reaction = "\"Freed on a Technicality,\" screams the headline. Your inbox fills with angry emails."
            case .sympathetic:
                approval += Int(2 * mediaFactor)
                reaction = "Supporters cheer outside the courthouse. \"Justice delayed is justice denied,\" one sign reads."
            default:
                reaction = "A brief story on page six. Most people never hear about it."
            }
            let epilogue = truthGuilty ? fill(GenericPools.acquittedGuilty.randomElement() ?? "", c) : fill(GenericPools.acquittedInnocent.randomElement() ?? "", c)
            return CaseOutcome(headline: dismissalWasCorrect ? "Case Dismissed" : "Dismissal Reversed",
                               grade: grade(points: points, possible: possible), score: percent(points, possible),
                               dismissed: true, reviews: reviews, verdictLines: [], convicted: false, appeal: appeal,
                               sentenceSummary: nil, sentenceAssessment: nil, truthGuilty: truthGuilty,
                               truthText: c.truth.revelation, epilogue: epilogue, publicReaction: reaction,
                               integrityDelta: integrity, approvalDelta: approval, ethicsResult: ethicsResult)
        }

        // Objections
        for objection in c.objections {
            let sustained = r.objections[objection.id] ?? false
            let correct = sustained == objection.shouldSustain
            reviews.append(RulingReview(title: "Objection: \(objection.grounds)",
                                        yourRuling: sustained ? "Sustained" : "Overruled",
                                        correct: correct, explanation: objection.explanation,
                                        doctrineID: objection.doctrineID))
            integrity += correct ? 1 : -3
            possible += 1
            points += correct ? 1 : 0
        }

        // Verdicts
        let proper = properStrength(c)
        let ruled = ruledStrength(c, r)
        var verdictLines: [VerdictLine] = []
        var anyUnsoundConviction = false
        var convicted = false
        for charge in c.charges {
            let verdict = r.verdicts[charge.id] ?? .notGuilty
            let sound = isAcceptable(verdict, charge: charge, strength: proper)
            let label: String
            switch verdict {
            case .guilty: label = "Guilty"
            case .lesser: label = "Guilty of \(charge.lesserLaw?.title ?? "lesser offense")"
            case .notGuilty: label = "Not Guilty"
            }
            if verdict != .notGuilty {
                convicted = true
                if !sound { anyUnsoundConviction = true }
            }
            verdictLines.append(VerdictLine(count: charge.count, chargeTitle: charge.law.title, verdictLabel: label,
                                            sound: sound, explanation: assessment(charge: charge, strength: proper)))
            integrity += sound ? 4 : -8
            possible += 5
            points += sound ? 5 : 0
        }

        // Sentence
        var sentenceSummary: String?
        var sentenceAssessment: String?
        var sentenceZ = 0.0
        var harshness = 1.0
        if convicted {
            var chosenTerms: [Int] = []
            var guidelineTerms: [Int] = []
            for charge in c.charges {
                let verdict = r.verdicts[charge.id] ?? .notGuilty
                guard let law = convictedLaw(charge, verdict), let range = law.sentence else { continue }
                let chosen = r.probation ? 0 : (r.sentences[charge.id] ?? range.minMonths)
                chosenTerms.append(chosen)
                guidelineTerms.append(guideline(for: range, in: c))
            }
            let total = combine(chosenTerms, consecutive: r.consecutive)
            let sortedGuides = guidelineTerms.sorted(by: >)
            var guide = sortedGuides.first ?? 0
            for extra in sortedGuides.dropFirst() { guide += extra / 4 }
            guide = min(guide, SentenceRange.life)

            if r.probation {
                sentenceSummary = "Probation (prison suspended)" + (r.fine > 0 ? " + \(SentenceFormat.dollars(r.fine)) fine" : "")
            } else {
                sentenceSummary = SentenceFormat.months(total) + " in prison" + (r.fine > 0 ? " + \(SentenceFormat.dollars(r.fine)) fine" : "")
            }

            let scale = max(6.0, Double(guide) * 0.35)
            sentenceZ = Double(total - guide) / scale
            harshness = guide == 0 ? (total == 0 ? 1.0 : 2.0) : Double(total) / Double(guide)
            let guideText = guide == 0 ? "probation or no custody" : SentenceFormat.months(guide)
            if abs(sentenceZ) <= 1 {
                sentenceAssessment = "Proportionate. Guideline estimate for this defendant: about \(guideText)."
                integrity += 3
                points += 3
            } else if abs(sentenceZ) <= 2 {
                sentenceAssessment = "On the \(sentenceZ > 0 ? "harsh" : "lenient") side, but within reason. Guideline estimate: about \(guideText)."
                points += 2
            } else {
                sentenceAssessment = "Disproportionately \(sentenceZ > 0 ? "harsh" : "lenient"). Guideline estimate: about \(guideText)."
                integrity -= 5
            }
            possible += 3
        }

        // Appeal
        let appeal: AppealResult
        if !convicted {
            let wrongfullySuppressed = c.motions.contains { !$0.shouldGrant && (r.motions[$0.id] ?? false) }
            appeal = .none(wrongfullySuppressed
                ? "The State believes you wrongly suppressed evidence, but an acquittal can never be appealed. Double jeopardy makes your verdict final."
                : "An acquittal is final. Double jeopardy bars any appeal.")
        } else if anyUnsoundConviction {
            if ruled > proper {
                appeal = .reversed("The Court of Appeals reversed: evidence or testimony that should have been excluded was essential to the conviction. The remaining admissible evidence did not prove guilt beyond a reasonable doubt.")
            } else {
                appeal = .reversed("The Court of Appeals reversed: no rational fact-finder could have found every element proven beyond a reasonable doubt on this record.")
            }
            integrity -= 6
        } else if abs(sentenceZ) > 2.6 {
            appeal = .sentenceVacated(sentenceZ > 0
                ? "The defense appealed the sentence. The Court of Appeals vacated it as substantively unreasonable and remanded for resentencing."
                : "The State appealed the sentence. The Court of Appeals vacated it as unreasonably lenient given the aggravating factors.")
            integrity -= 3
        } else if ruled > proper {
            appeal = .affirmedHarmless
        } else {
            appeal = .affirmed
        }

        // Public reaction
        var reaction: String
        var publicDelta = 0.0
        switch c.mood {
        case .wantsConviction:
            if convicted {
                publicDelta = 4 + (harshness >= 1.1 ? 2 : 0) - ((harshness < 0.6 || r.probation) ? 5 : 0)
                reaction = harshness < 0.6 || r.probation
                    ? "The conviction pleases the public, but the sentence doesn't. \"A Slap on the Wrist,\" reads the editorial."
                    : "The gallery murmurs approval. Talk radio praises \"a judge with a spine.\""
            } else {
                publicDelta = -8
                reaction = "Outrage. Protesters gather outside your chambers, and a recall petition starts circulating online."
            }
        case .sympathetic:
            if convicted {
                publicDelta = -2 + ((harshness < 0.7 || r.probation) ? 4 : 0) - (harshness > 1.2 ? 4 : 0)
                reaction = harshness < 0.7 || r.probation
                    ? "Supporters are relieved by the mercy in your sentence, even if they hoped for an acquittal."
                    : "\"The System Crushed Them,\" reads a viral post. Many in the city feel you showed no mercy."
            } else {
                publicDelta = 5
                reaction = "Cheers erupt in the gallery. Local news calls it \"a triumph of compassion and common sense.\""
            }
        case .divided:
            publicDelta = convicted ? 0 : -1
            reaction = "The city splits down the middle. Half the comments call you a hero; half call you a disgrace."
        case .indifferent:
            publicDelta = 1
            reaction = "A short item in the Port Hollis Ledger. Life goes on."
        }
        approval += Int((publicDelta * mediaFactor).rounded())
        if appeal.isBad { approval -= 3 }

        // Truth & epilogue
        let epiloguePool: [String]
        switch (convicted, truthGuilty) {
        case (true, true): epiloguePool = GenericPools.convictedGuilty
        case (true, false): epiloguePool = GenericPools.convictedInnocent
        case (false, true): epiloguePool = GenericPools.acquittedGuilty
        case (false, false): epiloguePool = GenericPools.acquittedInnocent
        }
        if convicted && !truthGuilty { approval -= 4 }

        let headline: String
        switch appeal {
        case .reversed: headline = "Reversed on Appeal"
        case .sentenceVacated: headline = "Sentence Vacated"
        case .affirmed, .affirmedHarmless: headline = "Conviction Affirmed"
        case .none: headline = "Acquitted"
        case .dismissalReversed: headline = "Dismissal Reversed"
        }

        return CaseOutcome(headline: headline, grade: grade(points: points, possible: possible), score: percent(points, possible),
                           dismissed: false, reviews: reviews, verdictLines: verdictLines, convicted: convicted,
                           appeal: appeal, sentenceSummary: sentenceSummary, sentenceAssessment: sentenceAssessment,
                           truthGuilty: truthGuilty, truthText: c.truth.revelation,
                           epilogue: fill(epiloguePool.randomElement() ?? "", c), publicReaction: reaction,
                           integrityDelta: integrity, approvalDelta: approval, ethicsResult: ethicsResult)
    }

    private static func percent(_ points: Int, _ possible: Int) -> Int {
        possible == 0 ? 100 : Int((Double(points) / Double(possible) * 100).rounded())
    }

    private static func grade(points: Int, possible: Int) -> String {
        switch percent(points, possible) {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }

    private static func fill(_ text: String, _ c: CourtCase) -> String {
        TextFiller(values: ["DL": c.defendant.lastName, "D": c.defendant.name])(text)
    }
}
