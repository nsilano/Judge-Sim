import SwiftUI

/// The exhibit as the thing it really is: a bank statement on the bank's letterhead, a thermal receipt, a note
/// written by hand, a hospital chart, a carrier's call records, a map of GPS points, an evidence tag, a photo log,
/// an email, a social media post, a 911 dispatch record, a jail call, or a typed interview transcript.
/// Paper always uses its own paper colors, so it reads the same in light and dark mode.
enum ExhibitPalette {
    static let paper = Color(red: 0.99, green: 0.98, blue: 0.95)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let faint = Color(red: 0.45, green: 0.45, blue: 0.48)
    static let rule = Color(red: 0.80, green: 0.80, blue: 0.82)
    static let legalPad = Color(red: 0.99, green: 0.96, blue: 0.70)
    static let legalLine = Color(red: 0.55, green: 0.70, blue: 0.90)
    static let margin = Color(red: 0.90, green: 0.45, blue: 0.45)
    static let thermal = Color(red: 0.97, green: 0.97, blue: 0.96)
    static let manila = Color(red: 0.89, green: 0.80, blue: 0.60)
    static let bank = Color(red: 0.07, green: 0.27, blue: 0.47)
    static let medical = Color(red: 0.0, green: 0.45, blue: 0.50)
    static let lab = Color(red: 0.20, green: 0.25, blue: 0.40)
    static let carrier = Color(red: 0.45, green: 0.15, blue: 0.55)
    static let business = Color(red: 0.25, green: 0.30, blue: 0.30)
    static let social = Color(red: 0.23, green: 0.35, blue: 0.80)
}

/// Shared paper sheet with a slight shadow.
private struct Sheet<Content: View>: View {
    var color: Color = ExhibitPalette.paper
    var corner: CGFloat = 3
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: content)
            .foregroundStyle(ExhibitPalette.ink)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: corner).fill(color))
            .overlay(RoundedRectangle(cornerRadius: corner).strokeBorder(ExhibitPalette.rule, lineWidth: 0.5))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

/// A colored letterhead band with the organization's name.
private struct Letterhead: View {
    let name: String
    let detail: String
    let color: Color
    let icon: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(color.opacity(0.85)))
            VStack(alignment: .leading, spacing: 1) {
                Text(name).font(.system(.headline, design: .default).weight(.heavy)).foregroundStyle(color)
                Text(detail).font(.caption2).foregroundStyle(ExhibitPalette.faint)
            }
            Spacer()
            if let trailing {
                Text(trailing.uppercased()).font(.caption.weight(.bold)).tracking(1).foregroundStyle(color)
            }
        }
        .padding(.bottom, 6)
        .overlay(alignment: .bottom) { Rectangle().fill(color).frame(height: 2) }
    }
}

/// "Exhibit 4" sticker, the way an exhibit is marked in court.
private struct ExhibitSticker: View {
    let label: String
    var body: some View {
        Text(label.replacingOccurrences(of: "State's ", with: "STATE ").replacingOccurrences(of: "Defendant's ", with: "DEF. ").uppercased())
            .font(.system(size: 9, weight: .heavy)).tracking(0.5)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color.yellow.opacity(0.9)))
            .foregroundStyle(.black)
            .rotationEffect(.degrees(-4))
    }
}

/// The first dollar figure in a line, for ledgers and receipts.
private func amount(in text: String) -> String? {
    guard let range = text.range(of: "\\$[0-9][0-9,]*(\\.[0-9]{2})?", options: .regularExpression) else { return nil }
    return String(text[range])
}

private func particularValue(_ r: ExhibitReview, _ label: String) -> String? {
    r.particulars.first { $0.label == label }?.value
}

// MARK: - Handwritten

struct HandwrittenNoteView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        let quotes = Exhibits.quoted(evidence.detail)
        let words = quotes.isEmpty ? review.lines.map(\.text) : quotes
        let context = Exhibits.sentences(evidence.detail).filter { s in !quotes.contains { s.contains($0) } }
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                // Ruled paper with a red margin line.
                Canvas { ctx, size in
                    var y: CGFloat = 34
                    while y < size.height {
                        ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) },
                                   with: .color(ExhibitPalette.legalLine.opacity(0.6)), lineWidth: 0.7)
                        y += 28
                    }
                    ctx.stroke(Path { p in p.move(to: CGPoint(x: 34, y: 0)); p.addLine(to: CGPoint(x: 34, y: size.height)) },
                               with: .color(ExhibitPalette.margin.opacity(0.7)), lineWidth: 1)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(words.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.custom("Noteworthy-Bold", size: 20))
                            .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.45))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.leading, 44).padding(.trailing, 14).padding(.top, 14).padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
            .background(ExhibitPalette.legalPad)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
            .rotationEffect(.degrees(-1.2))
            .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).padding(8) }
            .padding(.vertical, 6)

            if !context.isEmpty {
                EvidenceLabel(lines: context)
            }
        }
    }
}

/// The small typed label investigators attach: where it came from and what it is.
private struct EvidenceLabel: View {
    let lines: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("EVIDENCE NOTE").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(ExhibitPalette.faint)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line).font(.system(.caption, design: .monospaced)).fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(ExhibitPalette.ink)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 2).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(ExhibitPalette.rule))
    }
}

// MARK: - Bank statement

/// A dollar figure as a number, for running balances.
private func dollars(_ text: String?) -> Double? {
    guard let text else { return nil }
    return Double(text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))
}

