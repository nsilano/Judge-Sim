import Foundation

// A read-only view over what the game already stores about a person and the judgments entered
// in this court. Nothing here is saved; it is recomputed from GameState every time a record is shown.

/// One entry of a judgment as stored in `CaseRecord.judgments` ("Title · line · line").
struct RecordEntry: Hashable {
    enum Kind {
        case sentence, findings, commitment, probationConditions, prayerForJudgment,
             conditionalDischarge, money, victimNotice, note, other
    }

    var title: String?
    var lines: [String]

    /// Trial judgments are stored as "Title · line · line"; hearing and calendar lines are plain sentences.
    static func parse(_ text: String, titled: Bool) -> RecordEntry {
        let parts = text.components(separatedBy: " · ")
        if titled && parts.count >= 2 {
            return RecordEntry(title: parts[0], lines: Array(parts.dropFirst()))
        }
        return RecordEntry(title: nil, lines: [text])
    }

    var kind: Kind {
        guard let title else { return .note }
        if title.hasPrefix("Count") { return .sentence }
        if title.hasPrefix("Findings of factors") { return .findings }
        if title == "Commitment" { return .commitment }
        if title == "Conditions of probation" { return .probationConditions }
        if title.hasPrefix("Prayer for judgment") { return .prayerForJudgment }
        if title.hasPrefix("Conditional discharge") { return .conditionalDischarge }
        if title == "Monetary obligations" { return .money }
        if title == "Victim notification" { return .victimNotice }
        return .other
    }

    // MARK: Sentence entries ("Count 1: Offense")

    /// "Count 1" or "Counts 1, 2 (consolidated)".
    var countLabel: String {
        guard let title, let range = title.range(of: ": ") else { return title ?? "" }
        return String(title[..<range.lowerBound])
    }

    /// The offense named in a sentence entry's title.
    var offense: String {
        guard let title, let range = title.range(of: ": ") else { return title ?? "" }
        return String(title[range.upperBound...])
    }

    /// e.g. "Class H Felony, prior record level II".
    var classLine: String? { lines.first { $0.hasPrefix("Class ") } }

    /// The sentencing class, read from the class line.
    var sentencingClass: NCClass? {
        guard let classLine else { return nil }
        let words = classLine.components(separatedBy: " ")
        guard words.count > 1 else { return nil }
        return NCClass(rawValue: words[1].trimmingCharacters(in: CharacterSet(charactersIn: ",")))
    }

    var isFelony: Bool { sentencingClass?.isFelony ?? (classLine?.contains("Felony") ?? false) }
    var isLife: Bool { lines.contains { $0.hasPrefix("Life imprisonment") } }
    var isActive: Bool { isLife || lines.contains { $0.contains("Active:") } }
    var isSuspended: Bool { lines.contains { $0.contains(", suspended.") } }

    /// "Presumptive range", "Aggravated range", "Mitigated range", or "Term set by the court".
    var rangeLine: String? { lines.first { $0.hasSuffix(" range") || $0 == "Term set by the court" } }

    var sentenceLine: String? {
        lines.first { $0.contains("Active:") || $0.contains(", suspended.") || $0.hasPrefix("Life imprisonment") }
    }

    /// Everything in a sentence entry other than its class, range, and sentence lines.
    var otherLines: [String] {
        lines.filter { $0 != classLine && $0 != rangeLine && $0 != sentenceLine }
    }

    /// Felony minimum and maximum months, when the entry is an active felony term.
    var minimumMaximum: (minimum: Int, maximum: Int)? {
        guard let line = lines.first(where: { $0.hasPrefix("Minimum ") }) else { return nil }
        let numbers = RecordText.integers(in: line)
        guard numbers.count >= 2 else { return nil }
        return (numbers[0], numbers[1])
    }

    /// Months of post-release supervision that follow an active felony term (G.S. 15A-1368.2).
    var postReleaseMonths: Int? {
        guard isActive, !isLife, let cls = sentencingClass, cls.isFelony else { return nil }
        switch cls {
        case .A: return nil
        case .B1, .B2, .C, .D, .E: return 12
        default: return 9
        }
    }
}

