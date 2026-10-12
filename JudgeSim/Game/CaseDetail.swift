import Foundation

// MARK: - Models

/// A job the defendant holds or held.
struct Job: Codable, Hashable {
    var title: String
    var employer: String
    var years: String
    var current: Bool
}

/// Who the defendant is outside the courtroom.
struct DefendantProfile: Codable, Hashable {
    var jobs: [Job]
    var education: String
    var family: String
    var residence: String
    var income: String
}

/// One question and answer in open court. An empty question is a narrated moment.
struct TestimonyExchange: Codable, Hashable {
    enum Phase: String, Codable {
        case direct = "Direct examination"
        case cross = "Cross-examination"
        case redirect = "Redirect"
    }

    var phase: Phase
    var examiner: Side
    var question: String
    var answer: String
}

/// The investigating agency's file.
struct InvestigationReport: Codable, Hashable {
    struct Entry: Codable, Hashable {
        var when: String
        var what: String
    }

    var agency: String
    var leadInvestigator: String
    var reportNumber: String
    var incident: String
    var scene: String
    var timeline: [Entry]
    var howIdentified: String
    var interviews: [String]
    var warrants: [String]
    var lab: [String]
    /// Steps not taken: the gaps both sides will argue about.
    var notDone: [String]
}

// MARK: - Defendant profiles

enum DefendantProfiles {

    private static let employersByKeyword: [(String, [String])] = [
        ("nurs", ["Hollis Regional Medical Center", "Bayard Rehabilitation and Nursing", "Cane Creek Home Care"]),
        ("health", ["Cane Creek Home Care", "Hollis Regional Medical Center"]),
        ("dental", ["Wexley Family Dentistry"]),
        ("warehouse", ["Harborview Distribution Center", "Tidewater Freight Logistics"]),
        ("driver", ["Tidewater Freight Logistics", "Hollis County Schools Transportation", "Coastal Courier Services"]),
        ("cook", ["The Brickyard Grill", "Pell Avenue Diner", "Harbor House Seafood"]),
        ("bartend", ["The Lantern Row Tavern", "Harbor House Seafood"]),
        ("construction", ["Kestrel Builders", "Dunmore Mills Restoration LLC"]),
        ("electric", ["Ridgeview Electrical Contractors"]),
        ("barber", ["Fifth Street Cuts (self-employed)"]),
        ("retail", ["Marlowe Boulevard Home Goods", "Cane Creek Hardware"]),
        ("software", ["Pinewood Analytics"]),
        ("police", ["Port Hollis Police Department"]),
        ("sergeant", ["Port Hollis Police Department"]),
        ("teacher", ["Hollis County Schools"]),
        ("bus", ["Hollis County Schools Transportation"]),
        ("account", ["Ashby & Greer, CPAs"]),
        ("contractor", ["self-employed"]),
        ("farm", ["Cane Creek Poultry"]),
        ("mechanic", ["Juniper Court Auto Repair"])
    ]

    private static let generalEmployers = ["Harborview Distribution Center", "Cane Creek Poultry", "Port Hollis Marine Supply",
                                           "Marlowe Boulevard Home Goods", "Tidewater Freight Logistics", "The Brickyard Grill"]

    private static let pastJobs = ["line cook", "warehouse worker", "landscaper", "retail associate", "poultry plant worker",
                                   "security guard", "delivery driver", "call center representative", "roofer", "server",
                                   "forklift operator", "gas station clerk", "Army infantryman (honorably discharged)"]

    private static func employer(for title: String, rng: inout SeededRNG) -> String {
        let lower = title.lowercased()
        for (key, list) in employersByKeyword where lower.contains(key) { return rng.pick(list) }
        return rng.pick(generalEmployers)
    }

