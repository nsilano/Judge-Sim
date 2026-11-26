import Foundation

/// A conference with both lawyers at the bench before sentencing: each side's recommendation, and whether
/// the State will consent to the court arresting judgment on a count.
enum BenchConference {

    struct Line: Identifiable, Hashable {
        let id = UUID()
        let speaker: String
        let side: Side?
        let text: String
    }

    /// Counts the defendant stands convicted of, most serious first, ignoring arrests.
    static func convictedCharges(_ c: CourtCase, _ r: Rulings) -> [Charge] {
        c.charges
            .filter { r.verdicts[$0.id]?.isConviction == true }
            .sorted { lhs, rhs in
                let a = severity(lhs, r), b = severity(rhs, r)
                return a == b ? lhs.count < rhs.count : a < b
            }
    }

    /// How serious the count of conviction is. Impaired driving has no class of its own and is sentenced under
    /// G.S. 20-179; it ranks with the Class 1 misdemeanors.
    private static func severity(_ charge: Charge, _ r: Rulings) -> Int {
        guard let law = r.verdicts[charge.id].flatMap({ Judgment.convictedLaw(charge, $0) }) else { return 99 }
        if let cls = law.ncClass { return cls.severity }
        return Judgment.isDWI(law) ? NCClass.misd1.severity : 99
    }

    /// The person a count names as its victim: the first name in its specification that appears among the case's
    /// people, so counts about different people don't merge.
    private static func victimNamed(in charge: Charge, _ c: CourtCase) -> String? {
        let names = ([c.victimName] + c.witnesses.map { Optional($0.name) }).compactMap { $0 }
        return names.filter { charge.specification.contains($0) }
            .min { (charge.specification.range(of: $0)?.lowerBound ?? charge.specification.endIndex) < (charge.specification.range(of: $1)?.lowerBound ?? charge.specification.endIndex) }
    }

    /// How far the State will go on arresting judgment on the other counts in this case.
    enum Posture {
        /// Every count stands; the State won't consent to arresting any of them.
        case firm
        /// The State gives up the lesser counts but fights for the ones that are serious in their own right.
        case selective
        /// Anything but the lead count, if it simplifies the judgment.
        case flexible
    }

    /// Set once per case by the prosecutor's temperament, the community's mood, and whether there was a plea.
    static func posture(_ c: CourtCase, _ r: Rulings) -> Posture {
        var rng = SeededRNG(seed: c.seed ^ 0xA77E57)
        var firm = 0.25, flexible = 0.3
        switch CounselDialogue.style(c, side: .prosecution) {
        case .aggressive, .combative: firm += 0.25; flexible -= 0.15
        case .pragmatic, .folksy: firm -= 0.1; flexible += 0.2
        default: break
        }
        if c.mood == .wantsConviction { firm += 0.15 }
        if c.victimName != nil && [LawCategory.violent, .family, .robbery].contains(c.category) { firm += 0.1 }
        // A negotiated plea usually settles what the counts are worth.
        if r.pleaAccepted == true { firm -= 0.2; flexible += 0.3 }
        let roll = Double.random(in: 0..<1, using: &rng)
        if roll < max(0.05, firm) { return .firm }
        if roll < max(0.05, firm) + max(0.05, flexible) { return .flexible }
        return .selective
    }

    /// A count the law folds into the lead count (a lesser offense of the same conduct): arresting judgment on it
    /// is proper whatever the State thinks.
    static func merges(_ c: CourtCase, _ r: Rulings, charge: Charge) -> Bool {
        guard let principal = convictedCharges(c, r).first, principal.id != charge.id else { return false }
        if charge.lawID == principal.lesserLawID { return true }
        // One death, one homicide: murder and a manslaughter or death-by-vehicle count for the same killing.
        let homicide = ["murder1", "murder2", "volManslaughter", "invManslaughter", "felonyDBV", "misdDBV"]
        guard homicide.contains(principal.lawID) && homicide.contains(charge.lawID) && principal.lawID != charge.lawID else { return false }
        // Two deaths are two homicides.
        return victimNamed(in: principal, c) == victimNamed(in: charge, c)
    }