enum RecordText {
    static func integers(in text: String) -> [Int] {
        var result: [Int] = []
        var current = ""
        for ch in text {
            if ch.isASCII && ch.isNumber {
                current.append(ch)
            } else if !current.isEmpty {
                if let value = Int(current) { result.append(value) }
                current = ""
            }
        }
        if !current.isEmpty, let value = Int(current) { result.append(value) }
        return result
    }

    /// "Label: value" split at the first colon, for money lines and similar.
    static func labelValue(_ line: String) -> (label: String, value: String)? {
        guard let range = line.range(of: ": ") else { return nil }
        return (String(line[..<range.lowerBound]), String(line[range.upperBound...]))
    }
}

extension CaseRecord {
    var recordEntries: [RecordEntry] {
        judgments.map { RecordEntry.parse($0, titled: resolvedKind == "trial") }
    }

    /// The trial docket without the "(PV)" suffix used for violation hearings.
    var baseDocket: String { docket.replacingOccurrences(of: " (PV)", with: "") }

    var isRevocation: Bool {
        resolvedKind == "hearing" && judgments.contains { $0.contains("revoked") || $0.contains("activated") }
    }

    /// Whether this record's judgment sent the defendant into custody that lasts: an active term, a commitment,
    /// a revocation, or a CRV. A quick dip is over within days.
    var committedToCustody: Bool {
        switch resolvedKind {
        case "trial":
            return imposedCustody || judgments.contains {
                $0.hasPrefix("Order of Commitment") || $0.contains("is activated") || $0.contains("confinement in response to violation")
                    || $0.contains("returned to the custody") || $0.contains("is confined for")
            }
        case "hearing": return judgments.contains { $0.contains("revoked") || $0.contains("confinement") }
        default: return false
        }
    }

    /// Whether this record's judgment put the defendant in custody.
    var imposedCustody: Bool {
        switch resolvedKind {
        case "trial": return recordEntries.contains { $0.kind == .sentence && $0.isActive }
        case "hearing": return judgments.contains { $0.contains("revoked") || $0.contains("confinement") || $0.contains("quick dip") }
        default: return false
        }
    }
}

/// An active term, gathered from the judgment that produced it.
struct ActiveSentenceSummary {
    var docket: String
    /// When the commitment was entered (nil when no court record shows it).
    var date: Date?
    var source: String
    var terms: [RecordEntry]
    var commitment: [String]
    var recommendations: [String]
    var advancedSupervisedRelease: [String]
    var revocationLines: [String]
    var postReleaseMonths: Int?
    var custody: String
}

/// Everything the court knows about one person, assembled from GameState.
struct PersonFile {
    let person: PersonRecord
    /// Judgments this court entered for the person, newest first.
    let records: [CaseRecord]
    /// Calendar-call minutes that name the person.
    let calendarLines: [(date: Date, lines: [String])]
    let appeals: [AppealTracker]
    let news: [NewsItem]
    let upcoming: [ScheduledMatter]
    let today: Date

