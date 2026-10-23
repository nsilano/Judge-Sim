import Foundation

/// Hollis County on a map: its towns, the streets and roads in each, and the businesses and landmarks people keep
/// coming back to. Cases, profiles and the paper all draw from here, so the same bar is always on the same street
/// in the same town.
enum Gazetteer {

    enum Kind: String, CaseIterable, Codable {
        case bar, gasStation, restaurant, grocery, plant, warehouse, church, school, hospital, bank, motel, park,
             boatLanding, pawnShop, autoShop, store, office, apartments, nursingHome, gym, salon, dayCare,
             pharmacy, storage, club, spa, veteransPost
    }

    struct Place: Hashable, Codable {
        let name: String
        let kind: Kind
        let town: String
        let street: String

        /// "The Lantern Row Tavern on Lantern Row in Bayard".
        var described: String { "\(name) on \(street) in \(town)" }
    }

    struct Town {
        let name: String
        /// What the town is like, for the paper and anyone describing it.
        let character: String
        let streets: [String]
        let roads: [String]
    }

    static let towns: [Town] = [
        Town(name: "Port Hollis", character: "the county seat: the courthouse, the harbor, and the old downtown",
             streets: ["Harbor Street", "Fifth Street", "Canal Street", "Saint Agnes Way", "Water Street", "Courthouse Square"],
             roads: ["Route 17", "Harbor Bypass"]),
        Town(name: "Wexley", character: "subdivisions, strip malls, and the county's newest schools",
             streets: ["Marlowe Boulevard", "Ridgeview Drive", "Juniper Court", "Sycamore Lane", "Pinewood Circle", "Wexley Commons Drive"],
             roads: ["Route 17", "Old Wexley Road"]),
        Town(name: "Cane Creek", character: "farm country, the poultry plant, and the distribution center out by the highway",
             streets: ["Brickyard Road", "Kestrel Road", "Mill Pond Road", "Tobacco Barn Lane", "Church Street"],
             roads: ["Highway 41", "Cane Creek Road", "Rock Quarry Road", "Route 9", "Industrial Boulevard", "Hobbs Creek Road"]),
        Town(name: "Dunmore Mills", character: "an old mill town: shuttered textile mills, rentals, and a stubborn Main Street",
             streets: ["Old Mill Lane", "Main Street", "Loom Street", "Railroad Avenue", "Dunmore Avenue"],
             roads: ["Highway 41", "Pruitt Mill Road", "Old Mill Road", "Route 9"]),
        Town(name: "Bayard", character: "the river town: bars, the boat landing, and summer traffic",
             streets: ["Lantern Row", "Pell Avenue", "River Street", "Landing Road", "Front Street"],
             roads: ["Route 17", "River Road"])
    ]

