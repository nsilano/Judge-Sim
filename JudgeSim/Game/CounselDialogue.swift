import Foundation

/// How a particular lawyer tends to talk. Fixed for each member of the county bar.
enum CounselStyle: String, CaseIterable {
    case methodical, aggressive, pragmatic, earnest, combative, folksy

    var label: String {
        switch self {
        case .methodical: return "Methodical, by the book"
        case .aggressive: return "Aggressive, rarely concedes"
        case .pragmatic: return "Pragmatic, looks for resolution"
        case .earnest: return "Earnest, client-focused"
        case .combative: return "Combative, pushes every point"
        case .folksy: return "Folksy, plain-spoken"
        }
    }

    static func forName(_ name: String, side: Side) -> CounselStyle {
        let value = name.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFF }
        let options: [CounselStyle] = side == .prosecution
            ? [.methodical, .aggressive, .pragmatic]
            : [.earnest, .combative, .folksy, .pragmatic]
        return options[value % options.count]
    }

    var opener: String {
        switch self {
        case .methodical: return "Your Honor, "
        case .aggressive: return "Judge, "
        case .pragmatic: return "Judge, "
        case .earnest: return "Your Honor, "
        case .combative: return "With respect, Judge, "
        case .folksy: return "Well, Judge, "
        }
    }
}

/// Something the judge learns by asking.
enum CounselReveal: Hashable {
    case mitigating(String)
    case aggravating(String)
}

struct CounselQuestion: Identifiable, Hashable {
    let id: String
    let side: Side
    let question: String
    let answer: String
    var reveal: CounselReveal?
}

struct TranscriptEntry: Identifiable, Hashable {
    let id = UUID()
    let side: Side
    let speaker: String
    let question: String
    let answer: String
    let reveal: CounselReveal?
}

/// Builds the questions a judge can put to counsel at each stage, with answers drawn from the case.
enum CounselDialogue {

    static func name(_ c: CourtCase, side: Side) -> String {
        let raw = side == .prosecution ? c.prosecutor : c.defenseAttorney
        return raw.components(separatedBy: ",").first ?? raw
    }

    static func style(_ c: CourtCase, side: Side) -> CounselStyle {
        CounselStyle.forName(name(c, side: side), side: side)
    }

    static func questions(_ c: CourtCase, stage: CaseSession.Stage, rulings r: Rulings, units: [SentencingUnit]) -> [CounselQuestion] {
        let bg = c.background ?? fallbackBackground
        switch stage {
        case .briefing: return pretrial(c, bg)
        case .motions: return motions(c, bg, r)
        case .trial, .verdict: return trial(c, bg, r)
        case .sentencing: return sentencing(c, bg, r, units)
        case .probation: return probation(c, bg, r)
        case .judgment: return []
        }
    }

    static let fallbackBackground = CaseBackground(
        pleaOffer: nil, pleaRejection: nil, custodyDays: 0, bondStatus: "Released on bond.", restitution: 0,
        restitutionBasis: nil, victimStance: .none, victimStanceDetail: "The State hasn't been in contact with a victim.",
        treatmentNeed: .none, treatmentDetail: nil, treatmentBedAvailable: false, employmentPlan: nil, indigent: true,
        supportPeople: nil, willTestify: false, discoveryIssue: nil, stateObjectsToASR: true, hiddenMitigator: nil,
        hiddenAggravator: nil, attorneyFeeEstimate: 1_500)

    // MARK: Pretrial

