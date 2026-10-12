import Foundation

/// Sentence dispositions under the Structured Sentencing Act (G.S. 15A-1340.11).
enum Disposition: String, Codable, CaseIterable, Hashable {
    case community = "C"
    case intermediate = "I"
    case active = "A"

    var label: String {
        switch self {
        case .community: return "Community"
        case .intermediate: return "Intermediate"
        case .active: return "Active"
        }
    }

    var detail: String {
        switch self {
        case .community: return "Suspended sentence with unsupervised or supervised probation, fines, or community service. No incarceration."
        case .intermediate: return "Suspended sentence with supervised probation. May include special probation (a short jail split), treatment court, or electronic house arrest."
        case .active: return "The defendant serves the sentence in custody."
        }
    }
}

enum SentenceRangeKind: String, Codable, CaseIterable, Hashable {
    case mitigated, presumptive, aggravated

    var label: String { rawValue.capitalized }
}

struct MonthRange: Codable, Hashable {
    let low: Int
    let high: Int

    var text: String { SentenceFormat.range(low, high) }
}

/// One cell of the felony punishment chart.
struct FelonyCell: Hashable {
    let dispositions: [Disposition]
    /// nil means "life imprisonment without parole".
    let aggravated: MonthRange?
    let presumptive: MonthRange
    let mitigated: MonthRange

    func range(_ kind: SentenceRangeKind) -> MonthRange? {
        switch kind {
        case .mitigated: return mitigated
        case .presumptive: return presumptive
        case .aggravated: return aggravated
        }
    }

    var dispositionCode: String { dispositions.map(\.rawValue).joined(separator: "/") }
}

struct MisdemeanorCell: Hashable {
    let dispositions: [Disposition]
    let maxDays: Int

    var dispositionCode: String { dispositions.map(\.rawValue).joined(separator: "/") }
}

/// North Carolina felony and misdemeanor punishment charts, for offenses committed on or after October 1, 2013.
enum StructuredSentencing {

    private static func cell(_ code: String, _ aggravated: (Int, Int)?, _ presumptive: (Int, Int), _ mitigated: (Int, Int)) -> FelonyCell {
        let dispositions = code.split(separator: "/").compactMap { Disposition(rawValue: String($0)) }
        return FelonyCell(dispositions: dispositions,
                          aggravated: aggravated.map { MonthRange(low: $0.0, high: $0.1) },
                          presumptive: MonthRange(low: presumptive.0, high: presumptive.1),
                          mitigated: MonthRange(low: mitigated.0, high: mitigated.1))
    }

    /// Minimum-sentence ranges in months, prior record levels I through VI.
    static let felonyGrid: [NCClass: [FelonyCell]] = [
        .B1: [cell("A", (240, 300), (192, 240), (144, 192)),
              cell("A", (276, 345), (221, 276), (166, 221)),
              cell("A", (317, 397), (254, 317), (190, 254)),
              cell("A", (365, 456), (292, 365), (219, 292)),
              cell("A", nil, (336, 420), (252, 336)),
              cell("A", nil, (386, 483), (290, 386))],
        .B2: [cell("A", (157, 196), (125, 157), (94, 125)),
              cell("A", (180, 225), (144, 180), (108, 144)),
              cell("A", (207, 258), (165, 207), (124, 165)),
              cell("A", (238, 297), (190, 238), (143, 190)),
              cell("A", (273, 342), (219, 273), (164, 219)),
              cell("A", (314, 393), (251, 314), (189, 251))],
        .C: [cell("A", (73, 92), (58, 73), (44, 58)),
             cell("A", (83, 104), (67, 83), (50, 67)),
             cell("A", (96, 120), (77, 96), (58, 77)),
             cell("A", (110, 138), (88, 110), (66, 88)),
             cell("A", (127, 159), (101, 127), (76, 101)),
             cell("A", (146, 182), (117, 146), (87, 117))],
        .D: [cell("A", (64, 80), (51, 64), (38, 51)),
             cell("A", (73, 92), (59, 73), (44, 59)),
             cell("A", (84, 105), (67, 84), (51, 67)),
             cell("A", (97, 121), (78, 97), (58, 78)),
             cell("A", (111, 139), (89, 111), (67, 89)),
             cell("A", (128, 160), (103, 128), (77, 103))],
        .E: [cell("I/A", (25, 31), (20, 25), (15, 20)),
             cell("I/A", (29, 36), (23, 29), (17, 23)),
             cell("A", (34, 42), (27, 34), (20, 27)),
             cell("A", (46, 57), (36, 46), (27, 36)),
             cell("A", (53, 66), (43, 53), (32, 43)),
             cell("A", (59, 74), (47, 59), (35, 47))],
        .F: [cell("I/A", (16, 20), (13, 16), (10, 13)),
             cell("I/A", (19, 23), (15, 19), (11, 15)),
             cell("I/A", (21, 26), (17, 21), (13, 17)),
             cell("A", (25, 31), (20, 25), (15, 20)),
             cell("A", (34, 42), (27, 34), (20, 27)),
             cell("A", (39, 49), (31, 39), (23, 31))],
        .G: [cell("I/A", (13, 16), (10, 13), (8, 10)),
             cell("I/A", (15, 19), (12, 15), (9, 12)),
             cell("I/A", (16, 20), (13, 16), (10, 13)),
             cell("I/A", (20, 25), (16, 20), (12, 16)),
             cell("A", (21, 26), (17, 21), (13, 17)),
             cell("A", (29, 36), (23, 29), (17, 23))],
        .H: [cell("C/I/A", (6, 8), (5, 6), (4, 5)),
             cell("I/A", (8, 10), (6, 8), (4, 6)),
             cell("I/A", (10, 12), (8, 10), (6, 8)),
             cell("I/A", (11, 14), (9, 11), (7, 9)),
             cell("I/A", (15, 19), (12, 15), (9, 12)),
             cell("A", (20, 25), (16, 20), (12, 16))],
        .I: [cell("C", (6, 8), (4, 6), (3, 4)),
             cell("C/I", (6, 8), (4, 6), (3, 4)),
             cell("I", (6, 8), (5, 6), (4, 5)),
             cell("I/A", (8, 10), (6, 8), (4, 6)),
             cell("I/A", (9, 11), (7, 9), (5, 7)),
             cell("I/A", (10, 12), (8, 10), (6, 8))]
    ]

