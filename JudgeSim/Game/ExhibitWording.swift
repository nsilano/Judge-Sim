import Foundation

/// How an exhibit's name reads in the middle of a sentence: "the gas receipt", "Smith's apron", "the 911 call".
/// Titles are written in title case; ordinary words are lowercased, and names, places and acronyms keep their capitals.
enum ExhibitWording {

    /// The everyday words exhibit titles are made of. A word not on this list is a name or a place and keeps its capital.
    static let commonWords: Set<String> = [
        "'employer", "'ray", "911", "a", "abandoned", "about", "abuse", "accelerant", "accelerator", "access",
        "accomplice", "account", "accountant", "accounting", "accounts", "across", "activity", "ad", "addiction", "address",
        "admin", "admission", "adoption", "adult", "advanced", "advice", "affair", "affidavit", "after", "again",
        "age", "agency", "agreement", "aid", "airport", "alarm", "alcohol", "alert", "alibi", "alley",
        "altered", "alternative", "ambulance", "ammunition", "an", "analysis", "and", "angle", "ant", "apartment",
        "apology", "app", "application", "applications", "approach", "approached", "arrest", "arresting", "arrivals", "arsenic",
        "as", "as-is", "assault", "assistant", "assistants", "assurances", "at", "attempt", "attempted", "attempts",
        "attendance", "attorney", "auction", "audio", "audit", "authority", "autopsy", "back", "back-calculation", "background",
        "backup", "badge", "bag", "baggies", "ballistics", "banded", "bank", "bankruptcy", "bar", "barbecue",
        "barn", "barrier", "bartender", "basement", "basis", "battered", "battery", "bedroom", "before", "behavior",
        "behind", "belongings", "between", "bike", "bill", "bills", "biomechanical", "black", "blank", "blood",
        "bloody", "blue", "board", "boat", "body", "body-camera", "bodycam", "bolt", "booking", "bookkeeping",
        "booster", "boot", "boots", "borrowed", "bottle", "bouncer", "box", "boy", "brake", "breach",
        "break", "break-in", "break-ins", "breakup", "breath", "bridge", "broken", "bruise", "brush", "bug",
        "building", "bulk", "bullet", "bumper", "burner", "bus", "business", "buy-sell", "buys", "by",
        "bystander", "cab", "cabinet", "cadaver", "call", "calls", "camera", "cameras", "can", "cap",
        "car", "carbon", "card", "cardiac", "caregiver", "caregiving", "carrier", "carry", "carton", "cash",
        "casing", "casings", "casino", "castle", "category", "cause", "cell", "cell-site", "certificate", "chance",
        "change", "changing", "character", "charged", "charges", "chart", "charting", "chat", "check-cashing", "chief",
        "child", "child-lock", "childhood", "chips", "chronic", "citizen", "claim", "claims", "clean", "clerk",
        "client", "clip", "clock", "closed", "closing", "clothes", "clothing", "cloud", "co-defendant", "co-signatures",
        "co-worker", "coach", "code", "codes", "coerced", "collapse", "collar", "collector", "commendations", "commissions",
        "common", "commute", "comparison", "compensation", "complaint", "complaints", "completed", "compliance", "computer", "concealed",
        "concerns", "condition", "confession", "confessions", "configuration", "confinement", "confusing", "confusion", "congregation", "consent",
        "construction", "consultation", "contact", "contents", "context", "contract", "contractor", "contracts", "contribution", "controlled",
        "conversion", "converters", "conviction", "convictions", "cook", "cooperation", "coordinator", "copper", "cord", "corporate",
        "cost", "costs", "council", "count", "counter", "course", "cousin", "coverage", "coworker", "crash",
        "creation", "credentials", "credit", "crew", "crime", "crimes", "critique", "crowd", "crypto", "cue",
        "curfew", "custody", "customer", "cutter", "cutters", "damage", "damaged", "dash", "dashcam", "data",
        "database", "date", "dates", "dating", "day", "days", "deal", "death", "debris", "debt",
        "debts", "deck", "declines", "deed", "deer", "defendant", "defense", "deficiency", "degraded", "delay",
        "deleted", "deletion", "delivered", "demand", "demos", "denial", "department", "deposit", "deposits", "deputies",
        "deputy", "description", "detective", "detectives", "detectors", "detention", "developer", "device", "diagram", "didn't",
        "different", "digital", "director", "disaster", "disclosures", "discrepancy", "disorder", "dispensing", "dispute", "disputes",
        "disruption", "distance", "disturbance", "diversion", "dock", "doctrine", "document", "dog", "domestic", "donations",
        "done", "door", "doorbell", "doormat", "doubts", "dozens", "drinking", "drive", "driver", "drug",
        "drugs", "dual", "duffel", "during", "dye-stained", "earlier", "early", "earring", "eggs", "electrical",
        "electronic", "email", "emails", "employee", "employer", "encounters", "endorsements", "engine", "engineer", "engraved",
        "enrollment", "environmental", "equipment", "error", "estimate", "evaluation", "event", "eviction", "evidence", "ex-boyfriend",
        "exam", "examination", "examiner", "exams", "exhumation", "exit", "experience", "expert", "expired", "explicit",
        "exposure", "extension", "extrapolation", "eyewitness", "eyewitnesses", "fabricated", "facial", "failures", "fake", "falsified",
        "family", "farmhand", "feed", "felony", "fentanyl", "filings", "final", "finances", "financial", "findings",
        "fingerprint", "fingerprints", "fire", "firearm", "fired", "first", "flea", "flight", "flipped", "floor",
        "folding", "footage", "for", "foreclosure", "forensic", "forged", "form", "former", "forms", "forum",
        "found", "four", "fourteen-hour", "frailty", "frames", "free", "freeze", "friend", "friendship", "from",
        "fuel", "fund", "fundraiser", "gambling", "gap", "gaps", "gas", "gasoline", "gate", "genealogy",
        "generator", "gifts", "glass", "glove", "gloves", "grandson", "gray", "green", "greenway", "grief",
        "grievances", "grocery", "ground-off", "group", "grudge", "grudges", "guard", "gun", "gunshot", "gym",
        "habit", "hair", "hallway", "hand", "handgun", "handle", "handler", "handoff", "handwriting", "handwritten",
        "hardware", "health", "heart", "heater", "height", "help", "helped", "helper", "her", "hidden",
        "him", "his", "history", "hold", "holders", "holster", "home", "honking", "hoodie", "hoodies",
        "hospital", "host", "hotel", "hours", "house", "houseguest", "housing", "hunting", "identical", "identification",
        "identity", "ignition", "images", "immediate", "impression", "in", "incidents", "increase", "increased", "independent",
        "informant", "initials", "injuries", "injury", "inspection", "inspections", "inspector", "insulin", "insurance", "intake",
        "intent", "interchange", "interior", "internal", "interrogation", "intersection", "interview", "into", "intoxication", "intoximeter",
        "inventory", "investigation", "investigator", "investigators", "investments", "investor", "investors", "invitation", "invoice", "invoices",
        "iron", "island", "items", "its", "jacket", "jail", "jewelry", "job", "jobs", "joint",
        "judgment", "judgments", "kayak", "kennel", "key", "keypad", "kitchen", "knew", "knife", "know",
        "known", "lab", "laboratory", "land", "landscaping", "language", "lanyard", "laptop", "latent", "laundromat",
        "lavish", "lawn", "lawyer", "layoff", "layouts", "league", "lease", "ledger", "length", "lent",
        "letter", "letters", "level", "levels", "license", "lies", "life", "light", "lighting", "lights",
        "limits", "line", "lineup", "liquidation", "list", "listing", "listings", "live", "livestream", "loaded",
        "loan", "lobby", "location", "lock", "lockbox", "locker", "log", "logging", "login", "logs",
        "long", "loss", "losses", "lot", "lunch", "mail", "maintenance", "manager", "manufacturer", "map",
        "marked", "market", "marketplace", "marshal", "match", "matching", "media", "medical", "medication", "meeting",
        "members", "memory", "mental", "message", "messages", "military", "minutes", "mirror", "missing", "mix",
        "mixed", "model", "module", "money", "monoxide", "motel", "mother", "motive", "motorcycle", "moved",
        "moving", "mower", "muffler", "mule", "my", "nap", "naturopathy", "nearby", "need", "neighbor",
        "neighborhood", "nephew", "network", "neurologist", "neuroradiologist", "never", "new", "news", "niece", "night",
        "nights", "nightstand", "nineteen", "no", "non-emergency", "non-prosecution", "not", "note", "notes", "notice",
        "number", "nurse", "observations", "occupants", "of", "off-duty", "offer", "office", "officer", "officers",
        "on", "one", "online", "open", "or", "order", "original", "other", "others", "our",
        "out", "outage", "outside", "over", "overdoses", "override", "overtime", "own", "owner", "owners",
        "ownership", "pad", "paddle", "paid", "pain", "palm", "panel", "panic", "papers", "parade",
        "parent", "parents", "parking", "partial", "partner", "party", "pass", "passenger", "password", "pastor",
        "pathologist", "patient", "patients", "patron", "pattern", "patterns", "pawn", "pay", "paycheck", "payment",
        "payments", "payoff", "payouts", "pedestrian", "pediatrician", "pension", "people", "period", "permit", "person",
        "personal", "pharmacy", "phishing", "phone", "phones", "photo", "photographs", "photos", "physical", "pickup",
        "pill", "pills", "pistol", "plan", "planning", "plate", "plea", "plug", "pod", "point-of-sale",
        "poison", "pole", "police", "policy", "pool", "population", "position", "post", "post-arrest", "posted",
        "posts", "pour", "power", "practice", "pre-paid", "pre-recorded", "prescription", "present", "press", "pressure",
        "prevention", "price", "prices", "print", "prints", "prior", "prize", "profit", "promise", "prompt",
        "property", "protective", "pry", "psychological", "psychologist", "purchase", "purchases", "purse", "pursuit", "quality",
        "quit", "rates", "ratios", "reach", "reaching", "reaction", "readouts", "real", "recantation", "recanted",
        "receipt", "receipts", "reciprocating", "recognition", "reconstruction", "record", "recorded", "recorder", "recording", "recordings",
        "records", "recovered", "recovery", "recruited", "red", "referee", "reflectors", "refund", "registered", "registration",
        "relationship", "relatives", "remains", "remorse", "rendered", "rent", "rental", "rented", "repair", "repayment",
        "repayments", "replacement", "report", "reported", "reports", "request", "requests", "required", "resales", "rescue",
        "research", "residents", "residue", "resignation", "resistance", "resource", "responders", "response", "restaurant", "restraining",
        "result", "results", "retrograde", "return", "returns", "revoked", "ride", "rideshare", "rifle", "rising",
        "road", "roadside", "robbery", "role", "rollback", "roof", "roofing", "room", "roommate", "round",
        "rounds", "route", "routine", "rules", "running", "safety", "sale", "sales", "saline", "salvage",
        "same", "sample", "satisfied", "saw", "scale", "scanner", "scene", "schedule", "school", "science",
        "scope", "score", "scores", "scrap", "scratches", "screens", "seal", "search", "searches", "seat",
        "second", "secret", "securities", "security", "seized", "seizure", "self", "seller", "separate", "serial",
        "server", "services", "setting", "settings", "settlement", "sexual", "sexually", "shared", "sharing", "sheath",
        "sheathed", "sheet", "sheets", "shell", "shift", "shirt", "shoe", "shoebox", "shoes", "shooter",
        "shooting", "shop", "shortage", "shotgun", "shots", "shoved", "shovel", "show-up", "side", "sightings",
        "sign", "signed", "signs", "similar", "site", "situation", "size", "skillet", "slashed", "sledgehammer",
        "smudges", "social", "solitary", "some", "son", "sophisticated", "source", "sources", "space", "spare",
        "spark", "spatter", "specifications", "spectator", "speech", "speeches", "speed", "spelling", "spending", "spouse",
        "staff", "staffing", "stale", "state", "statement", "statements", "station", "stay-away", "sticky", "stock",
        "stolen", "stolen-car", "stop", "storage", "store", "stories", "story", "street", "stress", "strikes",
        "struggle", "stub", "stubs", "stuck", "studies", "style", "subcontractor", "subscriber", "substation", "suggestive",
        "suicide", "summaries", "supervisor", "supplier", "supply", "surgeon", "surgical", "surrender", "surveillance", "survey",
        "surviving", "suspects", "swatting", "sweatshirt", "swerve", "syndrome", "syringe", "system", "tab", "tank",
        "tape", "teens", "termination", "test", "testimony", "testing", "tests", "text", "texts", "thank-you",
        "that", "the", "their", "them", "theory", "therapist", "thermos", "these", "thieves", "this",
        "those", "threat", "threatening", "threats", "three", "through", "thumbprint", "ticket", "ties", "time",
        "timeline", "timing", "tip", "tire", "to", "took", "tool", "toolmark", "tools", "torn",
        "touch", "touched", "tower", "towing", "toxicology", "trace", "tracker", "traffic", "trail", "trainer",
        "training", "trajectory", "transaction", "transcript", "treasurer", "treatment", "tree", "trespass", "trial", "tried",
        "trips", "trooper", "truck", "turned", "twelve", "twelve-hour", "twenty", "twine", "two", "umpire",
        "uncle", "under", "undercover", "understaffing", "unknown", "unlicensed", "unlocked", "unopened", "unpaid", "unpermitted",
        "unsigned", "unspent", "unused", "upgrade", "urging", "use", "use-of-force", "uses", "utilities", "van",
        "vandalism", "vault", "vehicle", "vehicles", "vet", "veterans", "veterinary", "vial", "victim", "victims",
        "video", "videos", "violation", "violations", "violent", "viral", "visibility", "visit", "visitor", "vitamin",
        "voicemail", "voided", "volume", "voluntary", "volunteer", "volunteers", "vote", "waistband", "wallet", "warehouse",
        "warning", "warnings", "warrant", "washed", "weapon", "weapons", "weather", "weeks", "wet", "widely",
        "window", "windshield", "wiretap", "with", "withdrawal", "witness", "witnesses", "work", "worker", "workplace",
        "wound", "write-ups", "writing", "yard", "years", "your", "zip"
    ]