    private static func pretrial(_ c: CourtCase, _ bg: CaseBackground) -> [CounselQuestion] {
        let s = style(c, side: .prosecution)
        let d = style(c, side: .defense)
        let dl = c.defendant.lastName
        var q: [CounselQuestion] = []

        let strongest = c.evidence.filter { $0.side == .prosecution }.max { $0.weight < $1.weight }
        q.append(CounselQuestion(id: "pre.state.theory", side: .prosecution,
                                 question: "Walk me through the State's case.",
                                 answer: c.prosecutionOpening + (strongest.map { " The centerpiece is \($0.exhibit), the \($0.title.lowercased())." } ?? "")))
        q.append(CounselQuestion(id: "pre.state.plea", side: .prosecution,
                                 question: "Was a plea offer extended?",
                                 answer: s.opener + (bg.pleaOffer.map { "yes. The offer was: \($0) It was rejected." }
                                                     ?? "no offer. District Attorney's office policy on cases like this is to try them.")))
        if let charge = c.charges.first, let lesser = charge.lesserLaw {
            let element = charge.law.elements.last ?? "the additional element"
            let confident = s == .aggressive
            q.append(CounselQuestion(id: "pre.state.charging", side: .prosecution,
                                     question: "Why charge \(charge.law.title) rather than \(lesser.title)?",
                                     answer: s.opener + (confident
                                        ? "because the evidence supports it. \(element) We'll prove that."
                                        : "the difference is this element: \(element.lowercased()) We believe the evidence gets us there, and if it doesn't, the court can consider the lesser-included offense.")))
        }
        if c.victimName != nil {
            q.append(CounselQuestion(id: "pre.state.victim", side: .prosecution,
                                     question: "Where does the victim stand?",
                                     answer: bg.victimStanceDetail))
        }
        q.append(CounselQuestion(id: "pre.state.discovery", side: .prosecution,
                                 question: "Has the State complied with discovery?",
                                 answer: s.opener + (bg.discoveryIssue.map { "in candor to the court, there's one issue. \($0)" }
                                                     ?? "yes. Open file. Everything we have, the defense has.")))
        let shaky = c.witnesses.filter { $0.calledBy == .prosecution }.first { w in
            w.cross.contains { $0.lowercased().contains("admits") || $0.lowercased().contains("concedes") || $0.lowercased().contains("acknowledges") }
        }
        q.append(CounselQuestion(id: "pre.state.witnesses", side: .prosecution,
                                 question: "Any problems with your witnesses I should know about?",
                                 answer: s.opener + (shaky.map { "the defense will go after \($0.name) on cross, and they'll have some material. We think the testimony holds up overall." }
                                                     ?? "no concerns. Our witnesses are here and ready.")))
        if c.habitualIndicted {
            q.append(CounselQuestion(id: "pre.state.habitual", side: .prosecution,
                                     question: "Why is the State seeking habitual felon status?",
                                     answer: s.opener + "the defendant has \(c.defendant.priors.filter { $0.ncClass.isFelony }.count) prior felony convictions. " + (s == .pragmatic
                                        ? "Frankly, we'd have dismissed the status in exchange for a plea. That offer is gone."
                                        : "District Attorney policy is to indict habitual status where the record supports it, and it does.")))
        }

        q.append(CounselQuestion(id: "pre.def.theory", side: .defense,
                                 question: "What's the defense theory?",
                                 answer: c.defenseOpening))
        q.append(CounselQuestion(id: "pre.def.plea", side: .defense,
                                 question: bg.pleaOffer == nil ? "Has there been any plea discussion?" : "Why did your client reject the State's offer?",
                                 answer: bg.pleaRejection ?? (d.opener + "the State never made an offer we could take back to our client.")))
        q.append(CounselQuestion(id: "pre.def.custody", side: .defense,
                                 question: "Is your client in custody?",
                                 answer: bg.bondStatus))
        q.append(CounselQuestion(id: "pre.def.testify", side: .defense,
                                 question: "Will your client testify?",
                                 answer: d.opener + (bg.willTestify
                                    ? "we expect \(dl) to testify. We've discussed the risks."
                                    : "we don't anticipate it. That's \(dl)'s constitutional right, and I'd remind the court it can draw no inference from it.")))
        q.append(CounselQuestion(id: "pre.def.capacity", side: .defense,
                                 question: "Any capacity or mental health concerns I should be aware of?",
                                 answer: d.opener + (bg.treatmentNeed.mentalHealth
                                    ? "nothing that rises to incapacity to proceed. But there is history. \(bg.treatmentDetail ?? "") It'll matter at sentencing, if we get there."
                                    : "no capacity issues. \(dl) understands the proceedings and has helped prepare the defense.")))
        q.append(CounselQuestion(id: "pre.def.ready", side: .defense,
                                 question: "Are you ready to proceed?",
                                 answer: d.opener + (c.defenseAttorney.contains("Public Defender")
                                    ? "we're ready. I'll note our office is carrying a heavy caseload, but this case has had the attention it needs."
                                    : "we're ready.")))
        return q
    }

