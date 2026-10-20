import Foundation

/// One matter on a day's calendar.
struct DocketEntry: Identifiable, Codable {
    enum Matter: Codable {
        case trial(CourtCase)
        case hearing(ViolationHearing)
        case calendar(CalendarCall)
    }

    enum Status: String, Codable {
        case pending, inProgress, done, continued
    }

    var id = UUID()
    var matter: Matter
    var status: Status = .pending
    /// Where a continued case left off.
    var resume: CaseSnapshot?
    /// How many times this matter has been continued.
    var continuances = 0
    /// Follow-up work the judge asked for before the case resumes.
    var requests: [EvidenceRequest]? = nil
    var note: String?
    var outcome: String?

    var matterID: UUID {
        switch matter {
        case .trial(let c): return c.id
        case .hearing(let h): return h.id
        case .calendar(let call): return call.id
        }
    }

    var title: String {
        switch matter {
        case .trial(let c): return c.caption
        case .hearing(let h): return "State v. \(h.personName)"
        case .calendar: return "Administrative calendar call"
        }
    }

    var subtitle: String {
        switch matter {
        case .trial(let c):
            let counts = c.charges.count
            return "\(c.docket) · \(c.charges.first?.law.title ?? "") " + (counts > 1 ? "and \(counts - 1) more count\(counts == 2 ? "" : "s")" : "")
        case .hearing(let h): return "\(h.probation.docket) · Probation violation"
        case .calendar(let call): return "\(call.matters.count) short matters"
        }
    }

    var icon: String {
        switch matter {
        case .trial: return "scalemass.fill"
        case .hearing: return "person.badge.clock.fill"
        case .calendar: return "list.bullet.rectangle.portrait.fill"
        }
    }

    /// Rough courtroom time, in minutes.
    var estimatedMinutes: Int {
        switch matter {
        case .trial(let c):
            if resume.map({ $0.stage >= CaseSession.Stage.sentencing.rawValue }) ?? false { return 60 }
            if c.background?.arrangementPresented == true { return 75 }
            return 120 + 12 * c.charges.count + 20 * c.witnesses.count + 20 * c.motions.count
        case .hearing: return 40
        case .calendar(let call): return 20 * call.matters.count
        }
    }

    var isOpen: Bool { status == .pending || status == .inProgress }
}

extension DocketEntry {
    /// Fields added since an entry was first saved decode as their defaults, so an older save still loads.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        matter = try c.decode(Matter.self, forKey: .matter)
        status = try c.decodeIfPresent(Status.self, forKey: .status) ?? .pending
        resume = try c.decodeIfPresent(CaseSnapshot.self, forKey: .resume)
        continuances = try c.decodeIfPresent(Int.self, forKey: .continuances) ?? 0
        requests = try c.decodeIfPresent([EvidenceRequest].self, forKey: .requests)
        note = try c.decodeIfPresent(String.self, forKey: .note)
        outcome = try c.decodeIfPresent(String.self, forKey: .outcome)
    }
}

/// A day in court.
struct CourtDay: Codable {
    enum Kind: String, Codable {
        case trial, administrative, specialSetting

        var label: String {
            switch self {
            case .trial: return "Criminal session"
            case .administrative: return "Administrative session"
            case .specialSetting: return "Special setting"
            }
        }
    }

    var date: Date
    /// The courtroom clock: court opens at the judge's chosen hour and time passes with each matter.
    var clock: Date
    var kind: Kind
    var entries: [DocketEntry]
    /// Which day of the week-long session this is (1–5), or 0 for a special setting.
    var sessionDay: Int
    /// How the week's trials came out, for the week in review.
    struct Tally: Codable {
        var convictions = 0
        var withoutConviction = 0
        var active = 0
    }
    var tally: Tally? = nil

    var isComplete: Bool { !entries.contains { $0.isOpen } }
}

/// A matter continued to a later date.
struct ScheduledMatter: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var entry: DocketEntry
}

