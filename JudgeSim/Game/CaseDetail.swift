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

    // The family line is the one record of the defendant's family. Everything the defendant, counsel, or anyone
    // else says about it reads these, so no line can say otherwise.

    /// The defendant's own children: "no children" is 0, "2 children" is 2.
    var childCount: Int {
        if family.contains("no children") { return 0 }
        guard let match = family.range(of: #"\d+ child"#, options: .regularExpression) else { return 0 }
        return Int(family[match].prefix { $0.isNumber }) ?? 0
    }
    /// Children the defendant is raising who aren't their own: foster children, a niece and nephew.
    var raisesOthers: Bool { family.contains("Foster parent") || family.contains("Raising a") }
    /// The first words of the family line: Single, Married, Divorced, Widowed, and so on.
    var status: String { family.components(separatedBy: ",").first ?? family }
    var married: Bool { status.hasPrefix("Married") }
    var partnered: Bool { status.hasPrefix("In a") || status.hasPrefix("Engaged") }
    /// The job the defendant holds now, if any: not "Unemployed", not time in custody.
    var currentJob: Job? { jobs.first { $0.current && $0.title != "Unemployed" && $0.title != "In custody" } }
    /// Whether an occupation is paid work someone can go back to: not a student, retiree, homemaker, or a job held before.
    static func isWork(_ occupation: String) -> Bool {
        let l = occupation.lowercased()
        return !["unemployed", "student", "retired", "former", "stay-at-home", "high school", "senior", "junior", "freshman",
                 "sophomore", "pledge", "homemaker"].contains(where: l.contains)
    }
    /// The family line says someone in the family is the victim in this case.
    var familyIsVictim: Bool { family.contains("victim in this case") || family.contains("victims in this case") }
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
    /// The fixed facts of the case: when, where, and in what order things happened. Optional for older saves.
    var facts: CaseFactSheet? = nil
}

/// The one place a case's dates, times, and places are decided, so every witness, report, and exhibit agrees.
struct CaseFactSheet: Codable, Hashable {
    var setting: CaseSetting
    /// The day of the incident (for records cases, the day the complaint came in).
    var incident: Date
    /// Clock time of the incident, such as "11:40 p.m.". Nil when there was no single moment.
    var time: String?
    /// Where it happened, as a phrase: "outside The Lantern Row Tavern on Harbor Street in Wexley".
    var place: String
    var street: String
    var town: String
    /// When the first officer arrived or made the stop.
    var arrivalTime: String?
    /// When the lead investigator took the case.
    var assigned: Date
    var arrest: Date
    /// When the defendant was interviewed, if they agreed to talk.
    var interview: Date?
    var labSubmitted: Date?
    var labReturned: Date?
    /// Who handled the case.
    var agency: String
    var lead: String
    var firstOfficer: String

    var day: String { CaseDates.day(incident) }
    var when: String { time.map { "\(day), at about \($0)" } ?? day }
}

/// Formats dates the way people say them in court.
enum CaseDates {
    static func day(_ date: Date) -> String { date.formatted(.dateTime.month(.wide).day()) }
    static func dayYear(_ date: Date) -> String { date.formatted(.dateTime.month(.wide).day().year()) }
    static func add(_ days: Int, to date: Date) -> Date { Calendar.current.date(byAdding: .day, value: days, to: date) ?? date }
    static func days(from a: Date, to b: Date) -> Int { Calendar.current.dateComponents([.day], from: a, to: b).day ?? 0 }
}

/// Clock times written like "11:40 p.m.".
enum Clock {
    static func minutes(_ time: String) -> Int? {
        let lower = time.lowercased()
        let pm = lower.contains("p.m")
        let digits = lower.components(separatedBy: CharacterSet(charactersIn: "0123456789:").inverted).joined()
        let parts = digits.split(separator: ":").compactMap { Int($0) }
        guard let hour = parts.first else { return nil }
        let minute = parts.count > 1 ? parts[1] : 0
        var h = hour % 12
        if pm { h += 12 }
        return h * 60 + minute
    }

    static func format(_ total: Int) -> String {
        let m = ((total % 1440) + 1440) % 1440
        let h24 = m / 60
        let h12 = h24 % 12 == 0 ? 12 : h24 % 12
        return "\(h12):\(String(format: "%02d", m % 60)) \(h24 < 12 ? "a.m." : "p.m.")"
    }

    static func shift(_ time: String, by delta: Int) -> String {
        guard let m = minutes(time) else { return time }
        return format(m + delta)
    }

    /// "night", "evening", "morning", or "afternoon".
    static func partOfDay(_ time: String?) -> String {
        guard let time, let m = minutes(time) else { return "day" }
        switch m {
        case 0..<300, 1260..<1440: return "night"
        case 300..<720: return "morning"
        case 720..<1020: return "afternoon"
        default: return "evening"
        }
    }
}



// MARK: - Defendant profiles

enum DefendantProfiles {

    private static let employersByKeyword: [(String, [String])] = [
        ("detention", ["Hollis County Detention Center"]),
        ("sheriff", ["Hollis County Sheriff's Office"]),
        ("media coordinator", ["Hollis County Schools"]),
        ("daycare", ["Little Harbor Day Care"]),
        ("day care", ["Little Harbor Day Care"]),
        ("fast-food", ["Harbor Burger on Pell Avenue"]),
        ("fast food", ["Harbor Burger on Pell Avenue"]),
        ("grocery", ["Bayard Family Grocery", "Wexley Food Mart"]),
        ("feed store", ["own feed store"]),
        ("horse", ["self-employed (horse training)"]),
        ("cell phone", ["Coastal Wireless on Marlowe Boulevard"]),
        ("phone store", ["Coastal Wireless on Marlowe Boulevard"]),
        ("truck", ["Tidewater Freight Logistics", "Coastal Carriers Inc."]),
        ("school bus", ["Hollis County Schools Transportation"]),
        ("bus driver", ["Hollis County Schools Transportation"]),
        ("restaurant owner", ["own restaurant"]),
        ("pawn", ["own shop"]),
        ("rescue", ["self-employed (dog rescue)"]),
        ("machinist", ["Port Hollis Shipyard", "Dunmore Mills Manufacturing"]),
        ("massage", ["Harbor Wellness Spa", "self-employed"]),
        ("cafeteria", ["Hollis County Schools"]),
        ("systems administrator", ["Tidewater Freight Logistics", "Coastal Carriers Inc."]),
        ("hvac", ["Coastal Heating & Air", "Ridgeview Mechanical"]),
        ("freshman", ["Hollis Community College"]),
        ("college", ["Hollis Community College", "East Carolina University"]),
        ("student", ["Hollis Community College"]),
        ("building inspector", ["Hollis County Inspections Department"]),
        ("dispatcher", ["Tidewater Freight Logistics"]),
        ("executive assistant", ["Pinewood Analytics", "Ashby & Greer, CPAs"]),
        ("trainer", ["Iron Harbor Fitness"]),
        ("bouncer", ["The Lantern Row Tavern"]),
        ("hair", ["Salon Bayard", "self-employed"]),
        ("child care", ["self-employed (licensed home day care)"]),
        ("reseller", ["self-employed (online sales)"]),
        ("dealership", ["Hollis County Motors (owner)"]),
        ("rental", ["self-employed (rental properties)"]),
        ("pharmaceutical", ["Meridian Pharmaceuticals"]),
        ("physical therap", ["Hollis Regional Medical Center", "Bayard Rehabilitation and Nursing"]),
        ("real estate", ["Coastal Realty Group"]),
        ("roofer", ["Kestrel Roofing", "self-employed"]),
        ("sales manager", ["Marlowe Motors", "Port Hollis Marine Supply"]),
        ("startup", ["own company"]),
        ("founder", ["own company"]),
        ("welder", ["Port Hollis Shipyard", "Kestrel Builders"]),
        ("landscap", ["Greenline Landscaping", "self-employed"]),
        ("poultry", ["Cane Creek Poultry"]),
        ("security guard", ["Allied Coastal Security"]),
        ("call center", ["Harborview Call Center"]),
        ("server", ["The Brickyard Grill", "Pell Avenue Diner", "Harbor House Seafood"]),
        ("forklift", ["Harborview Distribution Center", "Tidewater Freight Logistics"]),
        ("gas station", ["Pell Avenue Quik Stop"]),
        ("army", ["U.S. Army"]),
        ("navy", ["U.S. Navy"]),
        ("rideshare", ["self-employed (rideshare apps)"]),
        ("manager", ["Marlowe Boulevard Home Goods", "Cane Creek Hardware"]),
        ("aide", ["Cane Creek Home Care", "Bayard Rehabilitation and Nursing"]),
        ("high school", ["Hollis County High School"]),
        ("student", ["Hollis Community College", "East Carolina University"]),
        ("police", ["Port Hollis Police Department"]),
        ("council", ["Port Hollis City Council"]),
        ("financial", ["Harbor Point Wealth Advisors", "Tidewater Financial Group"]),
        ("bank", ["First Coastal Bank", "Tidewater Savings and Loan"]),
        ("restaurant owner", ["self-owned restaurant"]),
        ("restaurant", ["The Brickyard Grill", "Harbor House Seafood"]),
        ("programmer", ["self-employed (freelance)"]),
        ("it ", ["Hollis Regional Medical Center", "Pinewood Analytics", "Tidewater Freight Logistics"]),
        ("payroll", ["Tidewater Freight Logistics", "Harborview Distribution Center"]),
        ("store", ["Marlowe Boulevard Home Goods", "Cane Creek Hardware"]),
        ("caregiver", ["Cane Creek Home Care", "self-employed"]),
        ("treasurer", ["Ashby & Greer, CPAs"]),
        ("nurs", ["Hollis Regional Medical Center", "Bayard Rehabilitation and Nursing", "Cane Creek Home Care"]),
        ("health", ["Cane Creek Home Care", "Hollis Regional Medical Center"]),
        ("dental", ["Wexley Family Dentistry"]),
        ("warehouse", ["Harborview Distribution Center", "Tidewater Freight Logistics"]),
        ("driver", ["Tidewater Freight Logistics", "Coastal Courier Services"]),
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
        ("account", ["Ashby & Greer, CPAs"]),
        ("contractor", ["self-employed"]),
        ("poultry farm", ["Cane Creek Poultry"]),
        ("farm", ["self-employed (family farm)"]),
        ("mechanic", ["Juniper Court Auto Repair"])
    ]

