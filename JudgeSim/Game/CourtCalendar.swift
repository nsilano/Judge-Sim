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

    var isComplete: Bool { !entries.contains { $0.isOpen } }
}

/// A matter continued to a later date.
struct ScheduledMatter: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var entry: DocketEntry
}

enum CourtCalendar {
    static var calendar: Calendar { Calendar.current }

    static func isWeekend(_ date: Date) -> Bool { calendar.isDateInWeekend(date) }

    /// The same date, or the next weekday if it falls on a weekend.
    static func weekday(onOrAfter date: Date) -> Date {
        var day = calendar.startOfDay(for: date)
        while isWeekend(day) { day = calendar.date(byAdding: .day, value: 1, to: day) ?? day }
        return day
    }

    static func nextWeekday(after date: Date) -> Date {
        weekday(onOrAfter: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date)
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

    static func isSameDay(_ a: Date, _ b: Date) -> Bool { calendar.isDate(a, inSameDayAs: b) }
}