    // MARK: Motions

    private static func motions(_ c: CourtCase, _ bg: CaseBackground, _ r: Rulings) -> [CounselQuestion] {
        let s = style(c, side: .prosecution)
        let d = style(c, side: .defense)
        var q: [CounselQuestion] = []
        for (index, motion) in c.motions.enumerated() {
            let target = c.evidence(motion.targetEvidenceID)
            let label = target.map { "\($0.title.lowercased())" } ?? "the case"
            let stateStrong = !motion.shouldGrant
            q.append(CounselQuestion(id: "mot.state.\(index)", side: .prosecution,
                                     question: "What's the State's best argument on the motion regarding \(label)?",
                                     answer: s.opener + (stateStrong
                                        ? "it's straightforward. " + motion.appellateNote + " The officers did what the law requires."
                                        : (s == .aggressive
                                           ? "the officers acted reasonably in a fast-moving situation, and the exclusionary rule exists to deter misconduct, not good police work."
                                           : "I'll be candid. This is the State's weakest issue. We'd ask the court to find the officers acted in good faith."))))
            q.append(CounselQuestion(id: "mot.def.\(index)", side: .defense,
                                     question: "What's your strongest point on the motion regarding \(label)?",
                                     answer: d.opener + (motion.shouldGrant
                                        ? "look at the facts the court heard: " + motion.facts + " That's the whole motion, Judge. The Constitution doesn't bend because the result is inconvenient."
                                        : (d == .combative
                                           ? "the State's story about this search doesn't add up, and the court shouldn't accept it at face value."
                                           : "I'll be honest with the court: the facts at the hearing weren't as helpful as we hoped. We preserve the issue."))))
            if let target, motion.kind != .dismissSpeedyTrial {
                let remaining = Judgment.properStrength(c) - (motion.shouldGrant ? 0 : target.weight)
                let primary = c.charges.first?.threshold ?? 8
                q.append(CounselQuestion(id: "mot.state.impact.\(index)", side: .prosecution,
                                         question: "If I suppress \(target.title.lowercased()), can the State still proceed?",
                                         answer: s.opener + (target.weight >= 4 || remaining < primary
                                            ? "candidly, it would hurt badly. It's central to the case."
                                            : "yes. It's significant, but the case doesn't rise or fall on it.")))
            }
        }
        return q
    }

    // MARK: Trial