    init(person: PersonRecord, history: [CaseRecord], appeals: [AppealTracker], news: [NewsItem],
         scheduled: [ScheduledMatter], today: Date) {
        self.person = person
        self.today = today
        let mine = history.filter { $0.defendantID == person.id && $0.resolvedKind != "calendar" }
        self.records = mine.sorted { $0.date > $1.date }

        var dockets = Set(mine.map(\.baseDocket))
        dockets.formUnion(person.appearances.map { $0.docket.replacingOccurrences(of: " (PV)", with: "") })
        dockets.formUnion(person.priors.compactMap(\.docket))
        if let docket = person.probation?.docket { dockets.insert(docket) }

        var minutes: [(date: Date, lines: [String])] = []
        for record in history where record.resolvedKind == "calendar" {
            var picked: [String] = []
            var following = false
            for line in record.judgments {
                let isMatter = line.contains(" · ")
                if isMatter {
                    let parts = line.components(separatedBy: " · ")
                    following = line.contains(person.name) || (parts.first.map { dockets.contains($0) } ?? false)
                    if following { picked.append(line) }
                } else if following {
                    picked.append(line)
                }
            }
            if !picked.isEmpty { minutes.append((record.date, picked)) }
        }
        self.calendarLines = minutes.sorted { $0.date > $1.date }

        self.appeals = appeals.filter { $0.personID == person.id }.sorted { $0.filed > $1.filed }
        self.news = news.filter { item in
            if let docket = item.docket, dockets.contains(docket.replacingOccurrences(of: " (PV)", with: "")) { return true }
            return item.headline.contains(person.name) || item.body.contains(person.name)
        }.sorted { $0.date > $1.date }
        self.upcoming = scheduled.filter { item in
            switch item.entry.matter {
            case .trial(let c): return c.defendant.personID == person.id
            case .hearing(let h): return h.personID == person.id
            case .calendar: return false
            }
        }
    }

    var convictionsFromThisCourt: [PriorConviction] {
        person.priors.filter(\.fromThisCourt).sorted { $0.year > $1.year }
    }

    var convictionsElsewhere: [PriorConviction] {
        person.priors.filter { !$0.fromThisCourt }.sorted { $0.year > $1.year }
    }

    /// Prior record points as the court would count them today, before any points for the new offense
    /// or for being on supervision.
    var priorRecord: PriorRecord { PriorRecord(priors: person.priors, onSupervision: false) }

    /// The record of the judgment that created the current probation term, if this court entered it.
    var probationRecord: CaseRecord? {
        guard let term = person.probation else { return nil }
        return records.first { $0.docket == term.docket && $0.resolvedKind == "trial" }
    }

