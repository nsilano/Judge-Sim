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

struct BankStatementView: View {
    let review: ExhibitReview
    let evidence: Evidence
    let courtCase: CourtCase

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: review.sourceDetail, color: ExhibitPalette.bank, icon: "building.columns.fill", trailing: "Statement")
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Account holder").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                    Text(holder).font(.caption.weight(.semibold))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Account").font(.caption2).foregroundStyle(ExhibitPalette.faint)
                    Text("••••\(String(format: "%04d", abs(evidence.id.hashValue) % 10_000))").font(.caption.monospacedDigit().weight(.semibold))
                }
            }
            HStack {
                Text("DATE").frame(width: 92, alignment: .leading)
                Text("DESCRIPTION")
                Spacer()
                Text("AMOUNT")
            }
            .font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
            .padding(.horizontal, 6).padding(.vertical, 4)
            .background(ExhibitPalette.bank)
            ForEach(Array(review.lines.enumerated()), id: \.element.id) { i, line in
                HStack(alignment: .top) {
                    Text(line.stamp).font(.caption2.monospacedDigit()).foregroundStyle(ExhibitPalette.faint).frame(width: 92, alignment: .leading)
                    Text(line.text).font(.caption).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 6)
                    Text(amount(in: line.text) ?? "").font(.caption.monospacedDigit().weight(.semibold))
                }
                .padding(.horizontal, 6).padding(.vertical, 5)
                .background(i % 2 == 0 ? ExhibitPalette.bank.opacity(0.06) : Color.clear)
            }
            Text("Produced in response to subpoena. Certified as a record of regularly conducted activity (Rule 803(6)).")
                .font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
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

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 6) {
                Text(review.source.uppercased()).font(.system(.callout, design: .monospaced).weight(.bold))
                Text(review.sourceDetail).font(.system(size: 10, design: .monospaced)).multilineTextAlignment(.center)
                dashed
                ForEach(review.lines) { line in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(line.stamp).font(.system(size: 10, design: .monospaced)).foregroundStyle(ExhibitPalette.faint)
                        HStack(alignment: .top) {
                            Text(line.text.uppercased()).font(.system(size: 11, design: .monospaced)).fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 4)
                            Text(amount(in: line.text) ?? "").font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                dashed
                Text("THANK YOU · NO REFUNDS WITHOUT RECEIPT").font(.system(size: 9, design: .monospaced))
                // A barcode.
                HStack(spacing: 1) {
                    ForEach(0..<38, id: \.self) { i in
                        Rectangle().fill(ExhibitPalette.ink).frame(width: [1, 2, 1, 3, 1, 2][i % 6], height: 28)
                    }
                }
                Text(evidence.exhibit.uppercased()).font(.system(size: 9, design: .monospaced))
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
        Text(String(repeating: "-", count: 34)).font(.system(size: 10, design: .monospaced)).lineLimit(1)
    }
}

// MARK: - Business letterhead

