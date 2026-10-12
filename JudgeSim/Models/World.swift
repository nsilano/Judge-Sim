import Foundation

struct CastMember: Codable, Hashable {
    var name: String
    var title: String
    var agency: String

    var display: String { "\(title) \(name)" }
}

/// The county the player presides over. Generated once per career and never changes.
struct County: Codable, Hashable {
    var name = "Hollis County"
    var seat = "Port Hollis"
    var towns = ["Port Hollis", "Wexley", "Cane Creek", "Dunmore Mills", "Bayard"]
    var newspaper = "The Port Hollis Ledger"
    var courthouse = "Hollis County Courthouse"
    var policeDepartment = "Port Hollis Police Department"
    var sheriffsOffice = "Hollis County Sheriff's Office"

    var districtAttorney: String
    var assistantDAs: [String]
    var chiefPublicDefender: String
    var assistantPDs: [String]
    var privateCounsel: [String]
    var clerk: String
    var sheriff: String
    var policeChief: String
    var detectives: [CastMember]
    var officers: [CastMember]
    var troopers: [String]

    var fullName: String { "\(name), North Carolina" }
    var courtName: String { "\(name) Superior Court" }

    static func generate(seed: UInt64) -> County {
        var rng = SeededRNG(seed: seed ^ 0xC0FFEE)
        var used = Set<String>()
        func person() -> String { NameBank.person(using: &rng, excluding: &used) }

        let detectives = [
            CastMember(name: person(), title: "Detective", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Detective", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Detective Sergeant", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Investigator", agency: "Hollis County Sheriff's Office"),
            CastMember(name: person(), title: "Investigator", agency: "Hollis County Sheriff's Office")
        ]
        let officers = [
            CastMember(name: person(), title: "Officer", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Officer", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Officer", agency: "Port Hollis Police Department"),
            CastMember(name: person(), title: "Deputy", agency: "Hollis County Sheriff's Office"),
            CastMember(name: person(), title: "Deputy", agency: "Hollis County Sheriff's Office")
        ]
        return County(districtAttorney: person(),
                      assistantDAs: [person(), person(), person(), person()],
                      chiefPublicDefender: person(),
                      assistantPDs: [person(), person(), person()],
                      privateCounsel: [person(), person(), person(), person()],
                      clerk: person(),
                      sheriff: person(),
                      policeChief: person(),
                      detectives: detectives,
                      officers: officers,
                      troopers: [person(), person()])
    }
}

/// Someone who has appeared before the court. Persisted so they can come back.
struct PersonRecord: Identifiable, Codable, Hashable {
    enum Status: String, Codable {
        case free, probation, incarcerated

        var label: String {
            switch self {
            case .free: return "At liberty"
            case .probation: return "On probation"
            case .incarcerated: return "In custody"
            }
        }
    }

    struct Appearance: Codable, Hashable {
        var docket: String
        var date: Date
        var charges: String
        var outcome: String
    }

    var id: UUID
    var name: String
    var birthYear: Int
    var occupation: String
    var background: String
    var priors: [PriorConviction]
    var status: Status = .free
    var releaseDate: Date?
    var probation: ProbationTerm?
    /// Hidden likelihood of being arrested again.
    var propensity: Double
    var appearances: [Appearance] = []
    /// How the projected release date was figured: minimum and maximum terms, credit, and any revocation (optional for older saves).
    var releaseNote: String? = nil

    func age(on date: Date) -> Int {
        Calendar.current.component(.year, from: date) - birthYear
    }

    var lastName: String { name.components(separatedBy: " ").last ?? name }
}

/// A suspended sentence that can be activated if probation is revoked.
struct ProbationTerm: Codable, Hashable {
    var docket: String
    var offense: String
    var isFelony: Bool
    /// The suspended term, e.g. "8–19 months" or "45 days".
    var suspendedSentence: String
    /// Months the person would serve if the sentence is activated (felony minimum, or days / 30).
    var activeMonths: Int
    var ends: Date
    var imposedInThisCourt: Bool
    // Added in build 2; optional so earlier saves still load.
    var supervised: Bool?
    var conditions: [String]?
    var monthlyObligation: Int?
    var violationRisk: Double?
    var crvCount: Int?
    var treatmentNeed: TreatmentNeed?
    /// Where the sentence came from, when it wasn't this court.
    var origin: String?
}

/// A probation violation report on a probationer, heard on the court's calendar.
struct ViolationHearing: Identifiable, Codable, Hashable {
    var id = UUID()
    var seed: UInt64
    var date: Date
    var personID: UUID
    var personName: String
    var personAge: Int
    var probation: ProbationTerm
    var violations: [String]
    var absconded: Bool
    var newCriminalConduct: Bool
    var officerName: String
    var officerReport: String
    var defenseExplanation: String
    var prosecutor: String
    var defenseAttorney: String
    /// Hidden: whether the violations were truly willful.
    var willful: Bool
    var circumstances: String
    /// Whether the probationer admits the violations (optional for older saves).
    var admits: Bool?
    /// The probation officer's testimony if the violations are denied.
    var officerTestimony: [String]?
    var officerCross: [String]?
}

struct NewsItem: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case verdict, appeal, exoneration, arrest, revelation, ethics, community

        var icon: String {
            switch self {
            case .verdict: return "hammer.fill"
            case .appeal: return "building.columns.fill"
            case .exoneration: return "lock.open.fill"
            case .arrest: return "light.beacon.max.fill"
            case .revelation: return "eye.fill"
            case .ethics: return "exclamationmark.shield.fill"
            case .community: return "person.3.fill"
            }
        }
    }

    var id = UUID()
    var date: Date
    var kind: Kind
    var headline: String
    var body: String
    var docket: String?
    /// 1 inside pages, 2 metro front, 3 front page above the fold.
    var prominence: Int? = nil

    var placement: String? {
        switch prominence ?? 0 {
        case 3: return "Front page"
        case 2: return "Metro front"
        default: return nil
        }
    }
}

/// Something that will happen later in the world, such as an appellate opinion or an exoneration.
struct PendingEvent: Codable, Hashable {
    enum Effect: String, Codable {
        case none
        case releasePerson
        case raisePropensity
        case resentence
    }

    var due: Date
    var news: NewsItem
    var personID: UUID?
    var effect: Effect = .none
    var appealReversed = false
    /// For resentencing: the release date under the new, lawful sentence.
    var newReleaseDate: Date?
    /// A conviction from this docket is vacated and removed from the person's record.
    var vacatesDocket: String?
    /// A new trial the District Attorney may bring back to this court.
    var retrial: CourtCase?
}