private func money(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
}

/// A Bates number stamped on every page produced in discovery.
private struct BatesStamp: View {
    let prefix: String
    let seed: Int
    var body: some View {
        Text("\(prefix)-\(String(format: "%06d", seed % 900_000 + 1_000))")
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .foregroundStyle(ExhibitPalette.faint)
    }
}

/// A bank statement the way banks print them: period, account summary, and a running ledger.
struct BankStatementView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    private struct Row: Identifiable {
        let id: Int
        let date: String
        let description: String
        let memo: String
        let debit: Double?
        let credit: Double?
        let balance: Double
    }

    private var seed: Int { "\(evidence.id)".stableHash }

    private var rows: [Row] {
        var balance = Double(1_800 + seed % 9_000) + Double(seed % 100) / 100
        var out: [Row] = []
        for (i, line) in review.lines.enumerated() {
            let lower = line.text.lowercased()
            let value = dollars(amount(in: line.text))
            let incoming = ["deposit", "credit", "received", "transfer from", "paid to the account", "payroll", "refund"].contains { lower.contains($0) }
            var description: String
            if lower.contains("check") { description = "CHECK #\(1_000 + (seed / 7 + i * 3) % 900)" }
            else if lower.contains("atm") { description = "ATM WITHDRAWAL \(["#4471 MAIN ST", "#2208 HARBOR", "#0915 HWY 17"][i % 3])" }
            else if lower.contains("wire") { description = incoming ? "INCOMING WIRE TRANSFER" : "OUTGOING WIRE TRANSFER" }
            else if lower.contains("transfer") { description = incoming ? "ONLINE TRANSFER FROM CHK" : "ONLINE TRANSFER TO XXXXXX\(String(format: "%04d", (seed + i * 97) % 10_000))" }
            else if lower.contains("cash") { description = incoming ? "COUNTER DEPOSIT - CASH" : "COUNTER WITHDRAWAL - CASH" }
            else if incoming { description = "DEPOSIT" }
            else { description = "POS PURCHASE \(["DEBIT CARD", "VISA DEBIT", "CHECKCARD"][i % 3])" }
            if let value {
                balance += incoming ? value : -value
            }
            out.append(Row(id: i, date: line.stamp, description: description, memo: line.text,
                           debit: incoming ? nil : value, credit: incoming ? value : nil, balance: balance))
        }
        return out
    }

    var body: some View {
        let rows = self.rows
        let opening = (rows.first.map { $0.balance + ($0.debit ?? 0) - ($0.credit ?? 0) }) ?? 0
        let credits = rows.compactMap(\.credit)
        let debits = rows.compactMap(\.debit)
        Sheet {
            Letterhead(name: review.source, detail: review.sourceDetail + " · Member FDIC", color: ExhibitPalette.bank, icon: "building.columns.fill", trailing: "Statement")
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(holder.uppercased()).font(.caption.weight(.bold))
                    Text("Personal Checking").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                    Text("Account ••••\(String(format: "%04d", seed % 10_000))").font(.caption2.monospacedDigit())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Statement period").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                    Text(period).font(.caption2.monospacedDigit().weight(.semibold))
                    Text("Page 1 of 1").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                }
            }
            summary(opening: opening, credits: credits, debits: debits, closing: rows.last?.balance ?? opening)
            ledgerHeader
            ForEach(rows) { row in ledgerRow(row) }
            HStack {
                Text("Produced in response to subpoena. Certified as a record of regularly conducted activity (Rule 803(6)).")
                    .font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
                Spacer()
                BatesStamp(prefix: "BANK", seed: seed)
            }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }

    private var period: String {
        let first = review.lines.first?.stamp ?? review.date
        let last = review.lines.last?.stamp ?? review.date
        return first == last ? review.date : "\(first) – \(last)"
    }

    private func summary(opening: Double, credits: [Double], debits: [Double], closing: Double) -> some View {
        VStack(spacing: 3) {
            summaryLine("Beginning balance", money(opening))
            summaryLine("Deposits and other credits (\(credits.count))", "+" + money(credits.reduce(0, +)))
            summaryLine("Withdrawals and other debits (\(debits.count))", "–" + money(debits.reduce(0, +)))
            Divider()
            summaryLine("Ending balance", money(closing)).fontWeight(.bold)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).strokeBorder(ExhibitPalette.bank.opacity(0.4)))
    }

    private func summaryLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.caption2)
            Spacer()
            Text("$" + value.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "–", with: "")).font(.caption2.monospacedDigit())
        }
    }

    private var ledgerHeader: some View {
        HStack(spacing: 4) {
            Text("DATE").frame(width: 62, alignment: .leading)
            Text("DESCRIPTION")
            Spacer()
            Text("DEBITS").frame(width: 62, alignment: .trailing)
            Text("CREDITS").frame(width: 62, alignment: .trailing)
            Text("BALANCE").frame(width: 70, alignment: .trailing)
        }
        .font(.system(size: 8, weight: .bold)).foregroundStyle(.white)
        .padding(.horizontal, 4).padding(.vertical, 4)
        .background(ExhibitPalette.bank)
    }

    private func ledgerRow(_ row: Row) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .top, spacing: 4) {
                Text(row.date).frame(width: 62, alignment: .leading).foregroundStyle(ExhibitPalette.faint)
                Text(row.description).lineLimit(2)
                Spacer(minLength: 2)
                Text(row.debit.map(money) ?? "").frame(width: 62, alignment: .trailing)
                Text(row.credit.map(money) ?? "").frame(width: 62, alignment: .trailing)
                Text(money(row.balance)).frame(width: 70, alignment: .trailing).fontWeight(.semibold)
            }
            .font(.system(size: 9, design: .monospaced))
            Text(row.memo).font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
                .fixedSize(horizontal: false, vertical: true).padding(.leading, 66)
        }
        .padding(.horizontal, 4).padding(.vertical, 3)
        .background(row.id % 2 == 0 ? ExhibitPalette.bank.opacity(0.05) : Color.clear)
    }

    private var holder: String {
        let text = evidence.detail
        if let v = courtCase.victimName, text.contains(v) || text.contains(v.components(separatedBy: " ").last ?? "~") { return v }
        return courtCase.defendant.name
    }
}