    /// The same person always gets the same history.
    static func make(for defendant: Defendant, county: County) -> DefendantProfile {
        let bytes = withUnsafeBytes(of: defendant.personID.uuid) { Array($0) }
        let seed = bytes.prefix(8).reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
        var rng = SeededRNG(seed: seed | 1)
        let occupation = defendant.occupation
        let lower = occupation.lowercased()
        let currentYear = Calendar.current.component(.year, from: Date())
        var jobs: [Job] = []
        let unemployed = lower.contains("unemployed")
        let student = lower.contains("student")

        if !unemployed {
            let base = occupation.components(separatedBy: ",").first ?? occupation
            let years = max(1, min(defendant.age - 17, rng.int(1...12)))
            jobs.append(Job(title: base.capitalizedFirst, employer: employer(for: base, rng: &rng),
                            years: "\(currentYear - years)–present", current: true))
            if rng.chance(0.35) && !student {
                jobs.append(Job(title: rng.pick(["weekend " + rng.pick(["server", "security guard", "delivery driver"]), "part-time rideshare driver"]),
                                employer: rng.pick(["Coastal Courier Services", "The Lantern Row Tavern", "self-employed"]),
                                years: "\(currentYear - rng.int(1...3))–present", current: true))
            }
        }
        var start = currentYear - (jobs.first.map { _ in rng.int(2...12) } ?? rng.int(1...3))
        for _ in 0..<rng.int(1...2) where defendant.age > 22 {
            let length = rng.int(1...4)
            let past = rng.pick(pastJobs)
            jobs.append(Job(title: past.capitalizedFirst, employer: employer(for: past, rng: &rng),
                            years: "\(start - length)–\(start)", current: false))
            start -= length + rng.int(0...1)
        }
        if unemployed, let last = jobs.first(where: { !$0.current }) {
            jobs.insert(Job(title: "Unemployed", employer: "since leaving \(last.employer)", years: "\(start + 1)–present", current: true), at: 0)
        }

        let education = rng.pick([
            "High school diploma, Hollis County High School.",
            "GED, earned at Hollis Community College.",
            "Left school in the 10th grade.",
            "Associate degree in applied science, Hollis Community College.",
            "Bachelor's degree from East Carolina University.",
            "Some college; withdrew after two semesters."
        ])
        let children = rng.int(0...3)
        let family = rng.pick(["Married", "Single", "Divorced", "Separated", "In a long-term relationship"])
            + (children == 0 ? ", no children." : ", \(children) child\(children == 1 ? "" : "ren")" + (children > 0 && rng.chance(0.4) ? ", pays child support." : "."))
        let residence = rng.pick([
            "Rents an apartment on \(rng.pick(NameBank.streets)) in \(rng.pick(county.towns)).",
            "Lives with a parent on \(rng.pick(NameBank.streets)) in \(rng.pick(county.towns)).",
            "Owns a small house in \(rng.pick(county.towns)).",
            "Rents a room from a friend in \(rng.pick(county.towns)).",
            "Has moved three times in the past year; most recently staying with family in \(rng.pick(county.towns))."
        ])
        let income: String
        if unemployed { income = "No reported income." }
        else if student { income = "Part-time income under $12,000 a year." }
        else { income = "Reported income about $\(rng.int(18...68)),000 a year." }
        return DefendantProfile(jobs: jobs, education: education, family: family, residence: residence, income: income)
    }
}

// MARK: - Investigation reports

enum Investigations {

    struct Gap {
        let finding: String
        let question: String
        let answer: String
        let paper: Bool
    }

    static let gaps: [Gap] = [
        Gap(finding: "Surveillance video from a business across the street was requested late and had already been recorded over.",
            question: "You never got the video from the business across the street, did you?",
            answer: "We requested it. By the time we followed up, it had been recorded over.", paper: false),
        Gap(finding: "No fingerprints were lifted from the main point of contact.",
            question: "Nobody dusted for fingerprints where it happened?",
            answer: "No. In my judgment the surface wouldn't hold a usable print.", paper: false),
        Gap(finding: "The neighborhood canvass reached only four houses.",
            question: "Your canvass covered four houses. Out of how many on that block?",
            answer: "About twenty. We prioritized the ones with a view.", paper: false),
        Gap(finding: "A second phone found at the scene was never searched.",
            question: "There was a second phone at the scene. Did anyone ever search it?",
            answer: "No. We didn't think it was relevant at the time.", paper: false),
        Gap(finding: "The first responding officer's notes were not preserved; only the typed report survives.",
            question: "Where are the first officer's handwritten notes?",
            answer: "They weren't kept. The typed report was written from them.", paper: false),
        Gap(finding: "An anonymous tip naming a different person was logged but not followed up.",
            question: "You got a tip naming someone else. What did you do with it?",
            answer: "It was logged. We had already developed our suspect by then.", paper: false),
        Gap(finding: "No forensic accountant reviewed the records before the earliest disputed year.",
            question: "Nobody looked at the books before the first year you're alleging, did they?",
            answer: "No. We focused on the period where the losses showed up.", paper: true),
        Gap(finding: "Other employees with the same system access were never interviewed.",
            question: "How many other people had access to that system? Did you talk to any of them?",
            answer: "Several did. We interviewed two.", paper: true),
        Gap(finding: "The defendant's own explanation of the transactions was never checked against company emails.",
            question: "You never searched the company email for the approvals my client says exist?",
            answer: "We asked the company for them. They said there weren't any.", paper: true)
    ]

    private static let paperCategories: Set<LawCategory> = [.whiteCollar, .cyber]

