import Foundation

/// A crime the paper follows from the day it happens to the day someone is arrested; then the case comes to the judge.
struct OpenInvestigation: Identifiable, Codable {
    var id = UUID()
    var courtCase: CourtCase
    var incident: Date
    var arrest: Date
    var town: String
    var offense: String
    /// The first day the case can be tried: everything in its file happens before then.
    var ready: Date
    /// How the case reached the court, when it wasn't a story the paper followed (a warrant the judge signed).
    var note: String? = nil
}

/// The news of an investigation in progress. Nobody is named until the arrest, and nothing reported goes beyond
/// what the case file says happened.
enum InvestigationArc {

    /// What kind of investigation the paper is covering, in its words.
    static func subject(_ c: CourtCase) -> String {
        let title = c.charges.first?.law.title.lowercased() ?? "a crime"
        switch c.category {
        case .violent: return Consequences.victimDied(c) ? "a death" : "an assault"
        case .robbery: return "a robbery"
        case .property:
            if title.contains("arson") || title.contains("burn") { return "a fire" }
            if title.contains("burglary") || title.contains("breaking") { return "a break-in" }
            if title.contains("larceny") || title.contains("stolen") { return "a theft" }
            if title.contains("trespass") { return "a trespassing complaint" }
            if title.contains("injury to") { return "vandalism" }
            return "a property crime"
        case .drugs:
            if Consequences.victimDied(c) { return "an overdose death" }
            if title.contains("sale") || title.contains("deliver") || title.contains("intent") || title.contains("trafficking") { return "drug sales" }
            if title.contains("possession") || title.contains("paraphernalia") { return "a drug complaint" }
            return "a drug investigation"
        case .whiteCollar:
            if title.contains("false pretenses") || title.contains("fraud") || title.contains("forgery") { return "suspected fraud" }
            return "missing money"
        case .cyber: return "online harassment"
        case .family: return "a case involving a child"
        case .traffic:
            if Consequences.victimDied(c) { return "a fatal crash" }
            if title.contains("hit and run") || title.contains("death by vehicle") { return "a crash" }
            if title.contains("impaired") && !title.contains("revoked") { return "a drunk-driving incident" }
            if title.contains("elude") { return "a police chase" }
            // Only an offense an officer finds on the road reads as a stop; other traffic cases are incidents reported afterward.
            if c.charges.first.map({ CaseOrigin.roadsideLaws.contains($0.law.id) }) == true { return "a traffic stop" }
            return "a traffic incident"
        default: return title
        }
    }

    /// The first line of a case's timeline. A crime someone reports is "reported"; something the police run into themselves,
    /// a chase, a traffic stop or a crash, is not: the officers are there.
    static func openingLine(for c: CourtCase, agency: String, town: String) -> String {
        let what = subject(c)
        // "Traffic stop" is only right when the story is an officer stopping a car; a crash scene, a boat, or a driver
        // identified later from a photograph is something else.
        let story = c.summary.lowercased()
        let officerStop = ["stopped", "pulled over", "traffic stop", "checkpoint", "pulled the", "pulled a"].contains { story.contains($0) }
        let crash = ["crash", "wreck", "rolled", "collision", "struck", "ran off the road", "overturned"].contains { story.contains($0) }
        let vessel = ["boat", "vessel", "ferry", "kayak", "jet ski"].contains { story.contains($0) }
        if (what == "a traffic stop" || what == "a drunk-driving incident") && !officerStop {
            if vessel { return "Reported to the \(agency) in \(town): a boating incident." }
            if crash { return "The \(agency) responds to a crash in \(town)." }
            return "Reported to the \(agency) in \(town): a \(what == "a drunk-driving incident" ? "report of a drunk driver" : "traffic incident")."
        }
        switch what {
        case "a police chase": return "The \(agency) pursues a driver in \(town): a police chase."
        case "a traffic stop": return "Traffic stop by the \(agency) in \(town)."
        case "a drunk-driving incident": return "Traffic stop by the \(agency) in \(town): a drunk-driving incident."
        case "a fatal crash": return "The \(agency) responds to a fatal crash in \(town)."
        case "a crash": return "The \(agency) responds to a crash in \(town)."
        default: return "Reported to the \(agency) in \(town): \(what)."
        }
    }

    /// Offenses an officer sees happen (or finds on the spot), so no investigation runs and no one is "yet to be charged".
    static func policeWitnessed(_ subject: String) -> Bool {
        let s = subject.lowercased()
        return ["disorderly", "resisting", "riot", "concealed", "perjury", "trespass", "chase", "traffic stop", "drunk-driving",
                "affray", "disturbing", "fleeing", "weapon on", "obstruct", "contempt"].contains { s.contains($0) }
    }

    /// The line that follows when no one was arrested at the time.
    static func investigationLine(for c: CourtCase, agency: String) -> String {
        subject(c) == "a police chase" ? "The driver gets away; the \(agency) opens an investigation." : "\(agency) opens an investigation."
    }

