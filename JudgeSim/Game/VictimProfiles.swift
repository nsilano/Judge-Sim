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

extension VictimProfile {
    /// "a 34-year-old woman", "a 9-year-old boy": the age and the sex, the way the court would say them.
    var description: String {
        let child = (age ?? 30) < 18
        let person = gender == .female ? (child ? "girl" : "woman") : (child ? "boy" : "man")
        guard let age else { return "a \(person)" }
        return "a \(age)-year-old \(person)"
    }
}

enum VictimProfiles {

    static func make(_ c: CourtCase, county: County?) -> VictimProfile? {
        guard let name = c.victimName, !name.isEmpty else { return nil }
        // Seeded by the person, not the case, so a victim who comes back is the same person.
        var rng = SeededRNG(seed: SeededRNG.stableHash(name) ^ 0x51C7)
        let told = CaseTemplates.byKey[c.templateKey]?.story?.victim
        let last = name.components(separatedBy: " ").last ?? name
        let first = name.components(separatedBy: " ").first ?? name
        let summary = c.summary
        let lower = summary.lowercased()
        let ids = c.charges.map { $0.lawID.lowercased() }
        _ = ids
        let deceased = Consequences.victimDied(c)

        // The case file's own words about the victim.
        let inTheFile = Exhibits.sentences(summary).filter { $0.contains(last) || $0.contains(first) }

        // An age the written facts give ("Name, 58"), or a fitting one.
        let age = told?.age ?? statedAge(summary, name: name, last: last) ?? describedAge(inTheFile.joined(separator: " ")) ?? {
            if c.charges.contains(where: { ["felonyChildAbuse", "childAbuseMisd"].contains($0.lawID) }) { return rng.int(3...15) }
            switch c.category {
            case .whiteCollar: return rng.int(44...86)
            default: return rng.int(19...74)
            }
        }()

        let occupation: String
        if let job = told?.occupation ?? statedOccupation(summary, name: name, last: last) {
            occupation = job.capitalizedFirst
        } else if age < 18 { occupation = age < 6 ? "Not yet in school" : "Student at a Hollis County school" }
        else if age >= 68 { occupation = "Retired " + rng.pick(["schoolteacher", "textile mill worker", "postal carrier", "farmer", "nurse", "machinist", "church secretary", "mail clerk", "welder", "bus driver", "seamstress", "tobacco farmer", "shipyard worker", "cafeteria cook", "bookkeeper"]) }
        else {
            occupation = rng.pick(["Warehouse supervisor", "Nursing assistant", "Elementary school teacher", "Line cook", "Bank teller",
                                   "Truck driver", "Hair stylist", "Pharmacy technician", "Auto mechanic", "Cashier at a grocery store",
                                   "Community college student", "Landscaper", "Office manager at a dental practice", "Welder",
                                   "Home health aide", "Restaurant server", "Sheet metal worker", "Real estate agent", "Dental assistant", "Electrician's apprentice", "Child care worker", "Delivery driver", "Hotel front desk clerk", "Plumber", "Bus driver", "Carpenter", "Pharmacist", "Bakery counter worker", "School bus driver", "Hospital custodian"])
        }
        let town = rng.pick(county?.towns ?? ["Port Hollis"])
        let years = age < 18 ? age : rng.int(2...max(3, min(age, 50)))
        let residence = deceased ? "Lived in \(town)" + (age >= 18 ? " for \(years) years" : "") + "."
            : "Lives in \(town)" + (age >= 18 ? ", \(years) years at the same address." : " with family.")

        let family: String
        if let stated = told?.family {
            family = stated
        } else if age < 18 {
            family = rng.pick(["Lives with a mother and two siblings.", "Raised by grandparents.", "Lives with both parents and a younger brother.",
                               "Lives with a father who works nights; a grandmother helps.", "Lives with an aunt and two cousins.", "Splits time between a mother and a father.", "Lives with a stepfather and a mother who works two jobs.", "Raised by an older sister.", "Lives with a mother and a stepfather.", "Lives with a grandmother and an uncle.", "Lives with a father and an older half-sister.", "Lives with a foster family.", "Lives with an aunt; the mother lives out of state.", "Lives with both grandparents."])
        } else {
            let partner = rng.pick(["Married", "Married", "Divorced", "Single", "Widowed", "Engaged", "Separated", "Living with a partner", "In a long relationship"])
            let kids = age < 24 ? 0 : rng.int(0...3)
            family = partner + (kids == 0 ? ", no children." : ", \(kids) child\(kids == 1 ? "" : "ren").")
                + (deceased ? " " + rng.pick(["The family has attended every setting.", "A sister has spoken for the family.", "The family asked the court for privacy.", "A cousin has spoken for the family.", "The family has asked to be told before any plea is accepted.", "The family has asked to speak at sentencing.", "The family has asked to be notified of every hearing.", "A brother has spoken for the family.", "The family has said it wants the case resolved quickly.", "The family has asked for restitution to be considered.", "The family has asked that the victim's name not be used in the paper.", "A parent has spoken for the family at each setting."]) : "")
        }

        // Only what the file says about the victim decides the relationship, not every word in it.
        let aboutVictim = inTheFile.joined(separator: " ").lowercased()
        let relationship = told?.relationship ?? relationshipLine(aboutVictim.isEmpty ? lower : aboutVictim, c: c, first: first, rng: &rng)
        // Married to the defendant means married, whatever the family line drew.
        var familyLine = family
        if told?.family == nil, relationship.hasPrefix("Married"), let comma = family.firstIndex(of: ",") {
            familyLine = "Married to the defendant" + String(family[comma...])
        }
        var harm = harmLines(c, deceased: deceased, rng: &rng)
        if let stated = told?.harm { harm = stated + harm.filter { $0.hasPrefix("Restitution") } }

        // Children have no record.
        let record: String = told?.record ?? (age < 18 || rng.chance(0.8)
            ? "No criminal record."
            : rng.pick(["One misdemeanor conviction (worthless check), more than ten years ago.",
                        "A dismissed simple assault charge from a decade ago.",
                        "A prior conviction for misdemeanor possession of marijuana.",
                        "One prior conviction for driving while license revoked.", "A speeding ticket and nothing else.", "No record of any kind.", "A trespass charge from 2009 that was dismissed.", "A DWI conviction from fifteen years ago.", "A 2012 misdemeanor larceny conviction.", "One conviction for simple affray more than a decade ago.", "A single misdemeanor trespassing conviction.", "One traffic-related citation and nothing since.", "A misdemeanor DWI conviction from twenty years ago.", "A disorderly conduct charge that was dismissed."]))

        let testified: String
        if c.witnesses.contains(where: { $0.name == name }) {
            testified = deceased ? "Statements given before death are part of the record." : "Testifies for the State."
        } else {
            testified = deceased ? "Deceased; the State proves the case through other witnesses." : "Not on the State's witness list."
        }

        // A written case that never gives the victim's age or work doesn't get one made up: an invented "64-year-old
        // student" can contradict what the victim says on the stand.
        let written = c.templateKey.hasPrefix("story.")
        let ageKnown = told?.age ?? statedAge(summary, name: name, last: last) ?? describedAge(inTheFile.joined(separator: " "))
        let jobKnown = told?.occupation ?? statedOccupation(summary, name: name, last: last)
        let shownAge: Int? = written && ageKnown == nil ? nil : age
        let shownJob = written && jobKnown == nil ? (ageKnown.map { $0 < 18 } == true ? occupation : "Not stated in the case file") : occupation
        return VictimProfile(name: name, age: shownAge, gender: NameBank.gender(of: name), deceased: deceased, occupation: shownJob,
                             residence: residence, family: familyLine, relationship: relationship, harm: harm, record: record,
                             testified: testified, position: c.background?.victimStanceDetail, impactStatement: c.victimImpact,
                             inTheFile: inTheFile)
    }

