import Foundation

/// Where a person in custody is held.
enum CustodyPlace: String, Codable {
    case jail, prison, hospital
}

extension PersonRecord {
    /// Jail for a misdemeanor term counted in days, a CRV, or a probation sanction; prison for a felony term;
    /// a state hospital after an insanity verdict. Nil for someone not in custody.
    var custodyPlace: CustodyPlace? {
        guard status == .incarcerated else { return nil }
        let note = releaseNote ?? ""
        if note.contains("not guilty by reason of insanity") || note.contains("Central Regional Hospital") { return .hospital }
        if releaseDate == .distantFuture { return .prison }
        let lower = note.lowercased()
        let sanction = lower.contains("quick dip") || lower.hasPrefix("confinement in response to violation")
            || lower.contains("period of confinement in response to violation")
        let jail = sanction || note.contains(" days active") || (note.contains(" days") && !note.contains("months"))
        return jail ? .jail : .prison
    }

    /// A prison term still being served in the county jail while the person waits for a state bed.
    func awaitingStateBed(on date: Date) -> Bool {
        guard custodyPlace == .prison else { return false }
        guard let bed = stateBedDate, stateBedDocket == custodyDocket else { return true }
        return bed > date
    }

    /// Sleeps in the county jail tonight.
    func inCountyJail(on date: Date) -> Bool {
        custodyPlace == .jail || awaitingStateBed(on: date)
    }
}

/// One night's count, kept for the trend lines.
struct CorrectionsDay: Codable, Hashable {
    var date: Date
    var jail: Int
    var pretrial: Int
    var sentenced: Int
    var awaitingBed: Int
    var prison: Int
    var probation: Int
    var postRelease: Int
    var beds: Int
}

/// What the sheriff sends the judge when the jail fills.
struct SheriffNotice: Codable, Hashable, Identifiable {
    enum Kind: String, Codable { case nearCapacity, releases }
    var id = UUID()
    var kind: Kind
    var issued: Date
    /// When the sheriff starts releasing people, for a release notice.
    var deadline: Date?
    var population: Int
    var beds: Int
    var message: String
    var closed: Date? = nil
    var outcome: String? = nil

    var isOpen: Bool { closed == nil }
}

/// Someone let out of the jail early to ease crowding.
struct EarlyRelease: Codable, Hashable, Identifiable {
    var id = UUID()
    var personID: UUID
    var name: String
    var docket: String
    var charge: String
    var date: Date
    /// The judge chose this person; otherwise the sheriff did.
    var byJudge: Bool
    var pretrial: Bool
    /// Days left on the sentence, or days already held awaiting trial.
    var days: Int
    var rearrested: Date? = nil
}

/// What happened to a defendant at judgment, and whether the person was arrested again once free.
struct DispositionRecord: Codable, Hashable {
    enum Group: String, Codable, CaseIterable, Identifiable {
        case acquitted, noCustody, probation, jail, prison, early
        var id: String { rawValue }
        var label: String {
            switch self {
            case .acquitted: return "Acquitted or dismissed"
            case .noCustody: return "Fine or time served"
            case .probation: return "Probation"
            case .jail: return "Jail term"
            case .prison: return "Prison term"
            case .early: return "Released early"
            }
        }
    }
    var personID: UUID
    var docket: String
    var group: Group
    var date: Date
    /// When the person walked free: judgment day, or the end of a term.
    var freeFrom: Date?
    var rearrested: Date? = nil
}

/// The jail, prison, and probation picture for the county this judge sits in. It stays with the county.
struct CorrectionsState: Codable {
    var countyName: String
    var beds: Int
    var officers: Int
    var log: [CorrectionsDay] = []
    var lastDay: Date? = nil
    var daysOver = 0
    var yearDaysOver = 0
    var peak = 0
    var peakDate: Date? = nil
    var notices: [SheriffNotice] = []
    var releases: [EarlyRelease] = []
    var bedDays = 0
    var yearBedDays = 0
    /// Prison commitments from this court, for the wait for state beds.
    var prisonAdmissions: [Date] = []
    var budgetYear: Int? = nil