// MARK: - Receipt

struct ReceiptView: View {
    let review: ExhibitReview
    let evidence: Evidence

    private var receipt: Receipt { Receipt.make(evidence, source: review.source, date: review.documentDate) }

    private func row(_ left: String, _ right: String, bold: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(left).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 6)
            Text(right)
        }
        .font(.system(size: 11, weight: bold ? .bold : .regular, design: .monospaced))
    }

    var body: some View {
        let r = receipt
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 5) {
                Text(r.store.uppercased()).font(.system(.callout, design: .monospaced).weight(.bold)).multilineTextAlignment(.center)
                Text(review.sourceDetail.uppercased()).font(.system(size: 10, design: .monospaced)).multilineTextAlignment(.center)
                Text(r.phone).font(.system(size: 10, design: .monospaced))
                dashed
                VStack(spacing: 2) {
                    row(r.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year()), r.time)
                    row("STORE \(r.storeNumber)  REG \(r.register)", "TRN \(r.transaction)")
                    row(r.cashier.uppercased(), r.pump.map { "PUMP \($0)" } ?? "")
                }
                dashed
                VStack(spacing: 3) {
                    ForEach(r.items, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 1) {
                            row(item.name, Receipt.money(item.price))
                            if let detail = item.detail {
                                Text("  " + detail).font(.system(size: 10, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                dashed
                VStack(spacing: 2) {
                    row("SUBTOTAL", Receipt.money(r.subtotal))
                    if r.tax > 0 { row("TAX", Receipt.money(r.tax)) }
                    row(r.kind == .pawn ? "LOAN AMOUNT" : "TOTAL", Receipt.money(r.total), bold: true)
                    row(r.tender, r.kind == .pawn ? "" : Receipt.money(r.cash ?? r.total))
                    if let change = r.change { row("CHANGE", Receipt.money(change)) }
                    if r.tender.contains("*") { row("AUTH \(String(r.transaction * 7 % 1_000_000))", "APPROVED") }
                }
                dashed
                Text(r.kind == .pawn ? "90-DAY LOAN · 25% FINANCE CHG · ID ON FILE" : (r.kind == .laundromat ? "THANK YOU · ATTENDANT ON DUTY 7A-9P" : "THANK YOU FOR SHOPPING WITH US"))
                    .font(.system(size: 9, design: .monospaced)).multilineTextAlignment(.center)
                // A barcode.
                HStack(spacing: 1) {
                    ForEach(0..<38, id: \.self) { i in
                        Rectangle().fill(ExhibitPalette.ink).frame(width: [1, 2, 1, 3, 1, 2][(i + r.transaction) % 6], height: 28)
                    }
                }
                Text(String(r.transaction) + String(r.storeNumber)).font(.system(size: 9, design: .monospaced))
                Text(evidence.exhibit.uppercased()).font(.system(size: 9, design: .monospaced)).foregroundStyle(ExhibitPalette.faint)
            }
            .foregroundStyle(ExhibitPalette.ink)
            .padding(14)
            .frame(maxWidth: 290)
            .background(ExhibitPalette.thermal)
            .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
            .rotationEffect(.degrees(0.8))
            Spacer()
        }
    }

    private var dashed: some View {
        Text(String(repeating: "-", count: 34)).font(.system(size: 10, design: .monospaced)).foregroundStyle(ExhibitPalette.faint)
    }
}

// MARK: - Business letterhead

/// A business or agency record: letterhead, reference block, the record itself, and the custodian's certification,
/// with the Bates number it was produced under.
struct LetterheadView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    private var seed: Int { "\(evidence.id)".stableHash }

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: review.sourceDetail, color: ExhibitPalette.business, icon: "briefcase.fill")
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(evidence.title).font(.system(.title3, design: .serif).weight(.semibold))
                    Text("Date: \(review.date)").font(.caption).foregroundStyle(ExhibitPalette.faint)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Ref. \(String(format: "%05d", seed % 100_000))").font(.caption2.monospacedDigit())
                    Text("Re: \(courtCase.docket)").font(.caption2.monospacedDigit()).foregroundStyle(ExhibitPalette.faint)
                }
            }
            ForEach(review.lines) { line in
                HStack(alignment: .top, spacing: 8) {
                    if line.stamp.hasPrefix("Entry") {
                        Text("•").font(.callout)
                    }
                    Text(line.text).font(.system(.callout, design: .serif)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 2) {
                Text("CERTIFICATION OF RECORDS CUSTODIAN").font(.system(size: 9, weight: .bold)).foregroundStyle(ExhibitPalette.faint)
                Text("I certify that this record was made at or near the time of the events it records, by a person with knowledge, and kept in the regular course of business (Rules 803(6), 902).")
                    .font(.system(size: 9)).foregroundStyle(ExhibitPalette.faint).fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .bottom) {
                    Text("Custodian of Records").font(.custom("SnellRoundhand", size: 16))
                    Spacer()
                    BatesStamp(prefix: "DISC", seed: seed)
                }
            }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }
}

