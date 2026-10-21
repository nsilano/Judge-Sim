import Foundation

/// A register receipt as the store's printer produced it: no story, just the purchase, the time and how it was paid.
/// The receipt is built from what the case says was bought; the explanation stays in the exhibit's description.
struct Receipt {
    struct Item: Hashable {
        var name: String
        var detail: String?
        var price: Double
    }

    enum Kind { case store, fuel, laundromat, pawn }

    var kind: Kind
    var store: String
    var address: String
    var phone: String
    var date: Date
    var time: String
    var storeNumber: Int
    var register: Int
    var transaction: Int
    var cashier: String
    var items: [Item]
    var taxRate: Double
    var tender: String
    var cash: Double?
    var pump: Int?

    var subtotal: Double { items.reduce(0) { $0 + $1.price } }
    var tax: Double { (subtotal * taxRate * 100).rounded() / 100 }
    var total: Double { subtotal + tax }
    var change: Double? { cash.map { $0 - total } }

    static func money(_ v: Double) -> String { String(format: "%.2f", v) }

    /// What the case says was bought, at prices a store in eastern North Carolina would charge.
    private static let catalog: [(keys: [String], name: String, price: Double)] = [
        (["gas can", "gasoline can", "fuel can"], "GAS CAN 5 GAL", 18.99),
        (["duct tape"], "DUCT TAPE 60YD", 7.98), (["zip tie", "zip-tie", "cable tie"], "CABLE TIES 100PK", 6.47),
        (["rope"], "NYLON ROPE 50FT", 12.98), (["tarp"], "POLY TARP 8X10", 14.97), (["glove"], "WORK GLOVES L", 9.99),
        (["shovel"], "ROUND PT SHOVEL", 29.98), (["lighter fluid", "charcoal fluid"], "LIGHTER FLUID 32OZ", 6.49),
        (["lighter"], "BIC LIGHTER", 2.49), (["matches"], "MATCHES 10PK", 1.99), (["bleach"], "BLEACH 121OZ", 5.29),
        (["detergent"], "DETERGENT SNGL", 1.75), (["cigarette"], "CIGARETTES KS", 8.99), (["energy drink"], "ENERGY DRK 16OZ", 3.29),
        (["coffee"], "COFFEE 20OZ", 2.19), (["water"], "WATER 1L", 1.99), (["beer"], "BEER 12PK CAN", 15.99),
        (["vodka"], "VODKA 375ML", 9.95), (["wine"], "WINE 750ML", 11.99), (["scratch-off", "scratch off", "lottery"], "NC LOTTERY SCRATCH $5", 5.00),
        (["prepaid phone", "burner", "prepaid cell"], "PREPAID PHONE", 39.99), (["phone card", "minutes card", "refill card"], "PHONE REFILL $25", 25.00),
        (["gift card"], "GIFT CARD", 100.00), (["ammunition", "ammo", "shotgun shells", "rounds of"], "AMMO 9MM 50RD", 24.99),
        (["antifreeze"], "ANTIFREEZE 1GAL", 14.99), (["rat poison", "rodent"], "RODENT BAIT 1LB", 11.99), (["bolt cutter"], "BOLT CUTTER 24IN", 34.98),
        (["crowbar", "pry bar"], "PRY BAR 24IN", 16.98), (["ski mask", "face mask"], "KNIT MASK BLK", 9.99), (["hoodie", "sweatshirt"], "HOODED SWEATSHIRT", 24.99),
        (["chips"], "CHIPS LG BAG", 2.29), (["candy"], "CANDY BAR", 1.89), (["sandwich"], "DELI SANDWICH", 5.49), (["ice"], "BAG ICE 10LB", 2.99),
        (["feed"], "LAYER FEED 50LB", 17.49), (["fertilizer"], "FERTILIZER 40LB", 21.99), (["padlock", "lock"], "PADLOCK 40MM", 11.98),
        (["flashlight"], "LED FLASHLIGHT", 12.99), (["batteries"], "BATTERIES AA 8PK", 9.49), (["knife"], "UTILITY KNIFE", 8.97),
        (["syringe"], "SYRINGES 10CT", 4.99), (["baggies", "sandwich bags"], "ZIP BAGS 50CT", 3.49), (["scale"], "DIGITAL SCALE", 19.99),
        (["paint"], "SPRAY PAINT BLK", 5.98), (["plywood"], "PLYWOOD 4X8 1/2", 38.75), (["chain"], "STEEL CHAIN 10FT", 24.98),
    ]

