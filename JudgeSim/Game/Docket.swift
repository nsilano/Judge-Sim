import Foundation

/// How much the judge takes on in one court day.
struct DayLimit: Codable, Hashable {
    var trials: Int
    var hearings: Int

    static let closed = DayLimit(trials: 0, hearings: 0)
}

/// The judge's standing schedule: which weekdays court sits, how much each day takes, one-day changes, and time off.
/// Weekdays are numbered as the calendar numbers them: 2 is Monday, 6 is Friday.
struct CourtSchedule: Codable, Hashable {
    var courtDays: Set<Int> = [2, 3, 4, 5, 6]
    /// The usual limit for each weekday.
    var limits: [Int: DayLimit] = CourtSchedule.standardLimits
    /// One-day changes, by date ("2026-11-03").
    var overrides: [String: DayLimit] = [:]
    /// Days the judge has booked off, by date.
    var timeOff: Set<String> = []
    /// Court days of leave a year.
    var leavePerYear = 30

    static let weekdayNames = [2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday"]

    static let standardLimits: [Int: DayLimit] = [2: DayLimit(trials: 1, hearings: 0), 3: DayLimit(trials: 1, hearings: 1),
                                                  4: DayLimit(trials: 1, hearings: 1), 5: DayLimit(trials: 1, hearings: 1),
                                                  6: DayLimit(trials: 0, hearings: 1)]

    /// Ready-made weeks the judge can start from.
    enum Template: String, CaseIterable, Identifiable {
        case standard, light, trialHeavy
        var id: String { rawValue }

        var title: String {
            switch self {
            case .standard: return "Standard week"
            case .light: return "Light week"
            case .trialHeavy: return "Trial-heavy week"
            }
        }

        var detail: String {
            switch self {
            case .standard: return "A trial a day Monday through Thursday, hearings Tuesday through Friday."
            case .light: return "Trials on Tuesday and Thursday only, a hearing each of those days."
            case .trialHeavy: return "Two trials a day midweek. The backlog shrinks, and the days run long."
            }
        }

        var limits: [Int: DayLimit] {
            switch self {
            case .standard: return CourtSchedule.standardLimits
            case .light: return [2: DayLimit(trials: 0, hearings: 0), 3: DayLimit(trials: 1, hearings: 1), 4: .closed,
                                 5: DayLimit(trials: 1, hearings: 1), 6: .closed]
            case .trialHeavy: return [2: DayLimit(trials: 1, hearings: 1), 3: DayLimit(trials: 2, hearings: 1), 4: DayLimit(trials: 2, hearings: 1),
                                      5: DayLimit(trials: 2, hearings: 1), 6: DayLimit(trials: 1, hearings: 1)]
            }
        }
    }

    static func key(_ date: Date) -> String {
        let c = CourtCalendar.calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func weekday(_ date: Date) -> Int { CourtCalendar.calendar.component(.weekday, from: date) }

    func isOff(_ date: Date) -> Bool { timeOff.contains(Self.key(date)) }

    /// The judge is in court that day: a weekday the schedule sits, not a court holiday, not booked off.
    func sits(on date: Date) -> Bool {
        CourtCalendar.isCourtDay(date) && courtDays.contains(Self.weekday(date)) && !isOff(date)
    }

    /// What the day takes: its own change if it has one, else the weekday's usual limit.
    func limit(on date: Date) -> DayLimit {
        guard sits(on: date) else { return .closed }
        return overrides[Self.key(date)] ?? limits[Self.weekday(date)] ?? .closed
    }

    func hasOverride(_ date: Date) -> Bool { overrides[Self.key(date)] != nil }

    /// Trials the usual week takes.
    var weeklyTrials: Int { courtDays.reduce(0) { $0 + (limits[$1]?.trials ?? 0) } }

    /// Court days booked off in a year: only days court would otherwise sit count against leave.
    func leaveUsed(in year: Int) -> Int {
        timeOff.filter { key in
            guard key.hasPrefix(String(format: "%04d", year)), let date = Self.date(key) else { return false }
            return CourtCalendar.isCourtDay(date) && courtDays.contains(Self.weekday(date))
        }.count
    }

    static func date(_ key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return CourtCalendar.calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}

/// A case set for trial that has no date yet. The judge picks the date.
struct AwaitingCase: Identifiable, Codable {
    var id = UUID()
    /// The trial as it will go on the calendar, with its notes and any earlier continuances.
    var entry: DocketEntry
    /// When the case joined the list.
    var since: Date
    /// The first day it can be tried, and why: discovery, a lab report, an arrest, an evaluation.
    var earliest: Date?
    var earliestReason: String?
    /// Costs of waiting already felt, so each lands once.
    var warnings: [String] = []

    var courtCase: CourtCase? {
        if case .trial(let c) = entry.matter { return c }
        return nil
    }
}

/// How urgently a case needs a date, and why.
struct Urgency {
    enum Level: Int, Comparable {
        case routine, soon, urgent, critical

        static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }

        var label: String {
            switch self {
            case .routine: return "Routine"
            case .soon: return "Soon"
            case .urgent: return "Urgent"
            case .critical: return "Critical"
            }
        }
    }

    var level: Level
    var score: Int
    var reasons: [String]

    /// The urgency of a trial: who is waiting in jail, who is at risk, what the law presses, and how long it has sat.
    static func of(_ c: CourtCase, entry: DocketEntry, since: Date, today: Date) -> Urgency {
        let cal = CourtCalendar.calendar
        let waited = max(0, cal.dateComponents([.day], from: cal.startOfDay(for: since), to: cal.startOfDay(for: today)).day ?? 0)
        var level = Level.routine
        var score = waited / 10
        var reasons: [String] = []
        func raise(_ to: Level, _ why: String, _ points: Int) {
            level = max(level, to)
            score += points
            reasons.append(why)
        }
        if let bg = c.background, bg.isJailed {
            // Jail time keeps running from the last date it was credited.
            let held = bg.custodyDays + max(0, cal.dateComponents([.day], from: cal.startOfDay(for: c.sessionDate), to: cal.startOfDay(for: today)).day ?? 0)
            switch held {
            case 240...: raise(.critical, "In jail \(held) days: a speedy-trial dismissal is a real risk", 60)
            case 120...: raise(.urgent, "In jail \(held) days awaiting trial", 35)
            case 30...: raise(.soon, "In jail \(held) days awaiting trial", 20)
            default: raise(.soon, "The defendant is in jail", 12)
            }
        }
        let onRelease = c.background?.isJailed != true
        if onRelease && Consequences.stateWantsOrder(c) {
            raise(.urgent, "The victim is at risk while the defendant is out", 25)
        }
        if Consequences.victimIsChild(c) { raise(.soon, "A child victim: memories fade and the law favors moving these", 10) }
        if let age = CaseTemplates.byKey[c.templateKey]?.story?.victim?.age, age >= 70 {
            raise(.soon, "An elderly victim, \(age)", 10)
        }
        let note = entry.note ?? ""
        if note.contains("Court of Appeals") || note.contains("New trial ordered") { raise(.soon, "Sent back for a new trial", 12) }
        if note.contains("Back in your court") || note.contains("stay-away order") { raise(.soon, "A defendant you've judged before, charged again", 8) }
        if c.mediaAttention >= 3 { raise(.soon, "The paper is following it", 8) }
        if entry.continuances >= 2 { raise(.soon, "Already continued \(entry.continuances) times", 6) }
        switch waited {
        case 180...: raise(.urgent, "Waiting \(waited) days for a date", 20)
        case 90...: raise(.soon, "Waiting \(waited) days for a date", 10)
        default: break
        }
        return Urgency(level: level, score: score, reasons: reasons)
    }
}