    private static let generalEmployers = ["Harborview Distribution Center", "Cane Creek Poultry", "Port Hollis Marine Supply",
                                           "Marlowe Boulevard Home Goods", "Tidewater Freight Logistics", "The Brickyard Grill"]

    private static let pastJobs = ["line cook", "warehouse worker", "landscaper", "retail associate", "poultry plant worker",
                                   "security guard", "delivery driver", "call center representative", "roofer", "server",
                                   "forklift operator", "gas station clerk", "Army infantryman (honorably discharged)"]

    /// Earlier jobs that lead to a career, so a deputy's past isn't a poultry line.
    private static let careerPaths: [([String], [(String, String)])] = [
        (["sheriff", "police", "sergeant", "detective", "officer"], [("Detention officer", "Hollis County Detention Center"), ("Patrol officer", "Bayard Police Department"), ("Military police", "U.S. Army")]),
        (["teacher", "principal"], [("Teacher assistant", "Hollis County Schools"), ("Substitute teacher", "Hollis County Schools")]),
        (["nurs", "therap", "medical", "aide"], [("Certified nursing assistant", "Bayard Rehabilitation and Nursing"), ("Patient care technician", "Hollis Regional Medical Center")]),
        (["software", "analyst", "engineer"], [("Help desk technician", "Hollis Regional Medical Center"), ("IT support specialist", "Tidewater Freight Logistics")]),
        (["account", "treasurer", "bookkeep", "payroll"], [("Bookkeeper", "Cane Creek Hardware"), ("Accounts payable clerk", "Harborview Distribution Center")]),
        (["sales", "pharmaceutical", "real estate", "dealership"], [("Car salesperson", "Marlowe Motors"), ("Retail associate", "Marlowe Boulevard Home Goods")]),
        (["inspector", "contractor", "electric", "hvac", "welder", "construction"], [("Carpenter", "Kestrel Builders"), ("Apprentice", "Ridgeview Electrical Contractors")]),
        (["dental"], [("Dental assistant", "Wexley Family Dentistry")]),
        (["executive assistant", "secretary"], [("Receptionist", "Ashby & Greer, CPAs"), ("Office assistant", "Pinewood Analytics")]),
        (["founder", "ceo", "executive"], [("Product manager", "Pinewood Analytics"), ("Management consultant", "self-employed")]),
    ]

    private static func employer(for title: String, rng: inout SeededRNG) -> String {
        let lower = title.lowercased()
        // Whole words only ("bus" is not "business"), and the specific kind of work before the general one,
        // so a dental office manager works at a dental office, not a store.
        func matches(_ key: String) -> Bool {
            lower.range(of: "\\b" + NSRegularExpression.escapedPattern(for: key), options: .regularExpression) != nil
        }
        let general: Set<String> = ["manager", "store", "retail", "driver", "student", "college", "health", "contractor", "aide",
                                    "trainer", "server", "it ", "account", "financial", "construction"]
        for (key, list) in employersByKeyword where !general.contains(key) && matches(key) { return rng.pick(list) }
        for (key, list) in employersByKeyword where general.contains(key) && matches(key) { return rng.pick(list) }
        // No employer that obviously fits: a generic one only for generic work, otherwise self-employed.
        return ["worker", "laborer", "associate", "clerk", "helper"].contains(where: lower.contains) ? rng.pick(generalEmployers) : "self-employed"
    }