    private static func trial(_ c: CourtCase, _ bg: CaseBackground, _ r: Rulings) -> [CounselQuestion] {
        let s = style(c, side: .prosecution)
        let d = style(c, side: .defense)
        let dl = c.defendant.lastName
        var q: [CounselQuestion] = []
        let excluded = r.excludedEvidence(in: c)

        for item in c.evidence where !excluded.contains(item.id) {
            if item.side == .prosecution {
                q.append(CounselQuestion(id: "tri.state.ex.\(item.exhibit)", side: .prosecution,
                                         question: "Tell me more about \(item.exhibit), the \(item.title.lowercased()).",
                                         answer: s.opener + (item.weight >= 4
                                            ? "it was collected and documented properly, the chain of custody is complete, and it speaks directly to the defendant's guilt."
                                            : item.weight >= 2
                                                ? "it's corroborative. On its own it wouldn't carry the case, but it fits with everything else."
                                                : "it's a small piece. We offered it for completeness.")))
                q.append(CounselQuestion(id: "tri.def.ex.\(item.exhibit)", side: .defense,
                                         question: "What's the defense's answer to \(item.exhibit)?",
                                         answer: d.opener + (item.weight >= 4
                                            ? (d == .combative ? "it proves less than the State says. Weigh it for what it actually shows." : "it's a hard piece of evidence, and I won't pretend otherwise. We ask the court to weigh it in context.")
                                            : "it's thin. It shows, at most, that \(dl) was in the wrong place. It doesn't show what the State needs it to.")))
            } else {
                q.append(CounselQuestion(id: "tri.state.def.\(item.exhibit)", side: .prosecution,
                                         question: "What's the State's response to \(item.exhibit), the \(item.title.lowercased())?",
                                         answer: s.opener + (item.weight >= 3
                                            ? "it's a fair point, and the State has to account for it. But it doesn't explain away the rest of our evidence."
                                            : "it's a distraction. It doesn't actually contradict anything the State proved.")))
            }
        }
        for witness in c.witnesses {
            let callingSide = witness.calledBy
            let otherSide: Side = callingSide == .prosecution ? .defense : .prosecution
            let callingStyle = callingSide == .prosecution ? s : d
            let otherStyle = otherSide == .prosecution ? s : d
            q.append(CounselQuestion(id: "tri.\(callingSide.rawValue).wit.\(witness.id)", side: callingSide,
                                     question: "Why should I credit \(witness.name)?",
                                     answer: callingStyle.opener + (witness.weight >= 2
                                        ? "\(witness.name) was consistent on direct and cross, and has no reason to shade the truth."
                                        : "\(witness.name) had some trouble on cross, I'll concede. But the core of the testimony held.")))
            q.append(CounselQuestion(id: "tri.\(otherSide.rawValue).wit.\(witness.id)", side: otherSide,
                                     question: "What's wrong with \(witness.name)'s testimony?",
                                     answer: otherStyle.opener + (witness.cross.last.map { "remember what came out on cross: \($0)" } ?? "the testimony goes further than the witness's actual knowledge.")))
        }
        if !bg.willTestify {
            q.append(CounselQuestion(id: "tri.def.silent", side: .defense,
                                     question: "Is your client going to testify?",
                                     answer: d.opener + "no. \(dl) has exercised the right not to testify, and the court may not hold that against \(dl) in any way."))
        }
        q.append(CounselQuestion(id: "tri.state.burden", side: .prosecution,
                                 question: "If I have doubt about one element, where is it likely to be?",
                                 answer: s.opener + (s == .aggressive
                                    ? "there's no doubt on any element. The evidence is consistent across the board."
                                    : "if anywhere, it's the mental state. But the circumstances show what was in the defendant's mind.")))
        return q
    }

    // MARK: Sentencing

    static func recommendation(_ c: CourtCase, side: Side, units: [SentencingUnit]) -> String {
        guard let unit = units.first else { return "We'll defer to the court." }
        let persona = style(c, side: side)
        if unit.isMandatoryLife { return "The sentence is fixed by law, Judge: life without parole." }
        if let cell = unit.felonyCell {
            if side == .prosecution {
                switch persona {
                case .aggressive:
                    let range = c.aggravating.isEmpty ? cell.presumptive : (cell.aggravated ?? cell.presumptive)
                    return "The State asks for \(range.high) months, the top of the \(c.aggravating.isEmpty ? "presumptive" : "aggravated") range, active."
                case .pragmatic where cell.dispositions.contains(.intermediate):
                    return "The State would accept \(cell.presumptive.low) months suspended, on intermediate punishment with strict conditions."
                default:
                    let mid = (cell.presumptive.low + cell.presumptive.high) / 2
                    return "The State asks for \(mid) months in the presumptive range, active" + (cell.dispositions.contains(.active) ? "." : ", or the most restrictive disposition the chart allows.")
                }
            } else {
                let range = cell.mitigated
                if cell.dispositions.contains(.community) {
                    return "We ask for \(range.low) months in the mitigated range, suspended, on community punishment."
                }
                if cell.dispositions.contains(.intermediate) {
                    return "We ask for \(range.low) months in the mitigated range, suspended, with intermediate conditions including treatment."
                }
                return "The chart requires an active sentence here. We ask for the bottom of the mitigated range: \(range.low) months."
            }
        }
        if let cell = unit.misdemeanorCell {
            return side == .prosecution
                ? "The State asks for \(cell.maxDays) days" + (cell.dispositions.contains(.active) ? ", active." : ", suspended, on supervised probation.")
                : "We ask for a short suspended sentence on unsupervised probation, or a prayer for judgment continued."
        }
        return "We'll defer to the court."
    }