    /// The commitment that holds the person now: the one that set the release date, or for older saves the latest one.
    var activeSentence: ActiveSentenceSummary? {
        guard person.status == .incarcerated else { return nil }
        let held = person.custodyDocket
        let record = held.flatMap { docket in records.first { $0.docket == docket && $0.committedToCustody } }
            ?? (held == nil ? records.first(where: \.committedToCustody) : nil)
        // A calendar call keeps only the appearance; it may be newer than any judgment on file.
        let calendar = person.appearances.last {
            ($0.outcome.hasPrefix("Guilty plea at calendar call") && $0.outcome.hasSuffix(" active"))
                || ($0.outcome.hasPrefix("Calendar call:") && $0.outcome.contains("CRV"))
        }
        let calendarHolds = calendar.map { appearance in
            held.map { $0 == appearance.docket } ?? (appearance.date >= (record?.date ?? .distantPast))
        } ?? false
        guard let record, !calendarHolds else {
            // A calendar-call plea or CRV, or another court: only the conviction line is stored.
            if calendarHolds, let calendar {
                let prior = person.priors.last { $0.docket == calendar.docket }
                let felony = prior?.ncClass.isFelony ?? person.probation?.isFelony ?? false
                let crv = calendar.charges.hasPrefix("Probation violation")
                return ActiveSentenceSummary(docket: calendar.docket, date: calendar.date,
                                             source: crv ? "Confinement in response to violation" : "Judgment of this court",
                                             terms: [], commitment: [prior?.sentence ?? calendar.outcome], recommendations: [],
                                             advancedSupervisedRelease: [], revocationLines: crv ? [calendar.outcome] : [], postReleaseMonths: nil,
                                             custody: felony && !crv ? "N.C. Department of Adult Correction" : "Custody of the Sheriff")
            }
            guard let prior = person.priors.last(where: { $0.sentence.contains("active") || $0.sentence.contains("Life") }) else { return nil }
            let entered = person.appearances.last { $0.docket == prior.docket }?.date
            return ActiveSentenceSummary(docket: prior.docket ?? "—", date: entered, source: prior.fromThisCourt ? "Judgment of this court" : "\(prior.county) judgment",
                                         terms: [], commitment: [prior.sentence], recommendations: [], advancedSupervisedRelease: [],
                                         revocationLines: [], postReleaseMonths: nil,
                                         custody: prior.ncClass.isFelony ? "N.C. Department of Adult Correction" : "Custody of the Sheriff")
        }
        let entries = record.recordEntries
        let terms = entries.filter { $0.kind == .sentence && $0.isActive }
        let commitment = entries.filter { $0.kind == .commitment }.flatMap(\.lines)
        let notes = entries.filter { $0.kind == .note }.flatMap(\.lines)
        let recommendations = commitment.filter { $0.contains("recommends") }
        let asr = terms.flatMap(\.lines).filter { $0.contains("Advanced Supervised Release") }
        let revocation = record.resolvedKind == "hearing" ? record.judgments
            : notes.filter { $0.contains("revoked") || $0.contains("confinement") }

        let custody: String
        if terms.contains(where: { $0.isFelony }) || terms.flatMap(\.lines).contains(where: { $0.contains("Department of Adult Correction") }) {
            custody = "N.C. Department of Adult Correction (state prison)"
        } else if !terms.isEmpty {
            custody = "Hollis County Sheriff (county jail)"
        } else if record.judgments.contains(where: { $0.hasPrefix("Order of Commitment") }) {
            custody = "Central Regional Hospital (state psychiatric hospital)"
        } else if record.judgments.contains(where: { $0.contains("jail") }) {
            custody = "Hollis County jail"
        } else if let prior = person.priors.first(where: { $0.docket == record.baseDocket }) {
            custody = prior.ncClass.isFelony ? "N.C. Department of Adult Correction" : "Hollis County Sheriff (county jail)"
        } else {
            custody = "Facility not recorded"
        }

        let isHearing = record.resolvedKind == "hearing"
        let source = isHearing
            ? (record.isRevocation ? "Revocation of probation" : "Confinement in response to violation")
            : "Judgment and commitment"
        return ActiveSentenceSummary(docket: record.docket, date: record.date, source: source, terms: terms,
                                     commitment: commitment, recommendations: recommendations,
                                     advancedSupervisedRelease: asr, revocationLines: revocation,
                                     postReleaseMonths: isHearing || terms.contains(where: \.isLife) ? nil : terms.compactMap(\.postReleaseMonths).max(),
                                     custody: custody)
    }

    /// Where the person is right now, in a sentence.
    var custodyLine: String {
        switch person.status {
        case .incarcerated: return activeSentence?.custody ?? "In custody; facility not recorded"
        case .probation: return (person.probation?.supervised ?? true) ? "In the community under supervised probation" : "In the community on unsupervised probation"
        case .free:
            if let prs = person.postRelease { return "In the community on post-release supervision in \(prs.docket)" }
            return "At liberty; no sentence being served"
        }
    }

    // MARK: Probation

    /// The regular conditions every probationer is subject to (G.S. 15A-1343(b)), as they apply to this term.
    static func regularConditions(supervised: Bool) -> [String] {
        var lines = [
            "Commit no criminal offense in any jurisdiction.",
            "Possess no firearm, explosive device, or other deadly weapon listed in G.S. 14-269 without written permission of the court.",
            "Pay the costs of court, any fine, restitution, and other money ordered, as directed."
        ]
        if supervised {
            lines += [
                "Remain within the jurisdiction of the court unless granted written permission to leave by the court or the probation officer.",
                "Report to a probation officer as directed and permit the officer to visit at reasonable times.",
                "Answer all reasonable inquiries by the officer and obtain prior approval before changing address or employment.",
                "Submit at reasonable times to warrantless searches of person, vehicle, and premises by a probation officer for purposes directly related to supervision.",
                "Not use, possess, or control any illegal drug or controlled substance; submit to drug screening when instructed.",
                "Pay the monthly supervision fee unless remitted by the court."
            ]
        } else {
            lines.append("Remain gainfully and suitably employed or faithfully pursue a course of study or vocational training.")
        }
        return lines
    }
}
