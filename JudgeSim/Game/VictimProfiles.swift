import Foundation

/// Who the victim is: age, work, home and family, history with the defendant, what the crime cost them, their own
/// record, and what they want from the court. Built from the case itself, so the same case always shows the same person
/// and older saves get profiles too.
struct VictimProfile {
    var name: String
    var age: Int?
    var gender: Gender
    var deceased: Bool
    var occupation: String
    var residence: String
    var family: String
    var relationship: String
    var harm: [String]
    var record: String
    var testified: String
    var position: String?
    var impactStatement: String?
    /// What the case file says about the victim, sentence by sentence.
    var inTheFile: [String]
}

enum VictimProfiles {

    static func make(_ c: CourtCase, county: County?) -> VictimProfile? {
        guard let name = c.victimName, !name.isEmpty else { return nil }
        var rng = SeededRNG(seed: c.seed ^ 0x51C7)
        let last = name.components(separatedBy: " ").last ?? name
        let first = name.components(separatedBy: " ").first ?? name
        let summary = c.summary
        let lower = summary.lowercased()
        let ids = c.charges.map { $0.lawID.lowercased() }
        let deceased = ids.contains { $0.contains("murder") || $0.contains("manslaughter") || $0.contains("dbv") }
            || (lower.contains("\(first.lowercased())") && (lower.contains(" died") || lower.contains("was killed") || lower.contains("found dead")))

        // The case file's own words about the victim.
        let inTheFile = Exhibits.sentences(summary).filter { $0.contains(last) || $0.contains(first) }

        // An age the written facts give ("Name, 58"), or a fitting one.
        let age = statedAge(summary, name: name, last: last) ?? {
            switch c.category {
            case .family: return rng.int(4...80)
            case .whiteCollar: return rng.int(44...86)
            default: return rng.int(19...74)
            }
        }()

        let occupation: String
        if age < 18 { occupation = age < 6 ? "Not yet in school" : "Student at a Hollis County school" }
        else if age >= 68 { occupation = "Retired " + rng.pick(["schoolteacher", "textile mill worker", "postal carrier", "farmer", "nurse", "machinist", "church secretary"]) }
        else {
            occupation = rng.pick(["Warehouse supervisor", "Nursing assistant", "Elementary school teacher", "Line cook", "Bank teller",
                                   "Truck driver", "Hair stylist", "Pharmacy technician", "Auto mechanic", "Cashier at a grocery store",
                                   "Community college student", "Landscaper", "Office manager at a dental practice", "Welder",
                                   "Home health aide", "Restaurant server", "Sheet metal worker", "Real estate agent"])
        }
        let town = rng.pick(county?.towns ?? ["Port Hollis"])
        let years = age < 18 ? age : rng.int(2...max(3, min(age, 50)))
        let residence = deceased ? "Lived in \(town)" + (age >= 18 ? " for \(years) years" : "") + "."
            : "Lives in \(town)" + (age >= 18 ? ", \(years) years at the same address." : " with family.")

        let family: String
        if age < 18 {
            family = rng.pick(["Lives with a mother and two siblings.", "Raised by grandparents.", "Lives with both parents and a younger brother.",
                               "Lives with a father who works nights; a grandmother helps."])
        } else {
            let partner = rng.pick(["Married", "Married", "Divorced", "Single", "Widowed", "Engaged"])
            let kids = age < 24 ? 0 : rng.int(0...3)
            family = partner + (kids == 0 ? ", no children." : ", \(kids) child\(kids == 1 ? "" : "ren").")
                + (deceased ? " " + rng.pick(["The family has attended every setting.", "A sister has spoken for the family.", "The family asked the court for privacy."]) : "")
        }

        let relationship = relationshipLine(lower, c: c, first: first, rng: &rng)
        let harm = harmLines(c, deceased: deceased, rng: &rng)

        let record: String = rng.chance(0.8)
            ? "No criminal record."
            : rng.pick(["One misdemeanor conviction (worthless check), more than ten years ago.",
                        "A dismissed simple assault charge from a decade ago.",
                        "A prior conviction for misdemeanor possession of marijuana.",
                        "One prior conviction for driving while license revoked."])

        let testified: String
        if c.witnesses.contains(where: { $0.name == name }) {
            testified = deceased ? "Statements given before death are part of the record." : "Testifies for the State."
        } else {
            testified = deceased ? "Deceased; the State proves the case through other witnesses." : "Not on the State's witness list."
        }

        return VictimProfile(name: name, age: age, gender: NameBank.gender(of: name), deceased: deceased, occupation: occupation,
                             residence: residence, family: family, relationship: relationship, harm: harm, record: record,
                             testified: testified, position: c.background?.victimStanceDetail, impactStatement: c.victimImpact,
                             inTheFile: inTheFile)
    }