    /// Whether the State agrees to arresting judgment on this count.
    static func stateConsents(_ c: CourtCase, _ r: Rulings, charge: Charge) -> Bool {
        guard let principal = convictedCharges(c, r).first, principal.id != charge.id else { return false }
        switch posture(c, r) {
        case .firm: return false
        case .flexible: return true
        case .selective:
            // The State holds on to a felony that stands on its own: a different kind of crime, a weapon, or a
            // class close to the lead count's.
            let cls = charge.law.ncClass, lead = principal.law.ncClass
            let separate = charge.law.category != principal.law.category
                || ["felonFirearm", "dischargingOccupied", "awdwikisi", "awdwisi", "strangulation", "kidnapping2", "kidnapping1"].contains(charge.lawID)
            let close = (cls?.isFelony ?? false) && abs((cls?.severity ?? 99) - (lead?.severity ?? 0)) <= 2
            var rng = SeededRNG(seed: c.seed ^ UInt64(charge.count) &* 0x9E37)
            return !((cls?.isFelony ?? false) && (separate || close)) || rng.chance(0.2)
        }
    }

    static func transcript(_ c: CourtCase, _ r: Rulings) -> [Line] {
        var rng = SeededRNG(seed: c.seed ^ 0xBE4C4)
        let pros = CounselDialogue.name(c, side: .prosecution)
        let def = CounselDialogue.name(c, side: .defense)
        let dl = c.defendant.lastName
        var lines: [Line] = []
        let convicted = convictedCharges(c, r)
        guard let principal = convicted.first else { return lines }

        lines.append(Line(speaker: "The court", side: nil,
                          text: rng.pick(["Counsel, approach. Before I pronounce judgment, I want to hear where each of you stands.",
                                          "Both of you, up here please. Let's talk about judgment before I rule.",
                                          "Approach the bench. I'd like your positions on judgment off the record before we go back on.", "Counsel, please approach. I want your positions on judgment before I announce it.", "Let's go off the record for a moment. Tell me where you each are on sentencing.", "Counsel, come up, please. I'd like to hear from both of you on judgment before I announce it.", "Come on up, both of you. Let's talk through where each side is on sentencing.", "Let's have a brief word at the bench before I pronounce judgment.", "Counsel, approach. I'd like to hear any final thoughts on judgment, and then we'll be back on the record.", "Before we go further, I'd like to see both counsel at the bench about judgment.", "Approach, please. Tell me what you're asking for and why, and I'll take it under advisement."])))

        // Each side's recommendation, from the chart for the most serious conviction.
        let units = Judgment.units(c, r)
        if let unit = units.first(where: { $0.id == principal.id }) ?? units.first {
            if let cell = unit.felonyCell {
                let top = cell.presumptive.high
                let low = cell.mitigated.low
                let probationOK = cell.dispositions.contains(.intermediate) || cell.dispositions.contains(.community)
                let victimLine = c.victimName.map { " \($0)'s family is in the courtroom and they've waited a long time for this." } ?? ""
                let request = rng.pick(["The State asks for the top of the presumptive range on Count \(principal.count), \(top) months, active.",
                                        "The State's position is \(top) months active on Count \(principal.count).",
                                        "On Count \(principal.count), the State is asking for \(top) months, active time.",
                                        "We're asking for \(top) months on Count \(principal.count), and we're asking that it be active.", "On Count \(principal.count), the State asks for \(top) months active, the top of the presumptive range.", "The State is asking for \(top) months on Count \(principal.count), active time, no probation.", "The State's recommendation is \(top) months active on Count \(principal.count), Your Honor.", "On Count \(principal.count), we're asking for the top of the range: \(top) months, active.", "Your Honor, the State requests an active sentence of \(top) months on Count \(principal.count).", "For Count \(principal.count), we ask for an active term of \(top) months.", "We're asking for \(top) months, active, on Count \(principal.count). The top of the range is what the facts support.", "The State's request on Count \(principal.count) is \(top) months, active, at the top of the presumptive range."])
                lines.append(Line(speaker: pros, side: .prosecution,
                                  text: Allocutions.stateArgument(c, request: request, plea: r.pleaAccepted == true) + (rng.chance(0.4) ? victimLine : "")))
                lines.append(Line(speaker: def, side: .defense,
                                  text: probationOK
                                    ? rng.pick(["We'd ask the court to suspend the sentence and place \(dl) on supervised probation. \(dl) has a job and a family to get back to.",
                                                "The chart allows probation here, Judge, and \(dl) is a good candidate for it. We'd ask for a suspended sentence with treatment conditions.", "We'd ask for a suspended sentence and supervised probation, Judge. \(dl) has a job, a family, and no history that calls for prison.", "The chart allows probation, Judge, and the defense asks for it with conditions \(dl) can meet.", "The chart allows probation, Judge, and \(dl) has done what was asked since the arrest. We'd ask for a suspended sentence and supervised probation.", "We'd ask the court to consider supervised probation for \(dl). It would let \(dl) keep working and keep paying whatever the court orders.", "Judge, this is a case where probation can do the job prison would do. We ask for a suspended sentence with conditions \(dl) can follow.", "We're asking for a suspended sentence, Judge. \(dl) has shown up to every court date and has support at home.", "A suspended sentence with supervised probation fits \(dl) and fits this offense, Judge.", "The defense asks for probation, Judge, with whatever conditions the court thinks are right. \(dl) is willing to meet them."])
                                    : rng.pick(["We'd ask for the bottom of the mitigated range, \(low) months. The mitigating factors are real.",
                                                "The chart requires active time, so we're asking for \(low) months, the bottom of the mitigated range, and credit for time served.", "We ask for \(low) months, the bottom of the mitigated range, and credit for every day served.", "The mitigating factors justify the lowest term, \(low) months, Judge.", "We ask the court to sentence at the bottom of the mitigated range, \(low) months, and to credit the time already served.", "Judge, the defense asks for \(low) months. The mitigating factors in the record support the lowest term.", "Given the mitigating factors, we'd ask for the minimum, \(low) months, with credit for all time in custody.", "We're asking for \(low) months, Judge, the bottom of the mitigated range. The record supports it.", "The defense asks for the shortest sentence the law allows here, \(low) months, along with credit for time served.", "We'd ask for \(low) months, Judge. The mitigators are in the record."])))
            } else if let cell = unit.misdemeanorCell {
                lines.append(Line(speaker: pros, side: .prosecution,
                                  text: Allocutions.stateArgument(c, request: "The State asks for \(cell.maxDays) day\(cell.maxDays == 1 ? "" : "s")" + (cell.dispositions.contains(.active) ? ", active." : ", suspended, with supervised probation."),
                                                                  plea: r.pleaAccepted == true)))
                lines.append(Line(speaker: def, side: .defense,
                                  text: "We'd ask for unsupervised probation, Judge. This is a misdemeanor and \(dl) has learned from it."))
            }
        }

        // The other counts: what each side says about arresting judgment.
        let stance = BenchConference.posture(c, r)
        if stance == .firm && convicted.count > 1 {
            lines.append(Line(speaker: def, side: .defense,
                              text: rng.pick(["We'd ask the court to arrest judgment on everything but Count \(principal.count). It's one course of conduct.",
                                              "Judge, these counts all come out of the same few minutes. We'd ask you to arrest judgment on the rest and sentence on Count \(principal.count).", "The defense asks the court to arrest judgment on every count but Count \(principal.count). They are one episode.", "These counts overlap, Judge. We ask you to sentence on Count \(principal.count) only.", "Judge, this is one transaction broken into several counts. We'd ask you to arrest judgment on all but Count \(principal.count).", "We ask the court to sentence on Count \(principal.count) and arrest judgment on the others, since they all arise from one event.", "The counts here overlap, Judge. Count \(principal.count) covers the conduct, and the rest only stack punishment on top.", "We'd ask that judgment be arrested on the remaining counts. They grow out of the same act as Count \(principal.count).", "The defense asks the court to treat this as one offense and sentence on Count \(principal.count).", "Count \(principal.count) captures what happened, Judge. We ask the court to arrest judgment on the others."])))
            lines.append(Line(speaker: pros, side: .prosecution,
                              text: rng.pick(["Absolutely not. The defendant was convicted of each of these counts, and each one is a separate harm. The State wants judgment on all of them.",
                                              "The State objects to arresting judgment on any count. The court found each element of each offense proven. That should mean something.",
                                              "No, Your Honor. If the court consolidates for sentencing, fine, but every conviction should be entered.", "The State opposes. Each count is its own offense, and the court found each one proven.", "No, Judge. The court found every element of every count, and each should stand.", "The State objects, Your Honor. Each count carries its own elements, and the court found each one proven.", "No, Judge. These are separate convictions and they should all be entered. The court can run them together at sentencing.", "We oppose arresting judgment on any of them. The court heard the evidence on every count and found it sufficient.", "The State disagrees. Entering judgment on every count is what the verdict calls for, Your Honor.", "Judge, the State has no objection to concurrent sentences, but arresting judgment goes too far.", "No. Each conviction stands on its own, and the State asks that judgment be entered on all of them."])))
        } else {
            for charge in convicted.dropFirst() {
                let consents = stateConsents(c, r, charge: charge)
                let merges = BenchConference.merges(c, r, charge: charge)
                lines.append(Line(speaker: def, side: .defense,
                                  text: merges
                                    ? "Count \(charge.count) is a lesser version of Count \(principal.count) for the same act. The law requires the court to arrest judgment on one of them."
                                    : rng.pick(["On Count \(charge.count), we'd ask the court to arrest judgment. It arises from the same conduct as Count \(principal.count), and the State gets its full punishment there.",
                                                "Count \(charge.count) adds nothing but a longer record, Judge. We'd ask you to arrest judgment.",
                                                "We'd ask the court to arrest judgment on Count \(charge.count). Same night, same people, same act.", "On Count \(charge.count), the defense asks the court to arrest judgment; it is the same act as Count \(principal.count).", "Count \(charge.count) is the same conduct as Count \(principal.count), Judge. We ask the court to arrest judgment on it.", "On Count \(charge.count), the State is asking you to punish one event two ways, Judge. We ask the court to arrest judgment.", "Count \(charge.count) merges into Count \(principal.count). We ask the court to arrest judgment on it.", "Count \(charge.count) doesn't add any separate harm, Judge. It's already covered by Count \(principal.count).", "We'd ask the court to arrest judgment on Count \(charge.count). It's part of the same episode as Count \(principal.count).", "Judge, Count \(charge.count) rests on the same facts as Count \(principal.count). Entering both is duplicative.", "For Count \(charge.count), we ask the court to arrest judgment, since Count \(principal.count) already accounts for what happened."])))
                if consents {
                    lines.append(Line(speaker: pros, side: .prosecution,
                                      text: rng.pick(["The State won't object to arresting judgment on Count \(charge.count), as long as Count \(principal.count) stands.",
                                                      "We can live with that on Count \(charge.count), Judge. Count \(principal.count) is what matters to us.",
                                                      "No objection on Count \(charge.count).", "No objection to arresting judgment on Count \(charge.count) if Count \(principal.count) holds, Judge.", "The State can agree to that on Count \(charge.count) so long as Count \(principal.count) stands.", "The State has no objection to arresting judgment on Count \(charge.count) if Count \(principal.count) stands, Judge.", "We're fine with that on Count \(charge.count), Your Honor, so long as Count \(principal.count) is entered.", "That's acceptable to the State on Count \(charge.count), provided the court enters judgment on Count \(principal.count).", "On Count \(charge.count), the State doesn't oppose. Count \(principal.count) captures what we care about.", "The State can agree to that, Judge. Count \(principal.count) is the one that matters.", "No problem on Count \(charge.count), as long as Count \(principal.count) remains."])))
                } else {
                    lines.append(Line(speaker: pros, side: .prosecution,
                                      text: merges
                                        ? "The State would rather keep both, Judge, but we recognize the merger issue. We ask that the court arrest the lesser one, not Count \(principal.count)."
                                        : rng.pick(["The State objects on Count \(charge.count). That's a separate crime with its own harm, and it should stand.",
                                                    "No, Judge. Count \(charge.count) is \(charge.law.title.lowercased()). That's not a technicality; it's its own offense.",
                                                    "We oppose that. If the court wants to run Count \(charge.count) concurrent, fine, but the conviction should be entered.", "The State objects. Count \(charge.count) is a separate offense and should stand.", "No, Judge. Count \(charge.count) protects something different from Count \(principal.count).", "The State opposes arresting judgment on Count \(charge.count). It's a separate offense with its own elements.", "No, Judge. Count \(charge.count) stands on different facts than Count \(principal.count), and we ask that it be entered.", "We object. Count \(charge.count) reflects a different harm, and the court found it proven.", "The State disagrees, Judge. Count \(charge.count) isn't a lesser version of Count \(principal.count), and both should be entered.", "Count \(charge.count) has its own elements, and we ask the court not to arrest judgment on it.", "We don't agree, Your Honor. Count \(charge.count) deserves its own judgment."])))
                }
            }
        }
        if convicted.count > 1 {
            lines.append(Line(speaker: pros, side: .prosecution,
                              text: "But the State objects to any arrest of judgment on Count \(principal.count). That's the heart of this case."))
        }
        return lines
    }
}
