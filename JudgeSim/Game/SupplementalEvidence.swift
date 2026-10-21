import Foundation

/// Follow-up work a judge can ask for when continuing a case.
enum EvidenceRequest: String, Codable, CaseIterable, Identifiable {
    case video, phoneRecords, labTesting, witnessFollowUp, financialRecords, expertReview, alibi

    var id: String { rawValue }

    var label: String {
        switch self {
        case .video: return "Find surveillance video the investigation missed"
        case .phoneRecords: return "Obtain phone and location records"
        case .labTesting: return "Additional State Crime Laboratory testing"
        case .witnessFollowUp: return "Track down witnesses and tips that weren't followed up"
        case .financialRecords: return "Subpoena bank and business records"
        case .expertReview: return "Independent expert review of the forensic work"
        case .alibi: return "Check the alibi: phone location, cameras, and app records for where the defense says the defendant was"
        }
    }

    var icon: String {
        switch self {
        case .video: return "video.fill"
        case .phoneRecords: return "iphone"
        case .labTesting: return "testtube.2"
        case .witnessFollowUp: return "person.fill.questionmark"
        case .financialRecords: return "banknote.fill"
        case .expertReview: return "magnifyingglass"
        case .alibi: return "location.magnifyingglass"
        }
    }

    /// Requests that make sense for this kind of case.
    static func options(for c: CourtCase) -> [EvidenceRequest] {
        // A written case's record is complete as written; generic follow-up results wouldn't fit its story.
        // The one exception is an alibi, which the case itself says how to check.
        if c.templateKey.hasPrefix("story.") {
            return CaseTemplates.byKey[c.templateKey]?.story?.alibiCheck == nil ? [] : [.alibi]
        }
        let paper = c.category == .whiteCollar || c.category == .cyber
        var list: [EvidenceRequest] = paper ? [.financialRecords, .phoneRecords, .witnessFollowUp, .expertReview]
                                            : [.video, .phoneRecords, .witnessFollowUp]
        if c.evidence.contains(where: { $0.kind == .forensic }) && !paper { list += [.labTesting, .expertReview] }
        else if !paper { list.append(.labTesting) }
        return list
    }
}

/// What comes back when a case returns after the judge asked for more investigation.
/// Results follow what really happened, so they can clarify the case, cut the other way, or come back inconclusive.
enum SupplementalEvidence {

    private enum Direction { case guilt, innocence, inconclusive }

    static func gather(for c: inout CourtCase, requests: [EvidenceRequest], rng: inout SeededRNG) -> [String] {
        guard !requests.isEmpty else { return [] }
        if c.templateKey.hasPrefix("story.") { return checkAlibi(&c, requests: requests) }
        let dl = c.defendant.lastName
        var used = Set([c.defendant.name])
        var notes: [String] = []
        for request in requests {
            let roll = Double.random(in: 0..<1, using: &rng)
            let direction: Direction = roll < 0.65 ? (c.truth.actuallyGuilty ? .guilt : .innocence)
                : (roll < 0.8 ? (c.truth.actuallyGuilty ? .innocence : .guilt) : .inconclusive)
            let item = make(request, direction: direction, dl: dl, alt: NameBank.person(using: &rng, excluding: &used), rng: &rng)
            let side = item.side
            let number = c.evidence.filter { $0.side == side }.count + 1
            let label = side == .prosecution ? "State's Exhibit \(number)" : "Defendant's Exhibit \(number)"
            c.evidence.append(Evidence(exhibit: label, title: item.title, detail: item.detail, side: side, kind: item.kind,
                                       weight: item.weight, supplemental: "New: obtained during the continuance"))
            notes.append("\(label): \(item.title)")
        }
        if var report = c.investigation {
            report.timeline.append(.init(when: "During the continuance",
                                         what: "Follow-up ordered by the court: " + requests.map { $0.label.lowercased() }.joined(separator: "; ") + "."))
            c.investigation = report
        }
        return notes
    }

    /// A written case's alibi, checked: the records back it up when the defendant wasn't there, and break it when
    /// the defendant was.
    private static func checkAlibi(_ c: inout CourtCase, requests: [EvidenceRequest]) -> [String] {
        guard requests.contains(.alibi), let check = CaseTemplates.byKey[c.templateKey]?.story?.alibiCheck else { return [] }
        let holds = !c.truth.actuallyGuilty
        let finding = holds ? check.holds : check.breaks
        let side: Side = holds ? .defense : .prosecution
        let number = c.evidence.filter { $0.side == side }.count + 1
        let label = side == .prosecution ? "State's Exhibit \(number)" : "Defendant's Exhibit \(number)"
        let detail = finding.detail.replacingOccurrences(of: "{DL}", with: c.defendant.lastName)
        c.evidence.append(Evidence(exhibit: label, title: finding.title, detail: detail, side: side, kind: finding.kind, weight: 3,
                                   supplemental: "New: the alibi was checked during the continuance"))
        if var report = c.investigation {
            report.timeline.append(.init(when: "During the continuance",
                                         what: "Follow-up ordered by the court: records checked for where the defense says \(c.defendant.lastName) was."))
            c.investigation = report
        }
        return ["\(label): \(finding.title)"]
    }