struct LetterheadView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: review.sourceDetail, color: ExhibitPalette.business, icon: "briefcase.fill")
            Text(evidence.title).font(.system(.title3, design: .serif).weight(.semibold))
            Text("Date: \(review.date)").font(.caption).foregroundStyle(ExhibitPalette.faint)
            ForEach(review.lines) { line in
                HStack(alignment: .top, spacing: 8) {
                    if line.stamp.hasPrefix("Entry") {
                        Text("•").font(.callout)
                    }
                    Text(line.text).font(.system(.callout, design: .serif)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            Text("Business record · \(review.source)").font(.caption2).foregroundStyle(ExhibitPalette.faint)
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
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
                    field("MRN", "\(100_000 + abs(evidence.id.hashValue) % 899_999)")
                }
                GridRow {
                    field("Encounter", review.date)
                    field("Dept.", "Emergency Department")
                }
            }
            HStack(spacing: 8) {
                vital("BP", "\(118 + abs(evidence.id.hashValue) % 40)/\(72 + abs(evidence.id.hashValue) % 20)")
                vital("HR", "\(78 + abs(evidence.id.hashValue) % 40)")
                vital("SpO₂", "\(94 + abs(evidence.id.hashValue) % 6)%")
                vital("Pain", "\(4 + abs(evidence.id.hashValue) % 6)/10")
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

struct CarrierRecordsView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        Sheet {
            Letterhead(name: review.source, detail: "Subpoena Compliance · Legal Department", color: ExhibitPalette.carrier, icon: "antenna.radiowaves.left.and.right", trailing: "CDR")
            Text("Call detail records with cell-site location").font(.caption).foregroundStyle(ExhibitPalette.faint)
            HStack {
                Text("DATE/TIME (ET)").frame(width: 100, alignment: .leading)
                Text("EVENT")
                Spacer()
                Text("SECTOR")
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(.white)
            .padding(4).background(ExhibitPalette.carrier)
            ForEach(Array(review.lines.enumerated()), id: \.element.id) { i, line in
                HStack(alignment: .top) {
                    Text(line.stamp).frame(width: 100, alignment: .leading)
                    Text(line.text).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 4)
                    Text("\(310 + (i * 37) % 600)-\(["A", "B", "C"][i % 3])")
                }
                .font(.system(size: 11, design: .monospaced))
                .padding(.vertical, 3)
            }
            Text("Sector locations are approximate. Tower coverage may extend several miles.").font(.system(size: 9)).italic().foregroundStyle(ExhibitPalette.faint)
        }
        .overlay(alignment: .topTrailing) { ExhibitSticker(label: evidence.exhibit).offset(x: -6, y: -8) }
    }
}

struct GPSMapView: View {
    let review: ExhibitReview
    let evidence: Evidence

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Canvas { ctx, size in
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.93, green: 0.94, blue: 0.90)))
                    // Streets.
                    for i in 0..<7 {
                        let x = size.width * CGFloat(i) / 6
                        ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x + 30, y: size.height)) },
                                   with: .color(.white), lineWidth: i == 3 ? 7 : 3)
                    }
                    for j in 0..<5 {
                        let y = size.height * CGFloat(j) / 4
                        ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y - 18)) },
                                   with: .color(.white), lineWidth: j == 2 ? 7 : 3)
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: size.width * 0.68, y: size.height * 0.1, width: 70, height: 46)),
                             with: .color(Color(red: 0.78, green: 0.88, blue: 0.75)))
                    // The track, point to point.
                    let points = (0..<max(2, review.lines.count)).map { i -> CGPoint in
                        let t = CGFloat(i) / CGFloat(max(1, review.lines.count - 1))
                        return CGPoint(x: size.width * (0.12 + 0.76 * t), y: size.height * (0.75 - 0.5 * t + (i % 2 == 0 ? 0.08 : -0.05)))
                    }
                    var track = Path()
                    track.addLines(points)
                    ctx.stroke(track, with: .color(.blue.opacity(0.7)), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                    for (i, p) in points.enumerated() {
                        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 7, width: 14, height: 14)), with: .color(i == points.count - 1 ? .red : .blue))
                        ctx.draw(Text("\(i + 1)").font(.system(size: 8, weight: .bold)).foregroundColor(.white), at: p)
                    }
                }
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack {
                    HStack {
                        Text(review.source).font(.caption2.weight(.bold)).padding(5)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 5))
                        Spacer()
                        ExhibitSticker(label: evidence.exhibit)
                    }
                    Spacer()
                }
                .padding(8)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(review.lines.enumerated()), id: \.element.id) { i, line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(i + 1)").font(.caption2.weight(.bold)).foregroundStyle(.white)
                            .frame(width: 18, height: 18).background(Circle().fill(i == review.lines.count - 1 ? Color.red : Color.blue))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(line.stamp).font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                            Text(line.text).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .card()
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
        return "\(name) <\(handle)@\(["gmail.com", "outlook.com", "yahoo.com"][abs(name.hashValue) % 3])>"
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
                            Label("\(3 + abs(line.text.hashValue) % 40)", systemImage: "bubble.right")
                            Label("\(abs(line.text.hashValue) % 25)", systemImage: "arrow.2.squarepath")
                            Label("\(10 + abs(line.text.hashValue) % 300)", systemImage: "heart")
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
                          : "CAD INCIDENT \(abs(evidence.id.hashValue) % 900_000 + 100_000) · CALL RECORDING TRANSCRIPT")
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
