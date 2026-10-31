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
    /// How many new cases the judge takes; the rest go to visiting judges (optional for older saves).
    var intake: Intake? = nil

    /// New-case intake the judge asks the chief judge for. Cases already on the list, probation matters, and people
    /// the judge has sentenced still come back here.
    enum Intake: String, Codable, CaseIterable, Identifiable {
        case full, reduced, light, closed
        var id: String { rawValue }
        var title: String {
            switch self {
            case .full: return "Full share"
            case .reduced: return "Reduced"
            case .light: return "Light"
            case .closed: return "No new cases"
            }
        }
        var detail: String {
            switch self {
            case .full: return "Every new felony the county sends."
            case .reduced: return "About 60% of new cases; visiting judges take the rest."
            case .light: return "About a third of new cases."
            case .closed: return "No new indictments while you clear the list. Arrests in cases you've followed, probation matters, and people you've sentenced still come to you."
            }
        }
        var factor: Double {
            switch self {
            case .full: return 1
            case .reduced: return 0.6
            case .light: return 0.33
            case .closed: return 0
            }
        }
    }

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

    func isOff(_ date: Date) -> Bool { timeOff.contains(Self.key(date)) || closures?[Self.key(date)] != nil }

    /// Days the courthouse is closed or the judge is assigned elsewhere, and why. Not leave (optional for older saves).
    var closures: [String: String]? = nil

    func closure(on date: Date) -> String? { closures?[Self.key(date)] }

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
/// A case whose defendant has had a first appearance and now waits to be arraigned, or to plead, at a calendar call.
struct PendingArraignment: Identifiable, Codable {
    var id = UUID()
    var courtCase: CourtCase
    var since: Date
    var due: Date
    var note: String
}

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
    /// Days that don't work for someone the trial needs, by date ("2026-11-03"), with the reason.
    var conflicts: [String: String]? = nil
    /// When the DA's office asked for this case to be set first, and why.
    var priorityRequested: Date? = nil
    var priorityReason: String? = nil

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
            // Only the time held since the case reached this court is on this court. A case from before the intake
            // count was kept counts from when it joined the list.
            let intake = bg.custodyAtIntake ?? max(0, held - waited)
            let here = held >= intake ? held - intake : held
            let total = "In jail \(held) day\(held == 1 ? "" : "s")"
            let detail = here < held ? " (\(here) since the case reached your court)" : ""
            switch here {
            case 150...: raise(.critical, total + detail + ": a speedy-trial dismissal is a real risk", 60)
            case 75...: raise(.urgent, total + detail + " awaiting trial", 35)
            case 21...: raise(.soon, total + detail + " awaiting trial", 20)
            default: raise(.soon, total + detail + "; the defendant is waiting in jail", 12)
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
        if note.contains("Back in your court") || note.contains("stay-away order") || note.contains("no-contact condition") { raise(.soon, "A defendant you've judged before, charged again", 8) }
        if c.mediaAttention >= 3 { raise(.soon, "The paper is following it", 8) }
        if entry.continuances >= 2 { raise(.soon, "Already continued \(entry.continuances) times", 6) }
        switch waited {
        case 180...: raise(.urgent, "Waiting \(waited) day\(waited == 1 ? "" : "s") for a date", 20)
        case 90...: raise(.soon, "Waiting \(waited) day\(waited == 1 ? "" : "s") for a date", 10)
        default: break
        }
        return Urgency(level: level, score: score, reasons: reasons)
    }
}

/// How the lawyers in this courthouse feel about the judge, from what the judge has done. 50 is neutral.
struct CourthouseMood: Codable, Hashable {
    var prosecutors = 55
    var defenders = 55

    /// The mood as it stands, for the lawyers and families whose words are written as a case is called.
    static var current = CourthouseMood()

    /// The judge's name in the courthouse: lenient when the State is unhappy and the defense pleased, harsh the other way.
    enum Name { case lenient, harsh, respected, neutral }
    var name: Name {
        if prosecutors <= 42 && defenders >= 58 { return .lenient }
        if defenders <= 42 && prosecutors >= 58 { return .harsh }
        if prosecutors >= 62 && defenders >= 62 { return .respected }
        return .neutral
    }

