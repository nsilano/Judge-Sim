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
/// A defendant out on release who will be back in custody on a date: arrested on a new charge (bond revoked) or
/// picked up after missing court (bond doubled). Until then the person is out, and the case goes on as usual.
struct PendingRearrest: Identifiable, Codable {
    var id = UUID()
    var caseID: UUID
    var date: Date
    var status: String
    var arrestText: String
    var jailText: String
    var note: String
    /// The doubled bond after a missed court date (nil when the bond was revoked outright).
    var bond: Int? = nil
}

/// A case off the calendar while something takes its time: a capacity evaluation, or treatment to restore capacity.
/// It returns to the list waiting for a trial date when that's done.
struct HeldCase: Identifiable, Codable {
    var id = UUID()
    var courtCase: CourtCase
    var since: Date
    var until: Date
    /// What the case is waiting on, for the docket ("Forensic evaluation at Central Regional Hospital").
    var reason: String
    /// The note it returns with.
    var note: String
}

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
                             "We've heard how this court weighs the State's evidence. We'd ask it to weigh this evidence the same way: all of it.", "We know this court asks hard questions about the State's proof. We are prepared to answer every one.", "Your Honor has a reputation for making the State earn it. We intend to.", "Judge, I know you ask the State to prove every element. We came prepared to do exactly that.", "This court doesn't give the State anything it hasn't earned. We intend to earn it.", "Your Honor will hold us to our burden. That's fair, and that's what we expect.", "We've heard you give defendants room, Judge. We'd ask for the same careful look at what the State has brought.", "The State respects how closely this court reads the evidence. We have nothing to hide from that.", "Judge, you don't rubber-stamp anything. We've built this case to survive that kind of scrutiny."])
        case (.lenient, .defense):
            return rng.pick(["We're asking the court to do what it has done before: hold the State to its proof.",
                             "This court has never been afraid to say the State fell short. It has here.", "This court has been willing to let the State's weak cases fail. I ask for the same attention here.", "Judge, I've seen you hold the State to its burden before, and I ask for that again.", "Judge, this court has a record of making the State prove its case, and I'd ask it to do the same here.", "I'm asking the court to read the State's evidence as skeptically as it always has.", "This court has acquitted when the proof wasn't there. I'm asking for the same standard today.", "Your Honor has never been shy about holding the State to its burden. Please do it again.", "I trust this court to ask where the State's evidence runs out, Judge, and it runs out early.", "We're in the right courtroom for a case with this much doubt, Judge."])
        case (.harsh, .defense):
            return rng.pick(["I know this court's reputation for long sentences, Judge. I'm asking only that it hold the State to its burden first.",
                             "Defendants in this county are told what happens in this courtroom. I'm asking the court to look at the evidence before it looks at my client.",
                             "My client was afraid to try this case in front of you, Judge. I said the evidence would decide it. I'm counting on that.", "Judge, I know what happens in cases like this one in this courtroom. I ask only that the evidence come first.", "My client has heard about this courtroom. I told them the facts still matter here.", "I know your sentences are not light, Judge. That's why I'm asking the court to look hard at whether the State has proven anything.", "My client knows how this court treats convictions. I'm asking only that there not be one without proof.", "Judge, the stakes in this courtroom are high, and so is the State's burden. I'm asking the court to remember both.", "Everyone in the jail knows what happens here after a conviction. I'm asking you to be sure first.", "I'm not going to pretend I don't know your reputation, Judge. I'm asking for the evidence to be weighed fairly before any of that matters.", "A harsh sentence is only fair if the proof is solid. I'd ask the court to start with the proof."])
        case (.harsh, .prosecution):
            return rng.pick(["The court has never treated this kind of conduct lightly. The evidence shows why it shouldn't start now.",
                             "This court knows what accountability looks like. The State is asking for nothing less.", "The State appreciates a court that takes this seriously.", "This court has made clear what it expects of people who stand where this defendant stands.", "The State knows this court takes sentencing seriously, and we've prepared this case with that in mind.", "This court's reputation for accountability is why the State is comfortable asking for what the evidence supports.", "We know this court expects a thorough case. We're ready to give it one.", "This is the kind of case where this court's firmness matters, and the State is not shy about saying so.", "The State appreciates that this court doesn't flinch when the evidence is serious.", "Judge, you've never looked away from serious conduct, and the State is asking you not to start now."])
        case (.respected, .prosecution):
            return rng.pick(["We'll be brief, Your Honor. The court knows how to read evidence.", "The State trusts the court to weigh this carefully, as it always does.", "The State has always been able to rely on this court to read the whole record.", "We'll rest on the evidence, Your Honor. This court has always weighed it fairly.", "The State has full confidence in the court's reading of the evidence, and we'll try to be efficient.", "We trust the court to sort the evidence the way it always does, Your Honor.", "Your Honor has always given the State a fair and careful hearing, and we expect no less today.", "We'll present what we have and let the court weigh it, as it always does.", "The State appreciates this court's attention to detail, and we've prepared with that in mind.", "We know this court reads every exhibit, Your Honor, so we've made sure each one counts."])
        case (.respected, .defense):
            return rng.pick(["We're glad to try this case before a judge who listens.", "This court reads the record. That's all the defense asks.", "Judge, you have always given the defense a fair hearing, and that is all we ask.", "The defense is comfortable putting this case in front of this court.", "The defense appreciates a court that reads everything, and we've prepared with that in mind.", "We came here knowing this court listens, and that's all any defendant should ask.", "Judge, you've always been fair to the defense, and my client deserves exactly that.", "We're comfortable letting the court decide this case on the evidence.", "This court takes the time to understand what happened, and the defense is grateful.", "We have confidence in this court, Judge, and we'll keep our presentation short and clear."])
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
                                                "I looked up your other cases, Judge. I'm asking you to see us.", "A few people at the jail said you listen. I'm hoping you do.", "I read that you look at the whole person. Please look at me.", "I've heard you give people a chance. I won't waste it.", "I heard you take your time with every case. I hope you take it with mine.", "Somebody told me you give people the benefit of the doubt. I hope I've earned it.", "I've been told you look at what a person has been through. I'd ask you to look at my whole story.", "My lawyer says you are fair and patient. I'm hoping that's true today.", "I know you've given other people another chance. I'm asking for the same.", "I've heard good things about how you run your courtroom, Judge. I hope I can see that for myself."]) : nil
        case .harsh:
            return rng.chance(0.4) ? rng.pick(["People say you're tough, Judge. Good.", "I know you take cases like this seriously. Thank you for that.", "I know you don't take shortcuts. I respect that.", "Whatever you decide, I know it will be fair.", "I've heard you hold people accountable. I think that's right, Judge.", "I know you don't let things slide, Judge. I wouldn't want you to.", "I'm not here expecting a favor, Judge. I'm here expecting fairness.", "People told me this court is strict. I'd rather be in a strict court than a careless one.", "I know you take your time and you take your job seriously, Judge. I respect that.", "I expect you to hold me to every rule, Judge. I'm ready for that."]) : nil
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
                                                "People told me not to bother saying anything in front of you. I'm saying it anyway.", "I've been told you're hard on people. I'm still asking you to hear me.", "Nobody thinks you'll go easy. I'm not asking you to. I'm asking you to listen.", "I've heard what happens to people in front of you, Judge. I'm hoping you'll still see me as a person.", "Everybody warned me, Judge. I'm still asking you to hear my side.", "They say you're hard on people like me. I'm asking you to look at what's in the file before you decide.", "I know I'm not going to get any breaks here. I'm just asking for a fair hearing.", "I've been scared of this day since I heard your name, Judge. I'm still going to say what I came to say.", "Even people who like you say you don't bend. I'm asking you to listen to the reasons."]) : nil
        case .lenient:
            return rng.chance(0.4) ? rng.pick(["I've heard you give people a chance, Judge. I won't waste it.",
                                               "They say you listen. I hope that's true today.", "People in my town say you're fair. I hope today proves it.", "I heard you read the files. I hope mine tells you what I can't.", "I heard you take time with every person who comes in here. I hope you'll take time with me.", "They say you give people a chance to explain. I'm going to do my best with it.", "I heard this is a good courtroom to have to be in, if you have to be in one.", "My cousin said you were patient with the whole family. I hope you are with me.", "Someone at work told me you read everything. I hope that helps me.", "People who've been here before say you're even-handed. That's all I need."]) : nil
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
