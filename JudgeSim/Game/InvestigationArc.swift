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
        case .property: return title.contains("arson") || title.contains("burn") ? "a fire" : "a break-in"
        case .drugs: return Consequences.victimDied(c) ? "an overdose death" : "drug sales"
        case .whiteCollar: return "missing money"
        case .cyber: return "online harassment"
        case .family: return "a case involving a child"
        case .traffic: return Consequences.victimDied(c) ? "a fatal crash" : "a crash"
        default: return title
        }
    }

    /// The beats between the incident and the arrest, as scheduled news.
    static func beats(for c: CourtCase, incident: Date, arrest: Date, town: String, agency: String, rng: inout SeededRNG) -> [PendingEvent] {
        let cal = CourtCalendar.calendar
        let what = subject(c)
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
                            + rng.pick([" Anyone with information is asked to call the department's tip line.", " Investigators say they are following several leads.", ""]))]
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
        return NewsItem(date: date, kind: .arrest, headline: followed ? "Arrest made in \(town) investigation: \(d.name) charged" : "\(d.name) arrested after search in \(town)",
                        body: (followed
                            ? "\(agency) investigators arrested \(d.name), \(d.age), on a charge of \(offense), in the case the paper has followed since it began in \(town). "
                            : "\(agency) investigators arrested \(d.name), \(d.age), on a charge of \(offense) after executing a search warrant in \(town). ")
                            + (bondHearing
                                ? "\(d.lastName) is being held in the \(county.name) Detention Center until a bond hearing before Judge \(judge), who will also set a trial date."
                                : (held ? "\(d.lastName) is being held in the \(county.name) Detention Center." : "\(d.lastName) was released on bond.")
                                    + " The case goes to \(county.name) Superior Court, where Judge \(judge) will set a trial date."),
                        docket: c.docket, prominence: 2, section: "Crime")
    }
}
