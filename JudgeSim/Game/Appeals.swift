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