    /// The same person always gets the same history.
    static func make(for defendant: Defendant, county: County, year: Int? = nil, family known: FamilyFacts = FamilyFacts()) -> DefendantProfile {
        let bytes = withUnsafeBytes(of: defendant.personID.uuid) { Array($0) }
        let seed = bytes.prefix(8).reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
        var rng = SeededRNG(seed: seed | 1)
        // Split a compound occupation into the main role, a part-time job, and a former job:
        // "college senior and part-time restaurant server", "gym trainer and former bouncer".
        var role = defendant.occupation.lowercasedPhrase
        var partTime: String?
        var former: String?
        if let r = role.range(of: " and part-time ") { partTime = String(role[r.upperBound...]); role = String(role[..<r.lowerBound]) }
        if let r = role.range(of: " and former ") { former = String(role[r.upperBound...]); role = String(role[..<r.lowerBound]) }
        for prefix in ["unemployed former ", "former "] where role.hasPrefix(prefix) {
            former = String(role.dropFirst(prefix.count)); role = "unemployed"
        }
        for prefix in ["city council candidate and ", "volunteer treasurer and "] where role.hasPrefix(prefix) {
            role = String(role.dropFirst(prefix.count))
        }
        let occupation = role
        let lower = role
        let background = defendant.background
        let age = defendant.age
        let currentYear = year ?? Calendar.current.component(.year, from: Date())
        let birthYear = currentYear - age
        // Everything random is laid out as of the person's first appearance in this court and counted from the
        // birth year, so a returning defendant has the same history in every case, whatever year it is now.
        let anchorYear = min(currentYear, defendant.history.map { Calendar.current.component(.year, from: $0.date) }.min() ?? currentYear)
        let anchorAge = anchorYear - birthYear
        let bg = background.lowercased()
        var jobs: [Job] = []
        let unemployed = lower.contains("unemployed")
        let highSchool = lower.hasPrefix("high school")
        let student = highSchool || lower.contains("student") || lower.hasPrefix("college ") || lower.hasPrefix("university ")
        let schoolYear = ["freshman": "First-year", "sophomore": "Second-year", "junior": "Third-year", "senior": "Fourth-year"]
            .first { lower.contains($0.key) }?.value
        let retired = lower.hasPrefix("retired ")
        let has = { (keys: [String]) in keys.contains(where: lower.contains) }

        // Education first: it decides when a career can begin. Every year below is counted from the birth year.
        func grad(_ years: Int) -> Int { min(birthYear + years, currentYear) }
        // Graduation at about eighteen, unless the background says otherwise.
        let hsYear = grad(18)
        let diploma: String
        if bg.contains("ged in prison") {
            diploma = "GED, earned while incarcerated"
        } else if bg.contains("graduated at twenty-five") {
            diploma = "High school diploma through an adult high school program, \(grad(25))"
        } else if bg.contains("finished school at night") {
            diploma = "High school diploma, earned in night classes, \(grad(19))"
        } else {
            diploma = "High school diploma, \(hsYear)"
        }
        let education: String
        var careerAge = 18
        if highSchool {
            education = lower.contains("senior") ? "Senior at Hollis County High School; expected to graduate in \(currentYear + 1)." : "Currently enrolled at Hollis County High School."
        } else if student {
            let school = lower.contains("community college") ? "Hollis Community College" : (schoolYear != nil || lower.contains("college") ? "East Carolina University" : "Hollis Community College")
            let field = lower.contains("computer science") ? " in computer science" : ""
            education = "\(schoolYear.map { "\($0) student" } ?? "Currently enrolled")\(field) at \(school); high school diploma, Hollis County High School, \(min(hsYear, currentYear))."
        } else if has(["nurse practitioner"]) {
            careerAge = 26
            education = "BSN, East Carolina University, \(grad(22)); Master of Science in Nursing, \(grad(26))."
        } else if has(["physical therapist"]) {
            careerAge = 25
            education = "Bachelor's degree, \(grad(22)); Doctor of Physical Therapy, East Carolina University, \(grad(25))."
        } else if has(["dental hygienist"]) {
            careerAge = 20
            education = "Associate degree in dental hygiene, Hollis Community College, \(grad(20))."
        } else if bg.contains("ged in prison") {
            careerAge = 20
            education = "\(diploma); associate degree, Hollis Community College, \(grad(max(20, anchorAge - rng.int(1...3))))."
        } else if bg.contains("graduated at twenty-five") {
            careerAge = 16
            education = "Left high school without finishing; \(diploma.prefix(1).lowercased() + diploma.dropFirst())."
        } else if has(["nursing assistant", "aide", "caregiver"]) {
            careerAge = 19
            education = "\(diploma); nurse aide certificate, Hollis Community College, \(hsYear + 1)."
        } else if has(["software", "engineer", "account", "cpa", "founder", "ceo", "executive", "pharmaceutical", "teacher", "real estate", "sales manager"]) {
            careerAge = 22
            education = "Bachelor's degree from \(rng.pick(["East Carolina University", "UNC Wilmington", "NC State University"])), \(grad(22))."
        } else if has(["police", "sheriff", "sergeant", "deputy", "officer", "detention"]) {
            careerAge = 21
            education = "Associate degree in criminal justice, Hollis Community College, \(grad(20)); Basic Law Enforcement Training, \(grad(21))."
        } else if has(["electric", "hvac", "welder", "mechanic", "machinist", "massage"]) {
            careerAge = 19
            education = "\(diploma); vocational certificate, Hollis Community College, \(hsYear + 1)."
        } else if bg.contains("finished school at night") {
            education = "\(diploma)."
        } else if background.contains("finish high school") {
            education = "High school diploma, Hollis County High School, \(hsYear)."
        } else if background.contains("community college") {
            education = "\(diploma); some college at Hollis Community College."
        } else {
            switch rng.int(0...5) {
            case 0, 1: education = "High school diploma, Hollis County High School, \(hsYear)."
            case 2: education = "GED, earned at Hollis Community College, \(grad(min(rng.int(18...24), max(18, anchorAge))))."
            case 3: careerAge = 16; education = "Left school in the 10th grade, \(grad(16))."
            case 4 where anchorAge >= 20: careerAge = 20; education = "Associate degree in applied science, Hollis Community College, \(grad(20))."
            default: education = "High school diploma, \(hsYear); some college, withdrew after two semesters."
            }
        }

        careerAge = min(careerAge, max(16, anchorAge - 1))

        // Time in prison on a prior felony, from the record: no job overlaps it.
        var custody: [(start: Int, end: Int)] = []
        for prior in defendant.priors where prior.ncClass.isFelony && prior.sentence.contains("active") {
            let months = Int(prior.sentence.prefix { $0.isNumber }) ?? 12
            custody.append((prior.year, prior.year + max(1, Int((Double(months) / 12).rounded()))))
        }
        let lastRelease = custody.map { $0.end }.max() ?? 0
        func clear(_ start: Int, _ end: Int) -> Bool { !custody.contains { start < $0.end && end > $0.start } }

        // Service the background mentions appears in the work history, before civilian jobs.
        let service: [(key: String, title: String, employer: String, years: Int)] = [
            ("Navy", "U.S. Navy (honorably discharged)", "U.S. Navy", 4),
            ("medically discharged", "U.S. Army (medical discharge)", "U.S. Army", 1),
            ("Afghanistan", "U.S. Army infantry (honorably discharged)", "U.S. Army", 6),
            ("Marine Corps", "U.S. Marine Corps", "U.S. Marine Corps", 6),
            ("Air Force", "Aircraft mechanic, U.S. Air Force", "U.S. Air Force", 4),
            ("Coast Guard", "U.S. Coast Guard", "U.S. Coast Guard, Station Wilmington", 3),
            ("EMT", "Emergency medical technician", "Hollis County EMS", 4),
            ("corrections officer", "Correctional officer", "N.C. Department of Adult Correction", 3),
            ("long-haul", "Long-haul truck driver", "Tidewater Freight Logistics", 8),
            ("fishing boats in Alaska", "Deckhand", "Commercial fishing fleet, Alaska", 3),
            ("textile plant", "Line supervisor", "Dunmore Mills Textiles", 10),
            ("carnival", "Carnival ride operator", "Coastal Amusements", 5),
            ("call center", "Customer service representative", "Charlotte bank call center", 5)
        ]
        // Shortened if need be so it fits between eighteen and the current job.
        let stint = student ? nil : service.first(where: { background.contains($0.key) })
            .map { (title: $0.title, employer: $0.employer, years: min($0.years, max(1, anchorAge - 20))) }

        // Work history, laid out backward from the first appearance without overlaps.
        var timeline: [(start: Int, job: Job)] = []
        let careerStart = birthYear + careerAge
        let firstWork = birthYear + 16
        // The current job starts after any service the background describes.
        let afterService = stint.map { birthYear + 18 + $0.years + 1 } ?? 0
        var cursor = anchorYear
        if student, let job = partTime {
            let start = max(firstWork, anchorYear - rng.int(0...2))
            timeline.append((start, Job(title: "Part-time \(job)", employer: employer(for: job, rng: &rng), years: "\(start)–present", current: true)))
        } else if student {
            if rng.chance(0.45) {
                let (title, place) = rng.pick([("Part-time cashier", "Pell Avenue Quik Stop"), ("Part-time line cook", "The Brickyard Grill"),
                                               ("Weekend lifeguard", "Hollis County Parks and Recreation"), ("Part-time stocker", "Cane Creek Hardware")])
                let start = max(firstWork, anchorYear - rng.int(0...2))
                timeline.append((start, Job(title: title, employer: place, years: "\(start)–present", current: true)))
            }
        } else if retired {
            let base = String((occupation.components(separatedBy: ",").first ?? occupation).dropFirst("retired ".count))
            let left = min(currentYear - 1, birthYear + rng.int(58...66))
            let start = max(careerStart, left - rng.int(15...32))
            timeline.append((start, Job(title: base.capitalizedFirst, employer: employer(for: base, rng: &rng),
                                        years: "\(start)–\(left) (retired)", current: false)))
            cursor = start
        } else if !unemployed {
            let base = occupation.components(separatedBy: ",").first ?? occupation
            let earliest = min(max(careerStart, lastRelease, firstWork, afterService), anchorYear)
            let start = max(earliest, anchorYear - rng.int(1...12))
            timeline.append((start, Job(title: base.capitalizedFirst, employer: employer(for: base, rng: &rng),
                                        years: "\(min(start, currentYear))–present", current: true)))
            if let job = partTime {
                let sideStart = max(start, anchorYear - rng.int(1...3))
                timeline.append((sideStart, Job(title: "Part-time \(job)", employer: employer(for: job, rng: &rng), years: "\(sideStart)–present", current: true)))
            } else if rng.chance(0.3) && !has(["owner", "founder", "ceo", "therapist", "practitioner", "sergeant", "sheriff"]) {
                let side = rng.pick(["weekend server", "weekend security guard", "weekend delivery driver", "part-time rideshare driver"])
                let sideEmployer: String = switch side {
                case "weekend server": rng.pick(["The Lantern Row Tavern", "Pell Avenue Diner"])
                case "weekend security guard": "Allied Coastal Security"
                case "weekend delivery driver": "Coastal Courier Services"
                default: "self-employed (rideshare apps)"
                }
                let sideStart = max(start, anchorYear - rng.int(1...3))
                timeline.append((sideStart, Job(title: side, employer: sideEmployer, years: "\(sideStart)–present", current: true)))
            }
            cursor = start - rng.int(0...1)
        } else {
            cursor = anchorYear - rng.int(0...2)
        }
        let unemployedSince = cursor
        if !student {
            if let stint, cursor - stint.years >= birthYear + 18, clear(cursor - stint.years, cursor) {
                timeline.append((cursor - stint.years, Job(title: stint.title, employer: stint.employer,
                                                           years: "\(cursor - stint.years)–\(cursor)", current: false)))
                cursor -= stint.years
            }
            var formerPending = former
            for _ in 0..<rng.int(1...3) {
                // Step back past any prison term that ends at or after the cursor.
                if let term = custody.first(where: { $0.start < cursor && $0.end >= cursor - 1 }) { cursor = term.start }
                let length = rng.int(1...4)
                var start = cursor - length
                if let term = custody.first(where: { start < $0.end && cursor > $0.start }) { start = term.end }
                guard start >= firstWork, start < cursor, clear(start, cursor) else { break }
                let job: Job
                if let earlier = formerPending, start >= birthYear + 18 {
                    // The job the occupation says they used to have comes first.
                    job = Job(title: earlier.capitalizedFirst, employer: employer(for: earlier, rng: &rng), years: "\(start)–\(cursor)", current: false)
                    formerPending = nil
                } else if let path = careerPaths.first(where: { $0.0.contains(where: lower.contains) }), start >= birthYear + 18 {
                    let (title, place) = rng.pick(path.1)
                    job = Job(title: title, employer: place, years: "\(start)–\(cursor)", current: false)
                } else {
                    let past = rng.pick(pastJobs.filter { !$0.contains("Army") || start >= birthYear + 18 })
                    job = Job(title: past.capitalizedFirst, employer: employer(for: past, rng: &rng), years: "\(start)–\(cursor)", current: false)
                }
                timeline.append((start, job))
                cursor = start - rng.int(0...1)
            }
        }
        for term in custody where term.end > firstWork {
            timeline.append((term.start, Job(title: "In custody", employer: "N.C. Department of Adult Correction",
                                             years: "\(term.start)–\(min(term.end, currentYear))", current: false)))
        }
        if unemployed, let last = timeline.filter({ !$0.job.current && $0.job.title != "In custody" }).max(by: { $0.start < $1.start }) {
            timeline.append((currentYear + 1, Job(title: "Unemployed", employer: "since leaving \(last.job.employer)",
                                                  years: "\(unemployedSince + 1 > currentYear ? currentYear : unemployedSince + 1)–present", current: true)))
        }
        jobs = timeline.sorted { $0.start > $1.start }.map { $0.job }

        // Family fits the person's age, the background, and whatever the case itself says about spouse and children.
        var facts = known
        facts.merge(FamilyFacts.from(background: background))
        let family: String
        if (student || age < 20) && facts.minChildren == 0 && facts.status == nil {
            family = rng.pick(["Single, no children.", "Single, no children.", "In a relationship, no children."])
        } else {
            let maxChildren = max(facts.minChildren, min(3, max(0, (age - 18) / 4)))
            let drawn = maxChildren == 0 ? 0 : rng.int(0...maxChildren)
            let children = facts.exactChildren ?? max(facts.minChildren, drawn)
            var statuses = ["Single", "In a long-term relationship"]
            if age >= 21 { statuses += ["Married", "Married"] }
            if age >= 25 { statuses += ["Divorced", "Separated"] }
            if age >= 55 { statuses.append("Widowed") }
            let status = facts.status ?? rng.pick(statuses)
            let support = facts.paysSupport
                || (children > 0 && ["Divorced", "Separated", "Single"].contains(status) && rng.chance(0.5))
            family = status + (children == 0 ? ", no children." : ", \(children) child\(children == 1 ? "" : "ren")" + (support ? ", pays child support." : "."))
                + (facts.note.map { " " + $0 } ?? "")
        }

        // Where the defendant lives agrees with the background and the person's age.
        let town = county.towns.first { background.contains($0) } ?? (background.contains("Port Hollis") ? "Port Hollis" : rng.pick(county.towns))
        let street = rng.pick(NameBank.streets)
        let residence: String
        if background.contains("same apartment") {
            residence = "Rents an apartment on \(street) in \(town)."
        } else if highSchool {
            residence = background.contains("foster care") ? "Lives with a foster family in \(town)." : "Lives with family on \(street) in \(town)."
        } else if student {
            residence = rng.pick(["Lives in student housing.", "Lives with family on \(street) in \(town)."])
        } else {
            var options = ["Rents an apartment on \(street) in \(town).", "Rents a room from a friend in \(town)."]
            if age >= 25 { options.append("Owns a small house on \(street) in \(town).") }
            if age < 30 { options.append("Lives with a parent on \(street) in \(town).") }
            if unemployed || rng.chance(0.3) { options.append("Has moved three times in the past year; most recently staying with family in \(town).") }
            residence = rng.pick(options)
        }

        // Income fits the job.
        let income: String
        if unemployed {
            income = "No reported income."
        } else if retired {
            income = "Retirement income of about $\(rng.int(24...52)),000 a year."
        } else if student {
            income = jobs.isEmpty ? "No income; supported by family." : "Part-time income under $\(rng.int(4...11)),000 a year."
        } else if has(["dealership", "founder", "ceo"]) {
            income = "Reported income about $\(rng.int(180...420)),000 a year."
        } else if has(["nurse practitioner", "physical therapist", "software", "engineer", "pharmaceutical", "real estate", "account", "executive"]) {
            income = "Reported income about $\(rng.int(62...115)),000 a year."
        } else if has(["police", "sheriff", "sergeant", "deputy", "teacher", "electric", "hvac", "welder", "machinist", "manager", "inspector", "dental", "owner", "systems administrator"]) {
            income = "Reported income about $\(rng.int(42...72)),000 a year."
        } else {
            income = "Reported income about $\(rng.int(18...38)),000 a year."
        }
        return DefendantProfile(jobs: jobs, education: education, family: family, residence: residence, income: income)
    }
}