    private static func statedAge(_ text: String, name: String, last: String) -> Int? {
        for key in [name, last] {
            let pattern = NSRegularExpression.escapedPattern(for: key) + ", (\\d{1,3})\\b"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text), let age = Int(text[range]) else { continue }
            return age
        }
        return nil
    }

    private static func relationshipLine(_ lower: String, c: CourtCase, first: String, rng: inout SeededRNG) -> String {
        let pairs: [(String, String)] = [
            ("girlfriend", "Dating relationship with the defendant."), ("boyfriend", "Dating relationship with the defendant."),
            ("wife", "Married to the defendant."), ("husband", "Married to the defendant."),
            ("ex-", "A former partner of the defendant."), ("neighbor", "Neighbor of the defendant."),
            ("coworker", "Worked with the defendant."), ("co-worker", "Worked with the defendant."),
            ("roommate", "Shared a home with the defendant."), ("customer", "A customer of the defendant's business."),
            ("client", "A client of the defendant."), ("landlord", "The defendant's landlord."), ("tenant", "Rented from the defendant."),
            ("cousin", "Related to the defendant."), ("brother", "Related to the defendant."), ("sister", "Related to the defendant."),
            ("son", "Related to the defendant."), ("daughter", "Related to the defendant."), ("friend", "Knew the defendant socially.")
        ]
        for (word, line) in pairs where lower.contains(word) { return line }
        switch c.category {
        case .family: return "Family or household member of the defendant."
        case .robbery, .property: return rng.pick(["No known relationship; the investigation found no prior contact.", "Strangers before the incident."])
        default: return rng.pick(["Knew the defendant slightly before the incident.", "No known relationship before the incident."])
        }
    }

    private static func harmLines(_ c: CourtCase, deceased: Bool, rng: inout SeededRNG) -> [String] {
        var lines: [String] = []
        if deceased {
            lines.append("Died as a result of the offense.")
        } else {
            switch c.category {
            case .violent, .family:
                lines.append(rng.pick(["Treated at Hollis Regional Medical Center and released the same night.",
                                       "Hospitalized for four days; still in physical therapy.",
                                       "Stitches and a fractured orbital bone; the vision in one eye hasn't fully returned.",
                                       "Bruising and a sprained wrist; missed two weeks of work."]))
                lines.append(rng.pick(["Has trouble sleeping and has started counseling.", "Moved in with relatives for a time afterward.",
                                       "Had the locks changed and installed cameras.", "Says the fear is worse than the injuries."]))
            case .robbery:
                lines.append(rng.pick(["Not physically hurt, but had a gun pointed at them.", "Knocked down; scrapes and a bruised hip.",
                                       "Quit the job where it happened.", "Now carries pepper spray and won't work night shifts."]))
            case .property:
                lines.append(rng.pick(["Lost items of sentimental value that were never recovered.", "Paid an insurance deductible and lost a week of work dealing with it.",
                                       "Says the home doesn't feel safe anymore."]))
            case .whiteCollar:
                lines.append(rng.pick(["Lost savings meant for retirement.", "Had to take a second job to cover the loss.",
                                       "Credit was damaged and took months to repair."]))
            case .traffic:
                lines.append(rng.pick(["Broken leg and months of rehabilitation.", "The car was totaled; still paying off the loan.",
                                       "A concussion with lingering headaches."]))
            default:
                lines.append("Affected by the offense; details are in the victim impact statement.")
            }
        }
        if let bg = c.background, bg.restitution > 0 {
            lines.append("Restitution claimed: \(SentenceFormat.dollars(bg.restitution))" + (bg.restitutionBasis.map { " for \($0)" } ?? "") + ".")
        }
        return lines
    }
}
