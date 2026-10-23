import Foundation

/// What has happened to Hollis County in this career: businesses closed, opened and sold, plants laying off, new
/// subdivisions. Every career starts a little different, and the county keeps changing; cases follow it (a closed bar
/// stops turning up, a town in a hard stretch sees more thefts) and the paper reports it.
struct LivingCounty: Codable, Hashable {
    struct Event: Codable, Hashable {
        var date: Date
        var headline: String
        var town: String?
    }

    /// Place name → the day it closed.
    var closed: [String: Date] = [:]
    var opened: [Gazetteer.Place] = []
    /// Place name → owner.
    var owners: [String: String] = [:]
    /// "town|category" → how much likelier that kind of case is there, and until when.
    var heat: [String: Double] = [:]
    var heatUntil: [String: Date] = [:]
    var events: [Event] = []

    /// How much likelier a case of this category is in this town right now.
    func weight(town: String, category: String, on date: Date) -> Double {
        let key = "\(town)|\(category)"
        guard let until = heatUntil[key], until > date else { return 1 }
        return heat[key] ?? 1
    }
}

enum CountyLife {
    /// Places nobody closes or sells: the hospital, the schools, the courthouse.
    private static let fixed: Set<Gazetteer.Kind> = [.hospital, .school]
    /// Places the game names outright (on receipts, exhibits and in written aftermath), so they stay open.
    private static let named: Set<String> = ["Harbor Mart", "Tidewater Freight Logistics", "Cane Creek Hardware", "The Lantern Row Tavern",
                                             "Hollis County Courthouse"]
    private static func canClose(_ p: Gazetteer.Place) -> Bool { !fixed.contains(p.kind) && p.kind != .church && !named.contains(p.name) }

    /// Businesses that can open in the county, by town.
    private static let newcomers: [(String, Gazetteer.Kind, String)] = [
        ("Tidewater Taproom", .bar, "Port Hollis"), ("Smoke & Barrel BBQ", .restaurant, "Cane Creek"),
        ("Wexley Urgent Care", .office, "Wexley"), ("Dollar Depot", .store, "Dunmore Mills"),
        ("The Mill Yard Brewery", .bar, "Dunmore Mills"), ("Sunrise Vape & Smoke", .store, "Bayard"),
        ("El Toro Taqueria", .restaurant, "Bayard"), ("Coastal Cash Advance", .office, "Port Hollis"),
        ("Harbor Liquor Outlet", .store, "Port Hollis"), ("Creekside Fuel", .gasStation, "Cane Creek"),
        ("The Pines at Wexley", .apartments, "Wexley"), ("River Bend Motel", .motel, "Bayard"),
        ("Gold Rush Pawn", .pawnShop, "Wexley"), ("Night Owl Lounge", .bar, "Wexley"),
        ("Fresh Market on Main", .grocery, "Dunmore Mills"), ("Bayard Bait & Tackle", .store, "Bayard")
    ]

    /// A new career's county: a few places already gone, a few new ones, and owners for the businesses.
    static func begin(seed: UInt64) -> LivingCounty {
        var rng = SeededRNG(seed: seed ^ 0x11F1_C0DE)
        var c = LivingCounty()
        let start = Date.distantPast
        let closable = Gazetteer.places.filter(canClose)
        for p in rng.pick(closable, count: rng.int(4...7)) { c.closed[p.name] = start }
        for (name, kind, town) in rng.pick(newcomers, count: rng.int(2...4)) {
            c.opened.append(Gazetteer.Place(name: name, kind: kind, town: town, street: Gazetteer.street(in: town, rng: &rng)))
        }
        var used = Set<String>()
        for p in Gazetteer.places + c.opened where [.bar, .restaurant, .store, .gasStation, .motel, .pawnShop, .club].contains(p.kind) {
            c.owners[p.name] = NameBank.person(using: &rng, excluding: &used)
        }
        return c
    }