    private struct Item {
        let side: Side
        let kind: EvidenceKind
        let weight: Int
        let title: String
        let detail: String
    }

    private static func make(_ request: EvidenceRequest, direction: Direction, dl: String, alt: String, rng: inout SeededRNG) -> Item {
        let business = rng.pick(["a pharmacy", "a gas station", "a laundromat", "a pawn shop", "an auto parts store", "a church"])
        switch (request, direction) {
        case (.alibi, _):
            return make(.phoneRecords, direction: direction, dl: dl, alt: alt, rng: &rng)
        case (.video, .guilt):
            return Item(side: .prosecution, kind: .video, weight: 3, title: "Recovered Camera Footage",
                        detail: "Video from \(business) a block away, located during the continuance, shows a person matching \(dl)'s height, build, and clothing heading toward the scene minutes before, and away from it minutes after.")
        case (.video, .innocence):
            return Item(side: .defense, kind: .video, weight: 3, title: "Recovered Camera Footage",
                        detail: "Video from \(business) a block away, located during the continuance, shows a different person, noticeably taller than \(dl), leaving the scene at the critical time.")
        case (.video, .inconclusive):
            return Item(side: .defense, kind: .video, weight: 0, title: "Recovered Camera Footage",
                        detail: "Video from \(business) captures a figure near the scene, but the image is too dark and distant to identify anyone.")
        case (.phoneRecords, .guilt):
            return Item(side: .prosecution, kind: .digital, weight: 3, title: "Location History",
                        detail: "Records obtained by warrant place \(dl)'s phone within about 200 yards of the scene during the time in question.")
        case (.phoneRecords, .innocence):
            return Item(side: .defense, kind: .digital, weight: 3, title: "Location History",
                        detail: "Records obtained by subpoena place \(dl)'s phone, in active use, across town during the time in question.")
        case (.phoneRecords, .inconclusive):
            return Item(side: .prosecution, kind: .digital, weight: 0, title: "Location History",
                        detail: "The records show \(dl)'s phone was off or out of service for the two hours around the incident.")
        case (.labTesting, .guilt):
            return Item(side: .prosecution, kind: .forensic, weight: 3, title: "Supplemental Lab Report",
                        detail: "Additional testing of items not originally submitted found \(dl)'s DNA on a second item collected at the scene.")
        case (.labTesting, .innocence):
            return Item(side: .defense, kind: .forensic, weight: 3, title: "Supplemental Lab Report",
                        detail: "Additional testing found DNA from an unknown person on the key item, and excluded \(dl) as its source.")
        case (.labTesting, .inconclusive):
            return Item(side: .prosecution, kind: .forensic, weight: 0, title: "Supplemental Lab Report",
                        detail: "The additional samples were too degraded to produce a usable profile.")
        case (.witnessFollowUp, .guilt):
            return Item(side: .prosecution, kind: .statement, weight: 2, title: "Newly Located Witness",
                        detail: "\(alt), located during the continuance, gave a recorded statement placing \(dl) near the scene that night and describing what \(dl) was wearing.")
        case (.witnessFollowUp, .innocence):
            return Item(side: .defense, kind: .statement, weight: 3, title: "Follow-Up on the Old Tip",
                        detail: "Investigators finally followed up the overlooked tip. \(alt) admitted being at the scene and gave an account that doesn't involve \(dl).")
        case (.witnessFollowUp, .inconclusive):
            return Item(side: .defense, kind: .statement, weight: 0, title: "Follow-Up Interviews",
                        detail: "Re-interviews turned up nothing new. Two witnesses could not be located.")
        case (.financialRecords, .guilt):
            return Item(side: .prosecution, kind: .document, weight: 3, title: "Subpoenaed Bank Records",
                        detail: "The records show the missing money moving through an account \(dl) opened under a business name, then withdrawn in cash.")
        case (.financialRecords, .innocence):
            return Item(side: .defense, kind: .document, weight: 3, title: "Subpoenaed Business Records",
                        detail: "Internal records show a supervisor approved the disputed transactions in writing, as \(dl) has claimed.")
        case (.financialRecords, .inconclusive):
            return Item(side: .defense, kind: .document, weight: 0, title: "Subpoenaed Records",
                        detail: "The records are incomplete. The bank purged statements older than seven years.")
        case (.expertReview, .guilt):
            return Item(side: .prosecution, kind: .forensic, weight: 2, title: "Independent Expert Review",
                        detail: "An independent expert reviewed the State's forensic work and agreed with its conclusions.")
        case (.expertReview, .innocence):
            return Item(side: .defense, kind: .document, weight: 2, title: "Independent Expert Review",
                        detail: "An independent expert found that the State's analysis overstated its conclusions and skipped a confirmation step.")
        case (.expertReview, .inconclusive):
            return Item(side: .defense, kind: .document, weight: 0, title: "Independent Expert Review",
                        detail: "The independent expert found the State's methods acceptable but the results less certain than presented.")
        }
    }
}
