import Foundation

/// Top-level groupings used by the Law Library.
enum LawCategory: String, CaseIterable, Codable, Identifiable {
    case violent = "Violent Crimes"
    case property = "Property Crimes"
    case drugs = "Drug Offenses"
    case whiteCollar = "Fraud & White Collar"
    case publicOrder = "Public Order & Weapons"
    case traffic = "Vehicle & Traffic"
    case cyber = "Cyber Crimes"
    case family = "Family & Children"
    case procedure = "Constitutional Procedure"
    case evidence = "Rules of Evidence"
    case defenses = "Defenses"
    case sentencing = "Sentencing Principles"
    case ethics = "Judicial Ethics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .violent: return "bolt.fill"
        case .property: return "house.fill"
        case .drugs: return "pills.fill"
        case .whiteCollar: return "banknote.fill"
        case .publicOrder: return "megaphone.fill"
        case .traffic: return "car.fill"
        case .cyber: return "desktopcomputer"
        case .family: return "figure.and.child.holdinghands"
        case .procedure: return "building.columns.fill"
        case .evidence: return "magnifyingglass"
        case .defenses: return "shield.fill"
        case .sentencing: return "scalemass.fill"
        case .ethics: return "person.badge.shield.checkmark.fill"
        }
    }

    /// Offense categories carry sentencing ranges; the rest are doctrines.
    var isOffense: Bool {
        switch self {
        case .procedure, .evidence, .defenses, .sentencing, .ethics: return false
        default: return true
        }
    }
}

enum OffenseClass: String, Codable {
    case felonyA = "Class A Felony"
    case felonyB = "Class B Felony"
    case felonyC = "Class C Felony"
    case felonyD = "Class D Felony"
    case misdemeanorA = "Class A Misdemeanor"
    case misdemeanorB = "Class B Misdemeanor"

    var isFelony: Bool {
        switch self {
        case .misdemeanorA, .misdemeanorB: return false
        default: return true
        }
    }
}

/// Statutory sentencing range, in months. `life` stands in for a life sentence.
struct SentenceRange: Codable, Hashable {
    static let life = 1200

    var minMonths: Int
    var maxMonths: Int
    var typicalMonths: Int
    var maxFine: Int
    var probationEligible: Bool
    var mandatoryMinimum: Bool

    init(min: Int, max: Int, typical: Int, fine: Int, probation: Bool, mandatory: Bool = false) {
        self.minMonths = min
        self.maxMonths = max
        self.typicalMonths = typical
        self.maxFine = fine
        self.probationEligible = probation
        self.mandatoryMinimum = mandatory
    }

    var lifePossible: Bool { maxMonths >= SentenceRange.life }

    var summary: String {
        "\(SentenceFormat.months(minMonths)) – \(SentenceFormat.months(maxMonths))"
    }
}

/// A statute (offense) or a legal doctrine, as shown in the Law Library.
struct Law: Identifiable, Hashable {
    let id: String
    let code: String
    let title: String
    let category: LawCategory
    let offenseClass: OffenseClass?
    let summary: String
    /// For offenses: the elements the prosecution must prove. For doctrines: the key rules.
    let elements: [String]
    let sentence: SentenceRange?
    let aggravating: [String]
    let mitigating: [String]
    let defenses: [String]
    let related: [String]
    let notes: String?

    init(id: String,
         code: String,
         title: String,
         category: LawCategory,
         offenseClass: OffenseClass? = nil,
         summary: String,
         elements: [String],
         sentence: SentenceRange? = nil,
         aggravating: [String] = [],
         mitigating: [String] = [],
         defenses: [String] = [],
         related: [String] = [],
         notes: String? = nil) {
        self.id = id
        self.code = code
        self.title = title
        self.category = category
        self.offenseClass = offenseClass
        self.summary = summary
        self.elements = elements
        self.sentence = sentence
        self.aggravating = aggravating
        self.mitigating = mitigating
        self.defenses = defenses
        self.related = related
        self.notes = notes
    }
}

enum SentenceFormat {
    static func months(_ m: Int) -> String {
        if m >= SentenceRange.life { return "Life" }
        if m <= 0 { return "0 mo" }
        let years = m / 12
        let rem = m % 12
        if years == 0 { return "\(rem) mo" }
        if rem == 0 { return years == 1 ? "1 yr" : "\(years) yrs" }
        return "\(years) yr \(rem) mo"
    }

    static func dollars(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