    static func make(t: CaseTemplate, values: [String: String], detective: CastMember, officer: CastMember,
                     evidence: [Evidence], witnesses: [Witness], defendant: Defendant, charges: [Charge],
                     year: Int, rng: inout SeededRNG) -> InvestigationReport {
        let paper = paperCategories.contains(t.category)
        let date = values["DATE"] ?? "the date in question"
        let time = values["TIME"] ?? "night"
        let street = values["STREET"] ?? "the scene"
        let town = values["HOOD"] ?? "Port Hollis"
        let dl = defendant.lastName
        let state = evidence.filter { $0.side == .prosecution }
        let forensic = state.filter { $0.kind == .forensic }
        let statement = state.first { $0.kind == .statement }
        let abbreviation = detective.agency.split(separator: " ").compactMap { $0.first }.map(String.init).joined()

        var timeline: [InvestigationReport.Entry] = []
        if paper {
            timeline.append(.init(when: "\(date)", what: "Complaint received by \(detective.agency) from \(values["V"] ?? "the reporting party")."))
            timeline.append(.init(when: "Week 1", what: "\(detective.display) assigned as lead investigator; preservation letters sent for bank and business records."))
            timeline.append(.init(when: "Weeks 2–8", what: "Records obtained by subpoena and search warrant; transactions reconstructed."))
        } else {
            timeline.append(.init(when: "\(date), \(time)", what: "Hollis County 911 Communications receives a call reporting an incident near \(street) in \(town)."))
            timeline.append(.init(when: "\(rng.int(4...14)) minutes later", what: "\(officer.display) arrives, secures the scene, and begins a bodycam recording."))
            timeline.append(.init(when: "Same night", what: "Scene photographed and processed; \(state.filter { [.physical, .forensic].contains($0.kind) }.map(\.title).prefix(3).joined(separator: ", ").ifEmpty("no physical items")) collected."))
            timeline.append(.init(when: "Next morning", what: "\(detective.display) assigned as lead investigator."))
        }
        var day = 2
        for item in state where item.kind == .digital || item.kind == .document || item.kind == .video {
            day += rng.int(1...9)
            timeline.append(.init(when: "Day \(day)", what: "\(item.title) obtained."))
        }
        if !forensic.isEmpty {
            day += rng.int(2...6)
            timeline.append(.init(when: "Day \(day)", what: "Items submitted to the State Crime Laboratory: \(forensic.map(\.title).joined(separator: ", "))."))
        }
        day += rng.int(3...20)
        timeline.append(.init(when: "Day \(day)", what: statement != nil
            ? "\(defendant.name) interviewed after Miranda warnings; the interview is recorded."
            : "\(defendant.name) contacted; declined to give a statement and asked for a lawyer."))
        day += rng.int(0...10)
        timeline.append(.init(when: "Day \(day)", what: "\(defendant.name) arrested and charged with \(charges.map { $0.law.title }.joined(separator: ", "))."))
        if !forensic.isEmpty {
            timeline.append(.init(when: "Week \(rng.int(6...14))", what: "State Crime Laboratory results returned."))
        }

        let titles = state.map { $0.title.lowercased() }
        let howIdentified: String
        if titles.contains(where: { $0.contains("lineup") || $0.contains("identification") }) {
            howIdentified = "A witness picked \(dl) from a photo lineup."
        } else if titles.contains(where: { $0.contains("pawn") }) {
            howIdentified = "Pawn records listed an item under \(dl)'s name."
        } else if titles.contains(where: { $0.contains("cell") || $0.contains("phone") || $0.contains("text") }) {
            howIdentified = "Phone records pointed to \(dl)."
        } else if titles.contains(where: { $0.contains("video") || $0.contains("footage") || $0.contains("camera") }) {
            howIdentified = "Video from the scene led investigators to \(dl)."
        } else if paper {
            howIdentified = "The records traced the transactions to accounts and logins associated with \(dl)."
        } else if t.hasVictim {
            howIdentified = rng.pick(["\(values["V"] ?? "The complainant") named \(dl) to the first officer.",
                                      "A Crime Stoppers tip named \(dl).",
                                      "\(dl) was found near the scene shortly afterward."])
        } else {
            howIdentified = rng.pick(["A Crime Stoppers tip named \(dl).", "\(dl) was stopped nearby shortly afterward."])
        }

        var interviews = witnesses.filter { $0.isDefendant != true }.map { "\($0.name), \($0.role.lowercased())" }
        interviews.append(statement != nil ? "\(defendant.name) (recorded, after Miranda warnings)" : "\(defendant.name) declined to be interviewed")
        let warrants = state.filter { $0.detail.lowercased().contains("found") || $0.detail.lowercased().contains("recovered") || $0.kind == .digital }
            .prefix(3).map { "Warrant covering \($0.title.lowercased())" }
        let lab = forensic.map { "\($0.title): \($0.detail)" }
        let notDone = rng.pick(gaps.filter { $0.paper == paper }, count: 2).map(\.finding)

        let scene: String
        switch t.category {
        case .whiteCollar, .cyber:
            scene = "No physical scene. The investigation centered on bank, business, and computer records."
        case .traffic:
            scene = "Roadway near \(street) in \(town): skid marks measured, vehicle positions photographed, weather and lighting noted."
        default:
            scene = "\(street.capitalizedFirst) in \(town). Lighting: \(rng.pick(["one working streetlight", "lit storefronts", "dark, no streetlights", "daylight"])). The area was photographed and measured before evidence was moved."
        }

        return InvestigationReport(agency: detective.agency, leadInvestigator: detective.display,
                                   reportNumber: "\(abbreviation)-\(String(format: "%02d", year % 100))-\(String(format: "%05d", rng.int(1_000...99_999)))",
                                   incident: paper ? "Reported \(date)" : "\(date), about \(time), near \(street), \(town)",
                                   scene: scene, timeline: timeline, howIdentified: howIdentified,
                                   interviews: interviews, warrants: Array(warrants), lab: lab, notDone: notDone)
    }
}

extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