    /// People's names, which stay capitalized even when they double as ordinary words ("Green's phone").
    private static let names = Set(NameBank.firstNames + NameBank.lastNames).union(NameBank.femaleFirstNames)

    private static func isCommon(_ word: String) -> Bool {
        let bare = word.trimmingCharacters(in: CharacterSet(charactersIn: "(),:.\"")).lowercased()
        let possessive = bare.hasSuffix("'s") || bare.hasSuffix("'")
        let base = bare.hasSuffix("'s") ? String(bare.dropLast(2)) : (bare.hasSuffix("'") ? String(bare.dropLast()) : bare)
        if possessive && names.contains(base.prefix(1).uppercased() + base.dropFirst()) { return false }
        return commonWords.contains(base)
    }

    /// One word as it reads mid-sentence.
    private static func lowerWord(_ word: String) -> String {
        // Acronyms, numbers and names stay as written.
        if word.contains(where: \.isNumber) { return word }
        let letters = word.filter(\.isLetter)
        if letters.count >= 2 && letters == letters.uppercased() { return word }
        return isCommon(word) ? word.lowercased() : word
    }

    /// The title in sentence case, without an article: "gas receipt", "pills from Smith".
    static func lower(_ title: String) -> String {
        title.split(separator: " ", omittingEmptySubsequences: true).map { lowerWord(String($0)) }.joined(separator: " ")
    }

    /// The title as a noun phrase: "the gas receipt". A title that already starts with an article, or with a person's
    /// name in the possessive ("Smith's apron"), takes no "the".
    static func phrase(_ title: String) -> String {
        let lowered = lower(title)
        guard let first = lowered.split(separator: " ").first.map(String.init) else { return lowered }
        if ["a", "an", "the", "his", "her", "their", "its"].contains(first) { return lowered }
        if (first.hasSuffix("'s") || first.hasSuffix("s'")) && !isCommon(first) { return lowered }
        return "the " + lowered
    }
}

extension Evidence {
    /// The exhibit as it reads mid-sentence: "the gas receipt", "Smith's apron".
    var phrase: String { ExhibitWording.phrase(title) }
}
