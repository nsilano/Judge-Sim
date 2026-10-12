import Foundation

enum Side: String, Codable, Hashable {
    case prosecution = "Prosecution"
    case defense = "Defense"

    var opposite: Side { self == .prosecution ? .defense : .prosecution }
}

enum EvidenceKind: String, Codable, Hashable {
    case physical, forensic, digital, document, statement, video

    var icon: String {
        switch self {
        case .physical: return "shippingbox.fill"
        case .forensic: return "testtube.2"
        case .digital: return "iphone"
        case .document: return "doc.text.fill"
        case .statement: return "quote.bubble.fill"
        case .video: return "video.fill"
        }
    }

    var label: String {
        switch self {
        case .physical: return "Physical"
        case .forensic: return "Forensic"
        case .digital: return "Digital"
        case .document: return "Document"
        case .statement: return "Statement"
        case .video: return "Video"
        }
    }
}

struct Defendant: Codable, Hashable {
    var name: String
    var age: Int
    var occupation: String
    var background: String
    var priorRecord: [String]

    var lastName: String { name.components(separatedBy: " ").last ?? name }
}

struct Evidence: Identifiable, Codable, Hashable {
    var id = UUID()
    var exhibit: String
    var title: String
    var detail: String
    var side: Side
    var kind: EvidenceKind
    /// How strongly this item proves guilt (prosecution) or creates doubt (defense). Hidden from the player.
    var weight: Int
}

struct Witness: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var role: String
    var calledBy: Side
    var direct: [String]
    var cross: [String]
    /// Contribution toward (prosecution) or against (defense) guilt, after impeachment. Hidden.
    var weight: Int
}

struct Objection: Identifiable, Codable, Hashable {
    var id = UUID()
    var witnessID: UUID
    var question: String
    var answer: String
    var raisedBy: Side
    var grounds: String
    var shouldSustain: Bool
    var explanation: String
    var doctrineID: String
    /// Effect on the case's strength if this testimony stays in. Positive helps the prosecution.
    var weightIfAdmitted: Int
}

enum MotionKind: String, Codable, Hashable {
    case suppressSearch
    case suppressStatement
    case dismissSpeedyTrial

    var title: String {
        switch self {
        case .suppressSearch: return "Motion to Suppress Physical Evidence"
        case .suppressStatement: return "Motion to Suppress Statement"
        case .dismissSpeedyTrial: return "Motion to Dismiss: Speedy Trial Violation"
        }
    }
}

struct Motion: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: MotionKind
    var facts: String
    var defenseArgument: String
    var prosecutionResponse: String
    var targetEvidenceID: UUID?
    var shouldGrant: Bool
    var explanation: String
    var doctrineIDs: [String]
}

struct Charge: Identifiable, Codable, Hashable {
    var id = UUID()
    var count: Int
    var lawID: String
    var lesserLawID: String?
    var specification: String
    /// Strength needed to prove this charge beyond a reasonable doubt.
    var threshold: Int
    /// Strength needed for the lesser included offense.
    var lesserThreshold: Int

    var law: Law { LawLibrary.law(lawID) }
    var lesserLaw: Law? { lesserLawID.map { LawLibrary.law($0) } }
}

struct EthicsOption: Identifiable, Codable, Hashable {
    var id = UUID()
    var label: String
    var result: String
    var integrity: Int
    var approval: Int
    var isProper: Bool
}

struct EthicsEvent: Codable, Hashable {
    var title: String
    var body: String
    var doctrineID: String
    var options: [EthicsOption]
}

enum PublicMood: String, Codable, Hashable {
    case wantsConviction, sympathetic, divided, indifferent

    var label: String {
        switch self {
        case .wantsConviction: return "Public wants a conviction"
        case .sympathetic: return "Public sympathizes with the defendant"
        case .divided: return "Public opinion is divided"
        case .indifferent: return "Little public interest"
        }
    }

    var icon: String {
        switch self {
        case .wantsConviction: return "flame.fill"
        case .sympathetic: return "heart.fill"
        case .divided: return "arrow.left.arrow.right"
        case .indifferent: return "moon.zzz.fill"
        }
    }
}

struct HiddenTruth: Codable, Hashable {
    var actuallyGuilty: Bool
    var revelation: String
}

struct CourtCase: Identifiable, Codable, Hashable {
    var id = UUID()
    var seed: UInt64
    var templateKey: String
    var docket: String
    var headline: String
    var category: LawCategory
    var summary: String
    var defendant: Defendant
    var victimName: String?
    var charges: [Charge]
    var motions: [Motion]
    var prosecutor: String
    var defenseAttorney: String
    var prosecutionOpening: String
    var defenseOpening: String
    var prosecutionClosing: String
    var defenseClosing: String
    var evidence: [Evidence]
    var witnesses: [Witness]
    var objections: [Objection]
    var aggravating: [String]
    var mitigating: [String]
    var victimImpact: String?
    var allocution: String
    var twist: String?
    var ethics: EthicsEvent?
    var mood: PublicMood
    /// 1 = local paper, 2 = regional news, 3 = national story.
    var mediaAttention: Int
    var truth: HiddenTruth
    var relatedDoctrines: [String]

    var caption: String { "State of Westbrook v. \(defendant.name)" }

    func evidence(_ id: UUID?) -> Evidence? {
        guard let id else { return nil }
        return evidence.first { $0.id == id }
    }

    func objections(for witness: Witness) -> [Objection] {
        objections.filter { $0.witnessID == witness.id }
    }

    /// Every law the player might want to look up for this case.
    var relevantLawIDs: [String] {
        var ids: [String] = []
        for charge in charges {
            ids.append(charge.lawID)
            if let lesser = charge.lesserLawID { ids.append(lesser) }
        }
        ids.append(contentsOf: motions.flatMap(\.doctrineIDs))
        ids.append(contentsOf: objections.map(\.doctrineID))
        ids.append(contentsOf: relatedDoctrines)
        if let ethics { ids.append(ethics.doctrineID) }
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted && LawLibrary.lawIfPresent($0) != nil }
    }
}