// MARK: - Written statement

/// A witness's statement written out by hand on the agency's voluntary statement form, signed and witnessed.
struct WrittenStatementView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    private var seed: Int { "\(evidence.id)".stableHash }

    private var speaker: String {
        let firstQuote = evidence.detail.firstIndex(where: { $0 == "\"" || $0 == "\u{201C}" }) ?? evidence.detail.endIndex
        return Exhibits.statementSpeaker(evidence, in: courtCase, before: String(evidence.detail[..<firstQuote]))
    }

    private var words: [String] {
        let quotes = Exhibits.quoted(evidence.detail)
        return quotes.isEmpty ? Exhibits.sentences(evidence.detail) : quotes
    }

    var body: some View {
        Sheet {
            VStack(spacing: 2) {
                Text(review.source.uppercased()).font(.system(size: 12, weight: .heavy)).tracking(0.5)
                Text("VOLUNTARY STATEMENT").font(.system(size: 14, weight: .black)).tracking(2)
            }
            .frame(maxWidth: .infinity)
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 4) {
                GridRow { box("Name", speaker); box("Case no.", courtCase.docket) }
                GridRow { box("Date", review.date); box("Place taken", "\(courtCase.investigatingAgency)") }
            }
            Text("I, \(speaker), make the following statement of my own free will:")
                .font(.caption).foregroundStyle(ExhibitPalette.faint)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(words.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.custom("Noteworthy-Bold", size: 17))
                        .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.45))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Canvas { ctx, size in
                    var y: CGFloat = 30
                    while y < size.height {
                        ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) },
                                   with: .color(ExhibitPalette.rule), lineWidth: 0.6)
                        y += 26
                    }
                }
            )
            Text("I have read this statement consisting of 1 page. It is true and correct to the best of my knowledge.")
                .font(.system(size: 9)).foregroundStyle(ExhibitPalette.faint)
            HStack(alignment: .bottom) {
                signature(speaker, "Signature of person giving statement")
                Spacer()
                signature(courtCase.investigation?.leadInvestigator ?? "Investigating officer", "Witnessed by")
            }
            HStack { Spacer(); BatesStamp(prefix: "STMT", seed: seed) }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }

    private func box(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.uppercased()).font(.system(size: 8, weight: .bold)).foregroundStyle(ExhibitPalette.faint)
            Text(value).font(.caption.weight(.semibold)).lineLimit(2)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Rectangle().strokeBorder(ExhibitPalette.rule, lineWidth: 0.6))
    }

    private func signature(_ name: String, _ caption: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name).font(.custom("SnellRoundhand", size: 17))
            Rectangle().fill(ExhibitPalette.ink).frame(width: 130, height: 0.6)
            Text(caption).font(.system(size: 8)).foregroundStyle(ExhibitPalette.faint)
        }
    }
}

// MARK: - Medical

struct MedicalRecordView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: "Health Information Management · " + review.sourceDetail, color: ExhibitPalette.medical, icon: "cross.case.fill", trailing: "Confidential")
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 4) {
                GridRow {
                    field("Patient", patient)
                    field("MRN", "\(100_000 + seed * 7919 % 899_999)")
                }
                GridRow {
                    field("Encounter", review.date)
                    field("Dept.", "Emergency Department")
                }
            }
            HStack(spacing: 8) {
                if died {
                    vital("BP", "0/0")
                    vital("HR", "0")
                    vital("Resp", "0")
                    vital("Status", "Expired")
                } else {
                    vital("BP", "\(118 + seed % 40)/\(72 + seed % 20)")
                    vital("HR", "\(78 + seed % 40)")
                    vital("SpO₂", "\(94 + seed % 6)%")
                    vital("Pain", "\(4 + seed % 6)/10")
                }
            }
            Text("CLINICAL NOTES").font(.system(size: 10, weight: .bold)).foregroundStyle(ExhibitPalette.medical)
            ForEach(review.lines) { line in
                Text(line.text).font(.system(.callout, design: .default)).fixedSize(horizontal: false, vertical: true)
            }
            Text("Released under subpoena / HIPAA court-order exception (45 C.F.R. 164.512(e)).").font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }

    private var patient: String { courtCase.victimName ?? courtCase.defendant.name }
    /// The record of a victim who did not survive.
    private var died: Bool { courtCase.victimName != nil && Consequences.victimDied(courtCase) }
    /// Numbers that stay the same every time the exhibit is opened.
    private var seed: Int { "\(evidence.id)".stableHash }

    private func field(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label.uppercased()).font(.system(size: 9, weight: .bold)).foregroundStyle(ExhibitPalette.faint)
            Text(value).font(.caption.weight(.semibold))
        }
    }

    private func vital(_ label: String, _ value: String) -> some View {
        VStack(spacing: 1) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundStyle(ExhibitPalette.medical)
            Text(value).font(.caption.monospacedDigit().weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 4).fill(ExhibitPalette.medical.opacity(0.08)))
    }
}

// MARK: - Laboratory and autopsy

struct LabReportView: View {
    let review: ExhibitReview
    let evidence: Evidence
    var autopsy = false