    private static func sentencing(_ c: CourtCase, _ bg: CaseBackground, _ r: Rulings, _ units: [SentencingUnit]) -> [CounselQuestion] {
        let s = style(c, side: .prosecution)
        let d = style(c, side: .defense)
        let dl = c.defendant.lastName
        var q: [CounselQuestion] = []

        q.append(CounselQuestion(id: "sen.state.rec", side: .prosecution,
                                 question: "What sentence is the State requesting?",
                                 answer: recommendation(c, side: .prosecution, units: units)))
        q.append(CounselQuestion(id: "sen.state.restitution", side: .prosecution,
                                 question: "Is the State seeking restitution?",
                                 answer: s.opener + (bg.restitution > 0
                                    ? "yes, \(SentenceFormat.dollars(bg.restitution)) for \(bg.restitutionBasis ?? "the losses"). We'll hand up the documentation."
                                    : "no. There's no quantifiable loss in this case.")))
        if c.victimName != nil {
            q.append(CounselQuestion(id: "sen.state.victim", side: .prosecution,
                                     question: "What does the victim's family want?",
                                     answer: bg.victimStanceDetail))
        }
        q.append(CounselQuestion(id: "sen.state.conditions", side: .prosecution,
                                 question: "If I suspend the sentence, what conditions would the State want?",
                                 answer: s.opener + stateConditions(c, bg)))
        if units.contains(where: { [NCClass.D, .E, .F, .G, .H].contains($0.sentencingClass) }) {
            q.append(CounselQuestion(id: "sen.state.asr", side: .prosecution,
                                     question: "Would the State object to Advanced Supervised Release?",
                                     answer: s.opener + (bg.stateObjectsToASR
                                        ? "yes, the State objects. Given the nature of this offense, we want the full minimum served."
                                        : "the State has no objection to ASR.")))
        }
        q.append(CounselQuestion(id: "sen.state.more", side: .prosecution,
                                 question: "Is there anything else the court should consider?",
                                 answer: s.opener + (bg.hiddenAggravator.map { "yes. The State offers this as an aggravating factor: \($0.lowercased()). We gave notice and have the records." }
                                                     ?? "nothing further, Judge."),
                                 reveal: bg.hiddenAggravator.map { .aggravating($0) }))

        q.append(CounselQuestion(id: "sen.def.rec", side: .defense,
                                 question: "What is the defense asking for?",
                                 answer: recommendation(c, side: .defense, units: units)))
        q.append(CounselQuestion(id: "sen.def.plan", side: .defense,
                                 question: "What's your client's plan if released?",
                                 answer: (bg.employmentPlan ?? "Honestly, it's a work in progress. \(dl) would need help finding work.")
                                     + (bg.treatmentNeed != .none ? (bg.treatmentBedAvailable ? " There's also a treatment bed being held for \(dl) starting next week." : " We're on a waiting list for treatment.") : "")))
        q.append(CounselQuestion(id: "sen.def.pay", side: .defense,
                                 question: "Can your client pay fines, fees, and restitution?",
                                 answer: d.opener + (bg.indigent
                                    ? "no. \(dl) qualified for appointed counsel and has no assets. Every dollar of fees makes it harder to comply with probation. We ask the court to remit costs and fees."
                                    : "within reason, yes. \(dl) is employed and can make monthly payments.")))
        if bg.treatmentNeed != .none {
            q.append(CounselQuestion(id: "sen.def.treatment", side: .defense,
                                     question: "Is there a substance use or mental health issue I should address?",
                                     answer: (bg.treatmentDetail ?? "Yes.") + " Treatment, not just punishment, is what will keep \(dl) out of this courtroom.",
                                     reveal: bg.treatmentNeed.mentalHealth
                                        ? .mitigating("The defendant was suffering from a mental or physical condition that was insufficient to constitute a defense but significantly reduced culpability")
                                        : nil))
        }
        if let support = bg.supportPeople {
            q.append(CounselQuestion(id: "sen.def.support", side: .defense,
                                     question: "Is anyone here in support of your client?",
                                     answer: support,
                                     reveal: .mitigating("The defendant has a support system in the community")))
        }
        q.append(CounselQuestion(id: "sen.def.more", side: .defense,
                                 question: "Is there anything about your client the court doesn't know?",
                                 answer: d.opener + (bg.hiddenMitigator.map { "yes. We offer this as a mitigating factor: \($0.lowercased()). I have documentation." }
                                                     ?? "I think the court has the full picture."),
                                 reveal: bg.hiddenMitigator.map { .mitigating($0) }))
        if bg.custodyDays > 0 {
            q.append(CounselQuestion(id: "sen.def.credit", side: .defense,
                                     question: "How much time has your client already served?",
                                     answer: d.opener + "\(bg.custodyDays) days in the Hollis County jail. We ask that it be credited, as the statute requires."))
        }
        return q
    }