    static func make(_ e: Evidence, source: String, date: Date?) -> Receipt {
        let text = (e.title + " " + e.detail).lowercased()
        var rng = SeededRNG(seed: UInt64(truncatingIfNeeded: "\(e.id)".stableHash) &+ 0x5EC1)
        let amounts = dollarAmounts(in: e.detail)
        let kind: Kind
        if text.contains("pawn") { kind = .pawn }
        else if ["laundromat", "laundry", "washer", "dryer", "wash-and-fold"].contains(where: text.contains) { kind = .laundromat }
        else if ["gas station", "gasoline", "fuel", "pump", "gallon", "unleaded", "diesel", "gas receipt"].contains(where: text.contains) && !text.contains("gas can") { kind = .fuel }
        else { kind = .store }

        let storeName: String
        switch kind {
        case .fuel: storeName = source.isEmpty || source.contains("Hardware") ? rng.pick(["Gas & Go #17", "Coastal Fuel Mart", "Speedy Stop #4"]) : source
        case .laundromat: storeName = rng.pick(["Suds City Laundromat", "Bright Wash Coin Laundry", "Main Street Wash & Fold"])
        case .pawn: storeName = source.contains("Pawn") ? source : "Hollis Pawn & Gold"
        case .store: storeName = source.isEmpty ? "Harbor Mart" : source
        }

        // The time the story gives, if any; otherwise one from the store's day.
        let time: String
        if let range = e.detail.range(of: #"\b(1[0-2]|[1-9]):[0-5][0-9] ?[ap]\.?m\.?"#, options: [.regularExpression, .caseInsensitive]) {
            let raw = e.detail[range].lowercased().replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " ", with: "")
            time = raw.replacingOccurrences(of: "am", with: " AM").replacingOccurrences(of: "pm", with: " PM")
        } else {
            let minutes = rng.int(7 * 60...22 * 60)
            let h = minutes / 60, m = minutes % 60
            time = "\(h % 12 == 0 ? 12 : h % 12):" + String(format: "%02d", m) + (h < 12 ? " AM" : " PM")
        }

        var items: [Item] = []
        var taxRate = 0.07
        var pump: Int?
        switch kind {
        case .fuel:
            taxRate = 0
            pump = rng.int(1...12)
            let price = Double(rng.int(289...349)) / 100
            let spend = amounts.max() ?? Double(rng.int(25...65))
            let gallons = (spend / price * 1000).rounded() / 1000
            items.append(Item(name: text.contains("diesel") ? "DIESEL" : "UNLEADED REG", detail: String(format: "%.3f GAL @ $%.3f/GAL", gallons, price), price: (gallons * price * 100).rounded() / 100))
            for extra in catalog where extra.keys.contains(where: text.contains) && !["gas can"].contains(extra.name) {
                items.append(Item(name: extra.name, detail: nil, price: extra.price))
            }
            if items.count > 1 { taxRate = 0.07 * (items.dropFirst().reduce(0) { $0 + $1.price } / max(0.01, items.reduce(0) { $0 + $1.price })) }
        case .laundromat:
            taxRate = 0
            let washer = rng.int(1...24), dryer = rng.int(25...40)
            items = [Item(name: "WASHER #\(washer)", detail: rng.pick(["TOP LOAD", "FRONT LOAD 20LB", "FRONT LOAD 40LB"]), price: rng.pick([3.25, 3.50, 4.75, 6.50])),
                     Item(name: "DRYER #\(dryer)", detail: "\(rng.pick([30, 45, 60])) MIN", price: rng.pick([1.75, 2.25, 3.00]))]
            if text.contains("bleach") || text.contains("detergent") || rng.chance(0.5) { items.append(Item(name: "DETERGENT SNGL", detail: nil, price: 1.75)) }
        case .pawn:
            taxRate = 0
            let what = pawnedItem(text)
            let loan = amounts.max() ?? Double(rng.int(4...60) * 10)
            items = [Item(name: "PAWN LOAN", detail: what, price: loan)]
        case .store:
            for entry in catalog where entry.keys.contains(where: text.contains) {
                items.append(Item(name: entry.name, detail: nil, price: entry.price))
            }
            if items.isEmpty { items.append(Item(name: "MERCHANDISE", detail: nil, price: amounts.max() ?? Double(rng.int(8...60)) + 0.99)) }
            // When the case names the total, the receipt adds up to it.
            if let stated = amounts.max(), items.count > 1 {
                let target = stated / (1 + taxRate)
                let others = items.dropLast().reduce(0) { $0 + $1.price }
                if target - others > 0.5 { items[items.count - 1].price = ((target - others) * 100).rounded() / 100 }
            } else if let stated = amounts.max(), items.count == 1, !text.contains("each") {
                items[0].price = ((stated / (1 + taxRate)) * 100).rounded() / 100
            }
        }