enum CourtCalendar {
    /// The court keeps a Gregorian calendar with a Saturday–Sunday weekend, whatever the device's region settings.
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .current
        return calendar
    }()

    static func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    /// The same date, or the next day court sits: weekends and state court holidays are skipped.
    static func weekday(onOrAfter date: Date) -> Date {
        var day = calendar.startOfDay(for: date)
        while !isCourtDay(day) { day = calendar.date(byAdding: .day, value: 1, to: day) ?? day }
        return day
    }

    static func isCourtDay(_ date: Date) -> Bool {
        !isWeekend(date) && holiday(on: date) == nil
    }

    /// The North Carolina Judicial Branch holiday on this date, if any. A holiday that falls on a Saturday is
    /// observed the Friday before, and one on a Sunday the Monday after.
    static func holiday(on date: Date) -> String? {
        let day = calendar.startOfDay(for: date)
        let year = calendar.component(.year, from: day)
        for y in [year - 1, year, year + 1] {
            for (when, name) in holidays(in: y) where calendar.isDate(when, inSameDayAs: day) { return name }
        }
        return nil
    }

    /// The court holidays observed in a year.
    static func holidays(in year: Int) -> [(Date, String)] {
        func date(_ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        }
        /// The nth weekday (1 Sunday ... 7 Saturday) of a month; n = -1 for the last.
        func nth(_ n: Int, _ weekday: Int, of month: Int) -> Date {
            if n > 0 {
                return calendar.date(from: DateComponents(year: year, month: month, weekday: weekday, weekdayOrdinal: n)) ?? date(month, 1)
            }
            var d = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: date(month, 1)) ?? date(month, 28)
            while calendar.component(.weekday, from: d) != weekday { d = calendar.date(byAdding: .day, value: -1, to: d) ?? d }
            return d
        }
        func observed(_ d: Date) -> Date {
            switch calendar.component(.weekday, from: d) {
            case 7: return calendar.date(byAdding: .day, value: -1, to: d) ?? d
            case 1: return calendar.date(byAdding: .day, value: 1, to: d) ?? d
            default: return d
            }
        }
        // Easter Sunday (anonymous Gregorian algorithm), for Good Friday.
        let a = year % 19, b = year / 100, c = year % 100, d = b / 4, e = b % 4
        let f = (b + 8) / 25, g = (b - f + 1) / 3, h = (19 * a + b - d - g + 15) % 30
        let i = c / 4, k = c % 4, l = (32 + 2 * e + 2 * i - h - k) % 7, m = (a + 11 * h + 22 * l) / 451
        let easterMonth = (h + l - 7 * m + 114) / 31, easterDay = (h + l - 7 * m + 114) % 31 + 1
        let goodFriday = calendar.date(byAdding: .day, value: -2, to: date(easterMonth, easterDay)) ?? date(4, 1)
        /// Three days at Christmas, shifted as the State shifts them when the 24th, 25th, or 26th is a weekend.
        func christmas() -> [(Date, String)] {
            let days: [Int]
            switch calendar.component(.weekday, from: date(12, 25)) {
            case 1: days = [23, 26, 27]         // Sunday
            case 2: days = [22, 25, 26]         // Monday
            case 6: days = [24, 25, 28]         // Friday
            case 7: days = [23, 24, 27]         // Saturday
            default: days = [24, 25, 26]
            }
            return days.map { (date(12, $0), $0 < 25 ? "Christmas Eve" : ($0 == 25 ? "Christmas Day" : "Christmas")) }
        }
        let thanksgiving = nth(4, 5, of: 11)
        let fixed: [(Date, String)] = [
            (observed(date(1, 1)), "New Year's Day"),
            (nth(3, 2, of: 1), "Martin Luther King Jr. Day"),
            (goodFriday, "Good Friday"),
            (nth(-1, 2, of: 5), "Memorial Day"),
            (observed(date(7, 4)), "Independence Day"),
            (nth(1, 2, of: 9), "Labor Day"),
            (observed(date(11, 11)), "Veterans Day"),
            (thanksgiving, "Thanksgiving"),
            (calendar.date(byAdding: .day, value: 1, to: thanksgiving) ?? thanksgiving, "Thanksgiving"),
        ]
        return fixed + christmas()
    }

    /// Election Day: the first Tuesday after the first Monday in November.
    static func electionDay(in year: Int) -> Date {
        let firstMonday = calendar.date(from: DateComponents(year: year, month: 11, weekday: 2, weekdayOrdinal: 1)) ?? Date()
        return calendar.date(byAdding: .day, value: 1, to: firstMonday) ?? firstMonday
    }

    /// The days court sits in the week that starts on this Monday.
    static func courtDays(inWeekOf monday: Date) -> Int {
        (0..<5).filter { offset in
            guard let d = calendar.date(byAdding: .day, value: offset, to: monday) else { return false }
            return isCourtDay(d)
        }.count
    }

    /// The holidays that close the courthouse during the court week that starts on this Monday.
    static func holidays(inWeekOf monday: Date) -> [(Date, String)] {
        (0..<5).compactMap { offset in
            guard let d = calendar.date(byAdding: .day, value: offset, to: monday), let name = holiday(on: d) else { return nil }
            return (d, name)
        }
    }

    static func nextWeekday(after date: Date) -> Date {
        weekday(onOrAfter: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date)
    }

    static func monday(onOrBefore date: Date) -> Date {
        var day = calendar.startOfDay(for: date)
        while calendar.component(.weekday, from: day) != 2 { day = calendar.date(byAdding: .day, value: -1, to: day) ?? day }
        return day
    }

    static func monday(onOrAfter date: Date) -> Date {
        var day = calendar.startOfDay(for: date)
        while calendar.component(.weekday, from: day) != 2 { day = calendar.date(byAdding: .day, value: 1, to: day) ?? day }
        return day
    }

    /// Court opens at the judge's hour on the given date.
    static func opening(on date: Date, minutesAfterMidnight: Int) -> Date {
        calendar.date(byAdding: .minute, value: minutesAfterMidnight, to: calendar.startOfDay(for: date)) ?? date
    }

    static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func dayTitle(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    /// "Week of October 19–23, 2026"
    static func weekTitle(_ date: Date) -> String {
        let monday = monday(onOrBefore: date)
        let friday = calendar.date(byAdding: .day, value: 4, to: monday) ?? monday
        let sameMonth = calendar.component(.month, from: monday) == calendar.component(.month, from: friday)
        let end = sameMonth ? friday.formatted(.dateTime.day()) : friday.formatted(.dateTime.month(.wide).day())
        return "Week of " + monday.formatted(.dateTime.month(.wide).day()) + "–" + end + ", " + friday.formatted(.dateTime.year())
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool { calendar.isDate(a, inSameDayAs: b) }
}

/// Motions to continue that the parties bring when a case is called for trial.
enum ContinuanceMotions {

    /// A motion with a concrete, case-specific reason, or nil if the follow-up it would need doesn't fit this case.
    static func make(for c: CourtCase, rng: inout SeededRNG) -> ContinuanceMotion? {
        // Written cases carry only what was written for them.
        guard !c.templateKey.hasPrefix("story.") else { return nil }
        let options = EvidenceRequest.options(for: c)
        guard !options.isEmpty else { return nil }
        let request = rng.pick(options)
        let dl = c.defendant.lastName
        let ada = c.prosecutor
        let defense = c.defenseAttorney.components(separatedBy: ",").first ?? c.defenseAttorney
        let agency = c.investigatingAgency
        let jailed = c.background?.isJailed ?? false
        let weeks = rng.int(3...6)
        let stateEvidence = c.evidence.filter { $0.side == .prosecution }
        let place = rng.pick(["the convenience store across the street", "the apartment complex's front office", "a neighbor's doorbell camera",
                              "the gas station at the corner", "the city traffic camera at the intersection"])
        let speedyObjection = jailed
            ? "\(dl) has been sitting in the Hollis County jail waiting for this trial. Every week of delay is another week in custody."
            : "\(dl) has been under this charge for a long time and has been ready for trial at every setting."

        switch request {
        case .labTesting:
            let item = c.evidence.first { $0.kind == .forensic && $0.side == .prosecution } ?? stateEvidence.first
            let what = item.map { "\"\($0.title)\"" } ?? "the items seized in this case"
            return ContinuanceMotion(
                movant: .prosecution, title: "State Crime Laboratory report not back",
                argument: "\(ada): \"The State moves to continue, Your Honor. The State Crime Laboratory hasn't finished its analysis of \(what). The section chief tells us about \(weeks) weeks. Without the final report we can't call the analyst, and the Confrontation Clause won't let us put it in any other way.\"",
                opposition: "\(defense): \"We object. \(speedyObjection) The State has had this evidence since the day of the arrest.\"",
                request: request,
                ifDenied: "The trial goes forward without the lab's final report; the State proceeds on the evidence it has.",
                suggestedDays: weeks * 7)
        case .video:
            if rng.chance(0.5) {
                return ContinuanceMotion(
                    movant: .defense, title: "Subpoenaed surveillance footage not produced",
                    argument: "\(defense): \"The defense moves to continue. We subpoenaed the surveillance video from \(place) \(rng.int(3...6)) weeks ago. It still hasn't been produced, and the custodian says the system overwrites after 60 days unless it was pulled. My client tells me that video shows what really happened.\"",
                    opposition: "\(ada): \"The State opposes. The defense could have asked for this months ago. The State's witnesses are here and ready.\"",
                    request: request,
                    ifDenied: "The trial goes forward without the footage; the defense can argue its absence.",
                    suggestedDays: weeks * 7)
            }
            return ContinuanceMotion(
                movant: .prosecution, title: "Surveillance footage still being collected",
                argument: "\(ada): \"The State moves to continue. Investigators with the \(agency) identified a camera at \(place) after the case was indicted. A preservation letter went out, but the footage hasn't been turned over yet. We ask for \(weeks) weeks to get it and provide it in discovery.\"",
                opposition: "\(defense): \"Objection. This is the State's investigation, and the State had every opportunity to collect it. \(speedyObjection)\"",
                request: request,
                ifDenied: "The trial goes forward; any footage won't be part of the record.",
                suggestedDays: weeks * 7)
        case .witnessFollowUp:
            let movant: Side = rng.chance(0.5) ? .prosecution : .defense
            let witness = c.witnesses.filter { $0.calledBy == movant }.first
            let why = rng.pick(["was served with a subpoena but was admitted to the hospital on Saturday",
                                "is out of state on military orders until the end of the month",
                                "had a death in the family and is in Georgia for the funeral",
                                "was served but called this morning from the emergency room, where their child was taken overnight"])
            let who = witness.map { "\($0.name), \($0.role.lowercased())," } ?? "a material witness"
            let lawyer = movant == .prosecution ? ada : defense
            return ContinuanceMotion(
                movant: movant, title: "Witness under subpoena unavailable",
                argument: "\(lawyer): \"We move to continue, Your Honor. \(who.capitalizedFirst) \(why). The testimony is material, we've used due diligence to secure it, and we expect the witness to be available at the next setting.\"",
                opposition: movant == .prosecution
                    ? "\(defense): \"We object. \(speedyObjection) The State could have taken a deposition or arranged remote testimony.\""
                    : "\(ada): \"The State opposes. Our witnesses took off work again to be here, and the victim wants this resolved.\"",
                request: request,
                ifDenied: "The trial goes forward without that witness's testimony.",
                suggestedDays: weeks * 7)
        case .phoneRecords:
            if rng.chance(0.5) {
                return ContinuanceMotion(
                    movant: .prosecution, title: "Phone extraction pending",
                    argument: "\(ada): \"The State moves to continue. The digital forensics unit has the search warrant for the phone recovered in this case, but the extraction isn't finished. The examiner estimates \(weeks) weeks.\"",
                    opposition: "\(defense): \"Objection. The phone has been in the State's custody since the arrest. \(speedyObjection)\"",
                    request: request,
                    ifDenied: "The trial goes forward without the phone extraction.",
                    suggestedDays: weeks * 7)
            }
            return ContinuanceMotion(
                movant: .defense, title: "Cell-site records subpoenaed",
                argument: "\(defense): \"The defense moves to continue. We subpoenaed the carrier for the cell-site location records for \(dl)'s phone on the day in question. They haven't come back, and we expect them to place my client somewhere else.\"",
                opposition: "\(ada): \"The State opposes. Carriers take time, and the defense waited until the last minute to ask.\"",
                request: request,
                ifDenied: "The trial goes forward without the location records.",
                suggestedDays: weeks * 7)
        case .financialRecords:
            let movant: Side = rng.chance(0.6) ? .prosecution : .defense
            return ContinuanceMotion(
                movant: movant, title: movant == .prosecution ? "Bank records subpoena outstanding" : "Business records just disclosed",
                argument: movant == .prosecution
                    ? "\(ada): \"The State moves to continue. Subpoenaed bank records for the accounts in this case haven't been returned, and our forensic accountant can't finish the tracing without them.\""
                    : "\(defense): \"The defense moves to continue. The State turned over \(stateEvidence.first.map { "\"\($0.title)\"" } ?? "several hundred pages of business records") in supplemental discovery last week. We need time to review it with an accountant.\"",
                opposition: movant == .prosecution
                    ? "\(defense): \"Objection. \(speedyObjection)\""
                    : "\(ada): \"The State opposes. The records were available for inspection all along.\"",
                request: request,
                ifDenied: "The trial goes forward on the records already in evidence.",
                suggestedDays: weeks * 7)
        case .expertReview:
            let item = stateEvidence.first { $0.kind == .forensic || $0.kind == .digital } ?? stateEvidence.first
            return ContinuanceMotion(
                movant: .defense, title: "Late discovery: defense needs an expert",
                argument: "\(defense): \"The defense moves to continue. The State disclosed \(item.map { "\"\($0.title)\"" } ?? "a new forensic report") on Friday. We need to review it and consult an independent expert. A continuance is one of the remedies the statute provides for late discovery (G.S. 15A-910).\"",
                opposition: "\(ada): \"The State opposes. The report confirms what the defense already knew, and the disclosure was made as soon as we had it.\"",
                request: request,
                ifDenied: "The trial goes forward; the defense cross-examines on the new report without its own expert.",
                suggestedDays: weeks * 7)
        }
    }
}