// MARK: - Investigation reports

enum Investigations {

    /// A step the investigation skipped, and how the defense raises it with the lead investigator.
    struct Gap {
        let finding: String
        let question: String
        let answer: String
    }

    /// A kind of gap, written with tokens so it reads differently case to case.
    private struct GapSeed {
        var settings: Set<CaseSetting> = []
        var origins: Set<CaseOrigin> = []
        /// One of these words must appear in the case (empty means any).
        var needs: [String] = []
        /// None of these words may appear in the case.
        var unless: [String] = []
        /// Only when who did it is in dispute.
        var identity = false
        let findings: [String]
        let questions: [String]
        /// Any answer must fit any of the questions.
        let answers: [String]
    }

    private static let gapSeeds: [GapSeed] = [
        // Scenes
        // What the cameras couldn't see, not cameras the police forgot: footage gets pulled.
        GapSeed(settings: [.scene], origins: [.call, .report], unless: ["surveillance", "footage", "camera", "video"], identity: true,
                findings: ["Video from {NEARBY} was collected the next morning; the camera faces the lot, and {STREET} is at the edge of the frame.",
                           "A doorbell camera across {STREET} was downloaded, but the porch light washes out the far side of the street at night."],
                questions: ["The camera at {NEARBY} doesn't actually show {STREET}, does it?",
                            "You can't see a face on that doorbell video, can you?"],
                answers: ["Not all of it. We got everything that system recorded, and it shows what it shows.",
                          "Not a face, no. It shows the movement and the timing, and that matched the rest of the evidence."]),
        GapSeed(settings: [.scene], identity: true,
                findings: ["No fingerprints were lifted from {SURFACE}.", "{SURFACE} was never processed for prints or touch DNA."],
                questions: ["Nobody processed {SURFACE} for fingerprints?", "Did anyone swab or dust {SURFACE}?",
                            "If {DL} touched {SURFACE}, you'd have prints. Did you even look?"],
                answers: ["No. In my judgment the surface wouldn't hold a usable print.",
                          "It wasn't done. The technician thought the surface was too rough.",
                          "No, and I can't tell you today what it would have shown."]),
        GapSeed(settings: [.scene], origins: [.call], identity: true,
                findings: ["The neighborhood canvass reached {N} of about {M} homes and businesses on {STREET}.",
                           "Officers knocked on {N} doors on {STREET}, then stopped the canvass that night."],
                questions: ["Your canvass covered {N} doors. Out of how many?", "Why did the canvass stop at {N} doors?",
                            "So most of {STREET} was never asked what they saw?"],
                answers: ["About {M}. We prioritized the ones with a view.",
                          "We went back the next day for a few. Not all of them.",
                          "We talked to the people closest to it. I won't say it was every door."]),
        GapSeed(settings: [.scene, .drugs, .road], origins: [.call, .stop],
                findings: ["{OFF}'s handwritten notes from that night were not kept; only the typed report survives.",
                           "The first officer's field notes were discarded after the typed report was written."],
                questions: ["Where are the first officer's handwritten notes?", "The notes written that night are gone, aren't they?"],
                answers: ["They weren't kept. The typed report was written from them.",
                          "Department practice at the time was to discard them once the report was typed. That's changed since."]),
        GapSeed(settings: [.scene, .drugs], identity: true,
                findings: ["A Crime Stoppers tip naming {ALT} was logged on {TIPDAY} and never followed up.",
                           "An anonymous caller named {ALT}; the tip sheet shows no follow-up."],
                questions: ["You got a tip naming {ALT}. What did you do with it?", "Did anyone ever knock on {ALT}'s door?",
                            "Who is {ALT}, and why didn't you find out?"],
                answers: ["It was logged. We had already developed our suspect by then.",
                          "We ran the name. Nothing in it lined up, so we didn't go further.",
                          "No one interviewed {ALT}. In hindsight we should have."]),
        GapSeed(settings: [.scene], needs: ["gun", "pistol", "shot", "firearm", "rifle"],
                findings: ["Gunshot residue samples were never taken from {DL}'s hands or anyone else present.",
                           "No gunshot residue kit was collected that night."],
                questions: ["No one tested anyone's hands for gunshot residue?", "Why wasn't a GSR kit collected?"],
                answers: ["The lab stopped analyzing GSR kits for most cases years ago, so we don't routinely collect them.",
                          "It wasn't done. By the time we had a suspect, too much time had passed."]),
        GapSeed(settings: [.scene], origins: [.call], needs: ["911"],
                findings: ["The full 911 audio was never requested; only the CAD printout is in the file."],
                questions: ["Did you ever listen to the 911 call itself?", "The file has a CAD printout. Where's the audio?"],
                answers: ["I read the CAD notes. I didn't pull the audio.", "We have the dispatcher's summary. The recording wasn't requested."]),
        GapSeed(settings: [.scene], needs: ["lineup", "photo array", "identif"],
                findings: ["The photo lineup was run by an officer who knew which photo was {DL}'s."],
                questions: ["The officer who ran the lineup knew who the suspect was, didn't they?",
                            "Was the lineup administered blind, as the Eyewitness Identification Reform Act requires?"],
                answers: ["It wasn't a blind administrator. We used a folder shuffle instead.",
                          "The officer knew. The procedure we used is an allowed alternative under the statute."]),
        // Roads
        GapSeed(settings: [.road], needs: ["breath", "blew", "intoxilyzer"],
                findings: ["The 15-minute observation period before the breath test is logged only as a start and end time.",
                           "No one documented who watched {DL} during the observation period before the Intoxilyzer test."],
                questions: ["Who watched {DL} for the fifteen minutes before the breath test?",
                            "Can you tell the court {DL} didn't belch or put anything in their mouth during the observation period?",
                            "The observation period is two times on a form. That's all, isn't it?"],
                answers: ["The operator did. It's documented by the start and end times, which is what the form calls for.",
                          "I wasn't the operator. The form shows the period was observed.",
                          "The times are on the form. Beyond that I'd be guessing."]),
        GapSeed(settings: [.road], needs: ["blood"],
                findings: ["Blood was drawn about {HOURS} hours after the crash, and no one calculated what the level would have been at the time of driving.",
                           "No retrograde extrapolation was done to relate the blood result back to the time of the crash."],
                questions: ["The blood was drawn {HOURS} hours later. What was {DL}'s level at the time of driving?",
                            "Nobody did a retrograde extrapolation, did they?", "Why did the blood draw take {HOURS} hours?"],
                answers: ["The draw waited on the search warrant and the hospital. No extrapolation was requested.",
                          "I can't give you a number at the time of driving. The lab result is what it is at the time of the draw.",
                          "We got the warrant as fast as we could on a holiday weekend. That's how long it took."]),
        GapSeed(settings: [.road], needs: ["walk-and-turn", "field sobriety", "sobriety", "hgn", "one-leg", "impair", "weaving"], unless: ["blood"],
                findings: ["The field sobriety tests were given on the sloped shoulder of {ROADNAME}, in {LIGHT}.",
                           "The dash camera does not show the walk-and-turn test; {DL} was off-frame."],
                questions: ["Where exactly did you give the walk-and-turn test?", "The camera never shows the field tests, does it?",
                            "You'd agree a sloped shoulder at night isn't a standardized testing surface?"],
                answers: ["On the shoulder. It was the safest flat-ish spot available.",
                          "Part of it is off-frame. I wrote down what I saw.",
                          "It wasn't ideal. The clues I saw weren't about balance on a slope."]),
        GapSeed(settings: [.road], needs: ["crash", "struck", "collision", "rear-ended", "hit"],
                findings: ["The airbag control module (the car's \"black box\") was never downloaded.",
                           "No one downloaded the crash data from either vehicle."],
                questions: ["The car's event data recorder would show speed and braking. Did anyone pull it?",
                            "Where's the black box data?"],
                answers: ["It wasn't downloaded. The reconstruction relied on the scene measurements.",
                          "We didn't have the equipment that night, and the vehicle was released before anyone went back."]),
        GapSeed(settings: [.road], needs: ["crash", "struck", "collision", "killed", "pedestrian", "cyclist"],
                findings: ["No one evaluated whether the other driver's speed, lighting, or conduct contributed to the crash.",
                           "The other vehicle was never inspected for mechanical problems."],
                questions: ["Did anyone look at what the other driver was doing?", "So the investigation assumed {DL} caused the crash from the start?"],
                answers: ["The evidence put the cause on {DL}'s side of the road. We didn't go further than that.",
                          "We looked at the scene. A full reconstruction of the other vehicle wasn't done."]),
        GapSeed(settings: [.road], needs: ["bar", "tab", "drinks", "drinking"],
                findings: ["No one interviewed the bartender or matched the receipts to the time {DL} left."],
                questions: ["Did you ever talk to the bartender?", "When did {DL} actually leave the bar? Do you know?"],
                answers: ["No. The receipts were enough for our purposes.", "We know when the tab was closed. Not exactly when {DL} walked out."]),
        GapSeed(settings: [.road], origins: [.stop],
                findings: ["The dash camera began recording only after the patrol car's blue lights were activated, so the driving that prompted the stop is not on video."],
                questions: ["The driving you say you saw isn't on the video, is it?", "When did your camera start recording?"],
                answers: ["It starts with the blue lights. The driving before that is my observation.",
                          "The camera caught the stop. The weaving before it, no."]),
        // Drugs
        GapSeed(settings: [.drugs],
                findings: ["The bags were never processed for fingerprints or DNA.", "No one swabbed the packaging to show who handled it."],
                questions: ["Nobody printed or swabbed the bags, did they?", "How do you know {DL}'s hands ever touched that packaging?"],
                answers: ["No. The lab doesn't process drug packaging for prints in a case like this.",
                          "We rely on where it was found and who was there. The packaging wasn't swabbed."]),
        GapSeed(settings: [.drugs],
                findings: ["Only one of the {N} packages was chemically analyzed; the rest were weighed and described.",
                           "The laboratory tested a single sample and weighed the rest in aggregate."],
                questions: ["The lab tested one of {N} bags. The rest are assumptions, aren't they?", "How many of the bags were actually tested?"],
                answers: ["One was analyzed. The others were consistent in appearance and weighed.",
                          "That's the lab's sampling practice. I'd defer to the chemist on the rest."]),
        GapSeed(settings: [.drugs], needs: ["passenger", "three people", "occupant", "others", "inside"],
                findings: ["The other people present were released at the scene and never interviewed.",
                           "No one else with access to the {CONTAINER} was ever questioned."],
                questions: ["Other people had access. Did you interview any of them?", "Why were the others allowed to leave?"],
                answers: ["Not formally. They weren't charged, and they left.", "We spoke to them briefly at the scene. That's all."]),
        GapSeed(settings: [.drugs], needs: ["informant", "controlled buy", "controlled buys"],
                findings: ["The confidential informant's payment and reliability records were not produced to the defense."],
                questions: ["How much was your informant paid?", "What's your informant's own record?"],
                answers: ["I'd have to check the file. The informant was paid per buy, which is standard.",
                          "The informant has a record. That's often how informants come to us."]),
        // Records
        GapSeed(settings: [.paper], needs: ["account", "invoice", "payroll", "deposit", "transfer", "ledger", "check"],
                findings: ["No forensic review was done of the records before {EARLY}, the first year charged.",
                           "Investigators reviewed only the months the complainant flagged."],
                questions: ["Nobody looked at the books before {EARLY}, did they?", "You reviewed only the months they told you to?"],
                answers: ["No. We focused on the period where the losses showed up.",
                          "We started with what was flagged and followed the money from there. Earlier years weren't reviewed."]),
        GapSeed(settings: [.paper], needs: ["login", "access", "admin", "system", "password", "employee", "staff"],
                findings: ["Other employees with the same system access were never interviewed.",
                           "Investigators never established who else knew the shared credentials."],
                questions: ["How many other people had access to that system? Did you talk to them?",
                            "Who else knew the password?"],
                answers: ["Several did. We interviewed {FEW}.", "We didn't pin that down for everyone. The logins pointed to {DL}."]),
        GapSeed(settings: [.paper], needs: ["approv", "advance", "authoriz", "board", "supervisor"],
                findings: ["{DL}'s explanation of the transactions was never checked against internal email.",
                           "No one searched the organization's email for the approvals {DL} says exist."],
                questions: ["You never searched the email for the approvals my client says exist?",
                            "Did anyone ask the board for its own records of what it approved?"],
                answers: ["We asked the organization. They said there weren't any.",
                          "We relied on what management gave us. We didn't image the mail server."]),
        GapSeed(settings: [.paper], needs: ["ip", "login", "vpn", "server", "wallet", "online", "email", "account"],
                findings: ["The internet provider's logs for the key dates were never subpoenaed.",
                           "No one checked whether {DL}'s credentials had been phished or reused in a data breach."],
                questions: ["Did anyone check whether my client's password had been stolen?",
                            "The IP address is a household connection. Who else lived there?"],
                answers: ["We found no sign of compromise. We didn't run a full breach search.",
                          "Others could have used the connection. The activity matched {DL}'s devices, though."]),
        GapSeed(settings: [.paper],
                findings: ["Investigators worked from records the complainant chose to hand over; the full set was never subpoenaed.",
                           "No independent accountant reviewed the State's totals before trial."],
                questions: ["You worked from the records the complaining party gave you, didn't you?", "Did anyone outside your office check the totals?"],
                answers: ["At first. We subpoenaed more once we had cause.", "No outside review. Our analyst's work was checked internally."])
    ]