    var body: some View {
        Sheet {
            Letterhead(name: review.source,
                       detail: autopsy ? "N.C. Department of Health and Human Services · Raleigh" : "N.C. Department of Justice · Raleigh",
                       color: ExhibitPalette.lab, icon: autopsy ? "staroflife.fill" : "testtube.2",
                       trailing: autopsy ? "Report of Autopsy" : "Report of Analysis")
            ForEach(Array(review.particulars.filter { ["Lab number", "Item", "Method", "Submitted", "Reported"].contains($0.label) }.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top) {
                    Text(item.label).font(.caption.weight(.bold)).foregroundStyle(ExhibitPalette.faint).frame(width: 90, alignment: .leading)
                    Text(item.value).font(.caption).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text(autopsy ? "FINDINGS" : "RESULTS AND CONCLUSIONS").font(.system(size: 10, weight: .bold)).foregroundStyle(ExhibitPalette.lab).padding(.top, 4)
            ForEach(Array(review.lines.enumerated()), id: \.element.id) { i, line in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(i + 1).").font(.caption.weight(.bold))
                    Text(line.text).font(.system(.callout, design: .serif)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(particularValue(review, "Analyst")?.replacingOccurrences(of: "Forensic scientist ", with: "") ?? "Analyst")
                        .font(.custom("SnellRoundhand", size: 20))
                    Text(autopsy ? "Forensic Pathologist" : "Forensic Scientist").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                }
                Spacer()
                Text("ISO/IEC 17025 ACCREDITED").font(.system(size: 8, weight: .bold)).padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(ExhibitPalette.lab))
                    .foregroundStyle(ExhibitPalette.lab)
            }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }
}

// MARK: - Carrier records and GPS

/// A phone number with all but the last two digits masked, the way carriers redact non-target numbers.
private func maskedNumber(_ seed: Int) -> String {
    let area = ["252", "910", "919", "984"][seed % 4]
    return "(\(area)) ***-**\(String(format: "%02d", seed % 100))"
}

/// Call detail records with cell-site location, as a carrier's subpoena compliance unit produces them.
struct CarrierRecordsView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    private var seed: Int { "\(evidence.id)".stableHash }

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: "Subpoena Compliance · Legal Department", color: ExhibitPalette.carrier, icon: "antenna.radiowaves.left.and.right", trailing: "CDR")
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 2) {
                GridRow {
                    field("Target number", maskedNumber(seed / 3))
                    field("Subscriber", courtCase.defendant.name.uppercased())
                }
                GridRow {
                    field("Records", "Voice, SMS, data sessions")
                    field("Legal process", "Court order, G.S. 15A-262")
                }
            }
            header
            ForEach(Array(review.lines.enumerated()), id: \.element.id) { i, line in row(i, line) }
            Text("MO = mobile originated; MT = mobile terminated. Cell site and sector show the tower face that handled the event; coverage can extend several miles and does not show the phone's exact location.")
                .font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
            HStack { Spacer(); BatesStamp(prefix: "CARRIER", seed: seed) }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }

    private func field(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.uppercased()).font(.system(size: 8, weight: .bold)).foregroundStyle(ExhibitPalette.faint)
            Text(value).font(.system(size: 10, design: .monospaced))
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text("DATE/TIME").frame(width: 84, alignment: .leading)
            Text("DIR").frame(width: 24, alignment: .leading)
            Text("TYPE").frame(width: 34, alignment: .leading)
            Text("OTHER PARTY")
            Spacer()
            Text("DUR").frame(width: 40, alignment: .trailing)
            Text("SITE-SEC").frame(width: 58, alignment: .trailing)
        }
        .font(.system(size: 8, weight: .bold, design: .monospaced)).foregroundStyle(.white)
        .padding(4).background(ExhibitPalette.carrier)
    }

    private func row(_ i: Int, _ line: ExhibitReview.Line) -> some View {
        let lower = line.text.lowercased()
        let h = seed &+ i &* 7_919
        let type = lower.contains("text") || lower.contains("message") ? "SMS" : (lower.contains("data") || lower.contains("location") || lower.contains("app") ? "DATA" : "VOICE")
        let duration = type == "VOICE" ? String(format: "%d:%02d", (h % 9), (h / 9) % 60) : "--"
        let site = "\(1_100 + (h % 800))-\(["A", "B", "C"][h % 3])"
        return VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Text(line.stamp).frame(width: 84, alignment: .leading).lineLimit(2)
                Text(h % 2 == 0 ? "MO" : "MT").frame(width: 24, alignment: .leading)
                Text(type).frame(width: 34, alignment: .leading)
                Text(type == "DATA" ? "—" : maskedNumber(h / 5))
                Spacer(minLength: 2)
                Text(duration).frame(width: 40, alignment: .trailing)
                Text(site).frame(width: 58, alignment: .trailing)
            }
            .font(.system(size: 9, design: .monospaced))
            Text(line.text).font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 3)
        .background(i % 2 == 0 ? ExhibitPalette.carrier.opacity(0.05) : Color.clear)
    }
}

