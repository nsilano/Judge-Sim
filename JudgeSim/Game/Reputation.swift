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
        // What the judge has done lately: every ruling the community, the State, or the defense bar noticed.
        let ledger = stats.ledger ?? StandingLedger()
        let prosecutors = clamp(ledger.prosecutors + 62 + 40 * (harsh - lenient) + 20 * (activeShare - 0.5) + 25 * (affirm - 0.8) - 1.5 * delays)
        let defense = clamp(ledger.defense + 62 + 40 * (lenient - harsh) - 20 * (activeShare - 0.5) + 25 * (affirm - 0.8) - 120 * exonerationRate - 2.5 * delays)
        let overall = clamp(ledger.overall + 45 + 40 * (affirm - 0.6) + 15 * within - 150 * exonerationRate - 2 * delays - crowding / 25)
        let publicApproval = clamp(ledger.publicApproval + 55 + 15 * (harsh - lenient) + 10 * (activeShare - 0.5) - 8 * Double(stats.exonerations)
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
        // What people are saying about the last couple of months.
        var byTopic: [StandingTopic: Double] = [:]
        for s in ledger.recent.prefix(15) { byTopic[s.topic, default: 0] += s.publicApproval + s.prosecutors + s.defense + s.overall }
        if let worst = byTopic.min(by: { $0.value < $1.value }), worst.value <= -8 {
            switch worst.key {
            case .release, .rearrest: comments.append("\"Lets dangerous people out, and some of them don't wait long to prove it.\"")
            case .sentencing: comments.append("\"Soft on violent crime lately. The victims' families have noticed.\"")
            case .harshness: comments.append("\"Heavy-handed with small cases. Bonds nobody can post.\"")
            case .crowding: comments.append("\"That jail is bursting, and the court is part of why.\"")
            case .delay: comments.append("\"Nothing moves in that courtroom.\"")
            case .appeals: comments.append("\"The Court of Appeals keeps sending cases back.\"")
            case .fairness: break
            }
        }
        if stats.exonerations > 0 {
            comments.append("\"\(stats.exonerations) conviction\(stats.exonerations == 1 ? "" : "s") from this court later fell apart. That stays with people.\"")
        }
        if comments.isEmpty { comments.append(history.count < 15 ? "\"Still new. Fair so far.\"" : "\"Steady. Nothing worth complaining about.\"") }
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

// MARK: - Standing that moves with every ruling

/// What a shift in standing was about, so the paper can write about the problem that's actually there.
enum StandingTopic: String, Codable, Hashable {
    case release, rearrest, crowding, sentencing, delay, appeals, harshness, fairness
}

/// One ruling's effect on the judge's standing, kept for the Standing card and the paper.
struct StandingShift: Codable, Hashable, Identifiable {
    var id = UUID()
    var date: Date
    var reason: String
    var topic: StandingTopic
    var prosecutors: Double
    var defense: Double
    var overall: Double
    var publicApproval: Double

    /// The group that moved most, and by how much.
    var biggest: (group: String, change: Double) {
        [("Public", publicApproval), ("Prosecutors", prosecutors), ("Defense", defense), ("Lawyers", overall)]
            .max { abs($0.1) < abs($1.1) } ?? ("Public", 0)
    }
}

/// The running effect of recent rulings on each rating. Each day it fades a little toward zero, so the judge's
/// standing follows what the judge has been doing lately, and one bad stretch can be lived down.
struct StandingLedger: Codable, Hashable {
    var prosecutors = 0.0
    var defense = 0.0
    var overall = 0.0
    var publicApproval = 0.0
    var recent: [StandingShift] = []
    /// The last time the paper ran a story on the court's troubles, and whether it's still on the story.
    var lastCoverage: Date? = nil
    var covering = false
    /// The last time a quiet month without public complaints was credited.
    var lastQuietCredit: Date? = nil
    /// Public approval already moved by each decision (keyed by day and defendant). A decision's public effect runs
    /// one way: the public likes it or it doesn't, and the total stays within a few points.
    var decisionPublic: [String: Double]? = nil
    /// The last time the paper ran a recap of the judge's recent record, drawn from the career journal.
    var lastDigest: Date? = nil

    static let limit = 35.0
    /// The share of the ledger that fades each day: about half in six weeks.
    static let dailyFade = 0.985

    mutating func apply(_ s: StandingShift, record: Bool = true) {
        func add(_ x: inout Double, _ d: Double) { x = min(Self.limit, max(-Self.limit, x + d)) }
        add(&prosecutors, s.prosecutors)
        add(&defense, s.defense)
        add(&overall, s.overall)
        add(&publicApproval, s.publicApproval)
        if record {
            recent.insert(s, at: 0)
            if recent.count > 40 { recent.removeLast(recent.count - 40) }
        }
    }

    mutating func fade() {
        prosecutors *= Self.dailyFade
        defense *= Self.dailyFade
        overall *= Self.dailyFade
        publicApproval *= Self.dailyFade
    }
}

/// The rules standing follows. Each names who it moves and by how much (prosecutors, defense bar, lawyers overall, public).
enum StandingRule {
    // Bond
    case releasedViolentNoMoney, releasedViolentOnBond, releasedViolentMonitored, heldViolent, heldWithoutBond
    case releasedLowRisk, heldOnUnaffordableBond
    // People this court let go
    case rearrestedOnRelease, reoffendedAfterRuling, rearrestedAfterEarlyRelease
    // The jail
    case jailNotice, sheriffReleased, earlyReleaseViolent, earlyReleaseNonviolent, jailOverCapacityDay
    // Sentencing
    case lenientViolentSentence, mercyNonviolent, harshNonviolent, toughViolent, byTheBook, probationViolent
    // The calendar
    case repeatedContinuance, continuanceDenied, ftaOrderForArrest, ftaExcused, caseDelayed
    // Appeals and the record
    case reversed, affirmed, exoneration
    // Earning it back
    case convictedViolent, victimProtected, swiftJustice, probationCompleted, treatmentGraduate, jailRecovered, quietMonth
    // A ruling in a case the public followed: the amount is the paper's reaction.
    case publicReaction(Int)

    /// (prosecutors, defense, overall, public, topic)
    var effect: (Double, Double, Double, Double, StandingTopic) {
        switch self {
        case .releasedViolentNoMoney:      return (-3, 1, -1, -5, .release)
        case .releasedViolentOnBond:       return (-2, 1, 0, -3, .release)
        case .releasedViolentMonitored:    return (-1, 1, 0, -1, .release)
        case .heldViolent:                 return (1, 0, 0, 1, .release)
        case .heldWithoutBond:             return (1, -1, 0, 2, .release)
        case .releasedLowRisk:             return (0, 1, 0.5, 0, .fairness)
        case .heldOnUnaffordableBond:      return (0, -2, -1, 0, .harshness)
        case .rearrestedOnRelease:         return (-2, 0, -1, -4, .rearrest)
        case .reoffendedAfterRuling:       return (-1, 0, 0, -3, .rearrest)
        case .rearrestedAfterEarlyRelease: return (-2, 0, -1, -5, .rearrest)
        case .jailNotice:                  return (0, 0, -1, -1, .crowding)
        case .sheriffReleased:             return (-1, 0, -2, -3, .crowding)
        case .earlyReleaseViolent:         return (-1, 0, 0, -3, .release)
        case .earlyReleaseNonviolent:      return (0, 1, 0, -0.5, .crowding)
        case .jailOverCapacityDay:         return (0, 0, -0.2, -0.4, .crowding)
        case .lenientViolentSentence:      return (-2, 1, 0, -3, .sentencing)
        case .mercyNonviolent:             return (-1, 1, 0, 0, .fairness)
        case .harshNonviolent:             return (0, -2, -1, 0, .harshness)
        case .toughViolent:                return (1, -1, 0, 1, .sentencing)
        case .byTheBook:                   return (0, 0, 0.25, 0.25, .fairness)
        case .probationViolent:            return (-1, 0, 0, -2, .sentencing)
        case .repeatedContinuance:         return (-1, 0, -0.5, -1, .delay)
        case .continuanceDenied:           return (0.5, -0.5, 0, 0.25, .delay)
        case .ftaOrderForArrest:           return (0.5, 0, 0, 0.25, .fairness)
        case .ftaExcused:                  return (-1, 0, 0, -0.5, .release)
        case .caseDelayed:                 return (0, -2, -1, -1, .delay)
        case .reversed:                    return (0, 0, -3, 0, .appeals)
        case .affirmed:                    return (0, 0, 0.5, 0.25, .appeals)
        case .exoneration:                 return (0, 2, -4, -4, .appeals)
        case .convictedViolent:            return (0.5, 0, 0, 1, .sentencing)
        case .victimProtected:             return (0, 0, 0, 0.5, .fairness)
        case .swiftJustice:                return (0, 0, 0.25, 0.5, .delay)
        case .probationCompleted:          return (0, 0.5, 0, 0.5, .fairness)
        case .treatmentGraduate:           return (0, 1, 0.5, 2, .fairness)
        case .jailRecovered:               return (0, 0, 0.5, 1.5, .crowding)
        case .quietMonth:                  return (0, 0, 0, 1.5, .fairness)
        case .publicReaction(let delta):   return (0, 0, 0, 1.5 * Double(delta), delta < 0 ? .sentencing : .fairness)
        }
    }

    /// What kind of decision this is, for the career journal the story director reads.
    var journalKind: JournalEntry.Kind {
        switch self {
        case .releasedViolentNoMoney, .releasedViolentOnBond, .releasedViolentMonitored, .releasedLowRisk: return .bondRelease
        case .heldViolent, .heldOnUnaffordableBond: return .bondHeld
        case .heldWithoutBond: return .heldWithoutBond
        case .rearrestedOnRelease, .reoffendedAfterRuling, .rearrestedAfterEarlyRelease: return .reoffense
        case .jailNotice, .sheriffReleased, .jailOverCapacityDay, .jailRecovered: return .jail
        case .earlyReleaseViolent, .earlyReleaseNonviolent: return .earlyRelease
        case .lenientViolentSentence, .mercyNonviolent, .harshNonviolent, .toughViolent, .byTheBook, .probationViolent: return .sentence
        case .repeatedContinuance, .continuanceDenied: return .continuance
        case .ftaOrderForArrest, .ftaExcused: return .missedCourt
        case .caseDelayed: return .delay
        case .reversed, .affirmed, .exoneration: return .appeal
        case .publicReaction: return .publicReaction
        default: return .outcome
        }
    }

    func shift(on date: Date, _ reason: String) -> StandingShift {
        let e = effect
        return StandingShift(date: date, reason: reason, topic: e.4, prosecutors: e.0, defense: e.1, overall: e.2, publicApproval: e.3)
    }
}

/// What the paper writes when the court's standing has fallen in every quarter: the problem the county is living with.
enum StandingCoverage {
    static let lowMark = 40
    static let recoveredMark = 50
    static let daysBetween = 10

    static func story(topic: StandingTopic, judge: String, county: String, example: String?, jail: (held: Int, beds: Int)?,
                      rng: inout SeededRNG) -> (headline: String, body: String) {
        let case_ = example.map { " The most recent: \($0)." } ?? ""
        switch topic {
        case .rearrest, .release:
            return rng.pick([
                ("Residents ask why Judge \(judge) keeps letting violent defendants out",
                 "Neighborhood groups in \(county) County say defendants released from Judge \(judge)'s courtroom are back on the street and back in trouble.\(case_) \"We call the police, they make the arrest, and the judge lets them walk,\" one resident told the county commission."),
                ("Victims' advocates say release decisions are putting people at risk",
                 "Advocates for crime victims in \(county) County say Judge \(judge)'s bond and release decisions have left victims afraid in their own homes.\(case_) The district attorney's office says it has asked for higher bonds in several cases and been turned down."),
                ("Sheriff's deputies say they're arresting the same people twice",
                 "Deputies in \(county) County say a growing share of their arrests are people already out on Judge \(judge)'s release orders.\(case_) \"It wears on the officers,\" a sheriff's spokesman said.")])
        case .crowding:
            let count = jail.map { " The jail held \($0.held) people in space for \($0.beds) this week." } ?? ""
            return rng.pick([
                ("\(county) County jail strains under Judge \(judge)'s docket",
                 "Detention officers say the county jail has been over capacity for weeks, with inmates sleeping on floor mats.\(count) County commissioners have begun asking whether the Superior Court's rulings are filling it."),
                ("Jail crowding costs the county overtime and safety",
                 "The \(county) County Sheriff's Office says crowding has driven up overtime and fights in the jail.\(count) Officers point to the number of Superior Court defendants held on bonds they can't post."),
                ("Families describe conditions in packed county jail",
                 "Relatives of people held in the \(county) County jail describe crowded cell blocks and canceled visits.\(count) Defense lawyers say many of those held are waiting on Judge \(judge)'s calendar.")])
        case .sentencing:
            return rng.pick([
                ("Victims' families say Judge \(judge)'s sentences don't fit the crimes",
                 "Families of crime victims in \(county) County say sentences from Judge \(judge)'s courtroom have been too light for violent offenses.\(case_) The district attorney's office has stopped commenting on individual sentences."),
                ("Town meeting turns to the Superior Court",
                 "A town meeting on public safety in \(county) County turned into a long airing of complaints about Judge \(judge)'s sentences.\(case_) Several speakers said they plan to remember it at the next election.")])
        case .delay:
            return rng.pick([
                ("Cases stall in Judge \(judge)'s courtroom",
                 "Lawyers on both sides say cases in \(county) County Superior Court are waiting months for trial dates, while defendants sit in jail and victims wait for answers.\(case_)"),
                ("Victims wait as trials are pushed back again",
                 "Crime victims in \(county) County say their cases keep getting moved in Judge \(judge)'s courtroom.\(case_) \"Every time I take off work, it gets continued,\" one victim said.")])
        case .appeals:
            return rng.pick([
                ("Appeals court reverses Judge \(judge) again",
                 "The North Carolina Court of Appeals has sent another case back to \(county) County Superior Court, adding to a string of reversals from Judge \(judge)'s courtroom. Lawyers say retrials cost the county and put witnesses through it all again."),
                ("Questions about the record in Judge \(judge)'s courtroom",
                 "A run of reversed convictions and overturned verdicts has the \(county) County bar talking about Judge \(judge)'s rulings. \"The law isn't optional,\" one longtime defense lawyer said.")])
        case .harshness, .fairness:
            return rng.pick([
                ("Defense lawyers say Judge \(judge) jails people over small charges",
                 "Public defenders in \(county) County say Judge \(judge) is setting bonds that low-level defendants can't post and handing out top-of-the-range sentences for minor offenses.\(case_) \"People lose jobs and housing over a misdemeanor,\" one said."),
                ("Churches and civic groups question the Superior Court",
                 "A coalition of \(county) County churches and civic groups has asked the county to look at how Judge \(judge)'s courtroom treats people charged with minor crimes.\(case_)")])
        }
    }

    static func turnaround(judge: String, county: String) -> (headline: String, body: String) {
        ("Complaints about Judge \(judge) ease",
         "After months of criticism, lawyers and community groups in \(county) County say Judge \(judge)'s courtroom has steadied. \"It's been a better stretch,\" one prosecutor said.")
    }
}


extension StandingLedger {
    /// The person a decision is about, from a reason written "… — Name, charge" or "… — State v. Name".
    static func decisionKey(_ reason: String) -> String? {
        guard let tail = reason.components(separatedBy: " — ").last, tail != reason else { return nil }
        var name = tail
        if let r = name.range(of: " v. ") { name = String(name[r.upperBound...]) }
        if let r = name.range(of: ", ") { name = String(name[..<r.lowerBound]) }
        return name.isEmpty ? nil : name
    }

    /// Limits one decision's public effect: a single direction, and at most 4 points in total.
    mutating func limitPublic(_ delta: Double, key: String, on date: Date) -> Double {
        let dayKey = "\(Int(CourtCalendar.calendar.startOfDay(for: date).timeIntervalSince1970))|\(key)"
        var totals = decisionPublic ?? [:]
        let so = totals[dayKey] ?? 0
        var applied = delta
        if so != 0 && delta * so < 0 {
            applied = 0
        } else {
            let next = min(4, max(-4, so + delta))
            applied = next - so
            totals[dayKey] = next
        }
        if totals.count > 80 { totals = Dictionary(uniqueKeysWithValues: totals.sorted { $0.key > $1.key }.prefix(50).map { ($0.key, $0.value) }) }
        decisionPublic = totals
        return applied
    }
}