    /// Maximum days by prior conviction level I–III (G.S. 15A-1340.23).
    static let misdemeanorGrid: [NCClass: [MisdemeanorCell]] = [
        .misdA1: [MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 60),
                  MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 75),
                  MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 150)],
        .misd1: [MisdemeanorCell(dispositions: [.community], maxDays: 45),
                 MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 45),
                 MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 120)],
        .misd2: [MisdemeanorCell(dispositions: [.community], maxDays: 30),
                 MisdemeanorCell(dispositions: [.community, .intermediate], maxDays: 45),
                 MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 60)],
        .misd3: [MisdemeanorCell(dispositions: [.community], maxDays: 10),
                 MisdemeanorCell(dispositions: [.community, .intermediate], maxDays: 15),
                 MisdemeanorCell(dispositions: [.community, .intermediate, .active], maxDays: 20)]
    ]

    static func felonyCell(_ cls: NCClass, level: Int) -> FelonyCell? {
        felonyGrid[cls]?[max(1, min(6, level)) - 1]
    }

    static func misdemeanorCell(_ cls: NCClass, level: Int) -> MisdemeanorCell? {
        misdemeanorGrid[cls]?[max(1, min(3, level)) - 1]
    }

    /// Corresponding maximum sentence (G.S. 15A-1340.17): 120% of the minimum, rounded up,
    /// plus 12 months of post-release supervision for B1–E or 9 months for F–I.
    static func maximum(forMinimum minimum: Int, cls: NCClass) -> Int {
        let base = Int((Double(minimum) * 1.2).rounded(.up))
        switch cls {
        case .B1, .B2, .C, .D, .E: return base + 12
        default: return base + 9
        }
    }

    static func felonyLevel(points: Int) -> Int {
        switch points {
        case ...1: return 1
        case 2...5: return 2
        case 6...9: return 3
        case 10...13: return 4
        case 14...17: return 5
        default: return 6
        }
    }

    static func misdemeanorLevel(priorConvictions: Int) -> Int {
        switch priorConvictions {
        case 0: return 1
        case 1...4: return 2
        default: return 3
        }
    }

    /// Habitual felons are sentenced four classes higher than the principal felony, but no higher than Class C (G.S. 14-7.6).
    static func habitualClass(for cls: NCClass) -> NCClass {
        let felonies: [NCClass] = [.A, .B1, .B2, .C, .D, .E, .F, .G, .H, .I]
        guard let index = felonies.firstIndex(of: cls), cls.isFelony else { return cls }
        if index <= 3 { return cls }
        return felonies[max(3, index - 4)]
    }

    /// Typical probation lengths in months (G.S. 15A-1343.2).
    static func probationMonths(felony: Bool, disposition: Disposition) -> ClosedRange<Int> {
        switch (felony, disposition) {
        case (true, .community): return 12...30
        case (true, _): return 18...36
        case (false, .community): return 6...18
        case (false, _): return 12...24
        }
    }
}

/// A conviction on someone's record.
struct PriorConviction: Identifiable, Codable, Hashable {
    var id = UUID()
    var offense: String
    var ncClass: NCClass
    var year: Int
    var county: String
    var sentence: String
    var fromThisCourt = false

    var points: Int { ncClass.priorRecordPoints }
}

/// Prior record computation for one defendant.
struct PriorRecord: Hashable {
    struct Line: Hashable {
        let text: String
        let points: Int
    }

    let lines: [Line]
    let points: Int
    let felonyLevel: Int
    let misdemeanorLevel: Int
    let priorFelonies: [PriorConviction]

    init(priors: [PriorConviction], onSupervision: Bool, habitualPredicates: Set<UUID> = []) {
        var lines: [Line] = []
        var points = 0
        for prior in priors.sorted(by: { $0.year < $1.year }) {
            if habitualPredicates.contains(prior.id) {
                lines.append(Line(text: "\(prior.year) \(prior.offense) (used to establish habitual felon status)", points: 0))
                continue
            }
            lines.append(Line(text: "\(prior.year) \(prior.offense), \(prior.ncClass.shortLabel)", points: prior.points))
            points += prior.points
        }
        if onSupervision {
            lines.append(Line(text: "Offense committed while on probation, parole, or post-release supervision", points: 1))
            points += 1
        }
        self.lines = lines
        self.points = points
        self.felonyLevel = StructuredSentencing.felonyLevel(points: points)
        self.misdemeanorLevel = StructuredSentencing.misdemeanorLevel(priorConvictions: priors.count)
        self.priorFelonies = priors.filter { $0.ncClass.isFelony }.sorted(by: { $0.year < $1.year })
    }
}