/// A location history report: plotted points with their accuracy radius, coordinates, and how each was fixed,
/// the way a provider's warrant return or a cell-site analyst's map presents it.
struct GPSMapView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    private var seed: Int { "\(evidence.id)".stableHash }

    private struct Fix: Identifiable {
        let id: Int
        let stamp: String
        let text: String
        let x: CGFloat
        let y: CGFloat
        let lat: Double
        let lon: Double
        let accuracy: Int
        let source: String
    }

    private var fixes: [Fix] {
        let n = max(1, review.lines.count)
        let baseLat = 35.05 + Double(seed % 400) / 1_000
        let baseLon = -77.35 + Double((seed / 400) % 400) / 1_000
        return review.lines.enumerated().map { i, line in
            let t = n == 1 ? 0.5 : Double(i) / Double(n - 1)
            let wobble = Double((seed / (i + 3)) % 9) / 100
            let lower = line.text.lowercased()
            let source = lower.contains("tower") || lower.contains("cell") ? "Cell" : (lower.contains("wi-fi") || lower.contains("wifi") ? "Wi-Fi" : "GPS")
            let accuracy = source == "GPS" ? 6 + (seed + i * 13) % 20 : (source == "Wi-Fi" ? 25 + (seed + i) % 40 : 400 + (seed + i * 31) % 900)
            return Fix(id: i, stamp: line.stamp, text: line.text,
                       x: CGFloat(0.14 + 0.72 * t), y: CGFloat(0.78 - 0.55 * t + wobble - 0.04),
                       lat: baseLat + 0.012 * t + wobble / 50, lon: baseLon + 0.018 * t - wobble / 60,
                       accuracy: accuracy, source: source)
        }
    }

    var body: some View {
        let fixes = self.fixes
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("LOCATION HISTORY REPORT").font(.system(size: 11, weight: .heavy)).tracking(1)
                Text("\(review.source) · Produced pursuant to search warrant").font(.caption2).foregroundStyle(.secondary)
                Text("Account: \(accountHandle) · Times shown in Eastern Time").font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            ZStack(alignment: .topTrailing) {
                Canvas { ctx, size in draw(ctx, size: size, fixes: fixes) }
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                ExhibitSticker(label: evidence.exhibit).padding(8)
            }
            legend
            VStack(alignment: .leading, spacing: 6) {
                ForEach(fixes) { fix in fixRow(fix, last: fix.id == fixes.count - 1) }
            }
            .card()
            HStack { Spacer(); BatesStamp(prefix: "LOC", seed: seed) }
        }
    }

    private var accountHandle: String {
        let first = courtCase.defendant.name.lowercased().prefix(1)
        return "\(first)••••••@\(["gmail.com", "icloud.com", "outlook.com"][seed % 3])"
    }

    private func draw(_ ctx: GraphicsContext, size: CGSize, fixes: [Fix]) {
        ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.94, green: 0.94, blue: 0.91)))
        // Water and a park, then streets in a grid with one highway.
        ctx.fill(Path(CGRect(x: size.width * 0.82, y: 0, width: size.width * 0.18, height: size.height)), with: .color(Color(red: 0.70, green: 0.82, blue: 0.93)))
        ctx.fill(Path(roundedRect: CGRect(x: size.width * 0.18, y: size.height * 0.08, width: 80, height: 50), cornerRadius: 8),
                 with: .color(Color(red: 0.78, green: 0.88, blue: 0.75)))
        for i in 0..<8 {
            let x = size.width * CGFloat(i) / 8
            ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x + 12, y: size.height)) }, with: .color(.white), lineWidth: 3)
        }
        for j in 0..<6 {
            let y = size.height * CGFloat(j) / 5
            ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y - 10)) }, with: .color(.white), lineWidth: 3)
        }
        ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: size.height * 0.55)); p.addLine(to: CGPoint(x: size.width, y: size.height * 0.35)) },
                   with: .color(Color(red: 0.98, green: 0.84, blue: 0.45)), lineWidth: 7)
        // A cell tower and the sector that handled the phone, when the records rest on tower data.
        if fixes.contains(where: { $0.source == "Cell" }) {
            let tower = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
            var wedge = Path()
            wedge.move(to: tower)
            wedge.addArc(center: tower, radius: size.height * 0.85, startAngle: .degrees(-120), endAngle: .degrees(-60), clockwise: false)
            wedge.closeSubpath()
            ctx.fill(wedge, with: .color(.purple.opacity(0.10)))
            ctx.stroke(wedge, with: .color(.purple.opacity(0.4)), lineWidth: 1)
            ctx.draw(Text(Image(systemName: "antenna.radiowaves.left.and.right")).font(.system(size: 14)).foregroundColor(.purple), at: tower)
        }
        let points = fixes.map { CGPoint(x: size.width * $0.x, y: size.height * $0.y) }
        if points.count > 1 {
            var track = Path()
            track.addLines(points)
            ctx.stroke(track, with: .color(.blue.opacity(0.6)), style: StrokeStyle(lineWidth: 2.5, dash: [5, 4]))
        }
        for (fix, p) in zip(fixes, points) {
            // The accuracy radius: the phone was somewhere inside this circle.
            let r = CGFloat(min(60, max(8, fix.accuracy / 12)))
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(.blue.opacity(0.12)))
            ctx.stroke(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(.blue.opacity(0.35)), lineWidth: 1)
            let last = fix.id == fixes.count - 1
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 7, width: 14, height: 14)), with: .color(last ? .red : .blue))
            ctx.draw(Text("\(fix.id + 1)").font(.system(size: 8, weight: .bold)).foregroundColor(.white), at: p)
        }
    }

    private var legend: some View {
        HStack(spacing: 12) {
            Label("Recorded point", systemImage: "circle.fill").foregroundStyle(.blue)
            Label("Accuracy radius", systemImage: "circle.dashed").foregroundStyle(.blue.opacity(0.6))
            Label("Tower sector", systemImage: "antenna.radiowaves.left.and.right").foregroundStyle(.purple)
        }
        .font(.caption2)
    }

    private func fixRow(_ fix: Fix, last: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(fix.id + 1)").font(.caption2.weight(.bold)).foregroundStyle(.white)
                .frame(width: 18, height: 18).background(Circle().fill(last ? Color.red : Color.blue))
            VStack(alignment: .leading, spacing: 1) {
                Text(fix.stamp).font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                Text(String(format: "%.5f, %.5f", fix.lat, fix.lon) + " · ±\(fix.accuracy) m · \(fix.source)")
                    .font(.system(size: 10, design: .monospaced))
                Text(fix.text).font(.callout).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Evidence tag and photographs

struct EvidenceTagView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        let photos = review.lines.filter { $0.stamp.hasPrefix("Photo") }
        let custody = review.lines.filter { $0.stamp.hasPrefix("Custody") }
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle().strokeBorder(ExhibitPalette.ink.opacity(0.5), lineWidth: 2).frame(width: 18, height: 18)
                    Text("EVIDENCE").font(.system(.title3, design: .rounded).weight(.black)).tracking(3)
                    Spacer()
                    Text(particularValue(review, "Property tag") ?? "").font(.system(.caption, design: .monospaced).weight(.bold))
                }
                Text(review.source.uppercased()).font(.system(size: 10, weight: .bold))
                tagRow("Item", evidence.title)
                tagRow("Recovered", particularValue(review, "Recovered") ?? review.date)
                tagRow("Collected by", particularValue(review, "Collected by") ?? "")
                ForEach(photos) { line in
                    Text(line.text).font(.custom("Noteworthy-Bold", size: 15)).foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.4))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(ExhibitPalette.ink)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 6).fill(ExhibitPalette.manila))
            .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -8, y: -8) }
            .shadow(color: .black.opacity(0.15), radius: 3, y: 2)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("#").frame(width: 22)
                    Text("CHAIN OF CUSTODY")
                    Spacer()
                    Text("SEAL")
                }
                .font(.system(size: 9, weight: .bold)).padding(6).background(ExhibitPalette.ink.opacity(0.08))
                ForEach(Array(custody.enumerated()), id: \.element.id) { i, line in
                    HStack(alignment: .top) {
                        Text("\(i + 1)").frame(width: 22)
                        Text(line.text).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    }
                    .font(.caption)
                    .padding(6)
                    Divider()
                }
            }
            .foregroundStyle(ExhibitPalette.ink)
            .background(RoundedRectangle(cornerRadius: 4).fill(ExhibitPalette.paper))
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(ExhibitPalette.rule))
        }
    }

    private func tagRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.uppercased()).font(.system(size: 8, weight: .bold)).foregroundStyle(ExhibitPalette.ink.opacity(0.6))
            Text(value).font(.custom("Noteworthy-Bold", size: 15)).foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.4))
                .fixedSize(horizontal: false, vertical: true)
            Rectangle().fill(ExhibitPalette.ink.opacity(0.3)).frame(height: 0.5)
        }
    }
}

