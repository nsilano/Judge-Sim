import Foundation

/// An application for a search warrant brought to the judge in chambers (G.S. 15A-243 to 15A-246): the officer's
/// sworn affidavit, the place to be searched, and the items to be seized. The judge decides whether the
/// affidavit shows probable cause under the totality of the circumstances (Illinois v. Gates; State v. Arrington).
struct WarrantApplication: Codable, Hashable {
    enum Kind: String, Codable {
        case residenceDrugs, storageStolen, phoneRecords, bloodDraw, bankRecords, digitalAccounts, dnaSample, residenceWeapons
        case vehicleSearch, medicalRecords

        var label: String {
            switch self {
            case .residenceDrugs: return "Residence: controlled substances"
            case .storageStolen: return "Storage unit: stolen property"
            case .phoneRecords: return "Cell phone and location records"
            case .bloodDraw: return "Blood sample: impaired driving"
            case .bankRecords: return "Bank and financial records"
            case .digitalAccounts: return "Email, social media, and device contents"
            case .dnaSample: return "DNA sample (cheek swab)"
            case .residenceWeapons: return "Residence: firearm and clothing"
            case .vehicleSearch: return "Vehicle: contraband, stolen property, or evidence"
            case .medicalRecords: return "Hospital records: injuries and toxicology"
            }
        }

        /// The kinds of case a search like this turns into.
        var categories: Set<LawCategory> {
            switch self {
            case .residenceDrugs: return [.drugs]
            case .storageStolen: return [.property]
            case .phoneRecords: return [.robbery, .violent, .whiteCollar, .cyber]
            case .bloodDraw: return [.traffic]
            case .bankRecords: return [.whiteCollar]
            case .digitalAccounts: return [.cyber]
            case .dnaSample, .residenceWeapons: return [.violent, .robbery]
            case .vehicleSearch: return [.drugs, .property, .violent, .robbery, .traffic]
            case .medicalRecords: return [.violent]
            }
        }
    }

    /// What is wrong with the affidavit, if anything. Never shown before the ruling.
    enum Flaw: String, Codable {
        case none
        /// An anonymous tip the officers never corroborated (Florida v. J.L.; State v. Benters).
        case anonymousTip
        /// The information is months old, with nothing suggesting the evidence is still there.
        case stale
        /// Facts about the suspect, but nothing tying the evidence to this place.
        case noNexus
        /// Probable cause is fine, but the items to be seized include a catch-all that isn't particular.
        case overbroad
        /// An informant with no record of reliability and nothing to back the claim up (Illinois v. Gates; State v. Arrington).
        case unreliableInformant
        /// The affidavit was signed but the officer was never put under oath (G.S. 15A-244).
        case unsworn
        /// The place to be searched is described too loosely to be found without guessing (G.S. 15A-246).
        case wrongPlace
    }

    var kind: Kind
    var affiant: String
    var agency: String
    var applied: Date
    var target: String
    var place: String
    var items: [String]
    var affidavit: [String]
    var flaw: Flaw

    var probableCause: Bool { flaw == .none || flaw == .overbroad }

    /// Why the ruling is right or wrong, shown when the case it leads to is reviewed.
    var explanation: String {
        switch flaw {
        case .none:
            return "The affidavit set out first-hand observations and corroborated information tying evidence of a crime to the place to be searched. That is probable cause under the totality of the circumstances (Illinois v. Gates; G.S. 15A-245)."
        case .overbroad:
            return "The facts supported probable cause, but the catch-all for \"any and all\" papers and electronic devices failed the particularity requirement (G.S. 15A-246(4)). The careful course was to strike it and sign the rest; the particular items can be severed and upheld."
        case .anonymousTip:
            return "An anonymous tip, uncorroborated except for innocent details anyone could see, does not supply probable cause (Florida v. J.L.; State v. Benters). North Carolina recognizes no good-faith exception for a warrant issued without probable cause (State v. Carter, 322 N.C. 709 (1988))."
        case .stale:
            return "The information was months old, and nothing in the affidavit suggested an ongoing operation that would leave evidence in place. Stale information doesn't establish probable cause that evidence is there now (State v. Lindsey)."
        case .noNexus:
            return "The affidavit showed the suspect may be involved in crime but gave no reason to believe evidence would be found at this place. Probable cause requires a nexus between the items sought and the place searched (State v. Campbell, 282 N.C. 125 (1972))."
        case .unreliableInformant:
            return "The only source was an informant with no record of reliable tips, often with a reason to curry favor, and nothing from the officers to back the account up. Under the totality of the circumstances (Illinois v. Gates; State v. Arrington) the court weighs the informant's veracity and basis of knowledge together with what the police did to confirm it. Here that was nothing."
        case .unsworn:
            return "A search warrant may issue only on an affidavit made under oath before the judge or another official authorized to administer oaths (G.S. 15A-244, 15A-245). The facts were enough, but the officer was never sworn, and an unsworn affidavit supports no warrant. The careful course was to put the officer under oath before signing."
        case .wrongPlace:
            return "A warrant must describe the place to be searched with enough particularity that an officer can find it with reasonable effort (G.S. 15A-246; State v. Smith). A description that leaves officers to guess which house, unit, or vehicle is meant fails that requirement even when the facts support probable cause."
        }
    }
}

enum SearchWarrants {

    /// Whether the charge is one a storage-unit search for stolen goods makes sense for: theft and break-ins.
    private static func isTheft(_ c: CourtCase) -> Bool {
        guard let id = c.charges.first?.lawID else { return false }
        return ["larcenyFirearm", "larcenyMerchant", "felonyLarceny", "misdLarceny", "possStolen", "burglary1", "burglary2", "feloniousBE", "breakingVehicle"].contains(id)
    }

    private static func isBreakIn(_ c: CourtCase) -> Bool {
        guard let id = c.charges.first?.lawID else { return false }
        return ["burglary1", "burglary2", "feloniousBE", "breakingVehicle"].contains(id)
    }

    /// The warrant kinds that fit the offense charged: drugs get a residence search, theft and break-ins a storage-unit
    /// search, and everything else (trespass, vandalism, fraud, violence) phone and location records.
    static func fittingKinds(for c: CourtCase) -> [WarrantApplication.Kind] {
        switch c.category {
        case .drugs: return [.residenceDrugs, .vehicleSearch]
        case .property: return isTheft(c) ? [.storageStolen, .vehicleSearch] : [.phoneRecords]
        case .traffic: return isImpaired(c) ? [.bloodDraw] : [.phoneRecords, .vehicleSearch]
        case .whiteCollar: return [.bankRecords, .phoneRecords]
        case .cyber: return [.digitalAccounts, .phoneRecords]
        case .violent, .robbery:
            // Hospital records of the defendant's own injury only fit a fight: an assault or affray charge.
            let id = (c.charges.first?.lawID ?? "").lowercased()
            let fight = id.contains("assault") || id.contains("affray") || id.contains("battery") || id.contains("awdw")
            return [.dnaSample, .residenceWeapons, .phoneRecords, .vehicleSearch] + (fight ? [.medicalRecords] : [])
        default: return [.phoneRecords]
        }
    }

