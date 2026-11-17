import Foundation

/// An application for a search warrant brought to the judge in chambers (G.S. 15A-243 to 15A-246): the officer's
/// sworn affidavit, the place to be searched, and the items to be seized. The judge decides whether the
/// affidavit shows probable cause under the totality of the circumstances (Illinois v. Gates; State v. Arrington).
struct WarrantApplication: Codable, Hashable {
    enum Kind: String, Codable {
        case residenceDrugs, storageStolen, phoneRecords, bloodDraw, bankRecords, digitalAccounts, dnaSample, residenceWeapons

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
        case .drugs: return [.residenceDrugs]
        case .property: return isTheft(c) ? [.storageStolen] : [.phoneRecords]
        case .traffic: return isImpaired(c) ? [.bloodDraw] : [.phoneRecords]
        case .whiteCollar: return [.bankRecords, .phoneRecords]
        case .cyber: return [.digitalAccounts, .phoneRecords]
        case .violent, .robbery: return [.dnaSample, .residenceWeapons, .phoneRecords]
        default: return [.phoneRecords]
        }
    }

    private static func isImpaired(_ c: CourtCase) -> Bool {
        guard let id = c.charges.first?.lawID else { return false }
        return ["dwi", "dwlrImpaired", "felonyDBV", "misdDBV", "habitualDWI"].contains(id)
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

    static func application(for c: CourtCase, date: Date, kind requested: WarrantApplication.Kind? = nil, rng: inout SeededRNG) -> WarrantApplication {
        let facts = c.investigation?.facts
        let affiant = facts?.lead ?? "Detective \(rng.pick(NameBank.lastNames))"
        let agency = facts?.agency ?? c.investigatingAgency
        let town = facts?.town ?? "Port Hollis"
        let street = facts?.street ?? Gazetteer.street(in: town, rng: &rng)
        let name = c.defendant.name
        let last = c.defendant.lastName
        let fitting = fittingKinds(for: c)
        let kind: WarrantApplication.Kind = requested.flatMap { fitting.contains($0) ? $0 : nil } ?? rng.pick(fitting)
        let breakIn = isBreakIn(c)
        let violent = c.category == .robbery || c.category == .violent
        let stolenWord = breakIn ? "burglaries" : "thefts"
        let roll = rng.int(1...100)
        var flaw: WarrantApplication.Flaw = roll <= 50 ? .none : (roll <= 65 ? .overbroad : rng.pick([.anonymousTip, .stale, .noNexus]))
        // A blood sample or cheek swab has no 'any and all papers' clause to be too broad.
        if flaw == .overbroad && (kind == .bloodDraw || kind == .dnaSample) { flaw = .none }
        let years = rng.int(4...17)
        let monthsAgo = rng.int(5...9)
        var affidavit = ["Your affiant, \(affiant), has been a sworn law enforcement officer with the \(agency) for \(years) years and has training and experience in the investigation of \(kind == .residenceDrugs ? "narcotics distribution" : (kind == .storageStolen ? "property crimes and the fencing of stolen goods" : (kind == .bloodDraw ? "impaired driving enforcement" : crimeField(c)))), including the execution of more than \(rng.int(20...140)) search warrants."]
        let place: String
        var items: [String]
        switch kind {
        case .residenceDrugs:
            place = "The residence at \(rng.int(100...4_899)) \(street), \(town), a single-story frame house with a carport, and any vehicles on the curtilage"
            items = ["Cocaine and other controlled substances", "Scales, packaging, and other items used to weigh and package controlled substances",
                     "U.S. currency derived from the sale of controlled substances", "Records of drug sales"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("Within the past 72 hours, a confidential informant who has provided information leading to \(rng.int(3...9)) arrests and the seizure of controlled substances on \(rng.int(2...6)) occasions made a controlled purchase of cocaine inside the residence. Before the purchase the informant was searched and found to have no drugs or money; officers watched the informant enter and leave the residence; the informant returned with a substance that field-tested positive for cocaine.")
                affidavit.append("Officers conducting surveillance over \(rng.int(3...6)) days observed \(rng.int(18...45)) short visits to the residence, consistent with drug sales. \(name) was seen answering the door. Utility records list \(last) as the account holder.")
            case .anonymousTip:
                affidavit.append("On \(SentenceFormat.shortDate(date.addingTimeInterval(-86_400 * Double(rng.int(3...12))))), an anonymous caller to Crime Stoppers stated that \"\(name) sells crack out of the house on \(street).\" The caller did not give a name or explain how the caller knew this.")
                affidavit.append("Your affiant drove past the residence and confirmed that it matches the caller's description: a frame house with a carport. A car registered to \(last) was in the driveway.")
            case .stale:
                affidavit.append("In a debriefing about \(monthsAgo) months ago, a confidential informant told officers that the informant had bought cocaine from \(name) at the residence on one occasion.")
                affidavit.append("\(last) has a prior conviction for possession of cocaine. Officers have not conducted surveillance or controlled purchases at the residence since the informant's statement.")
            case .noNexus:
                affidavit.append("Within the past week, officers observed \(name) conduct two hand-to-hand transactions consistent with drug sales outside a convenience store on \(rng.pick(NameBank.streets)), about two miles from the residence.")
                affidavit.append("\(last) lists the residence as an address on a driver's license. Officers have not seen any drug activity at, or anyone carrying anything to or from, the residence.")
            }
        case .storageStolen:
            place = "Unit \(rng.int(10...240)) at \(rng.pick(["Coastal Self Storage", "Hollis Mini-Warehouse", "Route 17 Storage"])), \(town), rented to \(name)"
            items = ["Power tools, generators, and other property reported stolen in recent \(stolenWord)", "Documents showing the rental, use, or control of the unit",
                     "Receipts, pawn tickets, and records of sales of the property"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("Between the dates in the attached list, \(rng.int(5...14)) construction sites and garages in \(town) were \(breakIn ? "burglarized" : "hit by thieves") and power tools and generators were taken. Two of the stolen items, identified by serial number, were pawned within the past week by \(name).")
                affidavit.append("The storage facility's gate log shows \(last)'s access code used \(rng.int(6...15)) times in the past two weeks, late at night. A facility employee saw \(last) unloading generators from a truck into the unit three days ago.")
            case .anonymousTip:
                affidavit.append("An anonymous note left at the police department stated that \"the guy in unit \(rng.int(10...240)) has all the stuff from the \(breakIn ? "break-ins" : "thefts").\" The note was unsigned.")
                affidavit.append("Facility records show the unit is rented to \(name).")
            case .stale:
                affidavit.append("About \(monthsAgo) months ago, an acquaintance of \(name) told officers that \(last) once kept \"some tools that might have been hot\" in a storage unit.")
                affidavit.append("\(last) has a prior conviction for possession of stolen goods.")
            case .noNexus:
                affidavit.append("\(name) pawned two power tools reported stolen in a \(breakIn ? "burglary" : "theft") last month. The pawn shop has the items.")
                affidavit.append("\(last) rents a storage unit at the facility. Nothing in the investigation indicates any property was taken to the unit.")
            }
        case .bloodDraw:
            place = "The person of \(name), for a sample of blood to be drawn by a licensed medical professional at \(rng.pick(["the county hospital emergency department", "the detention center medical unit"]))"
            items = ["A sample of blood sufficient to test for alcohol concentration and the presence of impairing substances"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("At about \(rng.int(1...2)):\(rng.pick(["10", "25", "40"])) a.m. your affiant stopped \(name) after watching the vehicle cross the center line three times. \(last) had a strong odor of alcohol, red and glassy eyes, and slurred speech, and admitted to \"a few\" drinks. \(last) showed six of six clues on the horizontal gaze nystagmus test and could not complete the walk-and-turn.")
                affidavit.append("\(last) refused a breath test at the roadside and at the station. Alcohol leaves the blood over time, and less than two hours have passed since the driving, so a sample is needed now (Missouri v. McNeely requires a warrant absent exigency).")
            case .anonymousTip:
                affidavit.append("A caller who would not give a name told dispatch that \"the driver of the gray truck is drunk.\" The caller did not say what the caller saw.")
                affidavit.append("Your affiant found \(name) asleep in a parked truck matching that description. Your affiant did not see the truck being driven and did not note an odor or any sign of impairment.")
            case .stale:
                affidavit.append("\(name) was convicted of impaired driving about \(monthsAgo) months ago and, according to a records check, completed a substance abuse assessment.")
                affidavit.append("Your affiant believes \(last) may be a repeat offender and asks for a blood sample.")
            case .noNexus:
                affidavit.append("A restaurant receipt shows \(name) bought two beers about three hours before the stop. \(last) was stopped for an expired registration.")
                affidavit.append("Your affiant noted no odor, no driving violation, and no sign of impairment.")
            }
        case .bankRecords:
            let bank = rng.pick(["First Coastal Bank", "Tidewater Credit Union", "Carolina Trust"])
            place = "Records held by \(bank) for accounts in the name of \(name) and any business accounts controlled by \(last)"
            items = ["Account statements, signature cards, and deposit items for the period of the alleged offense", "Records of wire and electronic transfers into and out of the accounts"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("The victim's audit found \(rng.int(6...19)) transfers totaling $\(rng.int(14...96) * 1_000) to an account ending in \(rng.int(1000...9999)), opened by \(name) four months before the first transfer. The transfers began the week \(last) was given control of the victim's books.")
                affidavit.append("Your affiant interviewed two employees, who said that only \(last) had the password used for the transfers. A subpoena confirmed that the receiving account is held by \(name).")
            case .anonymousTip:
                affidavit.append("An anonymous letter to the victim's office said \"\(name) is stealing from the company.\" The letter was unsigned and gave no amounts or dates.")
                affidavit.append("Your affiant confirmed that \(last) works at the company and has access to its books.")
            case .stale:
                affidavit.append("An audit about \(monthsAgo) months ago questioned several entries made by \(name). The matter was closed after \(last) explained them as data entry errors.")
                affidavit.append("Your affiant believes the entries may have been theft.")
            case .noNexus:
                affidavit.append("\(name) has access to the victim's funds and drives a newer car than the salary suggests.")
                affidavit.append("Your affiant has no information that funds were moved to any account at this bank.")
            }
        case .digitalAccounts:
            place = "The email and social media accounts registered to \(name), held by the providers, and the laptop and phone seized from \(last)'s residence"
            items = ["Messages, posts, and attachments sent from or received by the accounts during the period of the offense", "Subscriber, login, and IP address records for the accounts"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("The victim received \(rng.int(12...60)) threatening or harassing messages from an account whose username matches a name \(name) has used online. A prior preservation request to the provider showed the account was created from an internet address assigned to \(last)'s home service.")
                affidavit.append("The victim identified \(last)'s writing style and a nickname only \(last) uses. The messages stopped the night officers spoke with \(last).")
            case .anonymousTip:
                affidavit.append("An anonymous tip said \"it's \(name)'s account, everyone knows.\" The tipster gave no reason for the belief.")
                affidavit.append("Your affiant found a social media profile in \(last)'s name. It has not posted anything to the victim.")
            case .stale:
                affidavit.append("\(name) was warned about harassing messages \(monthsAgo) months ago in an unrelated dispute.")
                affidavit.append("The current messages appear to come from a different account that your affiant has not connected to \(last).")
            case .noNexus:
                affidavit.append("\(name) is a former acquaintance of the victim and uses social media.")
                affidavit.append("The only information linking \(last) to the messages is that the victim believes \(last) sent them.")
            }
        case .dnaSample:
            place = "The person of \(name), for a buccal (cheek) swab to obtain a DNA sample"
            items = ["Two buccal swabs", "A DNA profile for comparison with evidence recovered at the scene"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("A swab of blood found on the broken window at the scene produced a partial DNA profile that does not match anyone known to live there. The victim and a neighbor described the person who fled, and each identified \(name) separately in a photo lineup administered by an officer who did not know the suspect.")
                affidavit.append("A comparison sample from \(last) will show whether the profile from the scene belongs to \(last) (G.S. 15A-271 to 15A-282).")
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"\(name) did it.\" The caller declined to say how the caller knew.")
                affidavit.append("Your affiant confirmed that \(last) lives in \(town) and was identified in no other way.")
            case .stale:
                affidavit.append("\(name) was a suspect in an unrelated case about \(monthsAgo) months ago and gave no sample.")
                affidavit.append("The DNA profile from the current scene has not been compared to anyone.")
            case .noNexus:
                affidavit.append("\(name) has a prior record and lives about a mile from the scene.")
                affidavit.append("No witness or other evidence ties \(last) to the scene, and the profile from the scene has not been compared to \(last).")
            }
        case .residenceWeapons:
            place = "The residence at \(rng.int(100...4_899)) \(street), \(town), and any vehicles on the curtilage"
            items = ["A handgun of the make and caliber used in the offense and ammunition", "Clothing matching the description given by witnesses", "Cartridge casings, holsters, and gun-cleaning supplies"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("Two witnesses described a person in a dark hooded jacket and a gray cap, and one identified \(name) from a photo lineup. Casings from the scene match a 9mm handgun. A neighbor saw \(last) return to the residence about ten minutes after the offense carrying a bag.")
                affidavit.append("Surveillance video from a store near the scene shows a person matching \(last)'s description leaving in a car registered to \(last) at the time of the offense. The car was parked at the residence the next morning.")
            case .anonymousTip:
                affidavit.append("An anonymous caller said \"\(name) has the gun, it's in the house.\" The caller did not give a name or say how the caller knew.")
                affidavit.append("Officers confirmed that \(last) lives at the address.")
            case .stale:
                affidavit.append("A witness told officers about \(monthsAgo) months ago that \(name) once showed off a pistol at the residence.")
                affidavit.append("\(last) has a prior conviction for a firearm offense. Nothing indicates a gun is in the residence now.")
            case .noNexus:
                affidavit.append("Surveillance video shows a person of \(last)'s general build leaving the scene on foot. Casings at the scene match a 9mm handgun.")
                affidavit.append("\(last) lives across town. Officers have no information that \(last) has a gun or that anything related to the offense is at the residence.")
            }
        case .phoneRecords:
            place = "Records held by the wireless carrier for the cell phone number assigned to \(name), and the phone itself, now in the property room of the \(agency)"
            items = ["Historical cell-site location information for the 48 hours around the offense",
                     "Call logs and text messages for the same period"]
            switch flaw {
            case .none, .overbroad:
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
            case .noNexus:
                affidavit.append("\(name) has \(violent ? "two prior robbery convictions and lives" : "a prior record and lives") about a mile from the scene.")
                affidavit.append("No witness, video, or other evidence links \(last) or \(last)'s phone to the current offense.")
            }
        }
        if flaw == .overbroad {
            items.append("Any and all papers, records, computers, cell phones, and electronic storage devices of any kind, and their contents")
        }
        affidavit.append("Based on the foregoing, your affiant believes probable cause exists that the items listed will be found in the place to be searched, and asks the court to issue a warrant. Sworn and subscribed before the court.")
        return WarrantApplication(kind: kind, affiant: affiant, agency: agency, applied: date, target: name, place: place,
                                  items: items, affidavit: affidavit, flaw: flaw)
    }

    private static func warrantTitle(_ k: WarrantApplication.Kind) -> String {
        switch k {
        case .phoneRecords: return "Phone Location Records"
        case .bloodDraw: return "Blood Test Results"
        case .bankRecords: return "Bank Records"
        case .digitalAccounts: return "Account and Device Records"
        case .dnaSample: return "DNA Comparison Results"
        default: return "Items Seized Under Search Warrant"
        }
    }

    private static func warrantEvidenceKind(_ k: WarrantApplication.Kind) -> EvidenceKind {
        switch k {
        case .phoneRecords, .digitalAccounts: return .digital
        case .bloodDraw, .dnaSample: return .forensic
        case .bankRecords: return .document
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
        }
    }

    /// The case once the warrant is executed: the seizure is an exhibit, and the defense moves to suppress it.
    /// `limited`: the judge struck the catch-all before signing.
    static func executed(_ w: WarrantApplication, on c: CourtCase, limited: Bool, signedBy judge: String, byThisJudge: Bool = true) -> CourtCase {
        var c = c
        var rng = SeededRNG(seed: c.seed ^ 0x5EA2_C4A1)
        let found: String
        switch w.kind {
        case .residenceDrugs: found = "Officers executing the warrant found cocaine packaged for sale in a kitchen cabinet, two digital scales, and $\(rng.int(18...64) * 100) in a bedroom closet."
        case .storageStolen: found = "Officers executing the warrant found \(rng.int(9...31)) power tools and three generators; serial numbers on eleven match \(isBreakIn(c) ? "burglary" : "theft") reports."
        case .bloodDraw: found = "A blood sample drawn under the warrant was analyzed by the State Crime Laboratory; the result was an alcohol concentration of 0.\(rng.int(9...19))."
        case .bankRecords: found = "Bank records show \(rng.int(6...19)) transfers totaling $\(rng.int(14...96) * 1_000) from the victim's accounts into an account held by \(c.defendant.name)."
        case .digitalAccounts: found = "Provider records show the account was created and logged into from an internet address assigned to \(c.defendant.lastName)'s home service, and the seized laptop holds copies of the messages."
        case .dnaSample: found = "The State Crime Laboratory reported that the swab profile matches the DNA recovered at the scene; the chance of a random match is about 1 in \(rng.int(8...900)) million."
        case .residenceWeapons: found = "Officers executing the warrant found a 9mm handgun, a box of ammunition, and a dark hooded jacket in a bedroom closet; the handgun test-fired casings match those from the scene."
        case .phoneRecords: found = "Carrier records place \(c.defendant.lastName)'s phone on the tower sector covering the scene from fifteen minutes before to ten minutes after the offense."
        }
        var evidence = Evidence(exhibit: "State's Exhibit \(c.evidence.filter { $0.side == .prosecution }.count + 1)",
                                title: warrantTitle(w.kind),
                                detail: found, side: .prosecution, kind: warrantEvidenceKind(w.kind), weight: 3)
        // Some seizures come back with a wrinkle that cuts against the State's reading of them.
        let twist = wrinkle(for: w.kind, rng: &rng)
        if let twist {
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
        let defense: String
        switch w.flaw {
        case .anonymousTip: defense = "The affidavit rests on an anonymous tip. Confirming the color of a house isn't corroboration. Without probable cause, everything seized must be suppressed, and there is no good-faith exception in North Carolina."
        case .stale: defense = "The only information about the place was months old. Nothing in the affidavit says the evidence would still be there."
        case .noNexus: defense = "The affidavit is about my client, not the place. There is nothing tying evidence to the location searched."
        case .overbroad: defense = limited ? "Even as narrowed, the warrant was obtained on an affidavit that cast a wide net. We ask the court to suppress." : "The warrant authorized a search of 'any and all' papers and devices. A general warrant is void."
        case .none: defense = "The informant's reliability isn't established, and the surveillance shows only visitors. The affidavit doesn't add up to probable cause."
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