struct PhotoLogView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        let photos = review.lines.filter { $0.stamp.hasPrefix("Photo") }
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { i, line in
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [Color(white: 0.25), Color(white: 0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 150)
                        Image(systemName: icon(for: line.text)).font(.system(size: 54)).foregroundStyle(.white.opacity(0.35))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        HStack {
                            Text("\(review.date)").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(.orange)
                            Spacer()
                            // A scale marker, the way crime-scene photos are taken.
                            Text("1 2 3 4 5 cm").font(.system(size: 8, weight: .bold, design: .monospaced)).padding(3)
                                .background(Color.white).foregroundStyle(.black)
                        }
                        .padding(6)
                    }
                    .frame(height: 150)
                    Text("Photo \(i + 1). \(line.text)").font(.custom("Noteworthy-Bold", size: 14)).foregroundStyle(ExhibitPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10).padding(.bottom, 8)
                .background(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .rotationEffect(.degrees(i % 2 == 0 ? -1.5 : 1.2))
            }
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -4, y: -4) }
    }

    private func icon(for text: String) -> String {
        let t = text.lowercased()
        if t.contains("car") || t.contains("vehicle") || t.contains("truck") { return "car.fill" }
        if t.contains("door") || t.contains("window") || t.contains("house") || t.contains("home") { return "door.left.hand.closed" }
        if t.contains("gun") || t.contains("pistol") || t.contains("knife") || t.contains("weapon") { return "exclamationmark.triangle.fill" }
        if t.contains("blood") || t.contains("injur") || t.contains("bruis") || t.contains("wound") { return "bandage.fill" }
        if t.contains("phone") { return "iphone" }
        if t.contains("bag") || t.contains("baggie") || t.contains("pill") { return "bag.fill" }
        return "camera.fill"
    }
}

// MARK: - Email and social media