        // How it was paid.
        var tender: String
        var cash: Double?
        let digits = e.detail.range(of: #"ending in (\d{4})"#, options: .regularExpression).map { String(e.detail[$0].suffix(4)) }
        if kind == .pawn {
            tender = "LOAN PAID OUT: CASH"
        } else if text.contains("cash") && digits == nil {
            tender = "CASH"
        } else {
            let brand = text.contains("debit") ? "DEBIT" : rng.pick(["VISA", "MASTERCARD", "DEBIT"])
            tender = "\(brand) ************\(digits ?? String(format: "%04d", rng.int(1...9999)))"
        }
        var receipt = Receipt(kind: kind, store: storeName, address: "", phone: "(252) \(rng.int(200...989))-\(String(format: "%04d", rng.int(0...9999)))",
                              date: date ?? Date(), time: time, storeNumber: rng.int(2...480), register: rng.int(1...6),
                              transaction: rng.int(10_000...99_999), cashier: rng.pick(["Cashier 04", "Cashier 11", "ID 2207", "Op 3", "Self-checkout 2"]),
                              items: items, taxRate: taxRate, tender: tender, cash: nil, pump: pump)
        if tender == "CASH" {
            let owed = receipt.total
            cash = owed <= 20 ? 20 : (owed <= 50 ? 50 : (owed / 20).rounded(.up) * 20)
            receipt.cash = cash
        }
        return receipt
    }

    private static func pawnedItem(_ text: String) -> String {
        for (key, name) in [("ring", "RING 14K YG"), ("necklace", "NECKLACE 10K"), ("chain", "CHAIN 14K"), ("watch", "WRISTWATCH"), ("laptop", "LAPTOP COMPUTER"),
                            ("tablet", "TABLET"), ("guitar", "GUITAR ACOUSTIC"), ("drill", "CORDLESS DRILL"), ("saw", "POWER SAW"), ("tool", "POWER TOOLS ASSTD"),
                            ("rifle", "RIFLE"), ("shotgun", "SHOTGUN"), ("pistol", "HANDGUN"), ("tv", "TELEVISION"), ("television", "TELEVISION"),
                            ("game", "GAME CONSOLE"), ("jewelry", "JEWELRY ASSTD"), ("phone", "CELL PHONE"), ("camera", "CAMERA")] where text.contains(key) {
            return name
        }
        return "MERCHANDISE"
    }

    private static func dollarAmounts(in text: String) -> [Double] {
        guard let regex = try? NSRegularExpression(pattern: #"\$([0-9][0-9,]*(?:\.[0-9]{2})?)"#) else { return [] }
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { m in
            Range(m.range(at: 1), in: text).flatMap { Double(text[$0].replacingOccurrences(of: ",", with: "")) }
        }.filter { $0 > 0 && $0 < 100_000 }
    }
}