    private static func isImpaired(_ c: CourtCase) -> Bool {
        guard let id = c.charges.first?.lawID else { return false }
        return ["dwi", "dwlrImpaired", "felonyDBV", "misdDBV", "habitualDWI", "seriousInjuryVehicle"].contains(id)
    }

    /// What the officer's experience is in, fitted to the crime.
    private static func crimeField(_ c: CourtCase) -> String {
        switch c.category {
        case .robbery, .violent: return "robbery and violent crime"
        case .whiteCollar: return "financial crimes and fraud"
        case .cyber: return "cyber crime"
        case .property: return "property crimes"
        default: return "criminal offenses"
        }
    }

    /// What drug a drugs warrant is about: taken from the charge, so a marijuana case is not searched for cocaine.
    static func drugName(_ c: CourtCase) -> String {
        let title = (c.charges.first?.law.title ?? "").lowercased()
        if title.contains("marijuana") || title.contains("cannabis") { return "marijuana" }
        if title.contains("methamphetamine") || title.contains("meth") { return "methamphetamine" }
        if title.contains("heroin") || title.contains("fentanyl") || title.contains("opium") || title.contains("opioid") { return "heroin and fentanyl" }
        if title.contains("hydrocodone") || title.contains("oxycodone") || title.contains("pill") { return "prescription pills" }
        return "cocaine"
    }

