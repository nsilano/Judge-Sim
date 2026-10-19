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
                let a = r.verdicts[lhs.id].flatMap { Judgment.convictedLaw(lhs, $0)?.ncClass?.severity } ?? 99
                let b = r.verdicts[rhs.id].flatMap { Judgment.convictedLaw(rhs, $0)?.ncClass?.severity } ?? 99
                return a == b ? lhs.count < rhs.count : a < b
            }
    }

    /// The State agrees to arresting judgment on any count except the most serious one.
    static func stateConsents(_ c: CourtCase, _ r: Rulings, charge: Charge) -> Bool {
        guard let principal = convictedCharges(c, r).first else { return false }
        return principal.id != charge.id
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
                                          "Approach the bench. I'd like your positions on judgment off the record before we go back on."])))

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
                                        "We're asking for \(top) months on Count \(principal.count), and we're asking that it be active."])
                lines.append(Line(speaker: pros, side: .prosecution,
                                  text: Allocutions.stateArgument(c, request: request, plea: r.pleaAccepted == true) + (rng.chance(0.4) ? victimLine : "")))
                lines.append(Line(speaker: def, side: .defense,
                                  text: probationOK
                                    ? rng.pick(["We'd ask the court to suspend the sentence and place \(dl) on supervised probation. \(dl) has a job and a family to get back to.",
                                                "The chart allows probation here, Judge, and \(dl) is a good candidate for it. We'd ask for a suspended sentence with treatment conditions."])
                                    : rng.pick(["We'd ask for the bottom of the mitigated range, \(low) months. The mitigating factors are real.",
                                                "The chart requires active time, so we're asking for \(low) months, the bottom of the mitigated range, and credit for time served."])))
            } else if let cell = unit.misdemeanorCell {
                lines.append(Line(speaker: pros, side: .prosecution,
                                  text: Allocutions.stateArgument(c, request: "The State asks for \(cell.maxDays) days" + (cell.dispositions.contains(.active) ? ", active." : ", suspended, with supervised probation."),
                                                                  plea: r.pleaAccepted == true)))
                lines.append(Line(speaker: def, side: .defense,
                                  text: "We'd ask for unsupervised probation, Judge. This is a misdemeanor and \(dl) has learned from it."))
            }
        }

        // The other counts: what each side says about arresting judgment.
        for charge in convicted.dropFirst() {
            lines.append(Line(speaker: def, side: .defense,
                              text: "On Count \(charge.count), we'd ask the court to arrest judgment. It arises from the same conduct as Count \(principal.count), and the State gets its full punishment there."))
            lines.append(Line(speaker: pros, side: .prosecution,
                              text: rng.pick(["The State won't object to arresting judgment on Count \(charge.count), as long as Count \(principal.count) stands.",
                                              "We can live with that on Count \(charge.count), Judge. Count \(principal.count) is what matters to us."])))
        }
        if convicted.count > 1 {
            lines.append(Line(speaker: pros, side: .prosecution,
                              text: "But the State objects to any arrest of judgment on Count \(principal.count). That's the heart of this case."))
        }
        return lines
    }
}