    // MARK: Building the file

    static func make(t: CaseTemplate, facts: CaseFacts, values: [String: String], incident: Date, sessionDate: Date,
                     detective: CastMember, officer: CastMember, evidence: [Evidence], defendant: Defendant,
                     charges: [Charge], victimName: String?, year: Int, rng: inout SeededRNG) -> (InvestigationReport, [Gap]) {
        let dl = defendant.lastName
        let street = values["STREET"] ?? "Harbor Street"
        let town = values["HOOD"] ?? "Port Hollis"
        let time = facts.setting == .paper ? nil : values["TIME"]
        let state = evidence.filter { $0.side == .prosecution }
        let forensic = state.filter { $0.kind == .forensic }
        // Only the defendant's own statement makes a defendant interview; a witness's statement doesn't.
        let statement = state.first { e in
            guard e.kind == .statement else { return false }
            let title = e.title.lowercased()
            return ["interview", "confession", "admission", "defendant"].contains { title.contains($0) } || title.contains(dl.lowercased())
        }
        let collected = state.filter { $0.kind == .physical || $0.kind == .forensic }
        let obtained = state.filter { $0.kind == .digital || $0.kind == .document || $0.kind == .video }
        let place = placePhrase(values: values, facts: facts, street: street, town: town)
        let abbreviation = detective.agency.split(separator: " ").compactMap { $0.first }.filter { $0.isLetter }.map(String.init).joined()
        let latest = CaseDates.add(-21, to: sessionDate)
        func clamp(_ d: Date) -> Date { min(d, latest) }

        var timeline: [InvestigationReport.Entry] = []
        var stamps: [Date] = []
        func log(_ date: Date, _ entry: InvestigationReport.Entry) {
            stamps.append(date)
            timeline.append(entry)
        }
        let arrival = time.map { Clock.shift($0, by: facts.origin == .stop ? 0 : rng.int(4...14)) }
        var assigned = CaseDates.add(1, to: incident)
        var arrest: Date
        var day = 1

        // How it began
        switch facts.origin {
        case .records:
            let reporter = victimName ?? organization(values) ?? "the reporting party"
            assigned = CaseDates.add(rng.int(2...9), to: incident)
            log(incident, .init(when: CaseDates.dayYear(incident), what: rng.pick([
                "Complaint received by \(detective.agency) from \(reporter).",
                "\(reporter.capitalizedFirst) reports suspected \(lossNoun(facts)) to \(detective.agency).",
                "\(detective.agency) opens a file after \(reporter) brings in \(facts.money ? "account statements" : "records and screenshots")."])))
            log(assigned, .init(when: CaseDates.day(assigned), what: "\(detective.display) assigned as lead investigator; preservation letters sent for \(facts.money ? "bank and business records" : "account, device, and provider records")."))
            day = CaseDates.days(from: incident, to: assigned)
            arrest = CaseDates.add(rng.int(45...150), to: incident)
        case .stop:
            log(incident, .init(when: "\(CaseDates.dayYear(incident)), \(time ?? "")",
                                  what: "\(officer.display) \(stopNarrative(facts, street: street, town: town, values: values))"))
            if !collected.isEmpty {
                log(incident, .init(when: "\(CaseDates.day(incident)), \(Clock.shift(time ?? "12:00 a.m.", by: rng.int(10...25)))",
                                      what: "\(collected.map(\.title).prefix(3).joined(separator: ", ")) \(collected.count == 1 ? "is" : "are") recovered from the vehicle and logged."))
            }
            if facts.impaired && facts.mentions(["breath", "blew", "intoxilyzer"]) {
                log(incident, .init(when: "\(CaseDates.day(incident)), \(Clock.shift(time ?? "12:00 a.m.", by: rng.int(48...75)))",
                                      what: "Breath test administered at the Hollis County Detention Center after a 15-minute observation period."))
            }
            arrest = incident
            assigned = incident
        case .warrant:
            let opened = CaseDates.add(-rng.int(18...45), to: incident)
            log(opened, .init(when: CaseDates.dayYear(opened), what: facts.setting == .drugs
                ? rng.pick(["Narcotics investigation opens after neighbor complaints about short-stay traffic on \(street).",
                            "\(detective.display) begins surveillance of a residence on \(street) in \(town)."])
                : "\(detective.display) develops information tying a residence on \(street) in \(town) to the investigation."))
            if facts.mentions(["controlled buy", "controlled buys"]) {
                let firstBuy = CaseDates.add(rng.int(4...9), to: opened)
                log(firstBuy, .init(when: CaseDates.day(firstBuy), what: "First controlled purchase by a confidential informant, recorded and field-tested."))
                let secondBuy = CaseDates.add(-rng.int(3...6), to: incident)
                log(secondBuy, .init(when: CaseDates.day(secondBuy), what: "Second controlled purchase."))
            }
            log(CaseDates.add(-1, to: incident), .init(when: CaseDates.day(CaseDates.add(-1, to: incident)), what: "Search warrant for the residence signed by a Superior Court judge."))
            log(incident, .init(when: "\(CaseDates.day(incident)), \(time ?? "early morning")",
                                  what: "Warrant executed at the residence on \(street). " + (collected.isEmpty ? "The house is searched." : "Seized: \(collected.map(\.title).prefix(3).joined(separator: ", ")).")))
            assigned = opened
            arrest = incident
        case .report:
            let reporter = victimName ?? "a member of the public"
            let reportDay = CaseDates.add(rng.int(0...3), to: incident)
            log(reportDay, .init(when: CaseDates.dayYear(reportDay), what: rng.pick([
                "\(reporter.capitalizedFirst) reports the incident to \(detective.agency); \(officer.display) takes the initial report.",
                "\(officer.display) takes a report from \(reporter) about events in \(town)."])))
            assigned = CaseDates.add(rng.int(1...3), to: reportDay)
            log(assigned, .init(when: CaseDates.day(assigned), what: "\(detective.display) assigned as lead investigator."))
            day = CaseDates.days(from: incident, to: assigned)
            arrest = CaseDates.add(rng.int(4...30), to: incident)
        case .call:
            log(incident, .init(when: "\(CaseDates.dayYear(incident)), \(time ?? "")",
                                  what: "Hollis County 911 Communications receives a call reporting \(incidentNoun(facts, charges: charges)) \(place)."))
            log(incident, .init(when: "\(CaseDates.day(incident)), \(arrival ?? "")",
                                  what: "\(officer.display) arrives, " + rng.pick(["secures the scene, and starts a body-camera recording.",
                                                                                 "checks on the people present, and calls for a supervisor.",
                                                                                 "requests EMS, separates the witnesses, and keeps the body camera running."])))
            if !collected.isEmpty {
                log(incident, .init(when: "\(CaseDates.day(incident)), overnight",
                                      what: "Scene photographed and processed; collected: \(collected.map(\.title).prefix(3).joined(separator: ", "))."))
            }
            let atScene = facts.setting == .road ? !facts.mentions(["didn't stop", "hit-and-run", "fled the scene", "drove away"]) : rng.chance(0.3)
            arrest = atScene ? incident : CaseDates.add(rng.int(2...40), to: incident)
            if atScene { assigned = incident }
            log(assigned, .init(when: CaseDates.day(assigned), what: "\(detective.display) assigned as lead investigator."))
        }

        // What was gathered, in order
        for item in obtained {
            day += rng.int(1...7)
            let when = CaseDates.add(day, to: incident)
            log(clamp(when), .init(when: CaseDates.day(clamp(when)), what: obtainedPhrase(item, rng: &rng)))
        }
        var labSubmitted: Date?
        var labReturned: Date?
        if !forensic.isEmpty {
            day += rng.int(1...4)
            let sent = clamp(CaseDates.add(day, to: incident))
            labSubmitted = sent
            log(sent, .init(when: CaseDates.day(sent), what: "Submitted to the State Crime Laboratory: \(forensic.map(\.title).joined(separator: ", "))."))
            labReturned = clamp(CaseDates.add(rng.int(18...70), to: sent))
        }
        if arrest < CaseDates.add(day, to: incident) && facts.origin != .stop && facts.origin != .warrant && arrest != incident {
            arrest = CaseDates.add(day + rng.int(1...6), to: incident)
        }
        arrest = clamp(arrest)

        // The interview and arrest
        let interview: Date? = statement == nil ? nil : (facts.origin == .records ? CaseDates.add(-rng.int(5...20), to: arrest) : arrest)
        if facts.origin == .records {
            if let interview {
                log(interview, .init(when: CaseDates.day(interview), what: "\(defendant.name) agrees to a recorded interview after Miranda warnings."))
            } else {
                let declined = CaseDates.add(-rng.int(5...20), to: arrest)
                log(declined, .init(when: CaseDates.day(declined), what: "\(defendant.name), through a lawyer, declines an interview."))
            }
        }
        let chargeList = charges.map { $0.law.title }.uniqued().joined(separator: ", ")
        log(arrest, .init(when: CaseDates.day(arrest), what: facts.origin == .records
            ? "\(defendant.name) charged with \(chargeList) and surrenders at the magistrate's office."
            : "\(defendant.name) arrested and charged with \(chargeList)."))
        if facts.origin != .records {
            log(arrest, .init(when: CaseDates.day(arrest), what: interview != nil
                ? "\(defendant.name) waives Miranda rights and gives a recorded statement to \(facts.origin == .stop ? officer.display : detective.display)."
                : "\(defendant.name) declines to answer questions and asks for a lawyer."))
        }
        if let back = labReturned {
            log(back, .init(when: CaseDates.day(back), what: "State Crime Laboratory report returned."))
        }
        // Keep the file in date order; entries on the same day stay in the order they happened.
        let order = stamps.indices.sorted { stamps[$0] != stamps[$1] ? stamps[$0] < stamps[$1] : $0 < $1 }
        timeline = order.map { timeline[$0] }

        let howIdentified = identification(facts: facts, t: t, dl: dl, state: state, victimName: victimName, officer: officer,
                                           arrestSameDay: arrest == incident, rng: &rng)

        // Gaps both sides will argue about
        var local = values
        local["NEARBY"] = rng.pick(["a pharmacy", "a gas station", "a laundromat", "a pawn shop", "an auto parts store", "a corner market", "a church"]) + " on \(street)"
        local["PLACESHORT"] = street
        local["SURFACE"] = rng.pick(["the door frame", "the counter", "the car door", "the railing", "the window ledge"])
        local["N"] = "\(rng.int(3...7))"
        local["M"] = "\(rng.int(14...30))"
        local["FEW"] = rng.pick(["two", "three", "one"])
        local["HOURS"] = rng.pick(["two and a half", "three", "nearly four"])
        local["ROADNAME"] = values["ROAD"] ?? street
        local["LIGHT"] = time.map { Clock.partOfDay($0) == "night" ? "the dark, lit by headlights" : "traffic going by" } ?? "traffic going by"
        local["CONTAINER"] = facts.origin == .stop ? "car" : "house"
        local["TIPDAY"] = CaseDates.day(CaseDates.add(rng.int(2...9), to: incident))
        local["EARLY"] = "\(year - rng.int(3...5))"
        local["OFF"] = officer.display
        let fill = TextFiller(values: local)
        let fitting = gapSeeds.filter { seed in
            (seed.settings.isEmpty || seed.settings.contains(facts.setting))
                && (seed.origins.isEmpty || seed.origins.contains(facts.origin))
                && facts.mentions(seed.needs)
                && !(seed.unless.contains { facts.text.contains($0) })
                && (!seed.identity || facts.identity)
        }
        let fallback = gapSeeds.filter { $0.settings.isEmpty || $0.settings.contains(facts.setting) }
        // Most investigations are done properly. Some leave one point for the defense, a few leave two.
        let roll = rng.int(1...20)
        let count = roll <= 8 ? 0 : (roll <= 17 ? 1 : 2)
        let chosen = count == 0 ? [] : rng.pick(fitting.count >= count ? fitting : fallback, count: count)
        let gaps = chosen.map { seed in
            Gap(finding: fill(rng.pick(seed.findings)), question: fill(rng.pick(seed.questions)), answer: fill(rng.pick(seed.answers)))
        }

        var interviews: [String] = []
        interviews.append(interview != nil ? "\(defendant.name) (recorded, after Miranda warnings)" : "\(defendant.name) declined to be interviewed")
        let warrants = state.filter { e in
            let detail = e.detail.lowercased()
            return (detail.contains("found") || detail.contains("recovered") || e.kind == .digital) && !detail.contains("consent")
        }
            .prefix(3).map { "Warrant covering \($0.phrase)" }
        let lab = forensic.map { "\($0.title): \($0.detail)" }

        let scene: String
        switch facts.setting {
        case .paper:
            scene = "No physical scene. The investigation centered on " + (facts.money ? "bank, business, and computer records." : "accounts, devices, and provider records.")
        case .road:
            scene = "\((values["ROAD"] ?? street).capitalizedFirst) near \(town): " + rng.pick([
                "tire marks measured, vehicle positions photographed, weather and lighting noted.",
                "a two-lane road, posted 45 mph, " + (Clock.partOfDay(time) == "night" ? "no streetlights." : "dry pavement."),
                "the roadway was photographed and marked before the vehicles were moved."])
        case .drugs:
            scene = facts.origin == .warrant
                ? "A residence on \(street) in \(town). Rooms were photographed before and after the search."
                : "\(street.capitalizedFirst) in \(town). The vehicle was photographed and inventoried."
        case .scene:
            scene = "\(place.capitalizedFirst). Lighting: \(Clock.partOfDay(time) == "night" ? rng.pick(["one working streetlight", "lit storefronts", "dark, no streetlights"]) : "daylight"). The area was photographed and measured before evidence was moved."
        }

        let sheet = CaseFactSheet(setting: facts.setting, incident: incident, time: time, place: place, street: street, town: town,
                                  arrivalTime: facts.origin == .call ? arrival : (facts.origin == .stop ? time : nil),
                                  assigned: assigned, arrest: arrest, interview: interview,
                                  labSubmitted: labSubmitted, labReturned: labReturned,
                                  agency: detective.agency, lead: detective.display, firstOfficer: officer.display)
        let report = InvestigationReport(agency: detective.agency, leadInvestigator: detective.display,
                                         reportNumber: "\(abbreviation)-\(String(format: "%02d", year % 100))-\(String(format: "%05d", rng.int(1_000...99_999)))",
                                         incident: facts.origin == .records ? "Reported \(CaseDates.dayYear(incident))" : "\(CaseDates.dayYear(incident))\(time.map { ", about \($0)" } ?? ""), \(place)",
                                         scene: scene, timeline: timeline, howIdentified: howIdentified,
                                         interviews: interviews, warrants: Array(warrants), lab: lab, notDone: gaps.map(\.finding),
                                         facts: sheet)
        return (report, gaps)
    }

