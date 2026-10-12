import Foundation
import SwiftUI

struct CaseRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var docket: String
    var caption: String
    var headline: String
    var category: LawCategory
    var verdictSummary: String
    var sentenceSummary: String?
    var grade: String
    var appealLabel: String
    var convicted: Bool
    var actuallyGuilty: Bool
    var integrityDelta: Int
    var approvalDelta: Int
    var date: Date
}

struct CareerEnd: Codable, Hashable {
    var title: String
    var reason: String
}

/// Persisted snapshot of a career.
private struct SaveData: Codable {
    var judgeName: String?
    var integrity: Int
    var approval: Int
    var casesHeard: Int
    var reversals: Int
    var wrongfulConvictions: Int
    var guiltyAcquitted: Int
    var history: [CaseRecord]
    var currentCase: CourtCase?
    var recentTemplates: [String]
    var seedBase: UInt64
    var careerEnd: CareerEnd?
}

@MainActor
final class GameState: ObservableObject {
    static let reviewInterval = 8

    @Published var judgeName: String?
    @Published var integrity = 70
    @Published var approval = 55
    @Published var casesHeard = 0
    @Published var reversals = 0
    @Published var wrongfulConvictions = 0
    @Published var guiltyAcquitted = 0
    @Published var history: [CaseRecord] = []
    @Published var currentCase: CourtCase?
    @Published var careerEnd: CareerEnd?
    @Published var lastReviewMessage: String?

    private var recentTemplates: [String] = []
    private var seedBase: UInt64 = UInt64.random(in: 1...UInt64.max / 2)
    private let saveKey = "JudgeSim.save.v1"

    init() {
        load()
    }

    var title: String {
        if casesHeard >= 40 && integrity >= 85 { return "State Supreme Court Nominee" }
        switch casesHeard {
        case 0..<5: return "Municipal Court Judge"
        case 5..<12: return "District Court Judge"
        case 12..<20: return "Superior Court Judge"
        case 20..<30: return "Senior Superior Court Judge"
        default: return "Presiding Judge"
        }
    }

    var casesUntilReview: Int {
        GameState.reviewInterval - (casesHeard % GameState.reviewInterval)
    }

    var reversalRate: Double {
        let convictions = history.filter(\.convicted).count
        return convictions == 0 ? 0 : Double(reversals) / Double(convictions)
    }

    // MARK: Actions

    func startCareer(name: String) {
        judgeName = name
        save()
    }

    /// Returns the case on the docket, generating a new one if needed.
    func docketCase() -> CourtCase {
        if let currentCase { return currentCase }
        let seed = seedBase &+ UInt64(casesHeard + 1) &* 0x9E37_79B9_7F4A_7C15
        let newCase = CaseGenerator.generate(seed: seed, avoiding: recentTemplates)
        currentCase = newCase
        recentTemplates.append(newCase.templateKey)
        if recentTemplates.count > 8 { recentTemplates.removeFirst(recentTemplates.count - 8) }
        save()
        return newCase
    }

    func complete(_ courtCase: CourtCase, outcome: CaseOutcome) {
        casesHeard += 1
        integrity = clamp(integrity + outcome.integrityDelta)
        approval = clamp(approval + outcome.approvalDelta)
        if outcome.appeal.isBad { reversals += 1 }
        if outcome.convicted && !outcome.truthGuilty { wrongfulConvictions += 1 }
        if !outcome.convicted && outcome.truthGuilty { guiltyAcquitted += 1 }

        let verdictSummary = outcome.dismissed
            ? "Dismissed"
            : outcome.verdictLines.map { "Count \($0.count): \($0.verdictLabel)" }.joined(separator: " · ")
        history.insert(CaseRecord(docket: courtCase.docket, caption: courtCase.caption, headline: courtCase.headline,
                                  category: courtCase.category, verdictSummary: verdictSummary,
                                  sentenceSummary: outcome.sentenceSummary, grade: outcome.grade,
                                  appealLabel: outcome.appeal.label, convicted: outcome.convicted,
                                  actuallyGuilty: outcome.truthGuilty, integrityDelta: outcome.integrityDelta,
                                  approvalDelta: outcome.approvalDelta, date: Date()), at: 0)
        currentCase = nil
        lastReviewMessage = nil

        if integrity <= 15 {
            careerEnd = CareerEnd(title: "Removed from the Bench",
                                  reason: "The Judicial Conduct Commission found a pattern of legal error and ethical lapses. Your commission has been revoked.")
        } else if casesHeard % GameState.reviewInterval == 0 {
            if approval < 30 {
                careerEnd = CareerEnd(title: "Voted Out",
                                      reason: "Your retention election wasn't close. With public approval at \(approval)%, voters chose not to retain you.")
            } else {
                lastReviewMessage = "Retention election: voters retained you with \(min(92, 40 + approval / 2))% of the vote."
            }
        }
        save()
    }

    func resetCareer() {
        judgeName = nil
        integrity = 70
        approval = 55
        casesHeard = 0
        reversals = 0
        wrongfulConvictions = 0
        guiltyAcquitted = 0
        history = []
        currentCase = nil
        careerEnd = nil
        lastReviewMessage = nil
        recentTemplates = []
        seedBase = UInt64.random(in: 1...UInt64.max / 2)
        save()
    }

    private func clamp(_ value: Int) -> Int { min(100, max(0, value)) }

    // MARK: Persistence

    private func save() {
        let data = SaveData(judgeName: judgeName, integrity: integrity, approval: approval, casesHeard: casesHeard,
                            reversals: reversals, wrongfulConvictions: wrongfulConvictions, guiltyAcquitted: guiltyAcquitted,
                            history: Array(history.prefix(100)), currentCase: currentCase, recentTemplates: recentTemplates,
                            seedBase: seedBase, careerEnd: careerEnd)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: saveKey),
              let data = try? JSONDecoder().decode(SaveData.self, from: raw) else { return }
        judgeName = data.judgeName
        integrity = data.integrity
        approval = data.approval
        casesHeard = data.casesHeard
        reversals = data.reversals
        wrongfulConvictions = data.wrongfulConvictions
        guiltyAcquitted = data.guiltyAcquitted
        history = data.history
        currentCase = data.currentCase
        recentTemplates = data.recentTemplates
        seedBase = data.seedBase
        careerEnd = data.careerEnd
    }
}
