import Foundation

/// An exhibit laid out the way the court would actually review it: footage played back with a running
/// description, a record read page by page, a phone extraction, a call or interview transcript, a lab
/// report, or a property tag with its chain of custody. Built from the exhibit and the case file, so it
/// never says more than the evidence does; it only puts it in a form the judge can examine.
struct ExhibitReview {
    enum Format {
        case video, document, records, messages, transcript, lab, property

        var label: String {
            switch self {
            case .video: return "Recording"
            case .document: return "Document"
            case .records: return "Records extract"
            case .messages: return "Phone extraction"
            case .transcript: return "Transcript"
            case .lab: return "Laboratory report"
            case .property: return "Property and photo log"
            }
        }
    }

    struct Line: Hashable, Identifiable {
        var id = UUID()
        /// A time code, a clock time, or an entry number.
        var stamp: String
        /// Who is speaking or sending, when there is one.
        var speaker: String?
        var text: String
        /// For messages: sent by the defendant.
        var fromDefendant = false
    }

    var format: Format
    /// Labeled particulars at the top: source, date, custodian, and so on.
    var particulars: [(label: String, value: String)]
    var lines: [Line]
    /// What the court should weigh about this kind of exhibit: foundation, limits, and how it came in.
    var considerations: [String]
}

enum Exhibits {

    static func review(_ e: Evidence, in c: CourtCase) -> ExhibitReview {
        let bytes = withUnsafeBytes(of: e.id.uuid) { Array($0) }
        var rng = SeededRNG(seed: (bytes.prefix(8).reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }) | 1)
        let facts = c.investigation?.facts
        let title = e.title.lowercased()
        let quotes = quoted(e.detail)

        let format: ExhibitReview.Format
        switch e.kind {
        case .video: format = .video
        case .forensic: format = .lab
        case .physical: format = .property
        case .statement: format = .transcript
        case .digital:
            format = (quotes.isEmpty || mentionsAny(title, ["record", "data", "log", "history", "gps", "location", "account", "payment", "search"]))
                && !mentionsAny(title, ["message", "text", "chat", "dm", "post"]) ? .records : .messages
        case .document:
            format = mentionsAny(title, ["log", "record", "statement", "ledger", "receipt", "report"]) && !quotes.isEmpty ? .records : .document
        }

        var particulars: [(label: String, value: String)] = [("Exhibit", e.exhibit), ("Offered by", e.side == .prosecution ? "The State" : "The defense")]
        if let supplemental = e.supplemental { particulars.append(("Obtained", supplemental)) }
        let date = facts.map { CaseDates.dayYear($0.incident) } ?? "Date in the case file"
        let collector = e.side == .prosecution ? (facts.map { "\($0.lead), \($0.agency)" } ?? c.investigatingAgency) : "Defense counsel"

        var lines: [ExhibitReview.Line] = []
        var considerations: [String] = []