    static let places: [Place] = [
        // Port Hollis
        Place(name: "Hollis Regional Medical Center", kind: .hospital, town: "Port Hollis", street: "Saint Agnes Way"),
        Place(name: "Harbor House Seafood", kind: .restaurant, town: "Port Hollis", street: "Water Street"),
        Place(name: "Port Hollis Marine Supply", kind: .store, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "Port Hollis Shipyard", kind: .plant, town: "Port Hollis", street: "Canal Street"),
        Place(name: "First Coastal Bank", kind: .bank, town: "Port Hollis", street: "Courthouse Square"),
        Place(name: "Ashby & Greer, CPAs", kind: .office, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Saint Agnes Catholic Church", kind: .church, town: "Port Hollis", street: "Saint Agnes Way"),
        Place(name: "Hollis County High School", kind: .school, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Harbor Point Apartments", kind: .apartments, town: "Port Hollis", street: "Canal Street"),
        Place(name: "Harbor Motor Inn", kind: .motel, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "Waterfront Park", kind: .park, town: "Port Hollis", street: "Water Street"),
        Place(name: "Iron Harbor Fitness", kind: .gym, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Harbor Pawn & Loan", kind: .pawnShop, town: "Port Hollis", street: "Canal Street"),
        Place(name: "Little Harbor Day Care", kind: .dayCare, town: "Port Hollis", street: "Saint Agnes Way"),
        // Wexley
        Place(name: "Marlowe Boulevard Home Goods", kind: .store, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Marlowe Motors", kind: .autoShop, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Coastal Wireless", kind: .store, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Wexley Food Mart", kind: .grocery, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Wexley Family Dentistry", kind: .office, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "Pinewood Analytics", kind: .office, town: "Wexley", street: "Pinewood Circle"),
        Place(name: "Ridgeview Baptist Church", kind: .church, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "Wexley Middle School", kind: .school, town: "Wexley", street: "Sycamore Lane"),
        Place(name: "The Commons at Wexley", kind: .apartments, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Juniper Court Auto Repair", kind: .autoShop, town: "Wexley", street: "Juniper Court"),
        Place(name: "Coastal Realty Group", kind: .office, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Salon Wexley", kind: .salon, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Wexley Quik Stop", kind: .gasStation, town: "Wexley", street: "Old Wexley Road"),
        // Cane Creek
        Place(name: "Cane Creek Poultry", kind: .plant, town: "Cane Creek", street: "Highway 41"),
        Place(name: "Harborview Distribution Center", kind: .warehouse, town: "Cane Creek", street: "Highway 41"),
        Place(name: "Tidewater Freight Logistics", kind: .warehouse, town: "Cane Creek", street: "Kestrel Road"),
        Place(name: "Cane Creek Hardware", kind: .store, town: "Cane Creek", street: "Church Street"),
        Place(name: "Cane Creek Farm Supply", kind: .store, town: "Cane Creek", street: "Tobacco Barn Lane"),
        Place(name: "Kestrel Builders", kind: .office, town: "Cane Creek", street: "Kestrel Road"),
        Place(name: "Cane Creek Methodist Church", kind: .church, town: "Cane Creek", street: "Church Street"),
        Place(name: "Kwik Fuel", kind: .gasStation, town: "Cane Creek", street: "Highway 41"),
        Place(name: "Brickyard Road Mobile Home Park", kind: .apartments, town: "Cane Creek", street: "Brickyard Road"),
        Place(name: "Cane Creek Elementary", kind: .school, town: "Cane Creek", street: "Mill Pond Road"),
        // Dunmore Mills
        Place(name: "Dunmore Mills Manufacturing", kind: .plant, town: "Dunmore Mills", street: "Loom Street"),
        Place(name: "The Brickyard Grill", kind: .restaurant, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "Dunmore Family Grocery", kind: .grocery, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "Dunmore Mills Motel", kind: .motel, town: "Dunmore Mills", street: "Railroad Avenue"),
        Place(name: "Mill Village Apartments", kind: .apartments, town: "Dunmore Mills", street: "Old Mill Lane"),
        Place(name: "Railroad Avenue Pawn", kind: .pawnShop, town: "Dunmore Mills", street: "Railroad Avenue"),
        Place(name: "Greater Hope AME Zion Church", kind: .church, town: "Dunmore Mills", street: "Main Street"),
        
        Place(name: "Harborview Call Center", kind: .office, town: "Dunmore Mills", street: "Loom Street"),
        Place(name: "Mill Street Park", kind: .park, town: "Dunmore Mills", street: "Main Street"),
        // Bayard
        Place(name: "The Lantern Row Tavern", kind: .bar, town: "Bayard", street: "Lantern Row"),
        Place(name: "The Rusty Anchor", kind: .bar, town: "Bayard", street: "Front Street"),
        Place(name: "Riverside Billiards", kind: .bar, town: "Bayard", street: "River Street"),
        Place(name: "Pell Avenue Diner", kind: .restaurant, town: "Bayard", street: "Pell Avenue"),
        Place(name: "Pell Avenue Quik Stop", kind: .gasStation, town: "Bayard", street: "Pell Avenue"),
        Place(name: "Bayard Boat Landing", kind: .boatLanding, town: "Bayard", street: "Landing Road"),
        Place(name: "River Road Inn", kind: .motel, town: "Bayard", street: "River Road"),
        Place(name: "Salon Bayard", kind: .salon, town: "Bayard", street: "Front Street"),
        Place(name: "Bayard Riverfront Park", kind: .park, town: "Bayard", street: "River Street"),
        Place(name: "First Baptist Church of Bayard", kind: .church, town: "Bayard", street: "Front Street"),
        Place(name: "Bayard Family Grocery", kind: .grocery, town: "Bayard", street: "Front Street"),
        Place(name: "Bayard Rehabilitation and Nursing", kind: .nursingHome, town: "Bayard", street: "River Road"),
        Place(name: "Cane Creek Home Care", kind: .office, town: "Cane Creek", street: "Church Street"),
        // Places the written cases name
        Place(name: "Rusty's Pool Hall", kind: .bar, town: "Dunmore Mills", street: "Railroad Avenue"),
        Place(name: "The Anchor Tavern", kind: .bar, town: "Port Hollis", street: "Water Street"),
        Place(name: "The Spillway Bar", kind: .bar, town: "Bayard", street: "River Road"),
        Place(name: "Station 9", kind: .club, town: "Cane Creek", street: "Route 9"),
        Place(name: "The Anchor", kind: .club, town: "Port Hollis", street: "Water Street"),
        Place(name: "Velvet Room", kind: .club, town: "Bayard", street: "Front Street"),
        Place(name: "Carolina Trust", kind: .bank, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Hollis Savings Bank", kind: .bank, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Piedmont Federal Bank", kind: .bank, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "Cane Creek Mini Storage", kind: .storage, town: "Cane Creek", street: "Industrial Boulevard"),
        Place(name: "Harbor Lock & Store", kind: .storage, town: "Port Hollis", street: "Harbor Bypass"),
        Place(name: "Route 17 Self Storage", kind: .storage, town: "Wexley", street: "Route 17"),
        Place(name: "Food Lion", kind: .grocery, town: "Wexley", street: "Route 17"),
        Place(name: "Harris Teeter", kind: .grocery, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Piggly Wiggly", kind: .grocery, town: "Cane Creek", street: "Church Street"),
        Place(name: "the Dollar General on Route 17", kind: .store, town: "Bayard", street: "Route 17"),
        Place(name: "Coastal CrossFit", kind: .gym, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "Pell Avenue Athletic Club", kind: .gym, town: "Bayard", street: "Pell Avenue"),
        Place(name: "Cash Corner Pawn", kind: .pawnShop, town: "Bayard", street: "Front Street"),
        Place(name: "Hollis Gold & Pawn", kind: .pawnShop, town: "Port Hollis", street: "Canal Street"),
        Place(name: "Route 17 Pawn & Loan", kind: .pawnShop, town: "Wexley", street: "Route 17"),
        Place(name: "Coastal Family Pharmacy", kind: .pharmacy, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Hollis Family Pharmacy", kind: .pharmacy, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Main Street Pharmacy", kind: .pharmacy, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "Medicap Drugs", kind: .pharmacy, town: "Cane Creek", street: "Church Street"),
        Place(name: "Riverside Apothecary", kind: .pharmacy, town: "Bayard", street: "River Street"),
        Place(name: "American Legion Post 54", kind: .veteransPost, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "VFW Post 2209", kind: .veteransPost, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "VFW Post 8817", kind: .veteransPost, town: "Cane Creek", street: "Cane Creek Road"),
        Place(name: "Big Lou's Smokehouse", kind: .restaurant, town: "Cane Creek", street: "Highway 41"),
        Place(name: "Delgado's Family Restaurant", kind: .restaurant, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "Mama Lu's Kitchen", kind: .restaurant, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "Riverside Grill", kind: .restaurant, town: "Bayard", street: "River Street"),
        Place(name: "The Copper Kettle", kind: .restaurant, town: "Port Hollis", street: "Courthouse Square"),
        Place(name: "Bayard County High", kind: .school, town: "Bayard", street: "Landing Road"),
        Place(name: "East Hollis High", kind: .school, town: "Cane Creek", street: "Mill Pond Road"),
        Place(name: "Eastview High School", kind: .school, town: "Wexley", street: "Sycamore Lane"),
        Place(name: "Hollis Central High", kind: .school, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "Hollis Central High School", kind: .school, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "Harbor Mart", kind: .gasStation, town: "Port Hollis", street: "Harbor Bypass"),
        Place(name: "Quik Stop #4", kind: .gasStation, town: "Dunmore Mills", street: "Highway 41"),
        Place(name: "Riverside Mini Mart", kind: .gasStation, town: "Bayard", street: "River Road"),
        Place(name: "Coastal Massage Studio", kind: .spa, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Harbor Wellness Spa", kind: .spa, town: "Port Hollis", street: "Water Street"),
        Place(name: "Serenity Day Spa", kind: .spa, town: "Bayard", street: "Front Street"),
        Place(name: "Bayard Feed and Hardware", kind: .store, town: "Bayard", street: "River Road"),
        Place(name: "Coastal Farm Supply", kind: .store, town: "Cane Creek", street: "Hobbs Creek Road"),
        Place(name: "Pruitt Feed & Seed", kind: .store, town: "Dunmore Mills", street: "Pruitt Mill Road"),
        Place(name: "Cedar Hill United Methodist Church", kind: .church, town: "Wexley", street: "Old Wexley Road"),
        Place(name: "Greater Hope Baptist Church", kind: .church, town: "Dunmore Mills", street: "Loom Street"),
        Place(name: "Mount Zion AME Zion Church", kind: .church, town: "Port Hollis", street: "Canal Street"),
        Place(name: "New Life Fellowship", kind: .church, town: "Wexley", street: "Pinewood Circle"),
        Place(name: "Pleasant Grove Missionary Baptist Church", kind: .church, town: "Cane Creek", street: "Tobacco Barn Lane"),
        Place(name: "Carolina Comfort Home Care", kind: .office, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "Hollis Senior Companions", kind: .office, town: "Port Hollis", street: "Saint Agnes Way"),
        Place(name: "Piedmont Home Health", kind: .office, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "Coastal Carriers Inc.", kind: .warehouse, town: "Cane Creek", street: "Industrial Boulevard"),
        Place(name: "Harborview Distribution", kind: .warehouse, town: "Cane Creek", street: "Highway 41"),
        Place(name: "St. Mark's Lutheran Church", kind: .church, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Riverside Drug", kind: .pharmacy, town: "Bayard", street: "Front Street"),
        Place(name: "The Harbor Table", kind: .restaurant, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "Port Hollis High School", kind: .school, town: "Port Hollis", street: "Saint Agnes Way"),
        Place(name: "Harbor Point Outboard", kind: .store, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "Riverbend Boat & Motor", kind: .store, town: "Bayard", street: "Landing Road"),
        Place(name: "Tidewater Marine Supply", kind: .store, town: "Port Hollis", street: "Canal Street"),
        // Places the older case templates name
        Place(name: "CareWell Pharmacy", kind: .pharmacy, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "Hollis Drug & Sundry", kind: .pharmacy, town: "Port Hollis", street: "Courthouse Square"),
        Place(name: "MediMart Pharmacy", kind: .pharmacy, town: "Cane Creek", street: "Highway 41"),
        Place(name: "the CVS in Bayard", kind: .pharmacy, town: "Bayard", street: "Front Street"),
        Place(name: "the Walgreens on Pell Avenue", kind: .pharmacy, town: "Bayard", street: "Pell Avenue"),
        Place(name: "Coastal Plains Logistics", kind: .warehouse, town: "Cane Creek", street: "Industrial Boulevard"),
        Place(name: "Corner Pantry", kind: .store, town: "Dunmore Mills", street: "Railroad Avenue"),
        Place(name: "Hollis 24/7 Fuel", kind: .gasStation, town: "Port Hollis", street: "Harbor Bypass"),
        Place(name: "Hollis Hardware", kind: .store, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Hollis Memorial Gardens", kind: .park, town: "Wexley", street: "Old Wexley Road"),
        Place(name: "Lucky Dragon Market", kind: .grocery, town: "Port Hollis", street: "Canal Street"),
        Place(name: "Quik-Stop Mart", kind: .gasStation, town: "Cane Creek", street: "Route 9"),
        Place(name: "Sunset Liquors", kind: .store, town: "Bayard", street: "River Road"),
        Place(name: "the Bojangles on Marlowe Boulevard", kind: .restaurant, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "the Dollar General in Bayard", kind: .store, town: "Bayard", street: "River Road"),
        Place(name: "the Port Hollis Marina", kind: .boatLanding, town: "Port Hollis", street: "Water Street"),
        Place(name: "Hollis County Courthouse", kind: .office, town: "Port Hollis", street: "Courthouse Square"),
        Place(name: "old Wexley Town Hall", kind: .office, town: "Wexley", street: "Old Wexley Road"),
        Place(name: "Mulligan's Tavern", kind: .bar, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "the Lamplighter", kind: .bar, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "the Neon Moose", kind: .bar, town: "Bayard", street: "Lantern Row"),
        Place(name: "Casa Mirasol", kind: .restaurant, town: "Wexley", street: "Wexley Commons Drive"),
        Place(name: "Pho Golden", kind: .restaurant, town: "Port Hollis", street: "Canal Street"),
        Place(name: "Rosalind's Diner", kind: .restaurant, town: "Dunmore Mills", street: "Main Street"),
        Place(name: "the Blue Gull Grill", kind: .restaurant, town: "Bayard", street: "Front Street"),
        Place(name: "a church parking lot in Wexley", kind: .park, town: "Wexley", street: "Ridgeview Drive"),
        Place(name: "the Hollis Transit depot", kind: .office, town: "Port Hollis", street: "Harbor Bypass"),
        Place(name: "the U-Haul lot on Harbor Street", kind: .store, town: "Port Hollis", street: "Harbor Street"),
        Place(name: "Cedar Hill Commons", kind: .apartments, town: "Wexley", street: "Pinewood Circle"),
        Place(name: "the Harbor Point complex", kind: .apartments, town: "Port Hollis", street: "Canal Street"),
        Place(name: "the Riverbend Apartments", kind: .apartments, town: "Bayard", street: "River Street"),
        Place(name: "Hollis Piggly Wiggly", kind: .grocery, town: "Dunmore Mills", street: "Dunmore Avenue"),
        Place(name: "the Food Lion on Pell Avenue", kind: .grocery, town: "Bayard", street: "Pell Avenue"),
        Place(name: "the Harris Teeter in Cedar Hill", kind: .grocery, town: "Wexley", street: "Pinewood Circle"),
        Place(name: "Cane Creek Early College", kind: .school, town: "Cane Creek", street: "Mill Pond Road"),
        Place(name: "Hollis High School", kind: .school, town: "Port Hollis", street: "Fifth Street"),
        Place(name: "Wexley Senior High", kind: .school, town: "Wexley", street: "Sycamore Lane"),
        Place(name: "Hollis Target", kind: .store, town: "Wexley", street: "Marlowe Boulevard"),
        Place(name: "the CVS in Cedar Hill", kind: .pharmacy, town: "Wexley", street: "Pinewood Circle")
    ]

    // MARK: The county's regulars

    /// The people who keep turning up in this county's cases: the medical examiner, the crime lab's analysts, the ER
    /// doctor at Hollis Regional, the fire investigator. The same names for a whole career.
    static func regulars(for county: County) -> [String: String] {
        var hash: UInt64 = 1469598103934665603
        for byte in (county.sheriff + county.clerk + county.districtAttorney).utf8 { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
        var rng = SeededRNG(seed: hash)
        var used = Set([county.sheriff, county.clerk, county.districtAttorney, county.policeChief, county.chiefPublicDefender])
        var out: [String: String] = [:]
        for key in ["ME", "CHEMIST", "TOX", "FIREARMS", "DNA", "PRINTS", "FIRE", "DIGITAL", "ERDOC", "OWNER.BAR", "MANAGER.PLANT", "PASTOR"] {
            out[key] = NameBank.person(using: &rng, excluding: &used)
        }
        return out
    }

    /// Which regular a State witness's role names, if any. Defense experts and second opinions are someone else.
    static func regularKey(forRole role: String) -> String? {
        let r = role.lowercased()
        if r.contains("defense") || r.contains("second") || r.contains("pediatric") { return nil }
        if r.contains("medical examiner") { return "ME" }
        if r.contains("toxicolog") { return "TOX" }
        if r.contains("chemist") { return "CHEMIST" }
        if r.contains("firearms") { return "FIREARMS" }
        if r.contains("dna") { return "DNA" }
        if r.contains("latent print") { return "PRINTS" }
        if r.contains("fire investigator") || r.contains("fire marshal") { return "FIRE" }
        if r.contains("digital forensic") { return "DIGITAL" }
        if r.contains("emergency physician") || r.contains("emergency room") || r.contains("er physician") || r.contains("er doctor") { return "ERDOC" }
        return nil
    }

    /// Every street and road in the county.
    static var allStreets: [String] { Array(Set(towns.flatMap { $0.streets + $0.roads })).sorted() }

    static func town(named name: String) -> Town? { towns.first { $0.name == name } }

    /// The place with this exact name, if it's on the map.
    static func place(named name: String) -> Place? { (places + living.opened).first { $0.name == name } }

    /// This career's county: what has closed, opened and changed hands. Set by the game whenever it changes.
    static var living = LivingCounty()

    /// The places open for business right now.
    static var livePlaces: [Place] { places.filter { living.closed[$0.name] == nil } + living.opened.filter { living.closed[$0.name] == nil } }

    /// A street in this town (a county-wide one if the town isn't on the map).
    static func street(in town: String, rng: inout SeededRNG) -> String {
        guard let t = self.town(named: town) else { return rng.pick(allStreets) }
        return rng.pick(t.streets)
    }

    /// A place of this kind, in this town when there is one, otherwise anywhere in the county.
    static func place(_ kind: Kind, in town: String? = nil, rng: inout SeededRNG) -> Place? {
        let all = livePlaces.filter { $0.kind == kind }
        let local = all.filter { $0.town == town }
        let pool = local.isEmpty ? all : local
        return pool.isEmpty ? nil : rng.pick(pool)
    }

    /// The tokens a written case can use for a place: {PLACE.BAR}, {PLACE.GASSTATION}, {PLACE.DINER} and so on, each
    /// filled with a real place in the case's own town when there is one, with {PLACE.BAR.ST} and {PLACE.BAR.TOWN} for
    /// its street and town. (Their own prefix keeps them apart from a case's own {BAR} or {SCHOOL}.)
    static func tokens(town: String, rng: inout SeededRNG) -> [String: String] {
        let wanted: [(String, Kind)] = [("BAR", .bar), ("GASSTATION", .gasStation), ("DINER", .restaurant), ("GROCERY", .grocery),
                                        ("PLANT", .plant), ("WAREHOUSE", .warehouse), ("CHURCH", .church), ("MOTEL", .motel),
                                        ("PARK", .park), ("BANK", .bank), ("PAWN", .pawnShop), ("APARTMENTS", .apartments),
                                        ("HOSPITAL", .hospital), ("SCHOOL", .school), ("LANDING", .boatLanding)]
        var out: [String: String] = [:]
        for (key, kind) in wanted {
            if let p = place(kind, in: town, rng: &rng) {
                out["PLACE." + key] = p.name
                out["PLACE." + key + ".ST"] = p.street
                out["PLACE." + key + ".TOWN"] = p.town
            }
        }
        return out
    }
}
