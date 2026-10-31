import Foundation

/// The bar's yearly evaluation of the judge, like the judicial performance surveys bar associations publish.
/// Each rating runs 0–100. Nothing here is a score for any single case: it follows from the record as a whole.
struct BarSurvey: Codable, Hashable, Identifiable {
    var id: Int { year }
    var year: Int
    /// Prosecutors' rating.
    var prosecutors: Int
    /// Public defenders' and private defense lawyers' rating.
    var defenseBar: Int
    /// Overall rating from all lawyers who appeared before the judge: legal ability, fairness, temperament.
    var overall: Int
    /// The public's view, from a newspaper poll.
    var publicApproval: Int
    /// The share of decided appeals the Court of Appeals affirmed, 0–100 (nil before any were decided).
    var affirmedPercent: Int?
    /// Plain-language comments from the survey.
    var comments: [String]
}

enum Reputation {

    static func survey(year: Int, stats: CareerStats, appeals: [AppealTracker], history: [CaseRecord]) -> BarSurvey {
        let sentenced = stats.belowPresumptive + stats.withinPresumptive + stats.abovePresumptive
        let harsh = sentenced == 0 ? 0 : Double(stats.abovePresumptive) / Double(sentenced)
        let lenient = sentenced == 0 ? 0 : Double(stats.belowPresumptive) / Double(sentenced)
        let within = sentenced == 0 ? 0.7 : Double(stats.withinPresumptive) / Double(sentenced)
        let decided = appeals.filter { !$0.isPending && $0.result != "Appeal dismissed" && !$0.isMoot }
        let reversed = decided.filter(\.wasReversed).count
        let affirm = decided.isEmpty ? 0.85 : Double(decided.count - reversed) / Double(decided.count)
        let trials = max(1, history.filter { $0.resolvedKind == "trial" }.count)
        let exonerationRate = Double(stats.exonerations) / Double(trials)
        let active = stats.activeSentences + stats.suspendedSentences
        let activeShare = active == 0 ? 0.5 : Double(stats.activeSentences) / Double(active)

        func clamp(_ x: Double) -> Int { Int(min(98, max(5, x)).rounded()) }
        // Cases left to wait too long: jailed defendants, victims at risk, files gathering dust.
        // Handing off a case now and then is ordinary; making a habit of it, less so.
        let delays = Double(min(10, (stats.delayedCases ?? 0) + max(0, (stats.delegated ?? 0) - 4) / 2))
        // A jail the court's own rulings filled past capacity: the strain fades by half each New Year.
        let crowding = Double(min(150, stats.crowdingStrain ?? 0))
        let prosecutors = clamp(62 + 40 * (harsh - lenient) + 20 * (activeShare - 0.5) + 25 * (affirm - 0.8) - 1.5 * delays)
        let defense = clamp(62 + 40 * (lenient - harsh) - 20 * (activeShare - 0.5) + 25 * (affirm - 0.8) - 120 * exonerationRate - 2.5 * delays)
        let overall = clamp(50 + 45 * (affirm - 0.6) + 25 * within - 150 * exonerationRate - 2 * delays - crowding / 25)
        let publicApproval = clamp(55 + 15 * (harsh - lenient) + 10 * (activeShare - 0.5) - 8 * Double(stats.exonerations)
                                   + 10 * (affirm - 0.8) - 2 * delays - crowding / 8
                                   // Rulings the public watched: each one it liked or hated moves the poll.
                                   + 1.5 * Double(max(-14, min(14, stats.communityStanding ?? 0))))

        var comments: [String] = []
        if !decided.isEmpty {
            comments.append(affirm >= 0.85 ? "\"Rarely reversed. Does the homework.\""
                            : (affirm >= 0.65 ? "\"Usually right on the law, with some reversals.\""
                               : "\"Reversed too often. Read the statutes before you rule.\""))
        }
        if sentenced >= 3 {
            if harsh - lenient > 0.25 { comments.append("\"Sentences at the top of the range more than most.\"") }
            else if lenient - harsh > 0.25 { comments.append("\"Willing to go below the presumptive range.\"") }
            else if within > 0.7 { comments.append("\"Sentences by the chart. Predictable, in a good way.\"") }
        }
        if (stats.delegated ?? 0) >= 8 {
            comments.append("\"Hands a lot of cases to other judges. The rest of the bench has noticed.\"")
        }
        if (stats.delayedCases ?? 0) >= 3 {
            comments.append("\"Cases sit too long in that courtroom. People wait in jail for a date.\"")
        }
        if crowding >= 20 {
            comments.append("\"The jail stays packed with that judge's defendants, and the sheriff has had to let people go.\"")
        } else if crowding >= 6 {
            comments.append("\"The jail ran over capacity this year. The county noticed.\"")
        }
        if stats.exonerations > 0 {
            comments.append("\"\(stats.exonerations) conviction\(stats.exonerations == 1 ? "" : "s") from this court later fell apart. That stays with people.\"")
        }
        if comments.isEmpty { comments.append("\"Still new. Fair so far.\"") }
        return BarSurvey(year: year, prosecutors: prosecutors, defenseBar: defense, overall: overall,
                         publicApproval: publicApproval, affirmedPercent: decided.isEmpty ? nil : Int((affirm * 100).rounded()),
                         comments: comments)
    }

    /// Superior court judges in North Carolina serve eight-year terms and stand for election in November.
    static func isElectionYear(_ year: Int, careerStartYear: Int) -> Bool {
        // Superior court races are on the even-year general election ballot. The game compresses an eight-year term
        // so every career sees a race: the first comes in the second even year on the bench, then every two years.
        let first = careerStartYear + 2 + (careerStartYear % 2 == 0 ? 0 : 1)
        return year >= first && (year - first) % 2 == 0
    }

    /// The share of the vote the judge wins, given the latest survey.
    static func voteShare(_ survey: BarSurvey, rng: inout SeededRNG) -> Double {
        let incumbency = 0.04
        // The public's mood matters, but so does being right: the bar's rating and the record on appeal carry weight.
        let affirmed = Double(survey.affirmedPercent ?? 85) / 100
        let share = 0.50 + incumbency + 0.18 * (Double(survey.publicApproval) / 100 - 0.55)
            + 0.18 * (Double(survey.overall) / 100 - 0.55) + 0.15 * (affirmed - 0.8) + Double(rng.int(-40...40)) / 1_000
        return min(0.78, max(0.28, share))
    }
}

extension Reputation {
    /// An opening statement, with what the lawyer says first to a judge with this judge's name.
    static func opening(_ text: String, side: Side, seed: UInt64) -> String {
        guard let aside = CourthouseMood.current.aside(for: side, closing: false, seed: seed) else { return text }
        return aside + " " + text
    }

    /// A closing argument, with what the lawyer says last to a judge with this judge's name.
    static func closing(_ text: String, side: Side, seed: UInt64) -> String {
        guard !text.isEmpty, let aside = CourthouseMood.current.aside(for: side, closing: true, seed: seed) else { return text }
        return text + " " + aside
    }

    /// Adds a sentence at the end of a quoted statement, inside the quotation marks.
    static func insideQuote(_ text: String, _ addition: String?) -> String {
        guard let addition, !addition.isEmpty else { return text }
        if text.hasSuffix("\"") { return String(text.dropLast()) + " " + addition + "\"" }
        return text + " " + addition
    }
}
