import Foundation

/// One appeal from a judgment in this court, followed from notice to decision.
struct AppealTracker: Identifiable, Codable {
    var id = UUID()
    var docket: String
    var caption: String
    var personID: UUID
    /// "the defendant" or "the State".
    var appellant: String
    var issue: String
    var filed: Date
    var briefsDue: Date
    /// nil when the panel decides on the briefs without oral argument.
    var argument: Date?
    var decisionDue: Date
    var decided: Date?
    var result: String?
    var opinion: String?
    var followUps: [String] = []
    /// What the appellant says the trial court got wrong (optional for older saves).
    var grounds: [String]? = nil
    /// For each ground, whether the ruling really was wrong. Hidden until the decision.
    var groundErrors: [Bool]? = nil
    /// The panel's answer to each issue, once decided.
    var holdings: [String]? = nil

    var isPending: Bool { decided == nil }

    enum Step: Int {
        case filed, briefing, awaitingArgument, underAdvisement, decided
    }

    func step(on date: Date) -> Step {
        if decided != nil { return .decided }
        if date < briefsDue { return .briefing }
        if let argument, date < argument { return .awaitingArgument }
        return .underAdvisement
    }

    func statusText(on date: Date) -> String {
        switch step(on: date) {
        case .filed, .briefing: return "Briefing under way"
        case .awaitingArgument: return "Oral argument set for \(SentenceFormat.shortDate(argument ?? date))"
        case .underAdvisement: return argument == nil ? "Submitted on the briefs; awaiting decision" : "Argued; awaiting decision"
        case .decided: return result ?? "Decided"
        }
    }

    var wasReversed: Bool {
        guard let result else { return false }
        return result.contains("vacated") || result.contains("New trial") || result.contains("reversed") || result.contains("reinstated")
    }
}

enum Appeals {
    /// The panel's answer to each issue raised: wrong and it mattered, wrong but harmless, or no error.
    static func holdings(for tracker: AppealTracker, reversed: Bool) -> [String] {
        guard let grounds = tracker.grounds, !grounds.isEmpty else {
            return [reversed ? "The panel found an error that affected the outcome; see the opinion." : "The panel found no reversible error in the record."]
        }
        let errors = tracker.groundErrors ?? []
        var anyCounted = false
        return grounds.enumerated().map { i, ground in
            let error = errors.indices.contains(i) ? errors[i] : false
            switch (reversed, error) {
            case (true, true):
                anyCounted = true
                return "Error, and it mattered. \(ground) The panel held the ruling was wrong and could have changed the result."
            case (false, true):
                return "Error, but harmless. \(ground) The panel agreed this was wrong, but held that the rest of the record makes it unlikely the result would have been different."
            case (true, false):
                return "No error. \(ground) The panel rejected this argument\(anyCounted ? "" : "; the case turned on another issue")."
            case (false, false):
                return "No error. \(ground) The panel held the ruling was correct, or within the court's discretion."
            }
        }
    }

    /// The status line an appellate decision gives the case.
    static func status(for event: PendingEvent) -> String {
        let headline = event.news.headline
        // A probation appeal is also scheduled as a resentencing, so it is checked first.
        let probationAppeal = (event.news.docket ?? "").hasSuffix("(PV)") || headline.contains("probation")
        if probationAppeal && (headline.contains("vacates") || headline.contains("reverses")) { return "Probation order vacated on appeal" }
        if !probationAppeal && (event.effect == .resentence || headline.contains("vacates sentence")) { return "Sentence vacated; remanded for resentencing" }
        if headline.contains("will retry") { return "New trial ordered; the State will retry" }
        if headline.contains("No retrial") { return "New trial ordered; the State declined to retry" }
        if headline.contains("new trial") { return "New trial ordered on appeal" }
        if headline.contains("vacates conviction") { return "Conviction vacated on appeal" }
        if headline.contains("reinstates") { return "Dismissal reversed; charges reinstated" }
        if headline.contains("Appeal dismissed") { return "Appeal dismissed" }
        if headline.contains("vacates probation") || headline.contains("reverses probation") { return "Probation order vacated on appeal" }
        return "Affirmed on appeal"
    }

    /// Follow-up news about a case already decided on appeal (retry decisions).
    static func isFollowUp(_ event: PendingEvent) -> Bool {
        let headline = event.news.headline
        return headline.contains("will retry") || headline.contains("No retrial")
    }

    /// Builds a tracker for the appeal decided by `event`, with a realistic briefing and argument schedule.
    static func tracker(for event: PendingEvent, caption: String, personID: UUID, filed: Date, appellant: String,
                        issue: String, rng: inout SeededRNG) -> AppealTracker {
        let decision = event.due
        let span = max(30, CourtCalendar.calendar.dateComponents([.day], from: filed, to: decision).day ?? 120)
        let briefs = CourtCalendar.calendar.date(byAdding: .day, value: min(110, span / 3), to: filed) ?? filed
        var argument: Date?
        if span > 120 && rng.chance(0.55) {
            argument = CourtCalendar.weekday(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: -rng.int(28...56), to: decision) ?? decision)
        }
        return AppealTracker(docket: event.news.docket ?? "", caption: caption, personID: personID, appellant: appellant,
                             issue: issue, filed: filed, briefsDue: briefs, argument: argument, decisionDue: decision)
    }
}

extension AppealTracker {
    /// Fields added since an appeal was first saved decode as their defaults, so an older save still loads.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        docket = try c.decodeIfPresent(String.self, forKey: .docket) ?? ""
        caption = try c.decodeIfPresent(String.self, forKey: .caption) ?? "State v. Unknown"
        personID = try c.decodeIfPresent(UUID.self, forKey: .personID) ?? UUID()
        appellant = try c.decodeIfPresent(String.self, forKey: .appellant) ?? "the defendant"
        issue = try c.decodeIfPresent(String.self, forKey: .issue) ?? ""
        filed = try c.decodeIfPresent(Date.self, forKey: .filed) ?? Date()
        briefsDue = try c.decodeIfPresent(Date.self, forKey: .briefsDue) ?? filed
        argument = try c.decodeIfPresent(Date.self, forKey: .argument)
        decisionDue = try c.decodeIfPresent(Date.self, forKey: .decisionDue) ?? briefsDue
        decided = try c.decodeIfPresent(Date.self, forKey: .decided)
        result = try c.decodeIfPresent(String.self, forKey: .result)
        opinion = try c.decodeIfPresent(String.self, forKey: .opinion)
        followUps = try c.decodeIfPresent([String].self, forKey: .followUps) ?? []
        grounds = try c.decodeIfPresent([String].self, forKey: .grounds)
        groundErrors = try c.decodeIfPresent([Bool].self, forKey: .groundErrors)
        holdings = try c.decodeIfPresent([String].self, forKey: .holdings)
    }
}
