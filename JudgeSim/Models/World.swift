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
    /// Post-release supervision after a prison term: active once released.
    var postRelease: PostReleaseTerm? = nil
    /// Post-release supervision that begins when the current prison term ends.
    var pendingPostRelease: PostReleaseTerm? = nil
    /// Probation and post-release supervision violations the court found (optional for older saves).
    var violations: [SupervisionViolation]? = nil
    /// The docket whose commitment sets `releaseDate` (optional for older saves).
    var custodyDocket: String? = nil
    /// Work, school, family, and home as the court learned them, kept so the person's life stays the same from case
    /// to case and changes only when something happens to it (optional for older saves).
    var profile: DefendantProfile? = nil
    /// Orders this court entered forbidding contact with a victim (optional for older saves).
    var stayAwayOrders: [StayAwayOrder]? = nil
    /// When the person last walked out of custody (optional for older saves).
    var lastReleased: Date? = nil

    /// Stay-away orders still in force on a date.
    func activeOrders(on date: Date) -> [StayAwayOrder] {
        (stayAwayOrders ?? []).filter { $0.issued <= date && $0.expires > date }
    }

    func age(on date: Date) -> Int {
        CourtCalendar.calendar.component(.year, from: date) - birthYear
    }

    /// Whether probation already under way picks up again on release (after a CRV), rather than beginning
    /// for the first time after a split sentence.
    var probationResumesOnRelease: Bool {
        guard let term = probation, let last = appearances.last else { return false }
        return last.docket != term.docket || last.charges.hasPrefix("Probation violation")
    }

    /// "supervised" or "unsupervised".
    var probationKind: String {
        (probation?.supervised ?? true) ? "supervised" : "unsupervised"
    }

    var lastName: String { name.components(separatedBy: " ").last ?? name }
}

/// A violation of probation or post-release supervision the court found.
struct SupervisionViolation: Codable, Hashable, Identifiable {
    var id = UUID()
    /// The case the supervision came from.
    var docket: String
    var date: Date
    /// "Probation violation" or "Post-release supervision violation".
    var kind: String
    /// What the person did.
    var conduct: String
    /// What the court ordered.
    var result: String
}

/// Supervision after release from a felony prison term (G.S. 15A-1368.2). Revoking it sends the person back
/// to serve the rest of the maximum term.
struct PostReleaseTerm: Codable, Hashable {
    var docket: String
    var offense: String
    var ends: Date
    var supervisionMonths: Int
    /// The unserved part of the maximum term, which revocation activates.
    var remainingMonths: Int
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
    // Added for supervision fixes; optional so earlier saves still load.
    /// Misdemeanor exposure in days (nil: activeMonths × 30).
    var activeDays: Int?
    /// Days actually served on CRV so far (nil: 90 per CRV).
    var crvDaysServed: Int?
    /// When probation began (nil: unknown; the sentencing appearance is used).
    var starts: Date?
    /// Class of the offense, for post-release supervision after revocation and for a deferred judgment.
    var offenseClass: NCClass?
    /// A conditional discharge: no judgment has been entered yet.
    var conditionalDischarge: Bool?
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
    /// Violations already found in this case before this hearing (optional for older saves).
    var priorViolationCount: Int?
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
    /// Who wrote it, and where it ran (optional for older saves).
    var byline: String? = nil
    var section: String? = nil

    var placement: String? {
        switch prominence ?? 0 {
        case 3: return "Front page"
        case 2: return "Metro front"
        default: return nil
        }
    }
}

/// A motion for appropriate relief on newly discovered evidence (G.S. 15A-1415(c)), filed after a conviction in
/// this court and heard by the judge who tried the case.
struct ReliefMotion: Codable, Hashable, Identifiable {
    var id = UUID()
    var docket: String
    var personID: UUID
    var personName: String
    var offense: String
    /// What the defense says it found.
    var newEvidence: String
    /// Whether the new evidence is real and would likely change the result. Never shown before the ruling.
    var meritorious: Bool
    /// The case as it would be retried, with the new evidence.
    var retrial: CourtCase
    /// Set once the court has held an evidentiary hearing.
    var hearingHeld: Bool? = nil
}

/// Something that will happen later in the world, such as an appellate opinion or an exoneration.
struct PendingEvent: Codable, Hashable {
    enum Effect: String, Codable {
        case none
        case releasePerson
        case raisePropensity
        case resentence
        /// Resentenced upward on remand after the State's appeal: the lawful term now runs.
        case lengthen
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
    /// A probation sanction vacated on appeal: the probation as it stood before the order (optional for older saves).
    var restoreProbation: ProbationTerm?
    /// The violation the vacated order recorded, to strike from the person's record.
    var removesViolationID: UUID?
    /// The appeal this event decides or follows up on (optional for older saves).
    var appealID: UUID?
    /// A post-conviction motion that comes to the judge's calendar when this event arrives.
    var reliefMotion: ReliefMotion?
    /// A new case against someone this court already judged, which reaches the calendar when this event arrives.
    var reoffense: Reoffense?
}

/// An order entered with a judgment: no contact with the victim, and stay away from their home, work, and school.
struct StayAwayOrder: Codable, Hashable, Identifiable {
    var id = UUID()
    var docket: String
    var protectedName: String
    var issued: Date
    var expires: Date
    /// Domestic cases are enforced like a Chapter 50B protective order; others as stalking under a court order.
    var domestic: Bool
    var violations: Int = 0
    /// The lead offense in the case that produced the order (optional for older saves).
    var offense: String? = nil
}

/// Something a person this court judged did afterward, on its way back to this courtroom as a new case.
struct Reoffense: Codable, Hashable {
    var personID: UUID
    /// The kinds of case it could be, most fitting first.
    var templateKeys: [String]
    /// The same victim, when the new crime is against the person the first case was about.
    var victimName: String?
    var incident: Date
    /// Shown on the docket so the judge sees the connection to the earlier decision.
    var note: String
    /// The earlier case in this court, for a written follow-up to refer to (optional for older saves).
    var priorOffense: String? = nil
    var priorDate: Date? = nil
}