    // MARK: Pieces

    private static func organization(_ values: [String: String]) -> String? {
        for key in ["CHARITY", "BIZ", "HOSP", "PHARM", "STORE2", "STORE"] { if let v = values[key] { return v } }
        return nil
    }

    static func placePhrase(values: [String: String], facts: CaseFacts, street: String, town: String) -> String {
        if facts.setting == .road, let road = values["ROAD"] { return "on \(road) near \(town)" }
        for key in ["BAR", "STORE", "STORE2", "BIZ", "PHARM", "COMPLEX", "LOT", "SCHOOL", "REST"] {
            if let v = values[key] { return "at \(v) on \(street) in \(town)" }
        }
        if let ch = values["CH"] { return "outside the \(ch) in \(town)" }
        return "near \(street) in \(town)"
    }

    private static func lossNoun(_ facts: CaseFacts) -> String {
        if facts.category == .cyber { return facts.money ? "a computer intrusion and theft" : "a computer crime" }
        if facts.key == "perjuryTrial" { return "false testimony" }
        return facts.money ? "theft of funds" : "fraud"
    }

    static func incidentNoun(_ facts: CaseFacts, charges: [Charge]) -> String {
        let law = charges.first?.lawID.lowercased() ?? ""
        switch facts.setting {
        case .road: return facts.mentions(["pedestrian", "cyclist", "crosswalk"]) ? "a person struck by a vehicle" : "a crash"
        case .drugs: return facts.mentions(["overdose", "unresponsive", "died"]) ? "an unresponsive person" : "suspected drug activity"
        default: break
        }
        if law.contains("robbery") { return "a robbery" }
        if law.contains("burglary") || law.contains("feloniousbe") { return "a break-in" }
        if law.contains("larceny") || law.contains("stolen") { return "a theft" }
        if law.contains("arson") || law.contains("burning") { return "a fire" }
        if law.contains("murder") || law.contains("manslaughter") { return facts.mentions(["shot", "gun"]) ? "shots fired and a person down" : "a person seriously hurt" }
        if law.contains("riot") || law.contains("disorderly") { return "a disturbance" }
        if facts.category == .violent || facts.category == .family { return facts.mentions(["gun", "shot", "pistol"]) ? "shots fired" : "an assault" }
        return "a disturbance"
    }

