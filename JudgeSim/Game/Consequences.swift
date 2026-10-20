import Foundation

/// How the world answers the court's decisions: a guilty defendant set free may do worse, a violent offender sent home
/// on probation may go back to the same victim, and a stay-away order is only as good as the person it binds. Each of
/// these comes back to this courtroom as a new case, with a note tying it to what the judge decided.
enum Consequences {

    /// Domestic cases, where an order is enforced like a Chapter 50B protective order.
    static func isDomestic(_ c: CourtCase) -> Bool {
        c.category == .family || ["dvStrangulation", "protectiveOrderParty", "abusedSpouse"].contains(c.templateKey)
            || c.charges.contains { ["dvpoViolation", "strangulation", "assaultFemale"].contains($0.lawID) }
    }

    /// Cases where the victim did not survive.
    static func victimDied(_ c: CourtCase) -> Bool {
        let deathLaws = ["murder1", "murder2", "volManslaughter", "invManslaughter", "felonyDBV", "misdDBV",
                         "deathByDistribution", "patientNeglect", "concealingDeath"]
        return c.charges.contains { deathLaws.contains($0.lawID) }
    }

    /// Cases where the victim is a child.
    static func victimIsChild(_ c: CourtCase) -> Bool {
        if c.charges.contains(where: { ["felonyChildAbuse", "childAbuseMisd"].contains($0.lawID) }) { return true }
        guard let name = c.victimName else { return false }
        let last = name.components(separatedBy: " ").last ?? name
        return (VictimProfiles.statedAge(c.summary, name: name, last: last) ?? 99) < 16
    }

    /// Cases where a stay-away order is what the State would ask for.
    static func stateWantsOrder(_ c: CourtCase) -> Bool {
        c.victimName != nil && !victimDied(c) && (isDomestic(c) || c.templateKey.lowercased().contains("stalk")
            || c.charges.contains { ["stalking", "cyberstalking", "communicatingThreats", "dvpoViolation", "witnessIntimidation"].contains($0.lawID) })
    }

    /// The new case a stay-away order violation brings.
    static func violationTemplates(domestic: Bool) -> [String] {
        domestic ? FollowUpCases.domesticViolations : FollowUpCases.otherViolations
    }

    /// Something worse than the case the court let go, in the same line of conduct.
    static func escalation(for c: CourtCase) -> (keys: [String], sameVictim: Bool) {
        // Written follow-up cases only: the same person, and the same victim where the conduct was aimed at one.
        // A victim who died, or a child, is never the victim again; the follow-ups are written for adults.
        if victimDied(c) || victimIsChild(c) {
            return (c.category == .property ? ["story.followup.occupiedHouse"] : ["story.followup.barParkingLot", "story.followup.occupiedHouse"], false)
        }
        if isDomestic(c) { return (["story.followup.kitchenAgain", "story.followup.hospitalNight"], true) }
        if c.templateKey.lowercased().contains("stalk") || c.charges.contains(where: { $0.lawID.hasPrefix("stalking") }) {
            return (["story.followup.hospitalNight"], true)
        }
        switch c.category {
        case .violent: return (["story.followup.barParkingLot"], false)
        case .robbery: return (["story.followup.gasStationKnife"], false)
        case .property: return (["story.followup.occupiedHouse", "story.followup.carBreakIns"], false)
        case .drugs: return (["story.followup.overdoseDeath"], false)
        case .traffic: return (["story.followup.secondCrash"], false)
        case .whiteCollar, .cyber: return (["story.followup.newMark"], false)
        default: return (["story.followup.barParkingLot", "story.followup.occupiedHouse"], false)
        }
    }

    /// When the judgment lets a guilty person go, or keeps a violent one on the street, what may follow.
    static func afterJudgment(_ c: CourtCase, convicted: Bool, active: Bool, dismissed: Bool = false, insanity: Bool = false,
                              judgeLast: String, date: Date, rng: inout SeededRNG) -> [PendingEvent] {
        // A person committed after an insanity verdict isn't on the street.
        if insanity { return [] }
        let d = c.defendant
        let offense = c.charges.first?.law.title.lowercasedPhrase ?? "the charges"
        let monthYear = date.formatted(.dateTime.month(.wide).year())
        let (keys, sameVictim) = escalation(for: c)
        let victim = sameVictim ? c.victimName : nil
        var chance = 0.0
        var lead = ""
        var note = ""
        if !convicted && c.truth.actuallyGuilty {
            chance = 0.4
            if dismissed {
                lead = "\(d.name), whose \(offense) charge Judge \(judgeLast) dismissed for a speedy-trial violation in \(monthYear), was arrested again this week"
                note = "You dismissed \(d.lastName)'s \(offense) charge for a speedy-trial violation on \(SentenceFormat.shortDate(date))."
            } else {
                lead = "\(d.name), whom Judge \(judgeLast) found not guilty of \(offense) in \(monthYear), was arrested again this week"
                note = "You acquitted \(d.lastName) of \(offense) on \(SentenceFormat.shortDate(date))."
            }
        } else if convicted && !active && c.truth.actuallyGuilty && c.victimName != nil
                    && [LawCategory.violent, .family, .robbery].contains(c.category) {
            chance = sameVictim ? 0.18 : 0.1
            lead = "\(d.name), sentenced to probation by Judge \(judgeLast) in \(monthYear) for \(offense), was arrested again this week"
            note = "You sentenced \(d.lastName) to probation for \(offense) on \(SentenceFormat.shortDate(date))."
        }
        guard chance > 0, rng.chance(chance) else { return [] }
        let incident = Calendar.current.date(byAdding: .day, value: rng.int(45...420), to: date) ?? date
        let toCourt = Calendar.current.date(byAdding: .day, value: rng.int(56...100), to: incident) ?? incident
        var body = lead + ", according to the Sheriff's Office."
        if let victim {
            body += " Investigators say the victim is \(victim), the same person at the center of the earlier case."
            note += " The victim in the new case is \(victim) again."
        }
        let arrest = PendingEvent(due: incident,
                                  news: NewsItem(date: incident, kind: .arrest,
                                                 headline: victim != nil ? "\(d.name) charged again; same victim, police say"
                                                                         : "\(d.lastName), let go by Hollis court, arrested again",
                                                 body: body, docket: c.docket, prominence: 2),
                                  personID: d.personID)
        let indicted = PendingEvent(due: toCourt,
                                    news: NewsItem(date: toCourt, kind: .arrest, headline: "\(d.name) indicted; case returns to Judge \(judgeLast)",
                                                   body: "A Hollis County grand jury returned an indictment against \(d.name). The case is set for trial in Superior Court before Judge \(judgeLast), who presided over \(d.lastName)'s earlier case.",
                                                   docket: c.docket),
                                    personID: d.personID,
                                    reoffense: Reoffense(personID: d.personID, templateKeys: keys, victimName: victim, incident: incident, note: note,
                                                         priorOffense: c.charges.first?.law.title, priorDate: date))
        return [arrest, indicted]
    }
}