    static func statedAge(_ text: String, name: String, last: String) -> Int? {
        for key in [name, last] {
            let pattern = NSRegularExpression.escapedPattern(for: key) + ", (\\d{1,3})\\b"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text), let age = Int(text[range]) else { continue }
            return age
        }
        return nil
    }

    /// "a 34-year-old nurse", "{V}, 81," and the like, when the summary gives an age without the name beside it.
    static func describedAge(_ text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: "\\b(\\d{1,2})-year-old\\b"),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return Int(text[range])
    }

    /// "Name, 26, an accountant" or "Name, a cashier": the work the summary gives the victim.
    static func statedOccupation(_ text: String, name: String, last: String) -> String? {
        for key in [name, last] {
            let pattern = NSRegularExpression.escapedPattern(for: key) + ",(?: \\d{1,3},)? (?:a|an) ([a-z][a-z -]{2,40}?)(?:[,.]| who| at| in| for)"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text) else { continue }
            let job = String(text[range])
            // Relationships and descriptions aren't jobs.
            let notJobs = ["friend", "neighbor", "widow", "retired couple", "guest", "regular", "stranger", "former", "mother", "father", "man", "woman", "boy", "girl", "child"]
            if notJobs.contains(where: { job.hasPrefix($0) }) { continue }
            return job
        }
        return nil
    }

    private static func relationshipLine(_ lower: String, c: CourtCase, first: String, rng: inout SeededRNG) -> String {
        let pairs: [(String, String)] = [
            // Former partners first, so "ex-girlfriend" isn't read as a current one.
            ("ex-", "A former partner of the defendant."), ("former partner", "A former partner of the defendant."),
            ("former boyfriend", "A former partner of the defendant."), ("former girlfriend", "A former partner of the defendant."),
            ("girlfriend", "Dating relationship with the defendant."), ("boyfriend", "Dating relationship with the defendant."),
            ("wife", "Married to the defendant."), ("husband", "Married to the defendant."), ("spouse", "Married to the defendant."),
            ("business partner", "The defendant's business partner."), ("co-owned", "The defendant's business partner."),
            ("partner", "In a relationship with the defendant."), ("resident", "A resident in the defendant's care."),
            ("patient", "A patient in the defendant's care."), ("client", "A client of the defendant."),
            ("neighbor", "Neighbor of the defendant."),
            ("coworker", "Worked with the defendant."), ("co-worker", "Worked with the defendant."),
            ("roommate", "Shared a home with the defendant."), ("customer", "A customer of the defendant's business."),
            ("client", "A client of the defendant."), ("landlord", "The defendant's landlord."), ("tenant", "Rented from the defendant."),
            ("cousin", "Related to the defendant."), ("brother", "Related to the defendant."), ("sister", "Related to the defendant."),
            ("son", "Related to the defendant."), ("daughter", "Related to the defendant."), ("friend", "Knew the defendant socially.")
        ]
        // The victim's own spouse ("Blake and his wife") is not the defendant.
        // "Her husband, {D}" and "his wife, {V}" still are.
        let vFirst = NSRegularExpression.escapedPattern(for: first.lowercased())
        let dFirst = NSRegularExpression.escapedPattern(for: (c.defendant.name.split(separator: " ").first.map(String.init) ?? "").lowercased())
        let lower = lower.regexReplacing(of: "\\b(his|her|their) (wife|husband|spouse)s?\\b(?!,? (\(dFirst)|\(vFirst)))", with: "")
        // Whole words only: "son" isn't in "person", nor "ex-" in "next".
        for (word, line) in pairs {
            let pattern = word.hasSuffix("-") ? "\\b" + NSRegularExpression.escapedPattern(for: word) : "\\b" + NSRegularExpression.escapedPattern(for: word) + "s?\\b"
            if lower.regexRange(of: pattern, options: .regularExpression) != nil { return line }
        }
        switch c.category {
        case .family: return "Family or household member of the defendant."
        case .robbery, .property: return rng.pick(["No known relationship; the investigation found no prior contact.", "Strangers before the incident.", "No known relationship; a stranger on the street.", "Never met the defendant before.", "No known relationship; the two never crossed paths before.", "Had never seen the defendant before the incident.", "A stranger; no connection found in the investigation.", "No relationship of any kind between them before that day.", "Never spoke to the defendant before the incident.", "Complete strangers, according to both sides."])
        default: return rng.pick(["Knew the defendant slightly before the incident.", "No known relationship before the incident.", "Had met the defendant at work.", "Knew the defendant from the neighborhood.", "Had known the defendant a short while through mutual friends.", "Lived on the same street as the defendant.", "Knew the defendant from church.", "Had worked in the same building as the defendant.", "Had seen the defendant around town but never spoken to them.", "Was an acquaintance of the defendant through a family member."])
        }
    }

    private static func harmLines(_ c: CourtCase, deceased: Bool, rng: inout SeededRNG) -> [String] {
        var lines: [String] = []
        // Threats, stalking, and messages harm without touching anyone.
        let noContact = ["stalking", "stalkingCourtOrder", "cyberstalking", "communicatingThreats", "witnessIntimidation",
                         "extortion", "privateImages", "dvpoViolation", "massViolenceThreat"]
        let contactless = noContact.contains(c.charges.first?.lawID ?? "")
        if deceased {
            lines.append("Died as a result of the offense.")
        } else if contactless {
            lines.append(rng.pick(["Not physically hurt. Has changed routines, phone numbers, and the route to work.",
                                   "No physical injury. Started counseling and sleeps with the lights on.",
                                   "Not touched, but says the fear hasn't let up; moved in with family for a time.", "Not injured physically, but quit a second job to be home more.", "No injuries. Stopped answering the door.", "No physical injury. Stopped going to the places the defendant is known to be.", "Not hurt, but has stopped answering unknown numbers and checks the mirror driving home.", "Not injured. Installed cameras and keeps the phone charged at all times.", "No injuries. Has missed days of work out of worry.", "Not touched, but says the messages made home feel unsafe.", "No physical harm. Started carrying a whistle and varies the route home."]))
        } else if c.templateKey.hasPrefix("story.") {
            // A written case says what happened to the victim; nothing is invented. The State's medical exhibit is the
            // injury, and with none, there was no physical injury.
            // Only where someone could be hurt: a fraud's "Hospital Letter" is not an injury.
            let canBeHurt = [.violent, .family, .robbery, .traffic].contains(c.category)
            let medical = c.evidence.first { e in
                canBeHurt && e.side == .prosecution && ["medical", "hospital", "emergency", "surgical", "pediatric", "x-ray", "injur", "autopsy", "necropsy", "surgeon",
                                           "nurse", "wound", "examiner", "trauma", "x-rays", "photos of"]
                    .contains { e.title.lowercased().contains($0) }
            }
            if let medical {
                lines.append(medical.detail)
            } else if [.violent, .family, .robbery].contains(c.category) {
                lines.append("No physical injury.")
            }
            if [.violent, .family, .robbery].contains(c.category) {
                lines.append(rng.pick(["Has trouble sleeping and has started counseling.", "Says the fear is worse than anything else.",
                                       "Avoids the place where it happened.", "Wakes at night and checks the locks.", "Doesn't go out alone after dark anymore.", "Hasn't been back to the place since.", "Gets nervous when the phone rings.", "Jumps at loud noises and has trouble in crowds.", "Keeps the lights on at night.", "Says every unfamiliar car feels like a threat.", "Has started seeing a therapist twice a month."]))
            }
        } else {
            switch c.category {
            case .violent, .family:
                lines.append(rng.pick(["Treated at Hollis Regional Medical Center and released the same night.",
                                       "Hospitalized for four days; still in physical therapy.",
                                       "Stitches and a fractured orbital bone; the vision in one eye hasn't fully returned.",
                                       "Bruising and a sprained wrist; missed two weeks of work.", "Treated and released with a cast and follow-up visits.", "Surgery on the hand and eight weeks off work.", "Broken nose and a concussion; released after observation.", "Cracked ribs and a collapsed lung; two nights in the hospital.", "A deep cut that needed twenty stitches; the scar will remain.", "Fractured jaw, wired shut for six weeks.", "Dislocated shoulder and bruising; physical therapy twice a week.", "Treated for a concussion and released with instructions to rest for a month."]))
                lines.append(rng.pick(["Has trouble sleeping and has started counseling.", "Moved in with relatives for a time afterward.",
                                       "Had the locks changed and installed cameras.", "Says the fear is worse than the injuries.", "Stopped going out in the evening.", "Missed a month of work and fell behind on rent.", "Has nightmares and avoids driving at night.", "Stopped attending church and social events for months.", "Had trouble returning to work and took a lower-paying position.", "Says the injuries healed faster than the memory.", "Started carrying a phone everywhere in case of an emergency.", "Has panic attacks in unfamiliar places."]))
            case .robbery:
                let armed = c.charges.contains { $0.lawID == "dangerousRobbery" }
                lines.append(rng.pick((armed ? ["Not physically hurt, but had a weapon pointed at them."] : ["Knocked down; scrapes and bruises."])
                                      + ["Quit the job where it happened.", "Now carries pepper spray and won't go out after dark alone."]))
            case .property:
                lines.append(rng.pick(["Lost items of sentimental value that were never recovered.", "Paid an insurance deductible and lost a week of work dealing with it.",
                                       "Says the home doesn't feel safe anymore.", "Replaced the locks and a stolen laptop at their own expense.", "Lost a family heirloom.", "Had to replace a stolen television and a bicycle.", "Lost tools used for work and had to borrow money to replace them.", "Found the back door forced open and has not slept well since.", "Lost a collection that had been in the family for decades.", "Spent a weekend cleaning up and repairing the damage.", "Filed an insurance claim that has not yet been paid."]))
            case .whiteCollar:
                lines.append(rng.pick(["Lost savings meant for retirement.", "Had to take a second job to cover the loss.",
                                       "Credit was damaged and took months to repair.", "Closed a bank account and spent months on the phone sorting it out.", "Delayed a medical procedure because of the lost money.", "Drained a savings account that was meant for tuition.", "Fell behind on the mortgage after the loss.", "Spent months disputing charges and filing reports.", "Had to sell a car to recover from the loss.", "Lost a down payment on a first home.", "Took on credit card debt to make up for the stolen money."]))
            case .traffic:
                lines.append(rng.pick(["Broken leg and months of rehabilitation.", "The car was totaled; still paying off the loan.",
                                       "A concussion with lingering headaches.", "Back pain that has not gone away and a long recovery.", "Missed a semester of school.", "Whiplash and months of physical therapy.", "A broken collarbone and three weeks off work.", "The car was a total loss and there was no rental coverage.", "Facial lacerations that required surgery.", "A fractured wrist that has not fully healed.", "Now afraid to drive on the highway."]))
            default:
                lines.append("Affected by the offense; details are in the victim impact statement.")
            }
        }
        if lines.isEmpty && c.templateKey.hasPrefix("story.") { lines.append("No physical injury.") }
        if let bg = c.background, bg.restitution > 0 {
            lines.append("Restitution claimed: \(SentenceFormat.dollars(bg.restitution))" + (bg.restitutionBasis.map { " for \($0)" } ?? "") + ".")
        }
        return lines
    }
}