    private static func stopNarrative(_ facts: CaseFacts, street: String, town: String, values: [String: String]) -> String {
        let road = values["ROAD"] ?? street
        if facts.mentions(["fled", "accelerated", "pursuit", "chase", "flee"]) {
            return "attempts a traffic stop on \(road) near \(town); the vehicle accelerates away and a pursuit begins."
        }
        if facts.impaired {
            return "stops a vehicle on \(road) near \(town) after watching it cross the center line and the fog line; field sobriety tests follow."
        }
        return "stops a vehicle on \(road) near \(town) for a traffic violation and speaks with the driver, identified as the defendant."
    }

    private static func obtainedPhrase(_ item: Evidence, rng: inout SeededRNG) -> String {
        let title = item.title
        switch item.kind {
        case .video: return rng.pick(["\(title) collected and copied to the case file.", "\(title) obtained and preserved.", "\(title) downloaded and reviewed."])
        case .digital: return rng.pick(["\(title) obtained by search warrant.", "\(title) returned by the provider under a warrant.", "\(title) extracted and reviewed."])
        case .document: return rng.pick(["\(title) obtained by subpoena.", "\(title) produced to investigators.", "\(title) collected and reviewed."])
        default: return "\(title) obtained."
        }
    }

    private static func identification(facts: CaseFacts, t: CaseTemplate, dl: String, state: [Evidence], victimName: String?,
                                       officer: CastMember, arrestSameDay: Bool, rng: inout SeededRNG) -> String {
        let titles = state.map { $0.title.lowercased() }.joined(separator: " ")
        switch facts.origin {
        case .stop:
            return rng.pick(["Identity was never in question: \(dl) was the driver when \(officer.display) stopped the car.",
                             "\(dl) was behind the wheel at the stop and produced a license.",
                             "\(officer.display) identified \(dl) at the roadside from a driver's license."])
        case .warrant:
            return rng.pick(["Lease and utility records tied \(dl) to the residence, and \(dl) was present when the warrant was served.",
                             "\(dl) was inside when the warrant was executed; the lease is in \(dl)'s name.",
                             "Surveillance and records connected \(dl) to the house before the warrant was served."])
        case .records:
            if facts.key == "perjuryTrial" { return "Comparing \(dl)'s sworn testimony with phone records and messages showed the testimony was false." }
            if facts.category == .cyber {
                return rng.pick(["Server logs and account records traced the activity to devices and accounts associated with \(dl).",
                                 "Login records, IP addresses, and payment trails led back to \(dl).",
                                 "The account activity was traced to \(dl)'s credentials and home connection."])
            }
            return rng.pick(["The records traced the money to accounts associated with \(dl).",
                             "Bank records showed the funds landing in accounts \(dl) controlled.",
                             "An audit flagged the transactions, and the paperwork bore \(dl)'s name or credentials."])
        case .report:
            if let victimName { return "\(victimName) named \(dl) in the initial report." }
            return rng.pick(["The report itself identified \(dl).", "Witnesses named \(dl) when the report was taken."])
        case .call:
            if facts.setting == .road {
                if facts.mentions(["paint", "body shop", "debris"]) { return "Vehicle debris and paint transfer from the scene were matched to \(dl)'s vehicle." }
                if facts.mentions(["walked into", "came forward", "turned"]) { return "\(dl) came forward the next day with a lawyer." }
                return rng.pick(["\(dl) was at the scene, identified as the driver of one of the vehicles. Identity was not in dispute.",
                                 "The first officer identified \(dl) at the scene as the driver.",
                                 "\(dl) was still at the scene when officers arrived and was identified from a driver's license."])
            }
            if titles.contains("lineup") || titles.contains("identification") { return "A witness picked \(dl) from a photo lineup." }
            if titles.contains("pawn") { return "Pawn records listed an item under \(dl)'s name." }
            if titles.contains("video") || titles.contains("footage") || titles.contains("camera") {
                return rng.pick(["Video from the area showed someone matching \(dl); a patrol officer recognized \(dl) from the stills.",
                                 "Stills from the footage were circulated, and a tip named \(dl)."])
            }
            if arrestSameDay { return rng.pick(["\(dl) was detained at the scene when officers arrived.", "\(dl) was still there when the first officer arrived."]) }
            if let victimName, !facts.identity { return "\(victimName) knew \(dl) and named \(dl) to the first officer." }
            if titles.contains("phone") || titles.contains("cell") || titles.contains("text") { return "Phone records pointed to \(dl)." }
            return rng.pick(["A Crime Stoppers tip named \(dl).", "\(dl) was stopped nearby shortly afterward and matched the description."])
        }
    }
}

extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}

extension Array where Element: Hashable {
    /// The elements in order, without repeats.
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension DefendantProfiles {
    /// A returning defendant's life as the court last recorded it, carried forward: a job ends when the person
    /// goes to prison, and the facts of the new case can add to the family but never erase it.
    static func continued(_ stored: DefendantProfile, person: PersonRecord, family known: FamilyFacts, on date: Date) -> DefendantProfile {
        var profile = stored
        // A note about the last case's victim belongs to that case, not to the person.
        for old in [" The late spouse is the victim in this case.", " The spouse is the alleged victim in this case."] {
            profile.family = profile.family.replacingOccurrences(of: old, with: "")
        }
        let cal = CourtCalendar.calendar
        let year = cal.component(.year, from: date)
        // The most recent commitment to prison or jail in this court.
        let committed = person.appearances.last { appearance in
            let text = appearance.outcome.lowercased()
            return text.contains("active") || text.contains("imprisonment") || text.contains("revoked") || text.contains("crv")
        }
        if let committed {
            let goneYear = cal.component(.year, from: committed.date)
            var lost = false
            // Being out of work isn't a job to lose; it's only ever recorded once.
            for i in profile.jobs.indices where profile.jobs[i].current && profile.jobs[i].title != "Unemployed" {
                let start = Int(profile.jobs[i].years.prefix(4)) ?? goneYear
                if start <= goneYear {
                    profile.jobs[i].current = false
                    profile.jobs[i].years = "\(start)–\(goneYear) (lost the job when incarcerated)"
                    lost = true
                }
            }
            if lost && person.status != .incarcerated && !profile.jobs.contains(where: { $0.current && $0.title == "Unemployed" }) {
                let release = max(goneYear, year - 1)
                profile.jobs.insert(Job(title: "Unemployed", employer: "since release from custody", years: "\(release)–present", current: true), at: 0)
            }
        }
        // New facts about family add to what was known.
        if known.minChildren > 0, profile.family.contains("no children") {
            let n = max(1, known.minChildren)
            profile.family = profile.family.replacingOccurrences(of: ", no children.", with: ", \(n) child\(n == 1 ? "" : "ren").")
        }
        if let status = known.status, !profile.family.hasPrefix(status) {
            let rest = profile.family.firstIndex(of: ",").map { String(profile.family[$0...]) } ?? "."
            profile.family = status + rest
        }
        if let note = known.note, !profile.family.contains(note) { profile.family += " " + note }
        return profile
    }
}

/// What is known about a defendant's spouse and children from the background and the written facts of the case,
/// so the profile never says "no children" about someone the case calls a parent.
struct FamilyFacts {
    var minChildren = 0
    var exactChildren: Int?
    var status: String?
    var note: String?
    var paysSupport = false

    mutating func merge(_ other: FamilyFacts) {
        minChildren = max(minChildren, other.minChildren)
        if exactChildren == nil { exactChildren = other.exactChildren }
        if let exact = exactChildren, exact < minChildren { exactChildren = minChildren }
        if status == nil { status = other.status }
        if note == nil { note = other.note }
        paysSupport = paysSupport || other.paysSupport
    }

    /// Family facts stated in a background line.
    static func from(background: String) -> FamilyFacts {
        var f = FamilyFacts()
        let b = background.lowercased()
        func has(_ words: String...) -> Bool { words.contains { b.contains($0) } }
        if has("has five children") { f.exactChildren = 5 }
        if has("raised two children", "estranged from both children") { f.exactChildren = 2 }
        if has("grandchildren", "grandchild", "became a grandparent") { f.minChildren = max(f.minChildren, 2) }
        if has("custody of a child", "custody fight", "became a parent", "child support", "a child plays on",
               "had a child removed", "day a child was born", "lost children", "disabled adult child",
               "teenage child", "adopted a former foster child") {
            f.minChildren = max(f.minChildren, 1)
        }
        if has("child support") { f.paysSupport = true }
        if has("widowed", "widow or widower") { f.status = "Widowed" }
        if has("married to a high school sweetheart") { f.status = "Married" }
        if has("going through a divorce") { f.status = "Separated, divorce pending" }
        if has("after a divorce", "custody fight") { f.status = "Divorced" }
        if has("recently got engaged") { f.status = "Engaged" }
        if has("foster parent to two teenagers") { f.note = "Foster parent to two teenagers." }
        if has("raising a niece and nephew") { f.note = "Raising a niece and nephew." }
        return f
    }

    /// Family facts the written case states about the defendant. `text` is the unfilled template text, so the
    /// defendant's own relationships can be told apart from everyone else's; `voice` is what the defendant says.
    static func from(caseText text: String, defendantVoice voice: String, victimDied: Bool) -> FamilyFacts {
        var f = FamilyFacts()
        let mine = #"(\{D\.[Hh]is\}|\{DL?\}'s)"#
        let kids = "(child|children|kids|son|sons|daughter|daughters|baby|toddler|infant|stepson|stepdaughter|stepchildren|grandchildren|grandson|granddaughter|boys|girls)"
        func found(_ pattern: String, in source: String) -> Bool {
            source.range(of: pattern, options: .regularExpression) != nil
        }
        if found(mine + #" (?:[A-Za-z0-9-]+ ){0,2}"# + kids + #"\b"#, in: text)
            || found(#"\b[Mm]y (?:[a-z0-9-]+ ){0,2}"# + kids + #"\b"#, in: voice) {
            f.minChildren = 1
        }
        for (word, n) in [("two", 2), ("three", 3), ("four", 4), ("five", 5)]
        where found(mine + " " + word + #" (children|kids|sons|daughters|boys|girls)\b"#, in: text) {
            f.minChildren = max(f.minChildren, n)
        }
        if found(#"\{DL?\}, the other parent of"#, in: text) { f.minChildren = max(f.minChildren, 1) }
        // "{DL}, a married father of two"
        for (word, n) in [("a", 1), ("one", 1), ("two", 2), ("three", 3), ("four", 4), ("five", 5)]
        where found(#"\{DL?\}, an? (married |single |divorced )?(father|mother|parent) of "# + word + #"\b"#, in: text) {
            f.minChildren = max(f.minChildren, n)
            if found(#"\{DL?\}, an? married (father|mother|parent)"#, in: text) { f.status = "Married" }
        }
        let spouseIsVictim = found(mine + #" (wife|husband|spouse),? \{V"#, in: text)
            || found(#"\{VL?\},? "# + mine + #" (wife|husband|spouse)\b"#, in: text)
            || (found(#"\{V\}"#, in: text) && found("the couple's (home|house|apartment)", in: text))
        if spouseIsVictim, f.status == nil || f.status == "Married" {
            f.status = victimDied ? "Widowed" : "Married"
            f.note = victimDied ? "The late spouse is the victim in this case." : "The spouse is the alleged victim in this case."
        } else if found(mine + #" (wife|husband|spouse)\b"#, in: text) || found(#"\b[Mm]y (wife|husband|spouse)\b"#, in: voice) {
            f.status = "Married"
        } else if found(mine + #" late (wife|husband|spouse)\b"#, in: text) || found(#"\b[Mm]y late (wife|husband|spouse)\b"#, in: voice) {
            f.status = "Widowed"
        } else if found(mine + #" (fiancé|fiancée|fiance|fiancee)\b"#, in: text) {
            f.status = "Engaged"
        } else if found(mine + #" (ex-wife|ex-husband|ex-spouse|ex)\b"#, in: text) || found(#"\b[Mm]y (ex-wife|ex-husband|ex)\b"#, in: voice) {
            f.status = "Divorced"
        } else if found(mine + #" (girlfriend|boyfriend|partner)\b"#, in: text) {
            f.status = "In a long-term relationship"
        }
        return f
    }
}