    var openNotice: SheriffNotice? { notices.last { $0.isOpen } }
}

/// Someone in the county jail tonight, as the sheriff's roster lists them.
struct JailInmate: Identifiable, Hashable {
    enum Kind: String { case pretrial, sentenced, awaitingBed }
    var id: UUID { personID }
    var personID: UUID
    var caseID: UUID?
    var name: String
    var age: Int
    var docket: String
    var charge: String
    var kind: Kind
    var since: Date?
    var releaseDate: Date?
    var bedDate: Date?
    var bond: String?
    var violent: Bool
    var felony: Bool
    var priors: Int
    var risk: Double
    var flags: [String]

    var canRelease: Bool { kind != .awaitingBed }

    var kindLabel: String {
        switch kind {
        case .pretrial: return "Awaiting trial"
        case .sentenced: return "Serving a jail term"
        case .awaitingBed: return "Waiting for a state prison bed"
        }
    }

    var riskLabel: String { risk < 0.3 ? "Low risk" : (risk < 0.55 ? "Moderate risk" : "High risk") }
}

enum Corrections {
    /// Daily cost of a bed or a supervision day, in dollars.
    static let jailDayCost = 92
    static let prisonDayCost = 115
    static let probationDayCost = 9
    /// The caseload probation officers are meant to carry.
    static let caseloadPerOfficer = 60
    /// The sheriff warns at this share of capacity; releases start above capacity and stop at the floor.
    static let warnAt = 0.9
    static let releaseFloor = 0.95
    static let noticeDays = 10

    /// A jail sized for the court's docket: beds for an ordinary judge's share of cases, with room to spare.
    /// Grows at budget time with the number of cases the court hears, never with how many it locks up.
    static func beds(casesPerYear: Int) -> Int {
        max(14, Int((Double(casesPerYear) * 0.16).rounded()))
    }

    static func officers(casesPerYear: Int) -> Int {
        max(1, Int((Double(casesPerYear) * 0.7 / Double(caseloadPerOfficer)).rounded(.up)))
    }

    /// Days a prison commitment waits in the county jail for a state bed: it varies person to person, and runs longer
    /// when this court has sent many people to prison lately.
    static func stateBedWait(personID: UUID, docket: String, recentAdmissions: Int) -> Int {
        var hash: UInt64 = 1469598103934665603
        for byte in (personID.uuidString + docket).utf8 { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
        let base = 9 + Int(hash % 52)
        return base + min(40, 3 * max(0, recentAdmissions - 4))
    }

    /// How likely the person looks to be arrested again or to run, 0–1, from what the file shows: the charge and the record.
    static func risk(violent: Bool, felony: Bool, priors: Int, orders: Int, failures: Int) -> Double {
        var r = 0.12 + 0.05 * Double(min(priors, 6)) + 0.09 * Double(min(failures, 3))
        if violent { r += 0.22 }
        if felony { r += 0.06 }
        if orders > 0 { r += 0.12 }
        return min(0.95, max(0.03, r))
    }

    static func money(_ dollars: Int) -> String {
        if dollars >= 1_000_000 { return String(format: "$%.1fM", Double(dollars) / 1_000_000) }
        if dollars >= 10_000 { return "$\(dollars / 1_000)K" }
        return "$\(dollars.formatted())"
    }
}

extension Corrections {
    /// Charges the sheriff treats as violent when deciding who can go.
    static func soundsViolent(_ charge: String) -> Bool {
        let c = charge.lowercased()
        return ["assault", "murder", "manslaughter", "robbery", "kidnapping", "rape", "sexual", "strangulation", "homicide",
                "firearm", "weapon", "arson", "stalking", "communicating threats", "child abuse", "domestic"].contains { c.contains($0) }
    }
}
