import Foundation

/// Builds a fresh case from a template, the county's standing cast, and (sometimes) a returning defendant.
enum CaseGenerator {

    struct Context {
        let county: County
        let judgeName: String
        let date: Date
        let docketSequence: Int
        let recentTemplateKeys: [String]
        /// Scenario signatures already heard in this career, so no exact scenario repeats.
        var usedSignatures: Set<String> = []
        var returning: PersonRecord?
        /// Backgrounds already given to people in this career, so each new defendant gets a fresh one.
        var usedBackgrounds: Set<String> = []
        /// A trial slot (true) or a calendar-call matter (false). Both are written stories; a trial slot takes an
        /// unheard one first.
        var storySlot = true
        /// A short calendar-call matter that never comes to trial before this judge, so no written story is spent on it.
        var generic = false
        /// Only cases of these kinds, e.g. a drug case for a search warrant the judge signed.
        var categories: Set<LawCategory>? = nil
        /// False when the week already has a murder trial, or had one last week.
        var allowMurder = true
        /// A follow-up case: what kind it is, the victim it involves, and how long ago it happened.
        var forcedTemplateKeys: [String]? = nil
        var victimOverride: String? = nil
        var incidentDaysAgo: Int? = nil
        /// The day of the arrest, when the court already knows it (a warrant executed, a first appearance).
        var arrestOn: Date? = nil
        /// Victims and witnesses from earlier cases, who may turn up again.
        var residents: [ResidentRef] = []
        /// Someone the court knows from an earlier case, now charged in this one (used when the written case allows them).
        var residentDefendant: ResidentRef? = nil
        /// Everyone the county already knows by name (residents, owners, regulars, officers): a new face never shares a name.
        var reservedNames: Set<String> = []
        /// The earlier case a written follow-up refers to.
        var priorOffense: String? = nil
        var priorDate: Date? = nil
    }

    static func isMurder(_ template: CaseTemplate) -> Bool { template.primaryLaw.hasPrefix("murder") }

    /// The hour a written case gives for what happened: its own setting, the first clock time on the day of the
    /// incident in its timeline, or the first in its summary. Stories that use {TIME} leave it to the draw.
    static func storyTime(_ t: CaseTemplate) -> String? {
        guard let story = t.story else { return nil }
        if let time = story.time { return time }
        if t.summaries.contains(where: { $0.contains("{TIME}") }) { return nil }
        let pattern = "\\b(1[0-2]|[1-9]):[0-5][0-9] [ap]\\.m\\."
        func first(_ text: String) -> String? {
            guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
            return String(text[range])
        }
        for entry in story.timeline where entry.0 == 0 { if let time = first(entry.1) { return time } }
        for summary in t.summaries { if let time = first(summary) { return time } }
        return nil
    }

    /// How strong the State's case should be, so that the evidence doesn't always point one way.
    private enum Band {
        case strong, close, weak
    }

    static func generate(seed: UInt64, context: Context) -> CourtCase {
        var rng = SeededRNG(seed: seed)
        var pool = CaseTemplates.all
        // Written cases come up first, until each has been heard once.
        // A follow-up to an earlier case: one of the kinds named, fitted to the person.
        if let keys = context.forcedTemplateKeys {
            let sex = context.returning.map { NameBank.gender(of: $0.name) }
            let age = context.returning.map { $0.age(on: context.date) }
            let named = keys.compactMap { key in (FollowUpCases.all + CaseTemplates.all).first { $0.key == key } }.filter { t in
                sex.map { (t.requiredGenders["D"] ?? $0) == $0 } ?? true
            }.filter { t in age.map { FollowUpCases.fits(t.key, age: $0) } ?? true }
            // Keep the same victim when the case allows that person; otherwise any of the kinds named.
            let keepsVictim = named.filter { t in
                context.victimOverride.map { v in t.hasVictim && (t.requiredGenders["V"].map { $0 == NameBank.gender(of: v) } ?? true) } ?? true
            }
            let fitting = keepsVictim.isEmpty ? named : keepsVictim
            if let template = fitting.first(where: { _ in rng.chance(0.6) }) ?? fitting.first {
                return build(template, seed: seed, band: rng.chance(0.6) ? .strong : .close, context: context, rng: &rng)
            }
        }
        // How many times each template has been heard, counted once rather than per template.
        var useCounts: [String: Int] = [:]
        for signature in context.usedSignatures {
            if let bar = signature.firstIndex(of: "|") { useCounts[String(signature[..<bar]), default: 0] += 1 }
        }
        var unheardStories = StoryCases.all.filter { useCounts[$0.key] == nil }
        if !context.allowMurder { unheardStories.removeAll(where: isMurder) }
        // Every case that can come to trial here is a written one, calendar-call matters included.
        // Unheard stories come first; once all have been heard, the ones heard least come back with new people.
        if !context.generic {
            var all = StoryCases.all
            if !context.allowMurder { all.removeAll(where: isMurder) }
            if let wanted = context.categories {
                let narrowed = all.filter { wanted.contains($0.category) }
                if !narrowed.isEmpty { all = narrowed }
            }
            var storyContext = context
            if let person = context.returning {
                // A returning defendant only in a story that can be about them; otherwise the story brings its own.
                let hasFelony = person.priors.contains { $0.ncClass.isFelony }
                let age = person.age(on: context.date)
                let sex = NameBank.gender(of: person.name)
                let fitting = all.filter { template in
                    template.occupations.isEmpty && (template.requiredGenders["D"] ?? sex) == sex
                        && (!template.requiresFelonyPrior || hasFelony) && template.forcedPriorOffenses.isEmpty
                        && age >= template.ageRange.lowerBound - 3 && age <= template.ageRange.upperBound + 8
                }
                if fitting.isEmpty { storyContext.returning = nil } else { all = fitting }
            }
            let fewest = all.map { useCounts[$0.key] ?? 0 }.min() ?? 0
            var candidates = all.filter { (useCounts[$0.key] ?? 0) == fewest }
            let notRecentStories = candidates.filter { !context.recentTemplateKeys.contains($0.key) }
            if !notRecentStories.isEmpty { candidates = notRecentStories }
            if !candidates.isEmpty {
                // Murder trials come up now and then, not every week: most draws go to another kind of case.
                let others = candidates.filter { !isMurder($0) }
                let story = rng.pick(!others.isEmpty && rng.chance(0.65) ? others : candidates)
                return build(story, seed: seed, band: .close, context: storyContext, rng: &rng)
            }
        }
        // A written case is heard once per career, and only with a new defendant, whose history it describes.
        if context.returning == nil && context.storySlot { pool += unheardStories }
        if let person = context.returning {
            let hasFelony = person.priors.contains { $0.ncClass.isFelony }
            let age = person.age(on: context.date)
            let sex = NameBank.gender(of: person.name)
            let fitting = pool.filter { template in
                template.occupations.isEmpty
                    && (template.requiredGenders["D"] ?? sex) == sex
                    && (!template.requiresFelonyPrior || hasFelony)
                    && template.forcedPriorOffenses.isEmpty
                    && age >= template.ageRange.lowerBound - 3 && age <= template.ageRange.upperBound + 8
            }
            if !fitting.isEmpty { pool = fitting }
        }

        if !context.allowMurder {
            let narrowed = pool.filter { !isMurder($0) }
            if !narrowed.isEmpty { pool = narrowed }
        }
        if let wanted = context.categories {
            let narrowed = pool.filter { wanted.contains($0.category) && $0.story == nil }
            if !narrowed.isEmpty { pool = narrowed }
        }
        // Serious felonies come up most; low-level cases still appear, but rarely.
        func weight(_ template: CaseTemplate) -> Double {
            if isMurder(template) { return 2 }
            switch LawLibrary.law(template.primaryLaw).ncClass {
            case .A?, .B1?, .B2?, .C?, .D?, .E?: return 5
            case .F?, .G?: return 3.5
            case .H?: return 2
            case .I?: return 1
            default: return 0.6
            }
        }
        // Rotate through the kinds of cases in proportion to their weight before any repeats.
        func uses(_ template: CaseTemplate) -> Int { useCounts[template.key] ?? 0 }
        func score(_ template: CaseTemplate) -> Double { Double(uses(template) + 1) / weight(template) }
        let lowest = pool.map(score).min() ?? 0
        var choices = pool.filter { score($0) <= lowest + 0.0001 }
        let notRecent = choices.filter { !context.recentTemplateKeys.contains($0.key) }
        if !notRecent.isEmpty { choices = notRecent }
        let template = rng.pick(choices)

        let roll = Double.random(in: 0..<1, using: &rng)
        // Some cases are clear one way or the other; about half sit on the line.
        let band: Band = roll < 0.32 ? .strong : (roll < 0.82 ? .close : .weak)

        // Never repeat an exact scenario (same template, set-up, headline, and details).
        var fallback: CourtCase?
        var unheard: CourtCase?
        for _ in 0..<60 {
            let candidate = build(template, seed: seed, band: band, context: context, rng: &rng)
            let fresh = !context.usedSignatures.contains(candidate.scenarioSignature ?? "")
            if fresh && (matches(candidate, band: band) || template.story != nil) { return candidate }
            if fresh && unheard == nil { unheard = candidate }
            if fallback == nil { fallback = candidate }
        }
        return unheard ?? fallback!
    }

    private static func matches(_ courtCase: CourtCase, band: Band) -> Bool {
        guard let primary = courtCase.charges.first else { return true }
        let s = Judgment.properStrength(courtCase)
        let floor = primary.lesserLawID == nil ? primary.threshold : primary.lesserThreshold
        switch band {
        case .strong: return s >= primary.threshold + 3
        case .close: return s >= min(floor, primary.threshold - 1) && s <= primary.threshold + 1
        case .weak: return s <= floor - 3
        }
    }

    // MARK: - Assembly