    private static func stateConditions(_ c: CourtCase, _ bg: CaseBackground) -> String {
        var asks: [String] = []
        if c.victimName != nil { asks.append("no contact with the victim's family") }
        if bg.restitution > 0 { asks.append("restitution as a condition of probation") }
        if bg.treatmentNeed.substance { asks.append("random drug screens and a TASC assessment") }
        if c.category == .violent || c.category == .robbery || c.category == .publicOrder { asks.append("surrender of all firearms") }
        asks.append("supervised probation")
        return "we'd ask for " + asks.joined(separator: ", ") + "."
    }

    // MARK: Probation violation (within a trial)

    private static func probation(_ c: CourtCase, _ bg: CaseBackground, _ r: Rulings) -> [CounselQuestion] {
        guard let term = c.defendant.probation else { return [] }
        let s = style(c, side: .prosecution)
        let d = style(c, side: .defense)
        let convicted = c.charges.contains { (r.verdicts[$0.id] ?? .notGuilty) != .notGuilty }
        return [
            CounselQuestion(id: "pv.state.position", side: .prosecution,
                            question: "What is the State's position on the violation?",
                            answer: s.opener + (convicted
                                ? "the court has just convicted the probationer of a new offense. That is a revocation-eligible violation, and the State asks the court to revoke and activate \(term.suspendedSentence)."
                                : "even with today's verdict, the State contends the court can be reasonably satisfied a new offense occurred. We ask at minimum for a CRV.")),
            CounselQuestion(id: "pv.def.position", side: .defense,
                            question: "What's the defense position on the violation?",
                            answer: d.opener + (convicted
                                ? "we ask the court not to stack time on time. Continue or modify probation and let today's judgment do the work."
                                : "the court just found my client not guilty. Revoking probation on the same facts would undercut that verdict.")),
            CounselQuestion(id: "pv.state.compliance", side: .prosecution,
                            question: "How had the probationer been doing before this?",
                            answer: s.opener + ((term.crvCount ?? 0) > 0
                                ? "there's been a prior CRV. Compliance has been uneven."
                                : "the officer reports reasonable compliance until the new charge, aside from some late payments."))
        ]
    }
}