    /// What a lawyer adds to an opening or closing in front of a judge with this name. Nothing when the judge is unknown.
    func aside(for side: Side, closing: Bool, seed: UInt64) -> String? {
        var rng = SeededRNG(seed: seed ^ (side == .prosecution ? 0x0A1 : 0x0D2) ^ (closing ? 0xC10 : 0))
        guard rng.chance(0.7) else { return nil }
        switch (name, side) {
        case (.lenient, .prosecution):
            return rng.pick(["The State knows this court holds it to every element. We will prove each one.",
                             "Judge, I know this courtroom gives defendants the benefit of every doubt. This case leaves none to give.",
                             "We've heard how this court weighs the State's evidence. We'd ask it to weigh this evidence the same way: all of it."])
        case (.lenient, .defense):
            return rng.pick(["We're asking the court to do what it has done before: hold the State to its proof.",
                             "This court has never been afraid to say the State fell short. It has here."])
        case (.harsh, .defense):
            return rng.pick(["I know this court's reputation for long sentences, Judge. I'm asking only that it hold the State to its burden first.",
                             "Defendants in this county are told what happens in this courtroom. I'm asking the court to look at the evidence before it looks at my client.",
                             "My client was afraid to try this case in front of you, Judge. I said the evidence would decide it. I'm counting on that."])
        case (.harsh, .prosecution):
            return rng.pick(["The court has never treated this kind of conduct lightly. The evidence shows why it shouldn't start now.",
                             "This court knows what accountability looks like. The State is asking for nothing less."])
        case (.respected, .prosecution):
            return rng.pick(["We'll be brief, Your Honor. The court knows how to read evidence.", "The State trusts the court to weigh this carefully, as it always does."])
        case (.respected, .defense):
            return rng.pick(["We're glad to try this case before a judge who listens.", "This court reads the record. That's all the defense asks."])
        case (.neutral, _):
            return nil
        }
    }

    /// What a victim's family adds when the judge's name has reached them.
    func familyPlea(seed: UInt64) -> String? {
        var rng = SeededRNG(seed: seed ^ 0xFA11)
        switch name {
        case .lenient:
            return rng.chance(0.75) ? rng.pick(["I've read what happens in this courtroom. Please don't let it happen in mine.",
                                                "People told me this court goes easy. I'm asking you to prove them wrong.",
                                                "I looked up your other cases, Judge. I'm asking you to see us."]) : nil
        case .harsh:
            return rng.chance(0.4) ? rng.pick(["People say you're tough, Judge. Good.", "I know you take cases like this seriously. Thank you for that."]) : nil
        default:
            return nil
        }
    }

    /// What a defendant adds when the judge's name has reached the jail.
    func defendantPlea(seed: UInt64) -> String? {
        var rng = SeededRNG(seed: seed ^ 0xDEF5)
        switch name {
        case .harsh:
            return rng.chance(0.75) ? rng.pick(["Everybody in the jail says you don't give second chances, Judge. I'm asking for one anyway.",
                                                "I know your reputation. I'm not asking you to change it, just to look at me.",
                                                "People told me not to bother saying anything in front of you. I'm saying it anyway."]) : nil
        case .lenient:
            return rng.chance(0.4) ? rng.pick(["I've heard you give people a chance, Judge. I won't waste it.",
                                               "They say you listen. I hope that's true today."]) : nil
        default:
            return nil
        }
    }

    mutating func adjust(prosecutors p: Int, defenders d: Int) {
        prosecutors = max(5, min(95, prosecutors + p))
        defenders = max(5, min(95, defenders + d))
    }

    /// The DA's bargaining: a frustrated office pushes harder for prison; a satisfied one bargains.
    var prosecutorEdge: Double { Double(55 - prosecutors) / 150 }

    func line(prosecutor name: String) -> String {
        switch prosecutors {
        case ..<35: return "\(name), in the hallway: \"We've stopped offering much in your courtroom, Judge. There's no point.\""
        case ..<50: return "\(name): \"The office thinks you give the defense the benefit of every doubt. We're adjusting.\""
        case ..<65: return "\(name): \"We know what to expect from you. That's all we ask.\""
        default: return "\(name): \"Your courtroom runs the way a courtroom should. We bring you our hardest cases gladly.\""
        }
    }

    func line(defender name: String) -> String {
        switch defenders {
        case ..<35: return "\(name), at the clerk's counter: \"My clients plead out rather than try a case in front of you.\""
        case ..<50: return "\(name): \"We'll take our chances at trial, Judge, but we're not optimistic.\""
        case ..<65: return "\(name): \"You listen. My clients can't ask for more than that.\""
        default: return "\(name): \"Defendants trust they'll get a fair hearing in your courtroom. That's rarer than you'd think.\""
        }
    }
}