    /// One week in the county's life: now and then something changes. Returns the news it makes.
    static func week(_ c: inout LivingCounty, on date: Date, placeHistory: [String: [String]], rng: inout SeededRNG) -> NewsItem? {
        guard rng.chance(0.35) else { return nil }
        let cal = CourtCalendar.calendar
        func heat(_ town: String, _ categories: [LawCategory], by factor: Double, weeks: Int) {
            for cat in categories {
                let key = "\(town)|\(cat.rawValue)"
                c.heat[key] = factor
                c.heatUntil[key] = cal.date(byAdding: .day, value: 7 * weeks, to: date) ?? date
            }
        }
        func news(_ headline: String, _ body: String, town: String?, section: String = "Business") -> NewsItem {
            c.events.append(LivingCounty.Event(date: date, headline: headline, town: town))
            return NewsItem(date: date, kind: .community, headline: headline, body: body, prominence: 1, section: section)
        }
        let live = Gazetteer.livePlaces

        // A bar that keeps sending cases to court loses its license.
        if let troubled = live.first(where: { ($0.kind == .bar || $0.kind == .club) && (placeHistory[$0.name]?.count ?? 0) >= 3 }) {
            c.closed[troubled.name] = date
            return news("\(troubled.name) loses its license", "The state ABC Commission pulled the permit for \(troubled.described) after a string of fights and arrests, several of which ended up in Superior Court. The doors are padlocked.", town: troubled.town, section: "Local")
        }
        switch rng.int(0...4) {
        case 0:
            // Layoffs: harder times in that town.
            guard let plant = live.filter({ $0.kind == .plant || $0.kind == .warehouse }).randomElement(using: &rng) else { return nil }
            let jobs = rng.int(4...18) * 10
            heat(plant.town, [.property, .drugs], by: 1.8, weeks: 12)
            return news("\(plant.name) lays off \(jobs) workers", "\(plant.name) in \(plant.town) cut \(jobs) jobs this week. \"People have rent due Friday,\" one worker said in the parking lot on \(plant.street).", town: plant.town)
        case 1:
            // A business opens.
            let open = newcomers.filter { n in !c.opened.contains { $0.name == n.0 } }
            guard let pick = open.randomElement(using: &rng) else { return nil }
            let place = Gazetteer.Place(name: pick.0, kind: pick.1, town: pick.2, street: Gazetteer.street(in: pick.2, rng: &rng))
            c.opened.append(place)
            var used = Set<String>()
            c.owners[place.name] = NameBank.person(using: &rng, excluding: &used)
            return news("\(place.name) opens on \(place.street)", "\(place.name) opened this week in \(place.town). The owner, \(c.owners[place.name] ?? "a local family"), says it's been a long time coming.", town: place.town)
        case 2:
            // A business closes.
            guard let gone = live.filter({ canClose($0) && $0.kind != .plant }).randomElement(using: &rng) else { return nil }
            c.closed[gone.name] = date
            return news("\(gone.name) closes its doors", "After years on \(gone.street) in \(gone.town), \(gone.name) has closed. A sign on the door thanks the customers.", town: gone.town)
        case 3:
            // A business changes hands.
            guard let sold = live.filter({ c.owners[$0.name] != nil }).randomElement(using: &rng) else { return nil }
            var used = Set([c.owners[sold.name] ?? ""])
            let buyer = NameBank.person(using: &rng, excluding: &used)
            let seller = c.owners[sold.name] ?? "the previous owner"
            c.owners[sold.name] = buyer
            return news("\(sold.name) sold", "\(seller) has sold \(sold.name) in \(sold.town) to \(buyer), who says the name stays.", town: sold.town)
        default:
            // Growth: a new subdivision brings construction-site thefts and break-ins for a while.
            let town = rng.pick(["Wexley", "Cane Creek", "Bayard"])
            heat(town, [.property], by: 1.4, weeks: 16)
            let street = Gazetteer.street(in: town, rng: &rng)
            return news("New subdivision breaks ground in \(town)", "Crews cleared land off \(street) for 140 homes. Deputies say building sites are a magnet for tool and copper thefts, and ask neighbors to call in anything after dark.", town: town)
        }
    }
}