struct EmailView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    var body: some View {
        let first = review.lines.first { $0.speaker != nil }
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(.red).frame(width: 10, height: 10)
                Circle().fill(.yellow).frame(width: 10, height: 10)
                Circle().fill(.green).frame(width: 10, height: 10)
                Spacer()
                Text("Mail").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
            }
            .padding(8).background(Color(white: 0.92))
            VStack(alignment: .leading, spacing: 4) {
                header("From", sender(first?.speaker ?? courtCase.defendant.name))
                header("To", sender(first?.speaker == courtCase.defendant.name ? (courtCase.victimName ?? "Recipient") : courtCase.defendant.name))
                header("Date", "\(review.date) \(first?.stamp ?? "")")
                header("Subject", evidence.title)
            }
            .padding(10)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                ForEach(review.lines) { line in
                    Text(line.text).font(.callout).fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(line.speaker == nil ? ExhibitPalette.faint : ExhibitPalette.ink)
                }
            }
            .padding(12)
        }
        .foregroundStyle(ExhibitPalette.ink)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(ExhibitPalette.rule))
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: 30) }
    }

    private func sender(_ name: String) -> String {
        let handle = name.lowercased().replacingOccurrences(of: " ", with: ".")
        return "\(name) <\(handle)@\(["gmail.com", "outlook.com", "yahoo.com"][name.stableHash % 3])>"
    }

    private func header(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label + ":").font(.caption.weight(.semibold)).foregroundStyle(ExhibitPalette.faint).frame(width: 58, alignment: .leading)
            Text(value).font(.caption).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SocialPostView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(review.lines) { line in
                if let speaker = line.speaker {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle().fill(ExhibitPalette.social.opacity(0.8)).frame(width: 36, height: 36)
                                .overlay(Text(String(speaker.prefix(1))).font(.headline).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 0) {
                                Text(speaker).font(.subheadline.weight(.bold))
                                Text("@\(speaker.lowercased().replacingOccurrences(of: " ", with: "_")) · \(line.stamp)").font(.caption).foregroundStyle(ExhibitPalette.faint)
                            }
                            Spacer()
                            Image(systemName: "ellipsis").foregroundStyle(ExhibitPalette.faint)
                        }
                        Text(line.text).font(.body).fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 22) {
                            Label("\(3 + line.text.stableHash % 40)", systemImage: "bubble.right")
                            Label("\(line.text.stableHash % 25)", systemImage: "arrow.2.squarepath")
                            Label("\(10 + line.text.stableHash % 300)", systemImage: "heart")
                        }
                        .font(.caption).foregroundStyle(ExhibitPalette.faint)
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ExhibitPalette.rule))
                } else {
                    Text("\(line.stamp): \(line.text)").font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Screenshot captured and preserved by investigators.").font(.caption2).italic().foregroundStyle(.secondary)
        }
        .foregroundStyle(ExhibitPalette.ink)
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }
}

// MARK: - Calls and interviews

struct DispatchRecordView: View {
    let review: ExhibitReview
    let evidence: Evidence
    var jail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: jail ? "phone.connection.fill" : "phone.badge.waveform.fill")
                    Text(review.source.uppercased()).font(.system(size: 11, weight: .bold, design: .monospaced))
                    Spacer()
                    ExhibitSticker(label: evidence.exhibit)
                }
                Text(jail ? "INMATE CALL RECORDING · ALL CALLS ARE RECORDED AND MAY BE MONITORED"
                          : "CAD INCIDENT \("\(evidence.id)".stableHash % 900_000 + 100_000) · CALL RECORDING TRANSCRIPT")
                    .font(.system(size: 10, design: .monospaced))
                Text("RECEIVED \(review.date.uppercased())").font(.system(size: 10, design: .monospaced))
            }
            .foregroundStyle(Color.green)
            .padding(10)
            .background(Color.black)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(review.lines) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Text(line.stamp).font(.system(size: 10, design: .monospaced)).foregroundStyle(ExhibitPalette.faint).frame(width: 52, alignment: .leading)
                        VStack(alignment: .leading, spacing: 1) {
                            if let speaker = line.speaker {
                                Text(speaker.uppercased()).font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(speaker.lowercased().contains("dispatch") || speaker.lowercased().contains("operator") ? ExhibitPalette.bank : .red)
                            }
                            Text(line.text).font(.system(.callout, design: .monospaced)).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .foregroundStyle(ExhibitPalette.ink)
            .padding(12)
            .background(ExhibitPalette.paper)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(ExhibitPalette.rule))
    }
}

struct InterviewTranscriptView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    var body: some View {
        Sheet {
            VStack(alignment: .center, spacing: 2) {
                Text(review.source.uppercased()).font(.custom("Courier-Bold", size: 13))
                Text("TRANSCRIPT OF RECORDED INTERVIEW").font(.custom("Courier-Bold", size: 13))
                Text("Interview Room 2 · \(review.date)").font(.custom("Courier", size: 12))
            }
            .frame(maxWidth: .infinity)
            Rectangle().fill(ExhibitPalette.ink).frame(height: 1)
            ForEach(review.lines) { line in
                HStack(alignment: .top, spacing: 8) {
                    Text(label(line)).font(.custom("Courier-Bold", size: 13)).frame(width: 46, alignment: .leading)
                    Text(line.text).font(.custom("Courier", size: 13)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Rectangle().fill(ExhibitPalette.ink).frame(height: 1)
            Text("END OF RECORDING").font(.custom("Courier-Bold", size: 12)).frame(maxWidth: .infinity)
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }

    private func label(_ line: ExhibitReview.Line) -> String {
        guard let speaker = line.speaker else { return line.stamp.isEmpty ? "" : "NOTE" }
        if speaker == courtCase.defendant.name || speaker.contains(courtCase.defendant.lastName) { return "A:" }
        return "Q:"
    }
}

extension String {
    /// A small hash that is the same on every launch, for numbers drawn on exhibits.
    var stableHash: Int { unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFFF } }
}
