import Foundation

/// Top-level groupings used by the Law Library.
enum LawCategory: String, CaseIterable, Codable, Identifiable {
    case violent = "Homicide & Assault"
    case robbery = "Robbery, Kidnapping & Stalking"
    case property = "Burglary, Larceny & Arson"
    case drugs = "Controlled Substances"
    case whiteCollar = "Fraud & Public Corruption"
    case publicOrder = "Weapons & Public Order"
    case traffic = "Motor Vehicle Offenses"
    case cyber = "Computer & Privacy Crimes"
    case family = "Children & Family"
    case procedure = "Criminal Procedure"
    case evidence = "Rules of Evidence"
    case defenses = "Defenses"
    case sentencing = "Structured Sentencing"
    case ethics = "Code of Judicial Conduct"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .violent: return "bolt.fill"
        case .robbery: return "figure.walk.motion"
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

    /// Offense categories carry a punishment class; the rest are doctrines.
    var isOffense: Bool {
        switch self {
        case .procedure, .evidence, .defenses, .sentencing, .ethics: return false
        default: return true
        }
    }
}

/// North Carolina offense classes (G.S. 14-1.1 and 14-3).
enum NCClass: String, Codable, CaseIterable, Hashable {
    case A, B1, B2, C, D, E, F, G, H, I
    case misdA1 = "A1"
    case misd1 = "1"
    case misd2 = "2"
    case misd3 = "3"

    var isFelony: Bool {
        switch self {
        case .misdA1, .misd1, .misd2, .misd3: return false
        default: return true
        }
    }

    /// 0 is most serious.
    var severity: Int { NCClass.allCases.firstIndex(of: self) ?? 0 }

    var label: String { isFelony ? "Class \(rawValue) Felony" : "Class \(rawValue) Misdemeanor" }
    var shortLabel: String { isFelony ? "Class \(rawValue) felony" : "Class \(rawValue) misd." }

    /// Prior record points this class carries as a prior conviction (G.S. 15A-1340.14(b)).
    var priorRecordPoints: Int {
        switch self {
        case .A: return 10
        case .B1: return 9
        case .B2, .C, .D: return 6
        case .E, .F, .G: return 4
        case .H, .I: return 2
        case .misdA1, .misd1: return 1
        case .misd2, .misd3: return 0
        }
    }

    /// Maximum fine for misdemeanors with a statutory cap; nil means the court's discretion.
    var maxFine: Int? {
        switch self {
        case .misd2: return 1_000
        case .misd3: return 200
        default: return nil
        }
    }
}

/// A statute (offense) or a legal doctrine, as shown in the Law Library.
struct Law: Identifiable, Hashable {
    let id: String
    let statute: String
    let title: String
    let category: LawCategory
    let ncClass: NCClass?
    let summary: String
    /// For offenses: the elements the State must prove. For doctrines: the key rules.
    let elements: [String]
    /// Punishment that falls outside the ordinary grid (e.g. life without parole, trafficking).
    let specialPunishment: String?
    let defenses: [String]
    let related: [String]
    let notes: String?

    init(id: String,
         statute: String,
         title: String,
         category: LawCategory,
         ncClass: NCClass? = nil,
         summary: String,
         elements: [String],
         specialPunishment: String? = nil,
         defenses: [String] = [],
         related: [String] = [],
         notes: String? = nil) {
        self.id = id
        self.statute = statute
        self.title = title
        self.category = category
        self.ncClass = ncClass
        self.summary = summary
        self.elements = elements
        self.specialPunishment = specialPunishment
        self.defenses = defenses
        self.related = related
        self.notes = notes
    }
}

enum SentenceFormat {
    static func months(_ m: Int) -> String {
        if m <= 0 { return "0 mo" }
        let years = m / 12
        let rem = m % 12
        if years == 0 { return "\(m) mo" }
        if rem == 0 { return years == 1 ? "1 yr" : "\(years) yrs" }
        return "\(years) yr \(rem) mo"
    }

    static func range(_ low: Int, _ high: Int) -> String {
        "\(low)–\(high) months"
    }

    static func dollars(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    static func date(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }

    static func shortDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    static let romanLevels = ["I", "II", "III", "IV", "V", "VI"]
}