        switch format {
        case .video:
            let handheld = mentionsAny(title, ["phone", "cell", "bystander", "neighbor", "facebook", "live"])
            let bodyCam = mentionsAny(title, ["body", "dash", "cruiser", "patrol"])
            let device = bodyCam ? "Police body-worn or in-car camera, with audio"
                : (handheld ? "Handheld phone video, with audio" : "Fixed security camera, no audio")
            let start = clockMinutes(facts?.time) ?? rng.int(0...1_439)
            let begin = max(0, start - rng.int(1...6))
            particulars += [("Source", e.title), ("Device", device), ("Recorded", date),
                            ("Time stamp on screen", clock(begin)), ("Produced by", collector)]
            var elapsed = rng.int(4...20)
            lines.append(.init(stamp: timecode(0), text: "Recording begins. " + (handheld ? "The picture moves with the person holding the phone." : "A fixed view; the time stamp runs in the corner.")))
            for sentence in sentences(e.detail) {
                lines.append(.init(stamp: timecode(elapsed) + " · " + clock(begin + elapsed / 60), text: sentence))
                elapsed += rng.int(6...75)
            }
            lines.append(.init(stamp: timecode(elapsed), text: "Recording ends."))
            considerations = [
                "Foundation: someone with knowledge must testify that the recording fairly and accurately shows what it depicts, or that the system was working properly (G.S. 8-97).",
                handheld ? "A handheld video shows only what its holder pointed at, and only from when recording started."
                    : "A fixed camera shows only its field of view. Ask what happened just outside the frame.",
                bodyCam ? "Body and dash camera audio can capture statements; check whether any were made in custody without warnings."
                    : "Check whether the on-screen time stamp was compared with the actual time; system clocks drift.",
                "Identification from video depends on distance, lighting, and resolution. Weigh it against the other evidence of identity."
            ]
        case .document, .records:
            let custodian = e.side == .prosecution ? (mentionsAny(title, ["bank", "account", "financial", "payment"]) ? "Records custodian of the bank" : collector) : "Produced by the defense"
            particulars += [("Record", e.title), ("Custodian", custodian), ("Covers", date)]
            if format == .records {
                for (i, q) in quotes.enumerated() {
                    lines.append(.init(stamp: "Entry \(i + 1)", text: q))
                }
                for sentence in sentences(stripQuotes(e.detail)) where !sentence.isEmpty {
                    lines.append(.init(stamp: "Note", text: sentence))
                }
            } else {
                for (i, sentence) in sentences(e.detail).enumerated() {
                    lines.append(.init(stamp: "\(i + 1).", text: sentence))
                }
            }
            considerations = [
                "Business and public records come in through a custodian or a certification (Rules 803(6) and 803(8)); the person who made the entries need not testify.",
                "A record shows what was written down, not necessarily that it is true. Ask who made the entry, and when.",
                "Look for what the record does not show as much as what it does."
            ]
        case .messages:
            let defendantLast = c.defendant.lastName
            let otherParty = c.victimName ?? "Other party"
            particulars += [("Extraction", e.title), ("Tool", "Cellebrite extraction report"), ("Device", "Phone seized under a search warrant"),
                            ("Examiner", collector)]
            let base = clockMinutes(facts?.time) ?? rng.int(480...1_380)
            var minute = max(0, base - rng.int(30...240))
            for q in quotes {
                let before = context(before: q, in: e.detail).lowercased()
                let mine = before.contains(defendantLast.lowercased()) || before.contains(c.defendant.name.lowercased())
                lines.append(.init(stamp: clock(minute), speaker: mine ? c.defendant.name : otherParty, text: q, fromDefendant: mine))
                minute += rng.int(1...45)
            }
            let rest = sentences(stripQuotes(e.detail)).filter { !$0.isEmpty }
            if !rest.isEmpty { lines.append(.init(stamp: "Examiner's note", text: rest.joined(separator: " "))) }
            considerations = [
                "Authorship is the question with messages: an account or phone being someone's doesn't prove they typed every message. Look for content only that person would know.",
                "A defendant's own messages are admissions (Rule 801(d)); the other side of the conversation usually comes in only for context.",
                "Extraction reports can miss deleted messages or show times in a different time zone."
            ]
        case .transcript:
            let call = mentionsAny(title, ["911", "call", "dispatch", "voicemail", "jail"])
            let interview = mentionsAny(title, ["interview", "statement", "confession", "admission", "told"])
            particulars += [("Recording", e.title), ("Type", call ? "Recorded call" : (interview ? "Recorded interview" : "Recorded statement")),
                            ("Date", date)]
            if e.side == .prosecution && interview, let day = facts?.interview { particulars.append(("Interview date", CaseDates.dayYear(day))) }
            var second = 0
            let labeled = speakerLines(e.detail)
            if !labeled.isEmpty {
                for (speaker, text) in labeled {
                    lines.append(.init(stamp: timecode(second), speaker: speaker, text: text))
                    second += rng.int(4...40)
                }
            } else if !quotes.isEmpty {
                let speaker = call ? "Caller" : c.defendant.name
                for q in quotes {
                    lines.append(.init(stamp: timecode(second), speaker: speaker, text: q))
                    second += rng.int(4...40)
                }
            }
            let rest = sentences(stripQuotes(e.detail)).filter { !$0.isEmpty }
            if !rest.isEmpty { lines.append(.init(stamp: "Summary", text: rest.joined(separator: " "))) }
            if lines.isEmpty { lines = sentences(e.detail).map { .init(stamp: "", text: $0) } }
            considerations = call ? [
                "A 911 call made to get help with an ongoing emergency is usually not testimonial, so it can come in without the caller testifying (Davis v. Washington).",
                "Excited utterances and present sense impressions are hearsay exceptions (Rule 803(1)–(2)); listen for whether the speaker was still under the stress of the event."
            ] : [
                "A defendant's custodial statement is admissible only if Miranda warnings were given and waived and the statement was voluntary.",
                "Listen to the whole statement, not just the excerpt. Context can change what an answer means (Rule 106).",
                "Admissions are evidence, but the State still needs other evidence that the crime happened (corpus delicti)."
            ]
        case .lab:
            let analyst = "Forensic scientist \(rng.pick(NameBank.firstNames)) \(rng.pick(NameBank.lastNames))"
            let method: String
            switch true {
            case mentionsAny(title + " " + e.detail.lowercased(), ["dna", "swab", "profile"]): method = "DNA extraction, quantitation, and STR typing"
            case mentionsAny(title, ["blood alcohol", "bac", "blood test"]): method = "Headspace gas chromatography for ethanol"
            case mentionsAny(title, ["tox", "drug screen"]): method = "Toxicology screen with confirmation by LC-MS/MS"
            case mentionsAny(title, ["print", "latent"]): method = "Latent print comparison (ACE-V method), with verification"
            case mentionsAny(title + " " + e.detail.lowercased(), ["casing", "cartridge", "bullet", "firearm", "round", "ballistic"]): method = "Firearm and toolmark comparison microscopy"
            case mentionsAny(title + " " + e.detail.lowercased(), ["cocaine", "heroin", "fentanyl", "methamphetamine", "substance", "powder", "pills"]): method = "Chemical analysis by GC-MS; net weight determined"
            case mentionsAny(title, ["autopsy", "medical examiner", "cause of death"]): method = "Autopsy by the Office of the Chief Medical Examiner"
            default: method = "Examination and analysis"
            }
            particulars += [("Laboratory", method.contains("Medical Examiner") ? "Office of the Chief Medical Examiner" : "North Carolina State Crime Laboratory"),
                            ("Lab number", "\(CourtCalendar.calendar.component(.year, from: facts?.incident ?? c.sessionDate))-\(rng.int(10_000...99_999))"),
                            ("Item", e.title), ("Method", method), ("Analyst", analyst)]
            if let submitted = facts?.labSubmitted { particulars.append(("Submitted", CaseDates.dayYear(submitted))) }
            if let returned = facts?.labReturned { particulars.append(("Reported", CaseDates.dayYear(returned))) }
            for (i, sentence) in sentences(e.detail).enumerated() {
                lines.append(.init(stamp: "Result \(i + 1)", text: sentence))
            }
            considerations = [
                "A lab report is testimonial: the analyst who did the work must testify unless the defense waived it (Melendez-Diaz; Smith v. Arizona; G.S. 90-95(g)).",
                "Check the chain of custody from collection to the lab; a gap goes to weight, a broken chain can keep the item out.",
                "Ask what the result actually establishes. A DNA match shows contact, not when or how; a drug weight is net of packaging only if the report says so."
            ]
        case .property:
            let place = facts.map { "\($0.place), \($0.street), \($0.town)" } ?? "the scene"
            particulars += [("Item", e.title), ("Recovered", "\(place), \(date)"), ("Collected by", collector),
                            ("Property tag", "PR-\(rng.int(100_000...999_999))")]
            for (i, sentence) in sentences(e.detail).enumerated() {
                lines.append(.init(stamp: "Photo \(i + 1)", text: sentence))
            }
            var custody = ["Photographed in place, then collected and sealed in an evidence bag.",
                           "Logged into the \(facts?.agency ?? c.investigatingAgency) property room."]
            if let submitted = facts?.labSubmitted { custody.append("Released to the State Crime Laboratory on \(CaseDates.day(submitted)).") }
            custody.append("Brought to court sealed; seal intact.")
            for (i, step) in custody.enumerated() { lines.append(.init(stamp: "Custody \(i + 1)", text: step)) }
            considerations = [
                "Real evidence needs a showing that it is what it is claimed to be and is in substantially the same condition (chain of custody).",
                "An item proves only what it is linked to. Ask what connects it to the defendant: where it was found, who had access, prints or DNA."
            ]
        }
        if e.side == .defense {
            considerations.append("The defense has no burden. Defense evidence only has to raise a reasonable doubt; it doesn't have to prove anything.")
        }
        return ExhibitReview(format: format, particulars: particulars, lines: lines, considerations: considerations)
    }

    // MARK: Text helpers

    private static func mentionsAny(_ text: String, _ words: [String]) -> Bool {
        words.contains { text.contains($0) }
    }

    /// The text split into sentences, keeping quotations whole.
    static func sentences(_ text: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuote = false
        let chars = Array(text)
        for (i, ch) in chars.enumerated() {
            current.append(ch)
            if ch == "\"" || ch == "\u{201C}" || ch == "\u{201D}" { inQuote.toggle() }
            let next = i + 1 < chars.count ? chars[i + 1] : " "
            if !inQuote && (ch == "." || ch == "!" || ch == "?") && next == " " {
                let trimmed = current.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { result.append(trimmed) }
                current = ""
            }
        }
        let trimmed = current.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { result.append(trimmed) }
        return result
    }

    /// Text inside double quotation marks.
    static func quoted(_ text: String) -> [String] {
        var result: [String] = []
        var current: String?
        for ch in text {
            if ch == "\"" || ch == "\u{201C}" || ch == "\u{201D}" {
                if let inside = current {
                    let q = inside.trimmingCharacters(in: .whitespaces)
                    if q.count > 1 { result.append(q) }
                    current = nil
                } else {
                    current = ""
                }
            } else if current != nil {
                current?.append(ch)
            }
        }
        return result
    }

    private static func stripQuotes(_ text: String) -> String {
        var out = ""
        var inQuote = false
        for ch in text {
            if ch == "\"" || ch == "\u{201C}" || ch == "\u{201D}" { inQuote.toggle(); continue }
            if !inQuote { out.append(ch) }
        }
        // Tidy the leftovers of removed quotations: "said ," and empty colons.
        return out.replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: ": .", with: ".")
            .replacingOccurrences(of: ":  ", with: ": ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: ". ")
            .filter { $0.trimmingCharacters(in: .whitespaces).count > 12 }
            .joined(separator: ". ")
    }

    /// The forty characters before a quotation, to tell who said it.
    private static func context(before quote: String, in text: String) -> String {
        guard let range = text.range(of: quote) else { return "" }
        let start = text.index(range.lowerBound, offsetBy: -min(48, text.distance(from: text.startIndex, to: range.lowerBound)))
        return String(text[start..<range.lowerBound])
    }

    /// "Dispatcher: "Are you following him?"" pairs.
    private static func speakerLines(_ text: String) -> [(String, String)] {
        let pattern = #"([A-Z][A-Za-z.' -]{1,28}):\s*["“]([^"”]+)["”]"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = text as NSString
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map {
            (ns.substring(with: $0.range(at: 1)).trimmingCharacters(in: .whitespaces), ns.substring(with: $0.range(at: 2)))
        }
    }

    /// Minutes after midnight from "11:42 p.m." style times.
    static func clockMinutes(_ time: String?) -> Int? {
        guard let time else { return nil }
        let lower = time.lowercased()
        let digits = lower.components(separatedBy: CharacterSet(charactersIn: "0123456789:").inverted).joined()
        let parts = digits.split(separator: ":").compactMap { Int($0) }
        guard let hour = parts.first, hour <= 12 else { return nil }
        let minute = parts.count > 1 ? parts[1] : 0
        let pm = lower.contains("p.m") || lower.contains("pm")
        let am = lower.contains("a.m") || lower.contains("am")
        var h = hour % 12
        if pm { h += 12 } else if !am && hour < 7 { h += 12 }
        return h * 60 + minute
    }

    private static func clock(_ minutes: Int) -> String {
        let m = ((minutes % 1_440) + 1_440) % 1_440
        let h = m / 60, mm = m % 60
        let hour12 = h % 12 == 0 ? 12 : h % 12
        return String(format: "%d:%02d %@", hour12, mm, h < 12 ? "a.m." : "p.m.")
    }

    private static func timecode(_ seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds / 3_600, (seconds / 60) % 60, seconds % 60)
    }
}