    private static func build(_ t: CaseTemplate, seed: UInt64, band: Band, context: Context, rng: inout SeededRNG) -> CourtCase {
        let county = context.county
        let currentYear = Calendar.current.component(.year, from: context.date)

        var used = Set<String>()
        let castNames: [String] = [[county.districtAttorney, county.chiefPublicDefender, county.clerk, county.sheriff, county.policeChief],
                                   county.assistantDAs, county.assistantPDs, county.privateCounsel,
                                   county.detectives.map(\.name), county.officers.map(\.name), county.troopers].flatMap { $0 }
        for name in castNames {
            used.insert(name)
            used.insert(lastName(name))
        }

        // Defendant
        let defendant: Defendant
        if let person = context.returning {
            used.insert(person.name)
            used.insert(person.lastName)
            // A convicted officer doesn't keep the badge: a conviction from this court ends a law enforcement career.
            let lostBadge = CaseComplexity.isLawEnforcement(person.occupation) && !person.priors.isEmpty
                && !person.occupation.lowercased().hasPrefix("former")
            defendant = Defendant(personID: person.id, name: person.name, age: person.age(on: context.date),
                                  occupation: lostBadge ? "Former " + person.occupation.lowercased() : person.occupation,
                                  background: person.background, priors: person.priors,
                                  probation: person.status == .probation ? person.probation : nil,
                                  history: person.appearances,
                                  postRelease: person.status == .incarcerated ? nil : person.postRelease,
                                  violations: person.violations)
        } else {
            // Now and then the person charged is someone the court already knows: a former witness, or a victim.
            let known = context.residentDefendant.flatMap { r in
                (t.requiredGenders["D"].map { NameBank.gender(of: r.name) == $0 } ?? true) && r.occupation == nil && !used.contains(r.name) ? r.name : nil
            }
            let drawn = NameBank.person(using: &rng, excluding: &used, gender: t.requiredGenders["D"], avoiding: context.reservedNames)
            let name = known ?? drawn
            if known != nil { used.insert(name); used.insert(lastName(name)) }
            let age = rng.int(t.ageRange)
            let occupation = t.occupations.isEmpty ? rng.pick(NameBank.occupations) : rng.pick(t.occupations)
            // Written cases describe the defendant's record themselves; most say there is none. A serving officer
            // has none at all: a criminal record bars certification (12 NCAC 09B .0101).
            let officer = CaseComplexity.isLawEnforcement(occupation)
            var priors = t.story != nil || officer ? [] : randomPriors(age: age, year: currentYear, county: county, rng: &rng)
            for entry in t.forcedPriorOffenses where !officer {
                // "Offense@N" pins the conviction to about N years ago; otherwise any year since the defendant turned 17 (at most 20 back).
                let parts = entry.components(separatedBy: "@")
                let name = parts[0]
                guard let seed = GenericPools.priorSeeds.first(where: { $0.offense == name }) else { continue }
                let earliest = currentYear - max(1, min(age - 17, 20))
                let year: Int
                if parts.count > 1, let yearsAgo = Int(parts[1].trimmingCharacters(in: .whitespaces)) {
                    year = max(currentYear - max(1, age - 16), currentYear - max(1, yearsAgo))
                } else {
                    year = rng.int(earliest...(currentYear - 1))
                }
                priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass,
                                              year: year,
                                              county: rng.chance(0.6) ? county.name : rng.pick(GenericPools.otherCounties),
                                              sentence: rng.pick(seed.sentences)))
            }
            priors.sort { $0.year < $1.year }
            if t.requiresFelonyPrior && !officer && !priors.contains(where: { $0.ncClass.isFelony }) {
                priors.insert(PriorConviction(offense: "Possession of Stolen Goods", ncClass: .H, year: max(currentYear - max(1, age - 17), currentYear - 12),
                                              county: rng.pick(GenericPools.otherCounties),
                                              sentence: "6–17 months active"), at: 0)
            }
            // A written case's defendant gets the background the story gives, or a plain one; a random life story
            // could contradict what the case says (military service, a divorce, a layoff, a prison GED).
            let backgroundLine = t.story.map { story in
                story.background ?? rng.pick(["Grew up in {HOOD}.", "Has lived in {HOOD} for most of the last decade.",
                                              "Raised in {HOOD}.", "Moved to {HOOD} as a teenager and stayed."])
            } ?? BackgroundLines.pick(age: age, occupation: occupation, used: context.usedBackgrounds, towns: county.towns, rng: &rng)
            let background = TextFiller(values: ["HOOD": rng.pick(county.towns)])(backgroundLine)
            defendant = Defendant(personID: UUID(), name: name, age: age, occupation: occupation.capitalizedFirst,
                                  background: background, priors: priors, probation: nil, history: [])
        }

        // A follow-up case can involve the same victim, if the story allows that person.
        let sameVictim = context.victimOverride.flatMap { name in
            t.requiredGenders["V"].map { $0 == NameBank.gender(of: name) } ?? true ? name : nil
        }
        let knownNames = Set(context.residents.map(\.name)).union(context.reservedNames)
        let drawnVictim = NameBank.person(using: &rng, excluding: &used, gender: t.requiredGenders["V"], avoiding: knownNames)
        let victimName = t.hasVictim ? (sameVictim ?? drawnVictim) : nil
        let alternate = NameBank.person(using: &rng, excluding: &used, gender: t.requiredGenders["ALT"], avoiding: knownNames)
        let setting = CaseSetting.of(category: t.category, key: t.key)
        // Highway crashes and impaired driving are worked by the Highway Patrol.
        let trooperName = rng.pick(county.troopers)
        // A written case worked by deputies gets the Sheriff's Office, not the city police or the Patrol.
        let storyText = (t.story == nil ? [] : t.summaries + (t.prosecutionWitnesses + t.defenseWitnesses).map(\.role)).joined(separator: " ").lowercased()
        let sheriffs = storyText.contains("deput") || storyText.contains("sheriff")
        let sheriffDetectives = county.detectives.filter { $0.agency.contains("Sheriff") }
        let sheriffOfficers = county.officers.filter { $0.agency.contains("Sheriff") }
        var detective = setting == .road && !sheriffs
            ? CastMember(name: trooperName, title: rng.pick(["Trooper", "Master Trooper", "Sergeant"]), agency: "N.C. State Highway Patrol")
            : rng.pick(sheriffs && !sheriffDetectives.isEmpty ? sheriffDetectives : county.detectives)
        var officer = setting == .road && !sheriffs && rng.chance(0.5)
            ? CastMember(name: NameBank.person(using: &rng, excluding: &used, avoiding: context.reservedNames), title: "Trooper", agency: "N.C. State Highway Patrol")
            : rng.pick(sheriffs && !sheriffOfficers.isEmpty ? sheriffOfficers : county.officers)
        // The day it happened, fixed once so every report, witness, and exhibit agrees.
        // A written case's file can run long past the incident (a cold case solved years later), so the incident
        // sits far enough back that every entry in it still comes before trial.
        let lastEntry = t.story?.timeline.map(\.0).max() ?? 0
        let minDays = max(150, lastEntry + 45)
        // A speedy-trial motion needs a case that has actually waited a long time.
        let speedySeed: MotionSeed? = t.story == nil && context.incidentDaysAgo == nil && rng.chance(0.07) ? rng.pick(GenericPools.speedyTrialSeeds) : nil
        let daysBack = context.incidentDaysAgo.map { max(1, $0) } ?? (speedySeed != nil ? rng.int(560...900) : rng.int(150...330) + (minDays - 150))
        var incident = Calendar.current.date(byAdding: .day, value: -daysBack, to: context.date) ?? context.date
        if let pinned = t.story?.when?.incident(before: context.date, minDays: minDays, using: &rng) { incident = pinned }
        let prosecutor = rng.pick(county.assistantDAs)
        let usePublicDefender = rng.chance(0.6)
        let defenseLawyer = usePublicDefender ? rng.pick(county.assistantPDs) : rng.pick(county.privateCounsel)

        // The town comes first, and the street is one of that town's.
        // Towns going through a hard stretch (layoffs, a building boom) see more of the cases that come with it.
        let weights = county.towns.map { Gazetteer.living.weight(town: $0, category: t.category.rawValue, on: context.date) }
        var roll = Double(rng.int(0...999)) / 1000 * weights.reduce(0, +)
        var hood = county.towns.last ?? county.seat
        for (town, w) in zip(county.towns, weights) {
            if roll < w { hood = town; break }
            roll -= w
        }
        let street = Gazetteer.street(in: hood, rng: &rng)
        var values: [String: String] = [
            "D": defendant.name,
            "DL": defendant.lastName,
            "DA": "\(defendant.age)",
            "DO": defendant.occupation.lowercasedPhrase,
            "DET": detective.display,
            "OFF": officer.display,
            "TROOPER": setting == .road ? detective.display : "Trooper \(trooperName)",
            "ALT": alternate,
            "PROS": prosecutor,
            "DEF": defenseLawyer,
            "ELECTEDDA": county.districtAttorney,
            "SHERIFF": county.sheriff,
            "JUDGE": lastName(context.judgeName),
            "STREET": street,
            "TIME": storyTime(t) ?? rng.pick(NameBank.times),
            "DATE": CaseDates.day(incident),
            "HOOD": hood,
            "CITY": county.seat,
            "V": victimName ?? "the complainant",
            "VL": victimName.map(lastName) ?? "the complainant",
            // A follow-up case names the earlier one in this court.
            "PRIOR": context.priorOffense?.lowercasedPhrase ?? "an earlier charge",
            "PRIORDATE": context.priorDate.map { $0.formatted(.dateTime.month(.wide).year()) } ?? "an earlier term of court"
        ]
        for key in t.extras.keys.sorted() {
            // A place that has closed in this career doesn't host new cases, when there's another choice.
            if let options = t.extras[key] {
                let open = options.filter { Gazetteer.living.closed[$0] == nil }
                values[key] = rng.pick(open.isEmpty ? options : open)
            }
        }
        // A case set at a place on the county map happens in that place's town, on its street.
        // Where it happened comes first (the bar, the store, the pharmacy), not a company or a church that's only mentioned.
        let sites = ["BAR", "CLUB", "SHOP", "STORE", "STORE2", "PHARM", "LOT", "FAC", "PAWN", "REST", "GYM", "SPA", "BANK", "GROCER",
                     "COMPLEX", "BIZ", "SCHOOL", "CHURCH", "POST", "CH"]
        if let known = sites.filter({ t.extras[$0] != nil }).compactMap({ values[$0].flatMap(Gazetteer.place(named:)) }).first {
            values["HOOD"] = known.town
            values["STREET"] = known.street
        }
        // City police work inside the city; anywhere else in the county, it's the Sheriff's Office.
        if (values["HOOD"] ?? hood) != county.seat {
            if detective.agency.contains("Police"), !sheriffDetectives.isEmpty {
                detective = rng.pick(sheriffDetectives)
                values["DET"] = detective.display
            }
            if officer.agency.contains("Police"), !sheriffOfficers.isEmpty {
                officer = rng.pick(sheriffOfficers)
                values["OFF"] = officer.display
            }
        }
        // Real places in the case's own town for {PLACE.BAR}, {PLACE.GASSTATION} and the rest.
        values.merge(Gazetteer.tokens(town: values["HOOD"] ?? hood, rng: &rng)) { a, _ in a }
        values.merge(NameBank.gender(of: defendant.name).tokens(for: "D")) { a, _ in a }
        values.merge(NameBank.gender(of: victimName ?? "").tokens(for: "V")) { a, _ in a }
        values.merge(NameBank.gender(of: alternate).tokens(for: "ALT")) { a, _ in a }
        let fill = TextFiller(values: values)

        // Charges. A written case is the same story every time, but how much proof it takes varies, so some
        // stories are strong for the State and some are thin, and the motion to dismiss is a real decision.
        // A mix: about 4 in 10 are clearly proven, 4 in 10 are hard calls, and 2 in 10 are clearly too thin to convict.
        // (A lower threshold is a stronger case for the State; the hidden truth follows the strength.)
        let shift = t.story != nil ? rng.pick([-4, -3, -3, -2, 0, 0, 0, 1, 3, 4]) : 0
        let primaryThreshold = max(1, t.threshold + shift)
        var charges = [Charge(count: 1, lawID: t.primaryLaw, lesserLawID: t.lesserLaw,
                              specification: fill(t.specification), threshold: primaryThreshold,
                              lesserThreshold: max(1, t.lesserThreshold + shift))]
        for extra in t.secondary where rng.chance(extra.chance) {
            let threshold = extra.threshold == 0 ? primaryThreshold : max(1, extra.threshold + shift)
            charges.append(Charge(count: charges.count + 1, lawID: extra.lawID, lesserLawID: nil,
                                  specification: fill(extra.specification), threshold: threshold,
                                  lesserThreshold: threshold))
        }
        // Extra counts the facts support
        let addOns = CaseComplexity.pickAddOns(for: t, hasFelonyPrior: defendant.priors.contains { $0.ncClass.isFelony },
                                               existing: Set(charges.map(\.lawID)),
                                               lawEnforcement: CaseComplexity.isLawEnforcement(defendant.occupation),
                                               rng: &rng).filter { _ in t.story == nil }

        // Sometimes the State indicts a whole series of incidents: a big case with 7 to 9 counts.
        var seriesCount = 0
        let seriesCategories: Set<LawCategory> = [.property, .drugs, .whiteCollar, .cyber]
        if t.story == nil && seriesCategories.contains(t.category) && rng.chance(0.22) {
            let target = rng.int(7...9)
            let extraIncidents = max(2, target - charges.count - addOns.count)
            seriesCount = extraIncidents + 1
            charges[0].specification += " (Incident 1 of \(seriesCount).)"
            var day = incident
            for index in 2...seriesCount {
                day = Calendar.current.date(byAdding: .day, value: rng.int(9...40), to: day) ?? day
                let when = day.formatted(.dateTime.month(.wide).day().year())
                let threshold = max(3, t.threshold + rng.int(-1...1))
                let lesserThreshold = max(3, t.lesserThreshold + rng.int(-1...1))
                charges.append(Charge(count: charges.count + 1, lawID: t.primaryLaw, lesserLawID: t.lesserLaw,
                                      specification: "A separate incident on or about \(when), of the same kind as Count 1. (Incident \(index) of \(seriesCount).)",
                                      threshold: threshold, lesserThreshold: lesserThreshold))
            }
        }
        for addOn in addOns {
            let threshold = max(3, t.threshold + addOn.thresholdDelta)
            charges.append(Charge(count: charges.count + 1, lawID: addOn.lawID, lesserLawID: nil,
                                  specification: fill(addOn.specification), threshold: threshold, lesserThreshold: threshold))
        }
        let isFelonyCase = charges.contains { $0.law.ncClass?.isFelony ?? false }
        let court: CourtKind = isFelonyCase ? .felony : .misdemeanorAppeal

        // Evidence
        let prosecutionCount = t.story != nil ? t.prosecutionEvidence.count : min(t.prosecutionEvidence.count, band == .weak ? rng.int(2...3) : (band == .strong ? rng.int(4...5) : rng.int(3...4)))
        let defenseCount = t.story != nil ? t.defenseEvidence.count : min(t.defenseEvidence.count, band == .weak ? rng.int(2...3) : (band == .strong ? rng.int(0...1) : 2))
        var prosecutionSeeds = rng.pick(t.prosecutionEvidence, count: prosecutionCount) + addOns.map(\.evidence)
        var defenseSeeds = rng.pick(t.defenseEvidence, count: defenseCount)
        if seriesCount > 0 {
            prosecutionSeeds.append(EvidenceSeed(.document, 2, "Pattern Chart",
                                                 "A chart the lead investigator prepared, linking \(seriesCount) separate incidents to {DL} by date, method, and location. Some links are stronger than others."))
            defenseSeeds.append(EvidenceSeed(.document, 2, "Gaps in the Pattern",
                                             "For several of the \(seriesCount) incidents, the State has no witness, no video, and no physical evidence tying {DL} to that date."))
        }
        if band == .close && t.story == nil {
            // A case on the line pulls both ways: something real for each side.
            for complication in CaseComplexity.pickComplications(for: t, rng: &rng) {
                if complication.side == .prosecution { prosecutionSeeds.append(complication.evidence) } else { defenseSeeds.append(complication.evidence) }
            }
        }

        var evidence: [Evidence] = []
        var searchable: [(UUID, EvidenceKind, SearchPlace)] = []
        var statements: [UUID] = []
        for (index, item) in prosecutionSeeds.enumerated() {
            let exhibit = Evidence(exhibit: "State's Exhibit \(index + 1)", title: fill(item.title), detail: fill(item.detail),
                                   side: .prosecution, kind: item.kind, weight: item.weight)
            evidence.append(exhibit)
            switch item.acquisition {
            case .search: searchable.append((exhibit.id, item.kind, SearchPlace.infer(exhibit.title + " " + exhibit.detail, kind: item.kind)))
            case .statement: statements.append(exhibit.id)
            case .none: break
            }
        }
        for (index, item) in defenseSeeds.enumerated() {
            evidence.append(Evidence(exhibit: "Defendant's Exhibit \(index + 1)", title: fill(item.title),
                                     detail: fill(item.detail), side: .defense, kind: item.kind, weight: item.weight))
        }

        // Witnesses
        let regulars = Gazetteer.regulars(for: county)
        var witnesses: [Witness] = []
        if t.story != nil {
            // A written case calls every witness, in order, exactly as written.
            for item in t.prosecutionWitnesses {
                witnesses.append(makeWitness(item, side: .prosecution, fill: fill, rng: &rng, used: &used, impeach: false, regulars: regulars, residents: context.residents, hood: values["HOOD"] ?? hood, reserved: context.reservedNames))
            }
            for item in t.defenseWitnesses {
                witnesses.append(makeWitness(item, side: .defense, fill: fill, rng: &rng, used: &used, impeach: false, regulars: regulars, residents: context.residents, hood: values["HOOD"] ?? hood, reserved: context.reservedNames))
            }
        }
        let prosecutionWitnessCount = t.story != nil ? 0 : min(t.prosecutionWitnesses.count, rng.int(1...2))
        for item in rng.pick(t.prosecutionWitnesses, count: prosecutionWitnessCount) {
            witnesses.append(makeWitness(item, side: .prosecution, fill: fill, rng: &rng, used: &used, regulars: regulars,
                                         residents: context.residents, hood: values["HOOD"] ?? hood, reserved: context.reservedNames))
        }
        if t.story == nil && !t.defenseWitnesses.isEmpty && (band != .strong || rng.chance(0.3)) {
            witnesses.append(makeWitness(rng.pick(t.defenseWitnesses), side: .defense, fill: fill, rng: &rng, used: &used, regulars: regulars,
                                         residents: context.residents, hood: values["HOOD"] ?? hood, reserved: context.reservedNames))
        }

        // The investigation file and fact sheet come first: every generated witness reads from them.
        var profiledDefendant = defendant
        let deathLaws: Set<String> = ["murder1", "murder2", "volManslaughter", "invManslaughter", "felonyDBV", "misdDBV", "deathByDistribution"]
        var written: [String] = t.summaries
        written += t.prosecutionEvidence.map(\.detail)
        written += t.defenseEvidence.map(\.detail)
        for seed in t.prosecutionWitnesses + t.defenseWitnesses {
            written += seed.direct
            written += seed.cross
            for line in seed.exam { written += line.answers }
        }
        written += t.prosecutionTheory
        written += t.defenseTheory
        written += t.mitigating
        written += t.victimImpacts
        written.append(t.specification)
        written += t.secondary.map(\.specification)
        let writtenText = written.joined(separator: " ")
        var voice: [String] = t.allocutions
        for line in t.story?.defendantExam ?? [] { voice += line.answers }
        let defendantVoice = voice.joined(separator: " ")
        let familyFacts = FamilyFacts.from(caseText: writtenText, defendantVoice: defendantVoice, victimDied: t.victimDies)
        if let person = context.returning, let stored = person.profile {
            profiledDefendant.profile = DefendantProfiles.continued(stored, person: person, family: familyFacts, on: context.date)
        } else {
            profiledDefendant.profile = DefendantProfiles.make(for: defendant, county: county, year: currentYear, family: familyFacts)
        }
        // The workplace and school the story names are the ones on the profile.
        if var profile = profiledDefendant.profile, let story = t.story {
            if let place = story.employer.map({ fill($0) }) {
                if !profile.jobs.contains(where: { $0.current && $0.title != "Unemployed" }) {
                    // A returning defendant who has since found work there.
                    for i in profile.jobs.indices where profile.jobs[i].current { profile.jobs[i].current = false; profile.jobs[i].years = profile.jobs[i].years.replacingOccurrences(of: "present", with: "\(currentYear)") }
                    profile.jobs.insert(Job(title: "Employee", employer: place, years: "\(currentYear)–present", current: true), at: 0)
                }
                if let i = profile.jobs.firstIndex(where: { $0.current && $0.title != "Unemployed" }) {
                    profile.jobs[i].employer = place
                    if story.employmentEnded {
                        profile.jobs[i].current = false
                        profile.jobs[i].years = profile.jobs[i].years.replacingOccurrences(of: "present", with: "\(currentYear) (fired)")
                    }
                }
            }
            if let school = story.school.map({ fill($0) }) { profile.education = "Currently enrolled at \(school)." }
            if let family = story.family.map({ fill($0) }) { profile.family = family }
            if let residence = story.residence.map({ fill($0) }) { profile.residence = residence }
            if let years = story.yearsAtJob, let i = profile.jobs.firstIndex(where: { $0.current && $0.title != "Unemployed" }) {
                let start = currentYear - years
                profile.jobs[i].years = "\(start)–present"
                // Earlier jobs end before this one began.
                profile.jobs.removeAll { job in !job.current && (Int(job.years.prefix(4)) ?? 0) >= start }
                for j in profile.jobs.indices where !profile.jobs[j].current {
                    let parts = profile.jobs[j].years.components(separatedBy: "–")
                    if parts.count == 2, let first = Int(parts[0]), let end = Int(parts[1].prefix(4)), end > start {
                        profile.jobs[j].years = "\(first)–\(start)"
                    }
                }
            }
            profiledDefendant.profile = profile
        }
        let factParts: [[String]] = [t.summaries.map { fill($0) }, charges.map(\.specification),
                                     evidence.map { $0.title + ". " + $0.detail }, witnesses.flatMap { $0.direct + $0.cross }]
        let factText = factParts.flatMap { $0 }.joined(separator: " ")
        let facts = CaseFacts(key: t.key, category: t.category, hasVictim: t.hasVictim, text: factText)
        var (investigation, gaps) = Investigations.make(t: t, facts: facts, values: values, incident: incident, sessionDate: context.date,
                                                        detective: detective, officer: officer, evidence: evidence,
                                                        defendant: profiledDefendant, charges: charges, victimName: victimName,
                                                        year: currentYear, arrestOn: context.arrestOn, rng: &rng)
        let sheet = investigation.facts ?? CaseFactSheet(setting: setting, incident: incident, time: values["TIME"],
                                                         place: values["STREET"] ?? "", street: values["STREET"] ?? "",
                                                         town: values["HOOD"] ?? county.seat, arrivalTime: nil, assigned: incident,
                                                         arrest: incident, interview: nil, labSubmitted: nil, labReturned: nil,
                                                         agency: detective.agency, lead: detective.display, firstOfficer: officer.display)
        let testimonyContext = Testimony.Context(facts: facts, sheet: sheet, report: investigation, gaps: gaps, evidence: evidence,
                                                 charges: charges, defendant: profiledDefendant, victim: victimName, values: values,
                                                 defenseTheory: fill(rng.pick(t.defenseTheory)))
        for index in witnesses.indices where witnesses[index].exchanges == nil {
            witnesses[index].exchanges = Testimony.examination(for: witnesses[index], isVictim: witnesses[index].name == victimName,
                                                               ctx: testimonyContext, impeachment: nil,
                                                               timingSlip: witnesses[index].lay == true && rng.chance(0.3), rng: &rng)
        }
        let roles = witnesses.map { $0.role.lowercased() }
        var added: [Witness] = []
        if t.story == nil && !roles.contains(where: { $0.contains("detective") || $0.contains("investigator") || $0.contains("agent") || $0.contains("trooper") }) {
            added.append(Testimony.leadInvestigator(name: detective.display, agency: detective.agency, ctx: testimonyContext,
                                                    madeTheStop: facts.origin == .stop && rng.chance(0.5), rng: &rng))
        }
        if t.story == nil && setting != .paper && !roles.contains(where: { $0.contains("officer") || $0.contains("deputy") }) && rng.chance(0.65) {
            added.append(Testimony.firstOfficer(name: officer.display, agency: officer.agency, ctx: testimonyContext, rng: &rng))
        }
        if t.story == nil && !roles.contains(where: { $0.contains("analyst") || $0.contains("examiner") || $0.contains("scientist") || $0.contains("chemist") }) {
            let names = (0..<3).map { _ in NameBank.person(using: &rng, excluding: &used, avoiding: context.reservedNames) }
            added += Testimony.analysts(ctx: testimonyContext, names: names, rng: &rng)
        }
        if t.story == nil && rng.chance(0.55) {
            added.append(Testimony.characterWitness(name: NameBank.person(using: &rng, excluding: &used, avoiding: context.reservedNames), ctx: testimonyContext, rng: &rng))
        }
        // State witnesses first, then the defense's.
        witnesses = added.filter { $0.calledBy == .prosecution } + witnesses.filter { $0.calledBy == .prosecution }
            + witnesses.filter { $0.calledBy == .defense } + added.filter { $0.calledBy == .defense }
        investigation.interviews = witnesses.filter { $0.isDefendant != true && !$0.role.contains("State Crime Laboratory") }
            .map { "\($0.name), \($0.role.lowercased())" } + [investigation.interviews.last ?? ""]

        // Objections, built from each witness and the facts of this case
        var objections: [Objection] = []
        if let story = t.story {
            for (index, seed) in story.objections where witnesses.indices.contains(index) {
                objections.append(Objection(witnessID: witnesses[index].id, question: fill(seed.question), answer: fill(seed.answer),
                                            raisedBy: seed.raisedBy, grounds: seed.grounds, shouldSustain: seed.shouldSustain,
                                            appellateNote: fill(seed.explanation), doctrineID: seed.doctrineID, weightIfAdmitted: seed.weight))
            }
            investigation.timeline = story.timeline.map { offset, what in
                InvestigationReport.Entry(when: CaseDates.dayYear(CaseDates.add(offset, to: incident)), what: fill(what))
            }
            // The written file says when the arrest happened; the fact sheet follows it.
            if let offset = story.timeline.first(where: { $0.1.lowercased().contains("arrested") })?.0 {
                investigation.facts?.arrest = CaseDates.add(offset, to: incident)
            }
            investigation.howIdentified = fill(story.howIdentified)
            investigation.notDone = story.notDone.map { fill($0) }
        } else {
            for witness in witnesses where rng.chance(0.55) {
                if let objection = ObjectionEngine.make(for: witness, ctx: testimonyContext, rng: &rng) { objections.append(objection) }
            }
        }

        // Motions
        var motions: [Motion] = []
        if t.story == nil && !searchable.isEmpty && rng.chance(0.6) {
            let target = rng.pick(searchable)
            let fitting = GenericPools.suppressSearchSeeds.filter {
                ($0.kinds.isEmpty || $0.kinds.contains(target.1)) && ($0.places.isEmpty || $0.places.contains(target.2))
            }
            let wantGrant = rng.chance(0.45)
            let preferred = fitting.filter { $0.shouldGrant == wantGrant }
            let pool = preferred.isEmpty ? fitting : preferred
            if !pool.isEmpty {
                let option = rng.pick(pool)
                let title = evidence.first { $0.id == target.0 }?.title ?? "the evidence"
                motions.append(makeMotion(option, target: target.0, targetTitle: title, fill: fill))
            }
        }
        if t.story == nil && !statements.isEmpty && rng.chance(0.55) {
            let target = rng.pick(statements)
            let option = rng.pick(GenericPools.suppressStatementSeeds)
            let title = evidence.first { $0.id == target }?.title ?? "the statement"
            motions.append(makeMotion(option, target: target, targetTitle: title, fill: fill))
        }
        // An eyewitness identification the defense attacks.
        if t.story == nil, rng.chance(0.6),
           let id = evidence.first(where: { $0.side == .prosecution && ["lineup", "identif", "show-up", "photo array"].contains(where: $0.title.lowercased().contains) }) {
            // A lineup motion argues about a lineup; a show-up motion about a show-up.
            let title = id.title.lowercased()
            let showUp = title.contains("show-up")
            let lineup = title.contains("lineup") || title.contains("photo array")
            let seeds = GenericPools.identificationSeeds.filter { seed in
                let isShowUp = seed.facts.contains("detained") || seed.facts.contains("drove the witness past")
                return showUp ? isShowUp : (lineup ? !isShowUp : true)
            }
            motions.append(makeMotion(rng.pick(seeds.isEmpty ? GenericPools.identificationSeeds : seeds), target: id.id, targetTitle: id.title, fill: fill))
        }
        // Other acts the State wants to use.
        if t.story == nil, rng.chance(0.5),
           let prior = evidence.first(where: { $0.side == .prosecution && ["prior", "previous", "earlier", "history"].contains(where: $0.title.lowercased().contains) }) {
            // Each fact pattern needs what it talks about: a victim to threaten, or a break-in on the record.
            let brokeIn = defendant.priors.contains { ["break", "burglary"].contains(where: $0.offense.lowercased().contains) }
            let seeds = GenericPools.priorActsSeeds.filter { seed in
                if seed.facts.contains("{V}") { return t.hasVictim }
                if seed.facts.contains("break-in") { return brokeIn }
                return true
            }
            motions.append(makeMotion(rng.pick(seeds), target: prior.id, targetTitle: prior.title, fill: fill))
        }
        // Now and then, a count on a defective indictment.
        if t.story == nil, charges.count > 1, rng.chance(0.12), let count = charges.dropFirst().randomElement(using: &rng) {
            let countFill = TextFiller(values: values.merging(["COUNT": "\(count.count)"]) { a, _ in a })
            // The owner-allegation defect only arises on a larceny count.
            let law = count.lawID.lowercased()
            let takes = law.contains("larceny") || law.contains("robbery") || law.contains("embezzle")
            let seeds = GenericPools.indictmentSeeds.filter { seed in
                if seed.facts.contains("Dollar Mart") { return law.contains("larceny") && !t.hasVictim }
                if seed.facts.contains("permanently deprive") { return takes }
                if seed.facts.contains("victim's") { return t.hasVictim }
                return true
            }
            var motion = makeMotion(rng.pick(seeds), target: nil, targetTitle: nil, fill: countFill)
            motion.targetChargeID = count.id
            motions.append(motion)
        }
        if let speedySeed {
            // The delay the motion argues about is the real time from arrest to this session.
            let delayMonths = max(1, CaseDates.days(from: sheet.arrest, to: context.date) / 30)
            let delayFill = TextFiller(values: values.merging(["DELAY": "\(delayMonths)",
                                                               "DEFDELAY": "\(max(1, delayMonths * 3 / 4))"]) { a, _ in a })
            motions.append(makeMotion(speedySeed, target: nil, targetTitle: nil, fill: delayFill))
        }

        // Time in jail can't be longer than the time since the arrest.
        let maxCustodyDays = max(0, CaseDates.days(from: investigation.facts?.arrest ?? sheet.arrest, to: context.date))

        // Status and procedural posture
        let priorFelonies = Judgment.distinctFelonySessions(defendant.priors)
        let habitual = isFelonyCase && priorFelonies >= 3 && t.primaryLaw != "murder1" && rng.chance(0.65)
        var notes: [String] = []
        if isFelonyCase {
            if t.primaryLaw == "murder1" {
                notes.append("The State has declared this a non-capital case, so a jury may be waived. Bench trials for first-degree murder are rare in North Carolina; the defense requested one and you consented after hearing from the State.")
            }
            notes.append("The defendant waived the right to trial by jury in writing (N.C. Const. art. I, § 24). After hearing from the State, you consented on the record.")
        } else {
            notes.append("The defendant was convicted in Hollis County District Court and appealed for a trial de novo in Superior Court, then waived a jury. You hear the case fresh; the district court's verdict carries no weight.")
        }
        if habitual {
            notes.append("The defendant has also been indicted as a habitual felon (G.S. 14-7.1), based on \(priorFelonies) prior felony convictions. If you convict on a felony, you will decide that status before sentencing.")
        }
        if let probation = defendant.probation {
            notes.append("When this offense allegedly occurred, the defendant was on probation in \(probation.docket) (\(probation.offense)), with a suspended sentence of \(probation.suspendedSentence). A probation violation report alleging a new criminal offense has been filed.")
        }

        // Factors, twists, community mood
        let aggravatingCount = rng.int(1...2)
        let mitigatingCount = rng.int(1...2)
        let hasPriors = !defendant.priors.isEmpty
        let aboutRecord: (String) -> Bool = { text in
            let l = text.lowercased()
            return l.contains("record") || l.hasPrefix("prior") || l.hasPrefix("no prior") || l.contains("first offense") || l.contains("first-time")
                || l.contains("no incidents")
        }
        let aggravatingPool = t.aggravating.filter { hasPriors || !aboutRecord($0) }
        let mitigatingPool = t.mitigating.filter { !hasPriors || !aboutRecord($0) }
        var aggravating = fill(rng.pick(aggravatingPool.isEmpty ? t.aggravating : aggravatingPool, count: aggravatingCount))
        var mitigating = fill(rng.pick(mitigatingPool.isEmpty ? t.mitigating : mitigatingPool, count: mitigatingCount))
        if !hasPriors {
            aggravating.removeAll(where: aboutRecord)
            if !mitigating.contains(where: aboutRecord) {
                mitigating.append("The defendant has no prior criminal record")
            }
        } else {
            mitigating.removeAll(where: aboutRecord)
        }
        if DefendantProfile.isWork(defendant.occupation) && profiledDefendant.profile?.currentJob != nil && rng.chance(0.5) {
            mitigating.append("The defendant has a positive employment history and is gainfully employed")
        }
        var mood = rng.pick(t.moods)
        var media = rng.int(1...2)
        var doctrines = t.doctrines
        var twistText: String?
        var twistKey: String?
        var chosenTwist: TwistSeed?
        let jailedDays = min(330, maxCustodyDays)
        let jailedTime = jailedDays >= 60 ? "\(jailedDays / 30) months" : "\(jailedDays) days"
        let twistPool = GenericPools.twists.filter { $0.ages.contains(defendant.age) && ($0.key != "jailed" || jailedDays >= 45) }
        if t.story == nil, rng.chance(0.5), !twistPool.isEmpty {
            let twist = rng.pick(twistPool)
            twistKey = twist.key
            chosenTwist = twist
            // A twist about the defendant's family is part of the family record.
            if twist.key == "caregiver", var profile = profiledDefendant.profile {
                profile.family = "Single, 3 children. Their other parent died last year."
                profiledDefendant.profile = profile
            }
            twistText = fill(twist.text).replacingOccurrences(of: "{JAILTIME}", with: jailedTime)
            if let m = twist.mitigating { mitigating.append(fill(m).replacingOccurrences(of: "{JAILTIME}", with: jailedTime)) }
            if let a = twist.aggravating { aggravating.append(fill(a)) }
            if let m = twist.mood { mood = m }
            media += twist.mediaBoost
            if let d = twist.doctrine { doctrines.append(d) }
        }
        if defendant.isReturning { media += 1 }
        media = min(3, max(1, media))
        doctrines.append(contentsOf: ["burdenOfProof", "juryWaiver", isFelonyCase ? "punishmentChart" : "misdemeanorSentencing", "aggravatingFactors"])

        // Ethics dilemma
        var ethics: EthicsEvent?
        if rng.chance(0.3) {
            var event = rng.pick(GenericPools.ethicsEvents(hasVictim: t.hasVictim, retainedCounsel: !usePublicDefender))
            event.body = fill(event.body)
            event.options = event.options.map { option in
                var o = option
                o.label = fill(o.label)
                o.result = fill(o.result)
                o.laterHeadline = o.laterHeadline.map { fill($0) }
                return o
            }
            ethics = event
        }

        // The hidden truth. Suppressed evidence still counts here: the truth doesn't care about the exclusionary rule.
        let rawStrength = evidence.reduce(0) { $0 + ($1.side == .prosecution ? $1.weight : -$1.weight) }
            + witnesses.reduce(0) { $0 + ($1.calledBy == .prosecution ? $1.weight : -$1.weight) }
        var guiltProbability = 0.5 + Double(rawStrength - primaryThreshold) * 0.08
        if let person = context.returning { guiltProbability += (person.propensity - 0.3) * 0.3 }
        guiltProbability = min(0.93, max(0.1, guiltProbability))
        let actuallyGuilty = rng.chance(guiltProbability)
        let truth = HiddenTruth(actuallyGuilty: actuallyGuilty,
                                revelation: fill(rng.pick(actuallyGuilty ? t.guiltyTruths : t.innocentTruths)))

        let summaryIndex = rng.int(0...(t.summaries.count - 1))
        let headlineIndex = rng.int(0...(t.headlines.count - 1))
        let extrasSignature = t.extras.keys.sorted().compactMap { values[$0] }.joined(separator: ",")
        let addOnSignature = addOns.map(\.lawID).joined(separator: ",") + (seriesCount > 0 ? ",x\(seriesCount)" : "")
        let signature = "\(t.key)|s\(summaryIndex)|h\(headlineIndex)|\(extrasSignature)" + (addOnSignature.isEmpty ? "" : "|+\(addOnSignature)")

        let yy = String(format: "%02d", currentYear % 100)
        let docket = "\(yy) \(isFelonyCase ? "CRS" : "CR") \(String(format: "%06d", context.docketSequence))"

        // What the defendant would say on the stand
        let strongestState = evidence.filter { $0.side == .prosecution }.max { $0.weight < $1.weight }
        let testimonyHolds = !actuallyGuilty || rng.chance(0.2)
        let testimony = Witness(
            name: defendant.name, role: "Defendant, testifying in their own defense", calledBy: .defense,
            direct: ["\(defendant.lastName) gives their account, consistent with the defense theory: " + fill(rng.pick(t.defenseTheory)),
                     rng.pick(["\"I want the court to hear it from me.\"",
                               "\"I've waited a long time to tell my side.\"",
                               "\"I'm not going to pretend I'm perfect. But I didn't do what they say.\""])],
            cross: testimonyHolds
                ? ["On cross, \(defendant.lastName) stays calm and consistent, and concedes only small details."]
                : ["On cross, \(defendant.lastName) has no explanation for \(strongestState.map { "\"\($0.title)\"" } ?? "the State's evidence") and contradicts an earlier statement."],
            weight: testimonyHolds ? 2 : -2,
            lay: true, isDefendant: true)
        var fullTestimony = testimony
        fullTestimony.exchanges = Testimony.defendant(testimony, ctx: testimonyContext, holds: testimonyHolds,
                                                      sessionDate: context.date, rng: &rng)
        if let story = t.story {
            fullTestimony.exchanges = story.defendantExam.map { line in
                TestimonyExchange(phase: line.phase, examiner: line.phase == .cross ? .prosecution : .defense,
                                  question: fill(line.question(0)), answer: fill(line.answer(0)))
            }
        }
        if let objection = t.story == nil && rng.chance(0.4) ? ObjectionEngine.make(for: fullTestimony, ctx: testimonyContext, rng: &rng) : nil {
            objections.append(objection)
        }

        let impactBase = t.victimImpacts.isEmpty ? nil : fill(rng.pick(t.victimImpacts))
        var background = makeBackground(t, defendant: defendant, charges: charges, values: values, mood: mood,
                                        publicDefender: usePublicDefender, mitigating: mitigating,
                                        isFelony: isFelonyCase, habitual: habitual, maxCustodyDays: maxCustodyDays,
                                        suppressionMotion: motions.contains { [MotionKind.suppressSearch, .suppressStatement, .suppressIdentification].contains($0.kind) },
                                        rng: &rng)
        // A statement asking for mercy means the family wants leniency, whatever else was drawn.
        let victimAgeForVoice = t.story?.victim?.age ?? VictimProfiles.statedAge(t.summaries.map { fill($0) }.joined(separator: " "),
                                                                              name: fill("{V}"), last: fill("{VL}"))
        // The stance follows what the statement itself says: mercy when it asks for mercy, punishment when it demands it.
        if !t.hasVictim && impactBase != nil && VictimVoice.asksMercy(impactBase) {
            background.victimStance = .wantsLeniency
            background.victimStanceDetail = "The one statement in the file asks the court not to send the defendant to prison."
        }
        if t.hasVictim && VictimVoice.asksHarsh(impactBase) && !VictimVoice.asksMercy(impactBase) && background.victimStance == .wantsLeniency {
            background.victimStance = .wantsMaximum
            background.victimStanceDetail = VictimVoice.position(stance: .wantsMaximum, victim: fill("{VL}"), defendant: fill("{DL}"),
                                                                 category: t.category, died: t.victimDies,
                                                                 child: victimAgeForVoice.map { $0 < 16 } ?? false,
                                                                 restitutionBasis: background.restitutionBasis,
                                                                 cls: LawLibrary.lawIfPresent(t.primaryLaw)?.ncClass,
                                                                 young: victimAgeForVoice.map { $0 < 30 } ?? false, rng: &rng)
        }
        if t.hasVictim && VictimVoice.asksMercy(impactBase) && background.victimStance != .wantsLeniency {
            background.victimStance = .wantsLeniency
            background.victimStanceDetail = VictimVoice.position(stance: .wantsLeniency, victim: fill("{VL}"), defendant: fill("{DL}"),
                                                                 category: t.category, died: t.victimDies,
                                                                 child: victimAgeForVoice.map { $0 < 16 } ?? false,
                                                                 restitutionBasis: background.restitutionBasis,
                                                                 cls: LawLibrary.lawIfPresent(t.primaryLaw)?.ncClass,
                                                                 young: victimAgeForVoice.map { $0 < 30 } ?? false, rng: &rng)
        }
        let victimImpact = impactBase.map { VictimVoice.impact($0, stance: background.victimStance, defendant: fill("{DL}"),
                                                                died: t.victimDies, rng: &rng) }
        if let twist = chosenTwist {
            if twist.trialOnly && background.arrangementPresented == true {
                twistText = nil
                if let a = twist.aggravating { aggravating.removeAll { $0 == fill(a) } }
            }
            if twistKey == "jailed" {
                background.custodyDays = jailedDays
                background.bondStatus = "Held in the Hollis County jail on a $5,000 secured bond for \(jailedDays) days."
            }
            if twistKey == "rehab" && background.custodyDays > 0 {
                background.custodyDays = 0
                background.bondStatus = "Released on a secured bond. Has made every court date."
            }
        }

        return CourtCase(
            seed: seed,
            templateKey: t.key,
            docket: docket,
            court: court,
            sessionDate: context.date,
            headline: fill(t.headlines[headlineIndex]),
            category: t.category,
            summary: fill(t.summaries[summaryIndex]),
            defendant: profiledDefendant,
            victimName: victimName,
            charges: charges,
            habitualIndicted: habitual,
            proceduralNotes: notes,
            motions: motions,
            prosecutor: "ADA \(prosecutor)",
            defenseAttorney: usePublicDefender ? "\(defenseLawyer), Assistant Public Defender" : "\(defenseLawyer), retained counsel",
            investigatingAgency: detective.agency,
            // The lawyers speak to the judge they have: what the courthouse thinks of this judge colors how they open and close.
            prosecutionOpening: Reputation.opening(fill(t.story?.prosecutionOpening ?? rng.pick(t.prosecutionTheory)), side: .prosecution, seed: seed),
            defenseOpening: Reputation.opening(fill(t.story?.defenseOpening ?? rng.pick(t.defenseTheory)), side: .defense, seed: seed),
            // Without a written closing, one is built from the evidence when it's delivered (Allocutions.closing).
            prosecutionClosing: t.story.map { Reputation.closing(fill($0.prosecutionClosing), side: .prosecution, seed: seed) } ?? "",
            defenseClosing: t.story.map { Reputation.closing(fill($0.defenseClosing), side: .defense, seed: seed) } ?? "",
            evidence: evidence,
            witnesses: witnesses,
            objections: objections,
            aggravating: aggravating,
            mitigating: mitigating,
            // A family asking for mercy doesn't also ask the judge to be tough.
            victimImpact: victimImpact.map { background.victimStance == .wantsLeniency ? $0 : Reputation.insideQuote($0, CourthouseMood.current.familyPlea(seed: seed)) },
            // Cases without a written statement get one built from their facts when the defendant speaks (Allocutions).
            allocution: t.allocutions.isEmpty ? "" : Reputation.insideQuote(fill(rng.pick(t.allocutions)), CourthouseMood.current.defendantPlea(seed: seed)),
            twist: twistText,
            ethics: ethics,
            mood: mood,
            mediaAttention: media,
            truth: truth,
            relatedDoctrines: doctrines,
            background: background,
            scenarioSignature: signature,
            defendantTestimony: fullTestimony,
            investigation: investigation
        )
    }

    // MARK: - Background known to counsel

    /// The first dollar figure in a text, e.g. "$14,000" or "$2.3 million".
    private static func firstDollarAmount(in text: String) -> Int? {
        guard let range = text.range(of: "\\$[0-9][0-9,]*(\\.[0-9]+)?( million)?", options: .regularExpression) else { return nil }
        let value = dollars(in: String(text[range]))
        return value.map { max(100, $0) }
    }

    private static func dollars(in text: String?) -> Int? {
        guard let text else { return nil }
        let lower = text.lowercased()
        let digits = lower.filter { $0.isNumber || $0 == "." }
        guard let value = Double(digits) else { return nil }
        if lower.contains("million") { return Int(value * 1_000_000) }
        return Int(value)
    }

    private static func makeBackground(_ t: CaseTemplate, defendant: Defendant, charges: [Charge], values: [String: String],
                                       mood: PublicMood, publicDefender: Bool, mitigating: [String], isFelony: Bool,
                                       habitual: Bool, maxCustodyDays: Int, suppressionMotion: Bool = false,
                                       rng: inout SeededRNG) -> CaseBackground {
        let fill = TextFiller(values: values)
        let primary = charges[0]

        // What the punishment chart allows for a class at this defendant's record level, so no deal promises
        // a sentence the court couldn't lawfully impose. Nil when the chart doesn't govern (e.g. impaired driving).
        let record = PriorRecord(priors: defendant.priors, onSupervision: defendant.underSupervision)
        func allowed(_ cls: NCClass?) -> [Disposition]? {
            guard let cls else { return nil }
            if cls.isFelony { return StructuredSentencing.felonyCell(cls, level: record.felonyLevel)?.dispositions ?? [.active] }
            return StructuredSentencing.misdemeanorCell(cls, level: record.misdemeanorLevel)?.dispositions
        }
        func canSuspend(_ cls: NCClass?) -> Bool {
            allowed(cls).map { $0.contains(.community) || $0.contains(.intermediate) } ?? true
        }
        /// Class A has no ranges at all, only life or death.
        func hasRanges(_ cls: NCClass?) -> Bool {
            guard let cls, cls.isFelony else { return true }
            return StructuredSentencing.felonyCell(cls, level: record.felonyLevel) != nil
        }

        // Plea negotiations
        var pleaOffer: String?
        var pleaRejection: String?
        var offerClass: NCClass?
        if rng.chance(0.65) {
            offerClass = primary.lesserLaw?.ncClass ?? primary.law.ncClass
            if let lesser = primary.lesserLaw, let cls = lesser.ncClass {
                pleaOffer = rng.pick([
                    "Plead guilty to \(lesser.title) (\(cls.shortLabel)), remaining charges dismissed, sentencing in the court's discretion.",
                    cls.isFelony
                        ? "Plead guilty to \(lesser.title) (\(cls.shortLabel)) with a sentence at the bottom of the presumptive range."
                        : "Plead guilty to \(lesser.title) (\(cls.shortLabel)) with a sentence at the low end of the authorized range."
                ])
            } else if isFelony {
                var offers = ["Plead guilty as charged, remaining charges dismissed, sentencing in the court's discretion."]
                if hasRanges(primary.law.ncClass) { offers.append("Plead guilty as charged with a mitigated-range sentence, remaining charges dismissed.") }
                if canSuspend(primary.law.ncClass) { offers.append("Plead guilty as charged; the State would not oppose a suspended sentence.") }
                pleaOffer = rng.pick(offers)
            } else {
                pleaOffer = "Plead guilty and receive a prayer for judgment continued on payment of costs."
            }
            // The reason has to fit the offer, the motions, and the client.
            var reasons = ["My client maintains their innocence, Judge. They won't plead to something they didn't do.",
                           "My client was worried about immigration consequences of any conviction."]
            let pjc = pleaOffer?.contains("prayer for judgment") ?? false
            if (offerClass?.isFelony ?? false) && !defendant.priors.contains(where: { $0.ncClass.isFelony }) {
                reasons.append("Even the reduced charge carried a felony record, and that would end my client's career.")
            }
            if suppressionMotion {
                reasons.append("We think the suppression issue is strong, and my client wanted it decided.")
            }
            if !pjc && (offerClass?.isFelony ?? false) {
                reasons.append("The offer still left an active sentence on the table, and my client couldn't accept that.")
            }
            if pjc { reasons.append("Even a prayer for judgment is a conviction on the record, and my client wanted a trial.") }
            pleaRejection = rng.pick(reasons)
        }

        // Custody
        // The bond fits the charge: the same draw as before, scaled to the most serious count's class. The most serious
        // charges almost always mean jail until trial; a murder charge is usually held without bond.
        let worstClass = charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let gravest = [NCClass.A, .B1, .B2].contains(worstClass ?? .misd1)
        let serious = gravest || [NCClass.C, .D].contains(worstClass ?? .misd1)
        let inCustody = rng.chance(gravest ? 0.9 : (serious ? 0.7 : 0.45)) && maxCustodyDays > 0
        let custodyDays = inCustody ? min(rng.int(21...420), maxCustodyDays) : 0
        let bondFactor = rng.pick([0.5, 0.75, 1.0, 1.5, 2.0])
        let bond = "$" + CalendarCalls.roundBond(Double(CalendarCalls.bondBase(worstClass)) * bondFactor).formatted()
        let bondStatus = inCustody
            ? (gravest && rng.chance(0.6)
                ? "Held without bond in the Hollis County jail for \(custodyDays) days."
                : "Held in the Hollis County jail on a \(bond) secured bond for \(custodyDays) days.")
            : rng.pick(["Released on a \(bond) secured bond. Has made every court date.",
                        serious ? "Released on a \(bond) secured bond with electronic monitoring." : "Released on a written promise to appear, with electronic monitoring.",
                        "Released on a \(bond) secured bond; missed one court date early on, then was re-released."])

        // Restitution
        var restitution = 0
        var basis: String?
        switch t.key {
        case "storeRobbery":
            restitution = dollars(in: values["AMT"]) ?? 400; basis = "cash taken from the register"
        case "burglary":
            restitution = rng.int(3...16) * 1_000; basis = "unrecovered property and window repair"
        case "embezzlement", "elderScam":
            restitution = dollars(in: values["AMT"]) ?? 50_000; basis = "funds taken"
        case "ponzi":
            restitution = dollars(in: values["AMT"]) ?? 5_000_000; basis = "investor losses"
        case "insuranceArson":
            restitution = 640_000; basis = "insurer's payout exposure and the firefighter's medical bills"
        case "ransomware":
            restitution = rng.int(8...25) * 100_000; basis = "the hospital's recovery costs"
        case "barFight", "abusedSpouse", "poisoning", "drunkCrash", "overdose":
            restitution = rng.int(7...16) * 1_000; basis = "funeral expenses"
        case "protestAssault", "policeForce":
            restitution = rng.int(12...70) * 1_000; basis = "medical bills"
        case "imageLeak", "stalking":
            restitution = rng.int(2...9) * 500; basis = "counseling costs and lost wages"
        default:
            break
        }
        // Every other case with someone who lost money or was hurt: the State asks for what it can document.
        if restitution == 0 && rng.chance(0.85) {
            let text = fill(t.specification) + " " + t.secondary.map { fill($0.specification) }.joined(separator: " ")
            let stated = firstDollarAmount(in: text)
            let died = t.victimDies
            switch t.category {
            case .property:
                restitution = stated ?? rng.int(6...80) * 100; basis = rng.pick(["unrecovered property and repairs", "the value of what was taken and the damage to the door", "replacement costs the owner documented"])
            case .robbery:
                restitution = stated ?? rng.int(3...25) * 100; basis = rng.pick(["cash and property taken", "the stolen money and a replaced phone", "what was taken and the victim's lost wages"])
            case .whiteCollar, .cyber:
                restitution = stated ?? rng.int(4...90) * 1_000; basis = rng.pick(["money taken", "documented losses", "the victims' losses, per the bank records"])
            case .violent, .family, .traffic:
                let contactless = ["stalking", "stalkingCourtOrder", "cyberstalking", "communicatingThreats", "witnessIntimidation",
                                   "dvpoViolation", "assaultPointingGun"].contains(t.primaryLaw)
                if died {
                    restitution = rng.int(7...18) * 1_000; basis = "funeral and burial expenses"
                } else if contactless {
                    if rng.chance(0.5) { restitution = rng.int(3...20) * 100; basis = rng.pick(["counseling costs", "new locks and a security camera", "counseling and a changed phone number"]) }
                } else if t.hasVictim {
                    restitution = rng.int(8...90) * 100 * (t.category == .traffic ? 4 : 1)
                    basis = t.category == .traffic ? rng.pick(["medical bills and vehicle damage", "the victim's medical bills"])
                        : rng.pick(["medical bills", "emergency room and follow-up care", "medical bills and lost wages", "counseling and medical costs"])
                }
            default:
                break
            }
        }

        // Victim stance
        let stance: VictimStance
        let stanceDetail: String
        if t.hasVictim {
            switch mood {
            case .sympathetic:
                stance = rng.chance(0.6) ? .wantsLeniency : .wantsAccountability
            case .wantsConviction:
                stance = rng.chance(0.6) ? .wantsMaximum : .wantsAccountability
            default:
                stance = rng.pick([.wantsMaximum, .wantsAccountability, .wantsLeniency])
            }
            // The victim's age, as the story gives it or as the summary states it ("{V}, 14,").
            let victimAge = t.story?.victim?.age ?? VictimProfiles.statedAge(t.summaries.map { fill($0) }.joined(separator: " "),
                                                                          name: fill("{V}"), last: fill("{VL}"))
            let child = victimAge.map { $0 < 16 } ?? false
            stanceDetail = VictimVoice.position(stance: stance, victim: fill("{VL}"), defendant: fill("{DL}"), category: t.category,
                                                died: t.victimDies, child: child, restitutionBasis: basis,
                                                cls: LawLibrary.lawIfPresent(t.primaryLaw)?.ncClass, young: victimAge.map { $0 < 30 } ?? false, rng: &rng)
        } else if t.story != nil && !t.victimImpacts.isEmpty {
            // No single named victim, but people were hurt, and their statements are in the file.
            stance = .wantsAccountability
            stanceDetail = t.victimImpacts.count == 1 ? VictimVoice.singlePosition(rng: &rng) : VictimVoice.groupPosition(rng: &rng)
        } else {
            stance = .none
            stanceDetail = "There's no individual victim in this case, Judge."
        }

        // Treatment
        let need: TreatmentNeed
        if t.category == .drugs || t.key == "drunkCrash" {
            need = rng.chance(0.75) ? (rng.chance(0.2) ? .both : .substance) : .none
        } else if defendant.background.lowercased().contains("depression") || defendant.background.lowercased().contains("ptsd") {
            need = rng.chance(0.7) ? .mentalHealth : .both
        } else {
            let roll = Double.random(in: 0..<1, using: &rng)
            need = roll < 0.22 ? .substance : (roll < 0.36 ? .mentalHealth : (roll < 0.42 ? .both : .none))
        }
        let treatmentDetail: String?
        switch need {
        case .none: treatmentDetail = nil
        case .substance: treatmentDetail = rng.pick(["An opioid use disorder going back about six years.", "Alcohol, Judge. It's been the thread through everything.", "Methamphetamine use that started after a back injury at work."])
        case .mentalHealth: treatmentDetail = rng.pick(["Diagnosed bipolar disorder, untreated since losing Medicaid coverage.", "Severe depression, with one hospitalization last year.", "PTSD, documented by the VA."])
        case .both: treatmentDetail = "Co-occurring: a substance use disorder layered on untreated depression."
        }

        // Life circumstances
        // Plans and supporters fit the person: age, work, and whether the partner is the victim.
        let age = defendant.age
        let job = defendant.occupation.lowercased()
        let current = defendant.profile?.currentJob
        let working = DefendantProfile.isWork(job) && (defendant.profile == nil || current != nil)
        var plans = ["Moving in with family in {HOOD}, away from the people involved in this case."]
        if age < 50 { plans += ["A job offer from a roofing company in {HOOD}, starting the Monday after sentencing.",
                                "Enrollment in the welding program at Hollis Community College this spring."] }
        if working { plans.append("Return to work as \((current?.title.lowercased() ?? job).withIndefiniteArticle). The employer wrote a letter.") }
        let family = defendant.profile
        let kids = family?.childCount ?? 0
        if age >= 60 && kids > 0 { plans.append("Living quietly at home, with a grown child checking in every day.") }
        let plan: String? = rng.chance(0.6) ? fill(rng.pick(plans)) : nil
        let indigent = publicDefender ? rng.chance(0.85) : rng.chance(0.2)
        let partnerIsVictim = t.victimDies && t.category == .family
            || ["spouse", "wife", "husband", "partner"].contains { word in t.summaries.contains { $0.contains("{D.his} \(word), {V") } }
            || defendant.profile?.familyIsVictim == true
        var supporters = ["My client's family and their pastor are in the gallery today.",
                          "A former employer drove in from Raleigh to be here."]
        // Only people the profile says exist come to court.
        let partner = !partnerIsVictim && (family?.married == true || family?.partnered == true)
        if partner && kids > 0 && age < 60 { supporters.append("My client's \(family?.married == true ? "spouse" : "partner") is here, along with my client's children.") }
        else if partner { supporters.append("My client's \(family?.married == true ? "spouse" : "partner") is in the gallery today.") }
        else if kids > 0 && age < 60 && !partnerIsVictim { supporters.append("My client's children are here with their grandmother.") }
        if age < 35 { supporters.append("The client's grandmother, who raised them, is in the second row.") }
        if age >= 60 && kids > 0 && !partnerIsVictim { supporters.append("My client's grown children are here today.") }
        let support: String? = rng.chance(0.6) ? rng.pick(supporters) : nil
        let discovery: String? = rng.chance(0.25) ? rng.pick([
            "The State Crime Laboratory report arrived late; we turned it over nine days before trial.",
            "A supplemental police report surfaced last week and was disclosed immediately.",
            "Body camera footage from a second officer was located and disclosed on Friday."
        ]) : nil

        let hiddenMitigatorPool = [
            "The defendant voluntarily acknowledged wrongdoing at an early stage of the criminal process",
            "The defendant supports the defendant's family",
            "The defendant has been a person of good character or has had a good reputation in the community",
            "The defendant has successfully completed a substance abuse program while in custody",
            "The defendant was suffering from a mental condition that significantly reduced culpability"
        ].filter { !mitigating.contains($0) }
        let hiddenAggravatorPool = [
            "The defendant committed the offense while on pretrial release on another charge",
            "The defendant attempted to contact a State's witness from the jail",
            "The defendant has been found in willful violation of probation within the past 10 years"
        ]

        let violent = t.category == .violent || t.category == .robbery

        // Sometimes the parties reach a deal and present it to the court before trial.
        var arrangementPresented = false
        var arrangementLawID: String?
        var arrangementTerms: String?
        var arrangementHabitual: Bool?
        var arrangementKind: String?
        // A written case is meant to be tried, so it never arrives as a negotiated plea.
        if t.story == nil && pleaOffer != nil && rng.chance(0.3) {
            arrangementPresented = true
            let pleaLaw = primary.lesserLaw ?? primary.law
            arrangementLawID = pleaLaw.id
            let pleaFelony = pleaLaw.ncClass?.isFelony ?? false
            var dismissed = charges.count > 1 ? " The State will dismiss the remaining counts." : ""
            if habitual {
                if pleaFelony && rng.chance(0.5) {
                    arrangementHabitual = true
                    dismissed += " The defendant admits habitual felon status and will be sentenced as a habitual felon."
                } else {
                    arrangementHabitual = false
                    dismissed += " The State will dismiss the habitual felon indictment."
                }
            }
            let probationTerms = restitution > 0
                ? "a suspended sentence with supervised probation and \(restitution.formatted(.currency(code: "USD").precision(.fractionLength(0)))) in restitution"
                : "a suspended sentence with supervised probation"
            let bottom = pleaFelony ? "a sentence at the bottom of the presumptive range" : "a sentence at the low end of the authorized range"
            // Only recommendations the punishment chart allows for the class pleaded to (as a habitual felon, if admitted).
            var pleaClass = pleaLaw.ncClass
            if arrangementHabitual == true, let cls = pleaClass { pleaClass = StructuredSentencing.habitualClass(for: cls) }
            var kinds = ["open"]
            if hasRanges(pleaClass) { kinds.append("bottom") }
            if canSuspend(pleaClass) { kinds.append("suspended") }
            let kind = rng.pick(kinds)
            arrangementKind = kind
            let withdrawNote = " If the court decides on a harsher sentence, the defendant may withdraw the plea (G.S. 15A-1024)."
            switch kind {
            case "bottom":
                arrangementTerms = "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) The State recommends \(bottom).\(withdrawNote)"
            case "suspended":
                arrangementTerms = "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) The parties jointly recommend \(probationTerms).\(withdrawNote)"
            default:
                arrangementTerms = "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) Sentencing is left to the discretion of the court."
            }
            pleaRejection = nil
        }

        // Notice, disputed priors, and the posture below
        let probationNotice: Bool? = defendant.probation == nil ? nil : rng.chance(0.75)
        var disputedID: UUID?
        var disputedReason: String?
        if !defendant.priors.isEmpty && rng.chance(0.2) {
            let prior = rng.pick(defendant.priors.filter { !$0.fromThisCourt }.isEmpty ? defendant.priors : defendant.priors.filter { !$0.fromThisCourt })
            disputedID = prior.id
            disputedReason = rng.pick([
                "The State's only proof of the \(prior.year) \(prior.offense) conviction is a DCI printout. My client says that was a cousin with the same name, and the date of birth on the printout is off by a year.",
                "The \(prior.year) \(prior.offense) in \(prior.county) was a plea without counsel, Judge, and there's no waiver of counsel in the file.",
                "We dispute the \(prior.year) \(prior.offense). The State has no judgment, just a line in a statewide database, and the file number doesn't match."
            ])
        }
        var districtSentence: String?
        if !isFelony, let cls = primary.law.ncClass {
            // Within the chart for the class and record level: no more days than allowed, and active only where permitted.
            let cell = StructuredSentencing.misdemeanorCell(cls, level: record.misdemeanorLevel)
            let wanted = cls == .misdA1 ? rng.int(30...75) : (cls == .misd1 ? rng.int(20...45) : rng.int(10...30))
            let days = min(wanted, cell?.maxDays ?? wanted)
            let activeAllowed = cell?.dispositions.contains(.active) ?? true
            districtSentence = rng.chance(0.5) || !activeAllowed
                ? "\(days) days suspended, 12 months supervised probation"
                : "\(days) days active"
        }

        return CaseBackground(
            pleaOffer: pleaOffer,
            pleaRejection: pleaRejection,
            custodyDays: custodyDays,
            bondStatus: bondStatus,
            restitution: restitution,
            restitutionBasis: basis,
            victimStance: stance,
            victimStanceDetail: stanceDetail,
            treatmentNeed: need,
            treatmentDetail: treatmentDetail,
            treatmentBedAvailable: rng.chance(0.5),
            employmentPlan: plan,
            indigent: indigent,
            supportPeople: support,
            willTestify: rng.chance(defendant.priors.contains { $0.ncClass.isFelony } ? 0.45 : 0.7),
            discoveryIssue: discovery,
            stateObjectsToASR: rng.chance(violent ? 0.7 : 0.3),
            hiddenMitigator: rng.chance(0.7) && !hiddenMitigatorPool.isEmpty ? rng.pick(hiddenMitigatorPool) : nil,
            hiddenAggravator: rng.chance(0.4) ? rng.pick(hiddenAggravatorPool) : nil,
            attorneyFeeEstimate: isFelony ? rng.int(15...45) * 100 : rng.int(3...8) * 100,
            arrangementPresented: arrangementPresented,
            arrangementLawID: arrangementLawID,
            arrangementTerms: arrangementTerms,
            arrangementHabitual: arrangementHabitual,
            probationPointNotice: probationNotice,
            disputedPriorID: disputedID,
            disputedPriorReason: disputedReason,
            stateJoinsDischarge: stance == .wantsMaximum ? false : rng.chance(t.hasVictim ? 0.4 : 0.65),
            districtCourtSentence: districtSentence,
            arrangementKind: arrangementKind,
            stateConsentsNoContest: !t.hasVictim && rng.chance(0.6)
        )
    }

    private static func randomPriors(age: Int, year: Int, county: County, rng: inout SeededRNG) -> [PriorConviction] {
        let roll = Double.random(in: 0..<1, using: &rng)
        let count: Int
        if roll < 0.45 { count = 0 }
        else if roll < 0.72 { count = rng.int(1...2) }
        else if roll < 0.9 { count = rng.int(3...4) }
        else { count = rng.int(5...7) }
        guard count > 0 else { return [] }

        let earliest = year - max(1, min(age - 17, 20))
        let latest = year - 1
        guard earliest <= latest else { return [] }

        var priors: [PriorConviction] = []
        for _ in 0..<count {
            let seed = rng.pick(GenericPools.priorSeeds)
            if let last = priors.last, rng.chance(0.15) {
                // Two convictions entered in the same session of court.
                let key = last.sessionKey ?? UUID().uuidString
                priors[priors.count - 1].sessionKey = key
                priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: last.year,
                                              county: last.county, sentence: rng.pick(seed.sentences), sessionKey: key))
                continue
            }
            let where_ = rng.chance(0.55) ? county.name : rng.pick(GenericPools.otherCounties)
            priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: rng.int(earliest...latest),
                                          county: where_, sentence: rng.pick(seed.sentences)))
        }
        return priors.sorted { $0.year < $1.year }
    }

    private static func makeWitness(_ seed: WitnessSeed, side: Side, fill: TextFiller,
                                    rng: inout SeededRNG, used: inout Set<String>, impeach: Bool = true,
                                    regulars: [String: String] = [:], residents: [ResidentRef] = [], hood: String = "",
                                    reserved: Set<String> = []) -> Witness {
        let name: String
        var recalled: String?
        if let token = seed.name {
            name = fill(token)
        } else if let key = Gazetteer.regularKey(forRole: fill(seed.role)), let regular = regulars[key], !used.contains(regular) {
            // The county's medical examiner, lab analysts and ER doctor are the same people case after case.
            name = regular
            used.insert(regular)
        } else {
            // A role that names a woman or a man ("the victim's mother", "{DL}'s brother") gets a name to match.
            let role = " " + fill(seed.role).lowercased() + " "
            func says(_ words: [String]) -> Bool { words.contains { role.range(of: "\\b\($0)\\b", options: .regularExpression) != nil } }
            let female = says(["mother", "sister", "daughter", "wife", "girlfriend", "aunt", "niece", "grandmother", "granddaughter",
                               "stepmother", "stepdaughter", "woman", "mom", "widow", "fiancée"])
            let male = says(["father", "brother", "son", "husband", "boyfriend", "uncle", "nephew", "grandfather", "grandson",
                             "stepfather", "stepson", "man", "dad", "widower", "fiancé"])
            let gender: Gender? = female && !male ? .female : (male && !female ? .male : nil)
            // Someone the court has seen before, when the role fits them: the same bartender, a neighbor from that town.
            if seed.lay, let known = Residents.pick(for: fill(seed.role), gender: gender, town: hood, from: residents, used: used, rng: &rng) {
                name = known.name
                used.insert(known.name)
                recalled = known.lastCaption
            } else {
                // A new face never shares a name with someone the court already knows.
                let known = Set(residents.map(\.name)).union(reserved)
                let fresh = NameBank.person(using: &rng, excluding: &used, gender: gender, avoiding: known)
                name = fresh
            }
        }
        var cross = fill(seed.cross)
        var weight = seed.weight
        let isVictim = seed.name == "{V}"
        if impeach && seed.lay && rng.chance(0.45) {
            let pool = (side == .prosecution ? GenericPools.prosecutionImpeachments : GenericPools.defenseImpeachments)
                .filter { !isVictim || $0.victimSafe }
            let impeachment = rng.pick(pool)
            cross.append(fill(impeachment.text))
            weight = max(0, weight - impeachment.penalty)
        }
        var witness = Witness(name: name, role: fill(seed.role), calledBy: side, direct: fill(seed.direct), cross: cross, weight: weight,
                              lay: seed.lay)
        if !seed.exam.isEmpty {
            let opposing: Side = side == .prosecution ? .defense : .prosecution
            let versions = seed.exam.map { max($0.answers.count, $0.questions.count) }.max() ?? 1
            let version = rng.int(0...(max(1, versions) - 1))
            // A short examination keeps every line it has.
            let keepAll = seed.exam.count <= 3
            var exchanges = seed.exam.filter { keepAll || !$0.optional || rng.chance(0.6) }.map { line in
                TestimonyExchange(phase: line.phase, examiner: line.phase == .cross ? opposing : side,
                                  question: fill(line.question(version)), answer: fill(line.answer(version)))
            }
            // A witness with only a question or two gets a fuller examination from what the case already says
            // about them: who they are, their own account, and the point the other side presses on cross.
            if exchanges.count < 4 {
                let said = Set(exchanges.map { $0.answer })
                // "Victim's mother" → "the victim's mother"; "Lead detective" → "the lead detective".
                let role = witness.role
                let lowerRole = role.prefix(1).lowercased() + role.dropFirst()
                let who = ["victim's", "defendant's", "the ", "lead ", "first ", "responding ", "chief ", "head "].contains { lowerRole.hasPrefix($0) }
                    ? (lowerRole.hasPrefix("the ") ? lowerRole : "the " + lowerRole)
                    : Testimony.withArticle(role)
                let official = Testimony.isOfficial(witness.role)
                var direct: [TestimonyExchange] = [
                    TestimonyExchange(phase: .direct, examiner: side, question: "Please tell the court who you are.",
                                      answer: "\"\(name). I'm \(who).\"")
                ]
                for line in witness.direct where !said.contains(line) && !line.isEmpty {
                    direct.append(TestimonyExchange(phase: .direct, examiner: side,
                                                    question: official ? "What did your work in this case show?" : "In your own words, what happened?",
                                                    answer: line))
                    break
                }
                exchanges.insert(contentsOf: direct.prefix(max(1, 4 - exchanges.count)), at: 0)
                if !exchanges.contains(where: { $0.phase == .cross }) {
                    for line in seed.cross.map({ fill($0) }) where !said.contains(line) {
                        if let question = Testimony.leadingQuestion(from: line, rng: &rng) {
                            let at = exchanges.firstIndex { $0.phase == .redirect } ?? exchanges.count
                            exchanges.insert(TestimonyExchange(phase: .cross, examiner: opposing, question: question, answer: line), at: at)
                            break
                        }
                    }
                }
            }
            // A generic credibility problem drawn on cross shows up as a narrated moment before redirect.
            let extra = cross.count > seed.cross.count ? cross.last : nil
            if let extra {
                let insertAt = exchanges.firstIndex { $0.phase == .redirect } ?? exchanges.count
                exchanges.insert(TestimonyExchange(phase: .cross, examiner: opposing, question: "", answer: extra), at: insertAt)
            }
            // A witness who has been here before says so.
            if let recalled {
                let at = exchanges.firstIndex { $0.phase != .direct } ?? exchanges.count
                exchanges.insert(TestimonyExchange(phase: .direct, examiner: side, question: "Have you testified in this courtroom before?",
                                                   answer: "\"Yes. In \(recalled).\""), at: min(at, 1))
            }
            witness.exchanges = exchanges
            witness.direct = exchanges.filter { $0.phase == .direct }.map(\.answer)
            witness.cross = exchanges.filter { $0.phase != .direct }.map(\.answer)
        }
        return witness
    }

    private static func makeMotion(_ seed: MotionSeed, target: UUID?, targetTitle: String?, fill: TextFiller) -> Motion {
        let item = targetTitle.map { "\"\($0)\"" } ?? "the case"
        let defense: String
        let prosecution: String
        switch seed.kind {
        case .suppressSearch:
            defense = "The defense moves under G.S. 15A-974 to suppress \(item) as the product of an unconstitutional search."
            prosecution = "The State contends the search was lawful, or that an exception to the warrant requirement applies."
        case .suppressStatement:
            defense = "The defense moves to suppress \(item), arguing it was obtained in violation of the defendant's constitutional rights."
            prosecution = "The State contends the statement was voluntary and lawfully obtained."
        case .dismissSpeedyTrial:
            defense = "The defense moves to dismiss all charges for violation of the right to a speedy trial."
            prosecution = "The State contends the delay was justified and caused no prejudice."
        case .suppressIdentification:
            defense = "The defense moves to suppress \(item) and any in-court identification as the product of an unnecessarily suggestive procedure."
            prosecution = "The State contends the procedure was proper and the identification is reliable under the totality of the circumstances."
        case .excludePriorActs:
            defense = "The defense moves in limine to exclude \(item) under Rules 404(b) and 403."
            prosecution = "The State contends the evidence is admissible for a proper purpose: motive, intent, plan, or identity."
        case .dismissIndictment:
            defense = "The defense moves to dismiss the count as facially defective (G.S. 15A-924, 15A-954)."
            prosecution = "The State contends the indictment alleges every element and gave the defendant fair notice."
        }
        return Motion(kind: seed.kind, facts: fill(seed.facts), defenseArgument: defense, prosecutionResponse: prosecution,
                      targetEvidenceID: target, shouldGrant: seed.shouldGrant, appellateNote: fill(seed.explanation),
                      doctrineIDs: seed.doctrines)
    }

    private static func lastName(_ name: String) -> String {
        name.components(separatedBy: " ").last ?? name
    }
}

extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
