import Foundation

/// An application for a search warrant brought to the judge in chambers (G.S. 15A-243 to 15A-246): the officer's
/// sworn affidavit, the place to be searched, and the items to be seized. The judge decides whether the
/// affidavit shows probable cause under the totality of the circumstances (Illinois v. Gates; State v. Arrington).
struct WarrantApplication: Codable, Hashable {
    enum Kind: String, Codable {
        case residenceDrugs, storageStolen, phoneRecords

        var label: String {
            switch self {
            case .residenceDrugs: return "Residence: controlled substances"
            case .storageStolen: return "Storage unit: stolen property"
            case .phoneRecords: return "Cell phone and location records"
            }
        }

        /// The kinds of case a search like this turns into.
        var categories: Set<LawCategory> {
            switch self {
            case .residenceDrugs: return [.drugs]
            case .storageStolen: return [.property]
            case .phoneRecords: return [.robbery, .violent]
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

    static func application(for c: CourtCase, date: Date, rng: inout SeededRNG) -> WarrantApplication {
        let facts = c.investigation?.facts
        let affiant = facts?.lead ?? "Detective \(rng.pick(NameBank.lastNames))"
        let agency = facts?.agency ?? c.investigatingAgency
        let street = facts?.street ?? rng.pick(NameBank.streets)
        let town = facts?.town ?? "Port Hollis"
        let name = c.defendant.name
        let last = c.defendant.lastName
        let kind: WarrantApplication.Kind
        switch c.category {
        case .drugs: kind = .residenceDrugs
        case .property: kind = .storageStolen
        default: kind = .phoneRecords
        }
        let roll = rng.int(1...100)
        let flaw: WarrantApplication.Flaw = roll <= 50 ? .none : (roll <= 65 ? .overbroad : rng.pick([.anonymousTip, .stale, .noNexus]))
        let years = rng.int(4...17)
        let monthsAgo = rng.int(5...9)
        var affidavit = ["Your affiant, \(affiant), has been a sworn law enforcement officer with the \(agency) for \(years) years and has training and experience in the investigation of \(kind == .residenceDrugs ? "narcotics distribution" : (kind == .storageStolen ? "property crimes and the fencing of stolen goods" : "robbery and violent crime")), including the execution of more than \(rng.int(20...140)) search warrants."]
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
            items = ["Power tools, generators, and other property reported stolen in recent burglaries", "Documents showing the rental, use, or control of the unit",
                     "Receipts, pawn tickets, and records of sales of the property"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("Between the dates in the attached list, \(rng.int(5...14)) construction sites and garages in \(town) were burglarized and power tools and generators were taken. Two of the stolen items, identified by serial number, were pawned within the past week by \(name).")
                affidavit.append("The storage facility's gate log shows \(last)'s access code used \(rng.int(6...15)) times in the past two weeks, late at night. A facility employee saw \(last) unloading generators from a truck into the unit three days ago.")
            case .anonymousTip:
                affidavit.append("An anonymous note left at the police department stated that \"the guy in unit \(rng.int(10...240)) has all the stuff from the break-ins.\" The note was unsigned.")
                affidavit.append("Facility records show the unit is rented to \(name).")
            case .stale:
                affidavit.append("About \(monthsAgo) months ago, an acquaintance of \(name) told officers that \(last) once kept \"some tools that might have been hot\" in a storage unit.")
                affidavit.append("\(last) has a prior conviction for possession of stolen goods.")
            case .noNexus:
                affidavit.append("\(name) pawned two power tools reported stolen in a burglary last month. The pawn shop has the items.")
                affidavit.append("\(last) rents a storage unit at the facility. Nothing in the investigation indicates any property was taken to the unit.")
            }
        case .phoneRecords:
            place = "Records held by the wireless carrier for the cell phone number assigned to \(name), and the phone itself, now in the property room of the \(agency)"
            items = ["Historical cell-site location information for the 48 hours around the offense",
                     "Call logs and text messages for the same period"]
            switch flaw {
            case .none, .overbroad:
                affidavit.append("The victim identified \(name) from a photo lineup administered by an officer who did not know which photo was the suspect. Surveillance video shows a person matching \(last)'s description at the scene.")
                affidavit.append("\(last)'s phone number appears in the victim's call log twenty minutes before the offense. Location data would show whether the phone was near the scene at that time (Carpenter v. United States requires a warrant for it).")
            case .anonymousTip:
                affidavit.append("An anonymous caller said the person responsible \"goes by \(last) and hangs out on \(street).\"")
                affidavit.append("Officers found that a person named \(name) lives near \(street) and obtained the phone number from a prior arrest record.")
            case .stale:
                affidavit.append("\(name) was a suspect in a similar robbery about \(monthsAgo) months ago; that case was closed without charges.")
                affidavit.append("Officers believe the same person may be responsible for the current offense because of the similar method.")
            case .noNexus:
                affidavit.append("\(name) has two prior robbery convictions and lives about a mile from the scene.")
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

    /// The case once the warrant is executed: the seizure is an exhibit, and the defense moves to suppress it.
    /// `limited`: the judge struck the catch-all before signing.
    static func executed(_ w: WarrantApplication, on c: CourtCase, limited: Bool, signedBy judge: String, byThisJudge: Bool = true) -> CourtCase {
        var c = c
        let found: String
        switch w.kind {
        case .residenceDrugs: found = "Officers executing the warrant found cocaine packaged for sale in a kitchen cabinet, two digital scales, and $\(Int.random(in: 18...64) * 100) in a bedroom closet."
        case .storageStolen: found = "Officers executing the warrant found \(Int.random(in: 9...31)) power tools and three generators; serial numbers on eleven match burglary reports."
        case .phoneRecords: found = "Carrier records place \(c.defendant.lastName)'s phone on the tower sector covering the scene from fifteen minutes before to ten minutes after the offense."
        }
        let evidence = Evidence(exhibit: "State's Exhibit \(c.evidence.filter { $0.side == .prosecution }.count + 1)",
                                title: w.kind == .phoneRecords ? "Phone Location Records" : "Items Seized Under Search Warrant",
                                detail: found, side: .prosecution, kind: w.kind == .phoneRecords ? .digital : .physical, weight: 3)
        c.evidence.append(evidence)
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