    static func application(for c: CourtCase, date: Date, kind requested: WarrantApplication.Kind? = nil, rng: inout SeededRNG) -> WarrantApplication {
        let facts = c.investigation?.facts
        let affiant = facts?.lead ?? "Detective \(rng.pick(NameBank.lastNames))"
        let agency = facts?.agency ?? c.investigatingAgency
        let town = facts?.town ?? "Port Hollis"
        let street = facts?.street ?? Gazetteer.street(in: town, rng: &rng)
        let name = c.defendant.name
        let last = c.defendant.lastName
        let drug = drugName(c)
        let fitting = fittingKinds(for: c)
        let kind: WarrantApplication.Kind = requested.flatMap { fitting.contains($0) ? $0 : nil } ?? rng.pick(fitting)
        let breakIn = isBreakIn(c)
        let violent = c.category == .robbery || c.category == .violent
        let stolenWord = breakIn ? "burglaries" : "thefts"
        let itemWord = c.category == .drugs ? "drugs" : (c.category == .property ? "stolen property" : (violent ? "a gun" : "evidence"))
        let roll = rng.int(1...100)
        // Which defects fit which kind: a blood sample or cheek swab has no informant or street address to get wrong.
        var defects: [WarrantApplication.Flaw] = [.anonymousTip, .stale, .noNexus, .unsworn]
        if [.residenceDrugs, .storageStolen, .phoneRecords, .bankRecords, .digitalAccounts, .residenceWeapons, .vehicleSearch].contains(kind) { defects.append(.unreliableInformant) }
        if [.residenceDrugs, .storageStolen, .residenceWeapons, .vehicleSearch].contains(kind) { defects.append(.wrongPlace) }
        var flaw: WarrantApplication.Flaw = roll <= 50 ? .none : (roll <= 65 ? .overbroad : rng.pick(defects))
        // A blood sample or cheek swab has no 'any and all papers' clause to be too broad.
        if flaw == .overbroad && (kind == .bloodDraw || kind == .dnaSample || kind == .medicalRecords) { flaw = .none }
        let years = rng.int(4...17)
        let monthsAgo = rng.int(5...9)
        let field = kind == .residenceDrugs || kind == .vehicleSearch && c.category == .drugs ? "narcotics distribution"
            : (kind == .storageStolen ? "property crimes and the fencing of stolen goods" : (kind == .bloodDraw ? "impaired driving enforcement" : crimeField(c)))
        let warrantCount = rng.int(20...140)
        var affidavit = [Variety.pick([
            "Your affiant, \(affiant), has been a sworn law enforcement officer with the \(agency) for \(years) years and has training and experience in the investigation of \(field), including the execution of more than \(warrantCount) search warrants.",
            "Your affiant, \(affiant), is a sworn officer of the \(agency) with \(years) years of service, assigned to investigations of \(field), and has applied for or executed more than \(warrantCount) search warrants.",
            "\(affiant) swears that \(years) years with the \(agency) have given your affiant training in \(field), and that your affiant has taken part in more than \(warrantCount) search warrants.",
            "Your affiant, \(affiant) of the \(agency), has \(years) years of law enforcement experience, has completed courses on \(field), and has been affiant or assisting officer on about \(warrantCount) warrants.",
            "Your affiant is \(affiant), a sworn officer with \(years) years at the \(agency). The affiant has investigated \(field) throughout that time and has executed more than \(warrantCount) search warrants.",
            "Your affiant, \(affiant), has served the \(agency) for \(years) years and holds advanced certification in \(field); the affiant has prepared or served over \(warrantCount) search warrants.",
            "The affiant, \(affiant), has been with the \(agency) for \(years) years and has been the investigator on cases involving \(field), including the preparation of more than \(warrantCount) warrant applications.",
        "Your affiant, \(affiant), is employed by the \(agency) and has \(years) years of experience investigating \(field). In that time your affiant has helped obtain more than \(warrantCount) search warrants.",
        "Your affiant, \(affiant), has worked for the \(agency) for \(years) years, has received specialized training in \(field), and has participated in more than \(warrantCount) search warrant applications.",
        "Your affiant, \(affiant), is a sworn officer with the \(agency). During \(years) years of service your affiant has investigated \(field) and has prepared or assisted with more than \(warrantCount) search warrants.",
        "Your affiant, \(affiant), has \(years) years of service with the \(agency), has attended training on \(field), and has been involved in over \(warrantCount) search warrants.",
        "The affiant, \(affiant), a \(years)-year veteran of the \(agency), has handled investigations of \(field) and has taken part in more than \(warrantCount) warrant applications.",
        "Your affiant, \(affiant), is a sworn law enforcement officer with the \(agency) who has spent \(years) years on investigations involving \(field) and has been affiant on more than \(warrantCount) search warrants."
        ], rng: &rng)]
        var place: String
        var items: [String]
        switch kind {
        case .residenceDrugs:
            place = "The residence at \(rng.int(100...4_899)) \(street), \(town), a single-story frame house with a carport, and any vehicles on the curtilage"
            items = ["\(drug.prefix(1).uppercased() + drug.dropFirst()) and other controlled substances", "Scales, packaging, and other items used to weigh and package controlled substances",
                     "U.S. currency derived from the sale of controlled substances", "Records of drug sales"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("Within the past 72 hours, a confidential informant who has provided information leading to \(rng.int(3...9)) arrests and the seizure of controlled substances on \(rng.int(2...6)) occasions made a controlled purchase of \(drug) inside the residence. Before the purchase the informant was searched and found to have no drugs or money; officers watched the informant enter and leave the residence; the informant returned with a substance that field-tested positive for \(drug).")
                affidavit.append("Officers conducting surveillance over \(rng.int(3...6)) days observed \(rng.int(18...45)) short visits to the residence, consistent with drug sales. \(name) was seen answering the door. Utility records list \(last) as the account holder.")
            case .anonymousTip:
                affidavit.append("On \(SentenceFormat.shortDate(date.addingTimeInterval(-86_400 * Double(rng.int(3...12))))), an anonymous caller to Crime Stoppers stated that \"\(name) sells \(drug) out of the house on \(street).\" The caller did not give a name or explain how the caller knew this.")
                affidavit.append("Your affiant drove past the residence and confirmed that it matches the caller's description: a frame house with a carport. A car registered to \(last) was in the driveway.")
            case .stale:
                affidavit.append("In a debriefing about \(monthsAgo) months ago, a confidential informant told officers that the informant had bought \(drug) from \(name) at the residence on one occasion.")
                affidavit.append("\(last) has a prior conviction for possession of \(drug). Officers have not conducted surveillance or controlled purchases at the residence since the informant's statement.")
            case .noNexus, .unreliableInformant:
                affidavit.append("Within the past week, officers observed \(name) conduct two hand-to-hand transactions consistent with drug sales outside a convenience store on \(rng.pick(NameBank.streets)), about two miles from the residence.")
                affidavit.append("\(last) lists the residence as an address on a driver's license. Officers have not seen any drug activity at, or anyone carrying anything to or from, the residence.")
            }
        case .storageStolen:
            place = "Unit \(rng.int(10...240)) at \(Variety.pick(["Coastal Self Storage", "Hollis Mini-Warehouse", "Route 17 Storage", "Cane Creek Storage", "Bayard Self Storage", "Port Hollis U-Store", "Wexley Mini Storage", "Dunmore Mills Storage Depot", "Harbor Point Climate Storage"], rng: &rng)), \(town), rented to \(name)"
            items = ["Power tools, generators, and other property reported stolen in recent \(stolenWord)", "Documents showing the rental, use, or control of the unit",
                     "Receipts, pawn tickets, and records of sales of the property"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("Between the dates in the attached list, \(rng.int(5...14)) construction sites and garages in \(town) were \(breakIn ? "burglarized" : "hit by thieves") and power tools and generators were taken. Two of the stolen items, identified by serial number, were pawned within the past week by \(name).")
                affidavit.append("The storage facility's gate log shows \(last)'s access code used \(rng.int(6...15)) times in the past two weeks, late at night. A facility employee saw \(last) unloading generators from a truck into the unit three days ago.")
            case .anonymousTip:
                affidavit.append("An anonymous note left at the police department stated that \"the guy in unit \(rng.int(10...240)) has all the stuff from the \(breakIn ? "break-ins" : "thefts").\" The note was unsigned.")
                affidavit.append("Facility records show the unit is rented to \(name).")
            case .stale:
                affidavit.append("About \(monthsAgo) months ago, an acquaintance of \(name) told officers that \(last) once kept \"some tools that might have been hot\" in a storage unit.")
                affidavit.append("\(last) has a prior conviction for possession of stolen goods.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) pawned two power tools reported stolen in a \(breakIn ? "burglary" : "theft") last month. The pawn shop has the items.")
                affidavit.append("\(last) rents a storage unit at the facility. Nothing in the investigation indicates any property was taken to the unit.")
            }
        case .bloodDraw:
            place = "The person of \(name), for a sample of blood to be drawn by a licensed medical professional at \(rng.pick(["the county hospital emergency department", "the detention center medical unit", "the emergency department at Hollis Regional Medical Center", "the urgent care clinic on Route 17", "the county health department's clinic", "the medical room at the sheriff's office", "the nearest hospital laboratory", "a hospital draw station staffed by a phlebotomist"]))"
            items = ["A sample of blood sufficient to test for alcohol concentration and the presence of impairing substances"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("At about \(rng.int(1...2)):\(Variety.pick(["10", "25", "40", "05", "15", "20", "30", "35", "50", "55"], rng: &rng)) a.m. your affiant stopped \(name) after watching the vehicle cross the center line three times. \(last) had a strong odor of alcohol, red and glassy eyes, and slurred speech, and admitted to \"a few\" drinks. \(last) showed six of six clues on the horizontal gaze nystagmus test and could not complete the walk-and-turn.")
                affidavit.append("\(last) refused a breath test at the roadside and at the station. Alcohol leaves the blood over time, and less than two hours have passed since the driving, so a sample is needed now (Missouri v. McNeely requires a warrant absent exigency).")
            case .anonymousTip:
                affidavit.append("A caller who would not give a name told dispatch that \"the driver of the gray truck is drunk.\" The caller did not say what the caller saw.")
                affidavit.append("Your affiant found \(name) asleep in a parked truck matching that description. Your affiant did not see the truck being driven and did not note an odor or any sign of impairment.")
            case .stale:
                affidavit.append("\(name) was convicted of impaired driving about \(monthsAgo) months ago and, according to a records check, completed a substance abuse assessment.")
                affidavit.append("Your affiant believes \(last) may be a repeat offender and asks for a blood sample.")
            case .noNexus, .unreliableInformant:
                affidavit.append("A restaurant receipt shows \(name) bought two beers about three hours before the stop. \(last) was stopped for an expired registration.")
                affidavit.append("Your affiant noted no odor, no driving violation, and no sign of impairment.")
            }
        case .bankRecords:
            let bank = Variety.pick(["First Coastal Bank", "Tidewater Credit Union", "Carolina Trust", "Hollis Savings Bank", "Port Hollis Federal Credit Union", "Cane Creek National Bank", "Harbor Trust Bank", "Bayard Community Bank", "Wexley Farmers and Merchants Bank"], rng: &rng)
            place = "Records held by \(bank) for accounts in the name of \(name) and any business accounts controlled by \(last)"
            items = ["Account statements, signature cards, and deposit items for the period of the alleged offense", "Records of wire and electronic transfers into and out of the accounts"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("The victim's audit found \(rng.int(6...19)) transfers totaling $\(rng.int(14...96) * 1_000) to an account ending in \(rng.int(1000...9999)), opened by \(name) four months before the first transfer. The transfers began the week \(last) was given control of the victim's books.")
                affidavit.append("Your affiant interviewed two employees, who said that only \(last) had the password used for the transfers. A subpoena confirmed that the receiving account is held by \(name).")
            case .anonymousTip:
                affidavit.append("An anonymous letter to the victim's office said \"\(name) is stealing from the company.\" The letter was unsigned and gave no amounts or dates.")
                affidavit.append("Your affiant confirmed that \(last) works at the company and has access to its books.")
            case .stale:
                affidavit.append("An audit about \(monthsAgo) months ago questioned several entries made by \(name). The matter was closed after \(last) explained them as data entry errors.")
                affidavit.append("Your affiant believes the entries may have been theft.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) has access to the victim's funds and drives a newer car than the salary suggests.")
                affidavit.append("Your affiant has no information that funds were moved to any account at this bank.")
            }
        case .digitalAccounts:
            place = "The email and social media accounts registered to \(name), held by the providers, and the laptop and phone seized from \(last)'s residence"
            items = ["Messages, posts, and attachments sent from or received by the accounts during the period of the offense", "Subscriber, login, and IP address records for the accounts"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("The victim received \(rng.int(12...60)) threatening or harassing messages from an account whose username matches a name \(name) has used online. A prior preservation request to the provider showed the account was created from an internet address assigned to \(last)'s home service.")
                affidavit.append("The victim identified \(last)'s writing style and a nickname only \(last) uses. The messages stopped the night officers spoke with \(last).")
            case .anonymousTip:
                affidavit.append("An anonymous tip said \"it's \(name)'s account, everyone knows.\" The tipster gave no reason for the belief.")
                affidavit.append("Your affiant found a social media profile in \(last)'s name. It has not posted anything to the victim.")
            case .stale:
                affidavit.append("\(name) was warned about harassing messages \(monthsAgo) months ago in an unrelated dispute.")
                affidavit.append("The current messages appear to come from a different account that your affiant has not connected to \(last).")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) is a former acquaintance of the victim and uses social media.")
                affidavit.append("The only information linking \(last) to the messages is that the victim believes \(last) sent them.")
            }
        case .dnaSample:
            place = "The person of \(name), for a buccal (cheek) swab to obtain a DNA sample"
            items = ["Two buccal swabs", "A DNA profile for comparison with evidence recovered at the scene"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("A swab of blood found on the broken window at the scene produced a partial DNA profile that does not match anyone known to live there. The victim and a neighbor described the person who fled, and each identified \(name) separately in a photo lineup administered by an officer who did not know the suspect.")
                affidavit.append("A comparison sample from \(last) will show whether the profile from the scene belongs to \(last) (G.S. 15A-271 to 15A-282).")
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"\(name) did it.\" The caller declined to say how the caller knew.")
                affidavit.append("Your affiant confirmed that \(last) lives in \(town) and was identified in no other way.")
            case .stale:
                affidavit.append("\(name) was a suspect in an unrelated case about \(monthsAgo) months ago and gave no sample.")
                affidavit.append("The DNA profile from the current scene has not been compared to anyone.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) has a prior record and lives about a mile from the scene.")
                affidavit.append("No witness or other evidence ties \(last) to the scene, and the profile from the scene has not been compared to \(last).")
            }
        case .residenceWeapons:
            place = "The residence at \(rng.int(100...4_899)) \(street), \(town), and any vehicles on the curtilage"
            items = ["A handgun of the make and caliber used in the offense and ammunition", "Clothing matching the description given by witnesses", "Cartridge casings, holsters, and gun-cleaning supplies"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("Two witnesses described a person in a dark hooded jacket and a gray cap, and one identified \(name) from a photo lineup. Casings from the scene match a 9mm handgun. A neighbor saw \(last) return to the residence about ten minutes after the offense carrying a bag.")
                affidavit.append("Surveillance video from a store near the scene shows a person matching \(last)'s description leaving in a car registered to \(last) at the time of the offense. The car was parked at the residence the next morning.")
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"\(name) has the gun, it's in the house.\" The caller did not give a name or say how the caller knew.")
                affidavit.append("Officers confirmed that \(last) lives at the address.")
            case .stale:
                affidavit.append("A witness told officers about \(monthsAgo) months ago that \(name) once showed off a pistol at the residence.")
                affidavit.append("\(last) has a prior conviction for a firearm offense. Nothing indicates a gun is in the residence now.")
            case .noNexus, .unreliableInformant:
                affidavit.append("Surveillance video shows a person of \(last)'s general build leaving the scene on foot. Casings at the scene match a 9mm handgun.")
                affidavit.append("\(last) lives across town. Officers have no information that \(last) has a gun or that anything related to the offense is at the residence.")
            }
        case .vehicleSearch:
            let color = Variety.pick(["gray", "blue", "white", "black", "red", "silver", "green", "tan", "brown", "maroon", "gold", "beige", "orange", "dark blue"], rng: &rng)
            let body = Variety.pick(["sedan", "pickup truck", "SUV", "minivan", "hatchback", "coupe", "station wagon", "cargo van", "crew-cab pickup", "crossover", "compact car", "box truck"], rng: &rng)
            place = "A \(color) \(body), North Carolina tag \(Variety.pick(["TJX", "HLM", "PRC", "WDK", "BNV", "CCR", "FLM", "GRN", "KTS", "MPD", "SHW", "VLD"], rng: &rng))-\(rng.int(1000...9999)), registered to \(name), parked at \(rng.int(100...4_899)) \(street), \(town)"
            switch c.category {
            case .drugs:
                items = ["Controlled substances", "Scales, packaging, and paraphernalia", "U.S. currency derived from drug sales", "Cell phones used to arrange sales"]
            case .property:
                items = ["Property reported stolen in recent \(stolenWord)", "Tools used to force entry", "Receipts and pawn tickets"]
            case .violent, .robbery:
                items = ["A firearm and ammunition", "Clothing matching the descriptions given by witnesses", "Items taken from the victim"]
            default:
                items = ["Documents showing ownership and use of the vehicle", "Items connected to the offense"]
            }
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                let first: [String]
                let second: [String]
                switch c.category {
                case .drugs:
                    first = ["A certified narcotics-detection dog alerted on the driver's door and trunk of the vehicle while it was parked in a public lot on \(SentenceFormat.shortDate(date.addingTimeInterval(-86_400 * Double(rng.int(1...4))))). The dog's certification and field record are attached.",
                             "Officers watched \(name) drive the vehicle to a house on \(street) on \(rng.int(2...5)) occasions in the past two weeks and make short stops, carrying a bag in and out each time.",
                             "A confidential informant who has made controlled purchases for the \(agency) bought from \(name) on \(rng.int(2...4)) occasions, each time from the vehicle."]
                    second = ["The vehicle is registered to \(name). A passenger who was with \(last) that evening says a bag stayed in the car.",
                              "Your affiant has not seen anyone else drive the vehicle. Insurance records list \(name) as the only driver.",
                              "Your affiant's training and experience is that dealers commonly keep drugs and cash in a vehicle, where they can be moved quickly."]
                case .property:
                    first = ["A witness photographed the vehicle leaving the scene of one of the \(stolenWord) and wrote down its tag. The tag comes back to \(name).",
                             "A trail camera near the site recorded a vehicle matching \(last)'s at \(rng.int(1...4)):\(Variety.pick(["05", "20", "45", "10", "15", "30", "35", "50", "55"], rng: &rng)) a.m. on the night of the \(breakIn ? "burglary" : "theft").",
                             "A pawn shop clerk says \(name) brought in tools that match the reported property and drove away in the vehicle."]
                    second = ["The vehicle is registered to \(name), who has a prior conviction for possession of stolen goods.",
                              "Your affiant has not seen anyone else drive the vehicle. Insurance records list \(name) as the only driver.",
                              "Your affiant saw a generator in the bed of the vehicle two days after the report; the tarp was pulled tight."]
                case .violent, .robbery:
                    first = ["A witness saw the person who fled get into the vehicle and wrote down its tag. The tag comes back to \(name).",
                             "A camera near the scene recorded a vehicle matching \(last)'s leaving within a minute of the offense.",
                             "Two witnesses described a car the person got into; the vehicle matches, and \(name) is its registered owner."]
                    second = ["Your affiant has not seen anyone else drive the vehicle. Insurance records list \(name) as the only driver.",
                              "The victim says the person who fled put something in the car. Officers saw a bag on the back seat when they walked by the parked vehicle.",
                              "The vehicle was parked in front of \(last)'s home the morning after the offense."]
                default:
                    first = ["A witness photographed the vehicle leaving the scene and wrote down its tag. The tag comes back to \(name), and the photograph shows damage to the passenger side matching the report.",
                             "A traffic camera at the intersection nearest the scene shows the vehicle passing at the time of the offense.",
                             "Two witnesses described a \(Variety.pick(["gray", "dark", "light-colored", "silver", "white", "tan", "dark blue", "red", "black"], rng: &rng)) car leaving quickly; the vehicle matches, and \(name) is its registered owner."]
                    second = ["Your affiant has not seen anyone else drive the vehicle. Insurance records list \(name) as the only driver.",
                              "The victim says the person who fled left something in the car. Officers saw a bag on the back seat when they walked by the parked vehicle.",
                              "The vehicle was parked in front of \(last)'s home the morning after the offense with fresh mud on the lower panels."]
                }
                affidavit.append(Variety.pick(first, rng: &rng))
                affidavit.append(Variety.pick(second, rng: &rng))
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"the car is full of \(itemWord).\" The caller gave no description of the items and did not say how the caller knew.")
                affidavit.append("Your affiant found the vehicle registered to \(name) parked on \(street). Nothing about it was unusual.")
            case .stale:
                affidavit.append("About \(monthsAgo) months ago, a witness said \(name) had once carried \(itemWord) in the vehicle.")
                affidavit.append("The vehicle has not been seen at any scene since that time.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) is suspected in the offense and owns the vehicle.")
                affidavit.append("No witness, video, or other evidence connects the vehicle to the offense or places it near the scene.")
            }
        case .medicalRecords:
            let hospital = Variety.pick(["the county hospital", "Hollis Regional Medical Center", "the urgent care on Route 17", "the emergency department at the coast", "Harbor Point Urgent Care", "the Bayard Medical Clinic", "the Wexley Community Health Center", "the county health department clinic", "Cane Creek Family Medicine", "the emergency room at Port Hollis General"], rng: &rng)
            place = "Treatment records of \(name) held by \(hospital), for the date of the offense"
            items = ["Emergency department records, including the history the patient gave", "Descriptions and photographs of injuries", "Toxicology results"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append("A nurse at \(hospital) told your affiant that \(name) arrived about an hour after the offense with a cut hand and bruised knuckles and said the injury came from \"a fight.\"")
                affidavit.append("The victim told officers the attacker's hand was cut on broken glass. The records would show the injury, how \(last) said it happened, and any toxicology results (G.S. 8-53 allows disclosure when a judge finds it necessary to a proper administration of justice).")
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"\(name) went to the hospital after it happened.\" The caller did not say which hospital or why the caller knew.")
                affidavit.append("Your affiant has not confirmed that \(last) was treated anywhere.")
            case .stale:
                affidavit.append("\(name) was treated at \(hospital) \(monthsAgo) months ago for an injury in an unrelated incident.")
                affidavit.append("Your affiant believes the records may contain admissions about this offense.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) has been treated at \(hospital) before and has a history of fights.")
                affidavit.append("No witness places \(last) at a hospital after the offense, and the records sought are not tied to the date of the offense.")
            }
        case .phoneRecords:
            place = "Records held by the wireless carrier for the cell phone number assigned to \(name), and the phone itself, now in the property room of the \(agency)"
            items = ["Historical cell-site location information for the 48 hours around the offense",
                     "Call logs and text messages for the same period"]
            switch flaw {
            case .none, .overbroad, .unsworn, .wrongPlace:
                affidavit.append(violent
                    ? "The victim identified \(name) from a photo lineup administered by an officer who did not know which photo was the suspect. Surveillance video shows a person matching \(last)'s description at the scene."
                    : "Messages and account records obtained earlier in the investigation connect \(name) to the offense, and a witness places \(last) near the scene.")
                affidavit.append("\(last)'s phone number appears in the victim's call log twenty minutes before the offense. Location data would show whether the phone was near the scene at that time (Carpenter v. United States requires a warrant for it).")
            case .anonymousTip:
                affidavit.append("An anonymous caller said the person responsible \"goes by \(last) and hangs out on \(street).\"")
                affidavit.append("Officers found that a person named \(name) lives near \(street) and obtained the phone number from a prior arrest record.")
            case .stale:
                affidavit.append("\(name) was a suspect in a similar \(violent ? "robbery" : "case") about \(monthsAgo) months ago; that case was closed without charges.")
                affidavit.append("Officers believe the same person may be responsible for the current offense because of the similar method.")
            case .noNexus, .unreliableInformant:
                affidavit.append("\(name) has \(violent ? "two prior robbery convictions and lives" : "a prior record and lives") about a mile from the scene.")
                affidavit.append("No witness, video, or other evidence links \(last) or \(last)'s phone to the current offense.")
            }
        }
        // An informant the officers never checked: the affidavit says so in its own words.
        if flaw == .unreliableInformant {
            let claim: String
            switch kind {
            case .residenceDrugs: claim = "keeps drugs at the house"
            case .storageStolen: claim = "keeps stolen property in the unit"
            case .phoneRecords: claim = "was involved in the offense"
            case .bankRecords: claim = "has been moving money out of the company"
            case .digitalAccounts: claim = "sent the messages"
            case .residenceWeapons: claim = "keeps the gun at the house"
            default: claim = c.category == .drugs ? "keeps drugs in the car" : (c.category == .property ? "keeps stolen property in the car" : (violent ? "keeps the gun in the car" : "keeps evidence in the car"))
            }
            affidavit.removeLast(2)
            affidavit.append(Variety.pick([
                "The information comes from an informant who has worked with the \(agency) for about two weeks, has no earlier record of reliable tips, and has an interest in helping their own situation. The informant said \(name) \(claim).",
                "A person who was arrested last week and wants help with their own case told your affiant that \(name) \(claim). Your affiant has not used this person before.",
                "An informant whose information your affiant has never tested said that \(name) \(claim). The informant was paid \(rng.int(2...8) * 25) dollars.",
            "The source is a person already in the county jail on pending charges who contacted your affiant hoping for help. Your affiant has no history with this person. The source said \(name) \(claim).",
            "A person your affiant had never worked with before, who is awaiting trial, said that \(name) \(claim).",
            "A confidential source with no track record said that \(name) \(claim). The source was not under oath when the statement was given.",
            "An informant who has been working with the \(agency) for about a month, and who is on probation, told your affiant that \(name) \(claim).",
            "A person your affiant met for the first time two days ago, and who has charges pending, said that \(name) \(claim)."
            ], rng: &rng))
            affidavit.append(Variety.pick([
                "Your affiant did not corroborate the account through surveillance or a records check; it was taken at face value.",
                "Your affiant made no independent effort to check what the informant said before applying for this warrant.",
                "The informant's statement is the only information in this affidavit about \(last).",
            "Your affiant did not try to confirm any of the informant's statements before seeking this warrant.",
            "No surveillance or records check was done to verify what the informant said.",
            "Your affiant relied entirely on the informant's word and did not look for anything that would support it.",
            "The affidavit does not say how the informant knows what was reported, and your affiant did not ask.",
            "Your affiant did not check whether the informant had been truthful in the past.",
            "Nothing in this affidavit supports the informant's account beyond the informant's own statement."
            ], rng: &rng))
        }
        // The place described so loosely an officer would have to guess.
        if flaw == .wrongPlace {
            switch kind {
            case .storageStolen: place = "The storage unit rented to \(name) at a storage facility in \(town)"
            case .vehicleSearch: place = "A vehicle belonging to \(name)"
            default: place = "The house on \(street) in \(town) where \(name) lives"
            }
        }
        // A little more for the court when the facts are good: one more supporting fact, drawn from a larger set.
        if flaw == .none || flaw == .overbroad || flaw == .unsworn || flaw == .wrongPlace, rng.chance(0.65) {
            affidavit.append(Variety.pick(supportingFacts(kind: kind, name: name, last: last, agency: agency, drug: drug, rng: &rng), rng: &rng))
        }
        if flaw == .overbroad {
            items.append("Any and all papers, records, computers, cell phones, and electronic storage devices of any kind, and their contents")
        }
        let closing = "Based on the foregoing, your affiant believes probable cause exists that the items listed will be found in the place to be searched, and asks the court to issue a warrant."
        affidavit.append(flaw == .unsworn
            ? closing + Variety.pick([" Signed by the affiant at the sheriff's office; the affiant has not been placed under oath before an official.",
                                      " Signed by the affiant. The oath block is blank.",
                                      " Signed in the car on the way to chambers; no one has administered an oath.", " Signed by the affiant at the district attorney's office; no notary or magistrate was present to administer an oath.", " Signed by the affiant. The jurat is empty, and no one swore the affiant.", " Signed in the squad room; the affiant was never asked to raise a hand or swear to the contents.", " Signed by the affiant without a magistrate or notary present.", " The signature block is complete, but nothing shows an oath was ever given.", " Signed in the hallway outside the magistrate's office; no oath was administered."], rng: &rng)
            : closing + " Sworn and subscribed before the court.")
        return WarrantApplication(kind: kind, affiant: affiant, agency: agency, applied: date, target: name, place: place,
                                  items: items, affidavit: affidavit, flaw: flaw)
    }

    /// One more fact an officer might add to a good affidavit, by kind. They are drawn through `Variety`, so a long career sees
    /// all of them rather than the same two or three.
    private static func supportingFacts(kind: WarrantApplication.Kind, name: String, last: String, agency: String, drug: String, rng: inout SeededRNG) -> [String] {
        switch kind {
        case .residenceDrugs:
            return ["Trash pulled from the curb on \(rng.int(2...3)) separate days held baggies with \(drug) residue and mail addressed to \(name).",
                    "Utility records show the electricity at the residence has been in \(last)'s name since last year.",
                    "A neighbor who asked not to be named says cars stop at the house at all hours and leave within minutes.",
                    "Your affiant has seen \(last) at the residence on \(rng.int(3...7)) of the last \(rng.int(8...12)) days.",
                    "A traffic stop of a visitor leaving the house produced a small amount of \(drug), and the visitor said it came from \(last).",
                    "A thermal scan from the public street showed unusual heat consistent with a grow operation in one room."]
        case .storageStolen:
            return ["The facility manager says \(last) paid for the unit in cash and asked that it not be listed with a phone number.",
                    "A neighbor in the next unit heard what sounded like a generator being moved in and out around midnight.",
                    "Video from the front gate shows \(last)'s truck entering \(rng.int(3...8)) times in the week after the thefts.",
                    "Serial numbers on two tools sold to a pawn shop match the report, and the seller gave \(last)'s license.",
                    "The unit's rental application lists a false address for \(last).",
                    "Your affiant saw a tarp-covered load in the bed of \(last)'s truck being backed up to the unit door."]
        case .phoneRecords:
            return ["The victim's phone shows \(rng.int(3...9)) calls from the number in the hour before the offense.",
                    "A witness says \(last) was holding a phone when the incident began and photographed the scene.",
                    "Your affiant has confirmed the number is registered to \(name) through the carrier's subscriber records.",
                    "A friend of \(last) says the two texted about the incident that night.",
                    "The carrier has preserved the records at the agency's request; they will be deleted in 18 months.",
                    "Your affiant's training and experience is that location data can place a phone at a scene within minutes."]
        case .bloodDraw:
            return ["The trooper who made the stop smelled alcohol from \(last)'s breath from outside the vehicle.",
                    "\(last) failed three standardized field sobriety tests and admitted to drinking at a bar earlier in the evening.",
                    "A bar receipt in \(last)'s pocket showed a purchase of several drinks that evening.",
                    "Bodycam video shows \(last) swaying and slurring words at the roadside.",
                    "An open container was found in the cup holder.",
                    "The vehicle was weaving between lanes for about a mile before the stop, according to the dash camera."]
        case .bankRecords:
            return ["A bookkeeper says \(last) asked in the month before the first transfer how to change an authorization limit.",
                    "The company's records show every transfer was made while \(last) was logged in.",
                    "A bank officer says \(last) opened the receiving account in person and gave the company's address.",
                    "An internal audit flagged the transfers and a supervisor says \(last) had no explanation for them.",
                    "Your affiant has reviewed account statements showing \(last)'s personal bills paid from the receiving account.",
                    "A coworker says \(last) began taking vacations and buying a boat around the time of the first transfer."]
        case .digitalAccounts:
            return ["The provider's records show the account was last used from an address assigned to \(last)'s home.",
                    "The messages refer to events only \(last) and the victim knew about.",
                    "\(last)'s phone number is the recovery number registered on the account.",
                    "A screenshot the victim saved shows the account name matching \(last)'s old gaming username.",
                    "The victim blocked the account and a new one began messaging within minutes, from the same network.",
                    "Your affiant knows from training and experience that devices and accounts retain messages that people believe they deleted."]
        case .dnaSample:
            return ["The laboratory analyst says the profile from the scene is of sufficient quality for a comparison.",
                    "A witness saw the person at the scene touch the window frame with a bare hand.",
                    "\(last) had a fresh cut on the hand when officers saw \(name) the next day.",
                    "A second item from the scene produced a partial profile consistent with the first.",
                    "\(last)'s earlier sample was not retained because that case ended in a dismissal.",
                    "The comparison would exclude \(last) as well as include \(last), which the defense would be entitled to have."]
        case .residenceWeapons:
            return ["A witness saw \(last) carrying what looked like a handgun in a waistband two days before the offense.",
                    "A gun shop's records show \(last) bought a 9mm handgun \(rng.int(2...9)) months ago and has not reported it lost or sold.",
                    "\(last) posted a photograph holding a handgun a week before the offense.",
                    "A relative told your affiant \(last) keeps a gun in the bedroom closet.",
                    "A jacket matching the descriptions was seen in \(last)'s car the day after.",
                    "\(last) has no permit but an earlier case file lists the same handgun."]
        case .vehicleSearch:
            return ["The vehicle has been parked in the same place since the offense and has not been moved.",
                    "Insurance records show no one but \(last) has been listed as a driver.",
                    "A witness says \(last) opened the trunk and moved a bag shortly after the offense.",
                    "A tow-yard employee says \(last) asked for the vehicle to be released the same day.",
                    "The vehicle's interior had been recently cleaned, according to an officer who looked through the windows.",
                    "A registration check shows the vehicle was reported stolen by \(last) two days after the offense."]
        case .medicalRecords:
            return ["A nurse says \(last) asked that the injury not be reported to police.",
                    "\(last) gave a false name at registration.",
                    "The hospital's intake note records that \(last) smelled of alcohol.",
                    "The treating physician describes a wound consistent with glass.",
                    "A security guard at the hospital says \(last) left before being discharged.",
                    "The ambulance run sheet lists the location of the pickup as two blocks from the scene."]
        }
    }

    private static func warrantTitle(_ k: WarrantApplication.Kind) -> String {
        switch k {
        case .phoneRecords: return "Phone Location Records"
        case .bloodDraw: return "Blood Test Results"
        case .bankRecords: return "Bank Records"
        case .digitalAccounts: return "Account and Device Records"
        case .dnaSample: return "DNA Comparison Results"
        case .medicalRecords: return "Hospital Records"
        case .vehicleSearch: return "Items Seized From Vehicle"
        default: return "Items Seized Under Search Warrant"
        }
    }

    private static func warrantEvidenceKind(_ k: WarrantApplication.Kind) -> EvidenceKind {
        switch k {
        case .phoneRecords, .digitalAccounts: return .digital
        case .bloodDraw, .dnaSample: return .forensic
        case .bankRecords, .medicalRecords: return .document
        default: return .physical
        }
    }

    /// What can be wrong with what a search turned up, by kind: it comes back less conclusive than the State hoped, and the
    /// defense has something specific to point to. About four in ten searches have one.
    private static func wrinkle(for kind: WarrantApplication.Kind, rng: inout SeededRNG) -> (state: String, weight: Int, title: String, detail: String, defense: String, kind: EvidenceKind)? {
        guard rng.chance(0.4) else { return nil }
        switch kind {
        case .bloodDraw:
            return rng.pick([
                ("The draw was made nearly three hours after the stop.", 2, "Delay Before the Draw", "", "The sample was drawn almost three hours after the stop; the alcohol concentration at the time of driving is a matter of estimation.", EvidenceKind.document),
                ("The log shows the vial was out of the evidence refrigerator for several hours before it was logged in.", 2, "Chain of Custody Gap", "", "The custody log has an unexplained gap of several hours between the draw and the laboratory intake.", EvidenceKind.document)
            ])
        case .bankRecords:
            return ("Several of the transfers carry an approval code.", 2, "Approval Codes on Transfers", "", "Some transfers show an approval code from a supervisor, which the defense says authorized them.", EvidenceKind.document)
        case .digitalAccounts:
            return ("The internet address is shared by every device in the household.", 2, "Shared Internet Connection", "", "The home connection is used by four people; the records do not show which device or person sent the messages.", EvidenceKind.digital)
        case .dnaSample:
            return ("The sample at the scene was a mixture of at least two people.", 2, "Mixed DNA Sample", "", "The laboratory reports the profile from the scene is a mixture, and the comparison cannot rule out other contributors.", EvidenceKind.forensic)
        case .residenceWeapons:
            return ("The handgun is registered to a relative who lives in the house.", 2, "Registered to Another", "", "The handgun is registered to another person in the household, who says it was kept in the closet for years.", EvidenceKind.document)
        case .phoneRecords:
            return ("The tower sector covers about two square miles.", 2, "Wide Tower Coverage", "", "The sector the phone connected to covers about two square miles, including the defendant's home.", EvidenceKind.digital)
        case .residenceDrugs:
            return ("Three other people have keys to the house.", 2, "Other Occupants", "", "Several other people live in or come and go from the house, and nothing ties the items to one person.", EvidenceKind.statement)
        case .storageStolen:
            return ("The unit is shared with a business partner who also has the gate code.", 2, "Shared Unit", "", "A business partner shares the unit and the gate code, and says the equipment is the partner's.", EvidenceKind.statement)
        case .vehicleSearch:
            return ("The vehicle is driven by three members of the family, and anyone could have left the items in it.", 2, "Shared Vehicle", "", "Three people drive the vehicle and have keys, and nothing ties the items to one of them.", EvidenceKind.document)
        case .medicalRecords:
            return ("The history in the records says the hand injury came from a kitchen knife.", 2, "Injury Explained Another Way", "", "The records give a different account of the injury, from a knife in a kitchen, and the treating nurse did not note anything about a fight.", EvidenceKind.document)
        }
    }

    /// The case once the warrant is executed: the seizure is an exhibit, and the defense moves to suppress it.
    /// `limited`: the judge struck the catch-all before signing.
    static func executed(_ w: WarrantApplication, on c: CourtCase, limited: Bool, signedBy judge: String, byThisJudge: Bool = true) -> CourtCase {
        var c = c
        var rng = SeededRNG(seed: c.seed ^ 0x5EA2_C4A1)
        let drug = drugName(c)
        let found: String
        switch w.kind {
        case .residenceDrugs: found = "Officers executing the warrant found \(drug) packaged for sale in a kitchen cabinet, two digital scales, and $\(rng.int(18...64) * 100) in a bedroom closet."
        case .storageStolen: found = "Officers executing the warrant found \(rng.int(9...31)) power tools and three generators; serial numbers on eleven match \(isBreakIn(c) ? "burglary" : "theft") reports."
        case .bloodDraw: found = "A blood sample drawn under the warrant was analyzed by the State Crime Laboratory; the result was an alcohol concentration of 0.\(rng.int(9...19))."
        case .bankRecords: found = "Bank records show \(rng.int(6...19)) transfers totaling $\(rng.int(14...96) * 1_000) from the victim's accounts into an account held by \(c.defendant.name)."
        case .digitalAccounts: found = "Provider records show the account was created and logged into from an internet address assigned to \(c.defendant.lastName)'s home service, and the seized laptop holds copies of the messages."
        case .dnaSample: found = "The State Crime Laboratory reported that the swab profile matches the DNA recovered at the scene; the chance of a random match is about 1 in \(rng.int(8...900)) million."
        case .residenceWeapons: found = "Officers executing the warrant found a 9mm handgun, a box of ammunition, and a dark hooded jacket in a bedroom closet; the handgun test-fired casings match those from the scene."
        case .vehicleSearch:
            switch c.category {
            case .drugs: found = "Officers executing the warrant found \(drug) in a bag in the trunk, two digital scales, and $\(rng.int(6...34) * 100) in the center console."
            case .property: found = "Officers executing the warrant found \(rng.int(4...14)) power tools in the trunk; serial numbers on several match \(isBreakIn(c) ? "burglary" : "theft") reports."
            case .violent, .robbery: found = "Officers executing the warrant found a dark hooded jacket and a box of 9mm ammunition under the rear seat."
            default: found = "Officers executing the warrant found a bag on the back seat containing items that match the description in the report."
            }
        case .medicalRecords: found = "Hospital records show \(c.defendant.name) was treated for a laceration to the right hand and abrasions to two knuckles about \(rng.int(55...95)) minutes after the offense, and the history given records \"a fight.\""
        case .phoneRecords: found = "Carrier records place \(c.defendant.lastName)'s phone on the tower sector covering the scene from fifteen minutes before to ten minutes after the offense."
        }
        var evidence = Evidence(exhibit: "State's Exhibit \(c.evidence.filter { $0.side == .prosecution }.count + 1)",
                                title: warrantTitle(w.kind),
                                detail: found, side: .prosecution, kind: warrantEvidenceKind(w.kind), weight: 3)
        // Some seizures come back with a wrinkle that cuts against the State's reading of them.
        let twist = wrinkle(for: w.kind, rng: &rng)
        if let twist {
            if w.kind == .medicalRecords {
                evidence.detail = evidence.detail.replacingOccurrences(of: "and the history given records \"a fight.\"", with: "and the history section records how it happened.")
            }
            evidence.detail += " " + twist.state
            evidence.weight = twist.weight
        }
        c.evidence.append(evidence)
        if let twist {
            c.evidence.append(Evidence(exhibit: "Defendant's Exhibit \(c.evidence.filter { $0.side == .defense }.count + 1)", title: twist.title,
                                       detail: twist.defense, side: .defense, kind: twist.kind, weight: 1))
        }
        c.motions.removeAll { $0.kind == .suppressSearch }
        let shouldGrant = !w.probableCause
        let isRecords = [.bankRecords, .phoneRecords, .digitalAccounts, .medicalRecords].contains(w.kind)
        let defense: String
        switch w.flaw {
        case .anonymousTip: defense = "The affidavit rests on an anonymous tip, and all the officer confirmed were details anyone could know. That isn't corroboration. Without probable cause, everything seized must be suppressed; North Carolina has not adopted a good-faith exception for a constitutional violation (State v. Carter)."
        case .stale: defense = "The only information about the place was months old. Nothing in the affidavit says the evidence would still be there."
        case .noNexus: defense = isRecords ? "The affidavit is about my client, not the records. Nothing ties the records sought to the offense or to the date it happened." : "The affidavit is about my client, not the place. There is nothing tying evidence to the location searched."
        case .overbroad: defense = limited ? "Even as narrowed, the warrant was obtained on an affidavit that cast a wide net. We ask the court to suppress." : "The warrant authorized a search of 'any and all' papers and devices. A general warrant is void."
        case .unreliableInformant: defense = "The only source is an informant with no track record and every reason to curry favor, and the officers did nothing to confirm what was said. That is not probable cause under the totality of the circumstances."
        case .unsworn: defense = "The affidavit was never sworn. A warrant issued on an unsworn affidavit is not a warrant, and everything found under it must be suppressed."
        case .wrongPlace: defense = "The warrant doesn't say which place to search. An officer would have had to guess, and a warrant that has to be guessed at fails the particularity requirement."
        case .none: defense = isRecords ? "The affidavit doesn't show enough to link these records to the offense. A request this broad for one person's records isn't probable cause." : (w.kind == .bloodDraw || w.kind == .dnaSample ? "The affidavit doesn't show a sufficient basis to take a sample from my client's body. The State should have to show more than suspicion." : "The informant's reliability isn't established, and the surveillance shows only visitors. The affidavit doesn't add up to probable cause.")
        }
        let state = w.flaw == .overbroad
            ? "The particular items were described with care and are supported by probable cause. Any overbroad clause can be severed; nothing was seized under it."
            : "A judge's finding of probable cause when issuing a warrant is entitled to great deference (Illinois v. Gates). The affidavit is sufficient."
        let note = w.flaw == .overbroad && !limited
            ? w.explanation + " Because nothing was seized under the catch-all, the items described with particularity survive by severance; suppression of them would be error."
            : w.explanation
        c.motions.append(Motion(kind: .suppressSearch,
                                facts: "On \(SentenceFormat.shortDate(w.applied)), Judge \(judge) signed a search warrant for \(w.place.prefix(1).lowercased() + w.place.dropFirst()) on the affidavit of \(w.affiant). " + found
                                    + " The affidavit's grounds: " + w.affidavit.dropFirst().dropLast().joined(separator: " "),
                                defenseArgument: defense, prosecutionResponse: state, targetEvidenceID: evidence.id,
                                shouldGrant: shouldGrant, appellateNote: note, doctrineIDs: ["searchSeizure", "fruitPoisonousTree"]))
        c.proceduralNotes.insert(byThisJudge
            ? "You signed the search warrant in this case on \(SentenceFormat.shortDate(w.applied)). The defense now challenges it."
            : "Another judge signed the search warrant in this case after you denied an earlier application. The defense now challenges it.", at: 0)
        return c
    }
}