    /// The beats between the incident and the arrest, as scheduled news.
    static func beats(for c: CourtCase, incident: Date, arrest: Date, town: String, agency: String, rng: inout SeededRNG) -> [PendingEvent] {
        let cal = CourtCalendar.calendar
        let what = subject(c)
        // Offenses the officers see themselves are arrests on the spot; there is no open investigation for the paper to report.
        if policeWitnessed(what) { return [] }
        let span = max(2, cal.dateComponents([.day], from: incident, to: arrest).day ?? 2)
        func day(_ fraction: Double) -> Date {
            cal.date(byAdding: .day, value: max(1, Int(Double(span) * fraction)), to: incident) ?? incident
        }
        func item(_ date: Date, _ headline: String, _ body: String, prominence: Int = 1) -> PendingEvent {
            PendingEvent(due: date, news: NewsItem(date: date, kind: .arrest, headline: headline, body: body,
                                                   docket: nil, prominence: prominence, section: "Crime"))
        }
        let victimLine = c.victimName == nil ? "" : (Consequences.victimDied(c) ? " The victim's name has not been released." : " The victim is cooperating with investigators.")
        var out = [item(cal.date(byAdding: .day, value: 1, to: incident) ?? incident,
                        "\(agency) investigating \(what) in \(town)",
                        "Investigators with the \(agency) are looking into \(what) in \(town). No one has been charged." + victimLine
                            + rng.pick([" Anyone with information is asked to call the department's tip line.", " Investigators say they are following several leads.", "", " Anyone who saw something is asked to contact the agency.", " The agency said there is no known threat to the public.", " Investigators ask residents to check home cameras for anything useful.", " The agency said it will update the public when it can.", " Detectives are asking neighbors to report anything unusual.", " The agency said it has no further details to release at this time."]))]
        // Specifics make it local: the street, the lead investigator, a church in that town.
        let facts = c.investigation?.facts
        let street = facts?.street ?? town
        let lead = facts?.lead ?? "the lead investigator"
        let church = Gazetteer.place(.church, in: town, rng: &rng)?.name ?? "a church"
        var middle: [(String, String)] = [
            ("Investigators ask for tips in \(town) case", "\(lead) of the \(agency) asked anyone who was on or near \(street) around the time of \(what) to come forward, or to check doorbell and dash cameras. Tips can be left anonymously."),
            ("Search warrant served in \(town) investigation", "Investigators served a search warrant at a home in \(town) this week in connection with \(what). Neighbors on the street said they saw officers carrying out paper bags. The \(agency) would not say whether anyone is a suspect."),
            ("Lab results awaited in \(town) case", "Evidence in the investigation into \(what) on \(street) has gone to the State Crime Laboratory in Raleigh. \(lead) said results can take weeks."),
            ("Detectives knock on doors along \(street)", "Detectives spent the week talking to neighbors and coworkers in \(town). \"Somebody saw something,\" \(lead) said. \"We'd like to hear from them.\""),
        ]
        if c.victimName != nil && !Consequences.victimDied(c) {
            middle.append(("\"We just want answers,\" family says", "Relatives of the victim in the \(town) investigation say they check in with detectives every day. \"Somebody knows something,\" one said."))
        }
        if Consequences.victimDied(c) {
            middle.append(("Vigil held in \(town)", "Friends and family gathered with candles outside \(church) in \(town). \(lead) stood at the back of the crowd."))
        }
        let count = span >= 14 ? 2 : (span >= 4 ? 1 : 0)
        for (index, beat) in rng.pick(middle, count: count).enumerated() {
            out.append(item(day(count == 1 ? 0.5 : (index == 0 ? 0.35 : 0.7)), beat.0, beat.1, prominence: 0))
        }
        return out
    }

    /// The arrest, with the defendant named for the first time.
    static func arrestNews(_ c: CourtCase, on date: Date, town: String, agency: String, judge: String, county: County,
                           followed: Bool = true, bondHearing: Bool = false) -> NewsItem {
        let d = c.defendant
        let held = c.background?.isJailed == true
        let offense = c.charges.first?.law.title.lowercased() ?? "the charges"
        // Only a case that came through a signed search warrant is described as the result of a search.
        let warrant = c.proceduralNotes.contains { $0.localizedCaseInsensitiveContains("search warrant") }
        return NewsItem(date: date, kind: .arrest, headline: followed ? "Arrest made in \(town) investigation: \(d.name) charged" : (warrant ? "\(d.name) arrested after search in \(town)" : "\(d.name) arrested in \(town)"),
                        body: (followed
                            ? "\(agency) investigators arrested \(d.name), \(d.age), on a charge of \(offense), in the case the paper has followed since it began in \(town). "
                            : "\(agency) investigators arrested \(d.name), \(d.age), on a charge of \(offense) \(warrant ? "after executing a search warrant in" : "in") \(town). ")
                            + (bondHearing
                                ? "\(d.lastName) is being held in the \(county.name) Detention Center until a bond hearing before Judge \(judge), who will also set a trial date."
                                : (held ? "\(d.lastName) is being held in the \(county.name) Detention Center." : "\(d.lastName) was released on bond.")
                                    + " The case goes to \(county.name) Superior Court, where Judge \(judge) will set a trial date."),
                        docket: c.docket, prominence: 2, section: "Crime")
    }
}
