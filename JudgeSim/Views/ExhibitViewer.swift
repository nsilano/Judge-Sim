import SwiftUI

/// Opens an exhibit for the judge to examine: footage stepped through moment by moment, papers read
/// as papers, messages as a thread, a call or interview as a transcript.
struct ExhibitViewer: View {
    let evidence: Evidence
    let courtCase: CourtCase
    var suppressed = false
    @Environment(\.dismiss) private var dismiss
    @State private var moment = 0

    private var review: ExhibitReview { Exhibits.review(evidence, in: courtCase) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(evidence.exhibit) · \(review.format.label)").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                        Text(evidence.title).font(.system(.title3, design: .serif).weight(.bold))
                    }
                    if suppressed {
                        Label("You suppressed this exhibit. It isn't evidence, and you may not consider it.", systemImage: "nosign")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(Theme.bad)
                    }
                    exhibitBody(review)
                    if ![ExhibitReview.Look.courtPaper, .cctv, .bodycam, .dashcam, .phoneVideo, .messages, .transcript].contains(review.look) {
                        DisclosureGroup("Exhibit details") { particulars(review) }
                            .font(.subheadline.weight(.semibold))
                    }
                    considerations(review)
                }
                .padding(16)
            }
            .benchBackground()
            .navigationTitle("Review Exhibit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    /// The exhibit drawn as what it is.
    @ViewBuilder
    private func exhibitBody(_ r: ExhibitReview) -> some View {
        switch r.look {
        case .cctv, .bodycam, .dashcam, .phoneVideo: videoPlayer(r)
        case .messages: messageThread(r)
        case .email: EmailView(review: r, evidence: evidence, courtCase: courtCase)
        case .social: SocialPostView(review: r, evidence: evidence, courtCase: courtCase)
        case .call911: DispatchRecordView(review: r, evidence: evidence)
        case .jailCall: DispatchRecordView(review: r, evidence: evidence, jail: true)
        case .interview: InterviewTranscriptView(review: r, evidence: evidence, courtCase: courtCase)
        case .transcript: transcript(r)
        case .handwritten: HandwrittenNoteView(review: r, evidence: evidence)
        case .bank: BankStatementView(review: r, evidence: evidence, courtCase: courtCase)
        case .receipt: ReceiptView(review: r, evidence: evidence)
        case .letterhead: LetterheadView(review: r, evidence: evidence)
        case .medical: MedicalRecordView(review: r, evidence: evidence, courtCase: courtCase)
        case .lab: LabReportView(review: r, evidence: evidence)
        case .autopsy: LabReportView(review: r, evidence: evidence, autopsy: true)
        case .phoneRecords: CarrierRecordsView(review: r, evidence: evidence)
        case .gps: GPSMapView(review: r, evidence: evidence)
        case .propertyTag: EvidenceTagView(review: r, evidence: evidence)
        case .photos: PhotoLogView(review: r, evidence: evidence)
        case .courtPaper: paper(r)
        }
    }

    // MARK: Footage

    /// The screen, styled like the device that recorded it.
    @ViewBuilder
    private func screen(_ r: ExhibitReview, stamp: String, text: String, index: Int) -> some View {
        let caption = Text(text).font(.callout).foregroundStyle(.white).fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut(duration: 0.2), value: index)
        switch r.look {
        case .bodycam:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SENTRY BODY 3 · X\(abs(evidence.id.hashValue) % 90_000 + 10_000)").font(.system(size: 10, weight: .bold, design: .monospaced))
                    Spacer()
                    Text(stamp).font(.system(size: 10, design: .monospaced))
                }
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.3))
                Spacer(minLength: 0)
                caption
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(RadialGradient(colors: [Color(white: 0.22), .black], center: .center, startRadius: 20, endRadius: 260))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        case .dashcam:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(r.source.uppercased()).font(.system(size: 10, weight: .bold, design: .monospaced))
                    Spacer()
                    Text(stamp).font(.system(size: 10, design: .monospaced))
                }
                Spacer(minLength: 0)
                caption
                HStack {
                    Text("PATROL \(abs(evidence.id.hashValue) % 40 + 10)")
                    Spacer()
                    Text("\(abs(evidence.id.hashValue) % 45 + 20 + index * 3) MPH")
                    Spacer()
                    Text("LIGHTS ON").foregroundStyle(.red)
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(6).background(Color.black.opacity(0.6))
            }
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(LinearGradient(colors: [Color(red: 0.08, green: 0.1, blue: 0.18), Color(red: 0.2, green: 0.2, blue: 0.22)], startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        case .phoneVideo:
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text(stamp).font(.caption2.monospacedDigit()).foregroundStyle(.white)
                        Spacer()
                    }
                    Spacer(minLength: 0)
                    caption
                }
                .padding(12)
                .frame(width: 210, height: 340)
                .background(LinearGradient(colors: [Color(white: 0.3), Color(white: 0.1)], startPoint: .top, endPoint: .bottom))
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(Color(white: 0.15), lineWidth: 6))
                Spacer()
            }
        default:
            // A fixed security camera: grainy, gray-green, a camera label and a burned-in time stamp.
            ZStack {
                Canvas { ctx, size in
                    var y: CGFloat = 0
                    while y < size.height {
                        ctx.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(.white.opacity(0.04)))
                        y += 3
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("CAM 0\(abs(evidence.id.hashValue) % 8 + 1) · \(r.source.uppercased())").font(.system(size: 10, weight: .bold, design: .monospaced))
                        Spacer()
                        Label("REC", systemImage: "record.circle").font(.caption2.weight(.bold)).foregroundStyle(.red)
                    }
                    Spacer(minLength: 0)
                    caption
                    Text(stamp).font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundStyle(.yellow)
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(12)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color(red: 0.16, green: 0.2, blue: 0.17))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    @ViewBuilder
    private func videoPlayer(_ r: ExhibitReview) -> some View {
        let lines = r.lines
        let index = min(moment, max(0, lines.count - 1))
        VStack(alignment: .leading, spacing: 10) {
            screen(r, stamp: lines.isEmpty ? "" : lines[index].stamp, text: lines.isEmpty ? "No footage." : lines[index].text, index: index)

            if lines.count > 1 {
                Slider(value: Binding(get: { Double(index) }, set: { moment = Int($0.rounded()) }),
                       in: 0...Double(lines.count - 1), step: 1)
                HStack {
                    Button { moment = max(0, index - 1) } label: { Label("Back", systemImage: "backward.frame.fill") }
                        .disabled(index == 0)
                    Spacer()
                    Text("Moment \(index + 1) of \(lines.count)").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button { moment = min(lines.count - 1, index + 1) } label: { Label("Forward", systemImage: "forward.frame.fill") }
                        .disabled(index == lines.count - 1)
                }
                .font(.subheadline.weight(.semibold))
            }
            particulars(r)
            VStack(alignment: .leading, spacing: 8) {
                Text("Log of the recording").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                ForEach(Array(lines.enumerated()), id: \.element.id) { i, line in
                    Button { moment = i } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text(line.stamp).font(.caption.monospacedDigit()).foregroundStyle(i == index ? Theme.gold : .secondary)
                                .frame(width: 118, alignment: .leading)
                            Text(line.text).font(.callout).foregroundStyle(.primary).multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .card()
        }
    }

    // MARK: Messages

    @ViewBuilder
    private func messageThread(_ r: ExhibitReview) -> some View {
        particulars(r)
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chevron.left")
                Spacer()
                VStack(spacing: 2) {
                    Circle().fill(Color.gray.opacity(0.4)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.white))
                    Text(r.lines.first { $0.speaker != nil && !$0.fromDefendant }?.speaker ?? "Messages").font(.caption2.weight(.semibold))
                }
                Spacer()
                Image(systemName: "video")
            }
            .foregroundStyle(.blue)
            .padding(.bottom, 4)
            Divider()
            ForEach(r.lines) { line in
                if line.speaker == nil {
                    Text(line.stamp + ": " + line.text).font(.caption).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    HStack {
                        if line.fromDefendant { Spacer(minLength: 40) }
                        VStack(alignment: line.fromDefendant ? .trailing : .leading, spacing: 3) {
                            Text("\(line.speaker ?? "") · \(line.stamp)").font(.caption2).foregroundStyle(.secondary)
                            Text(line.text)
                                .font(.callout)
                                .padding(10)
                                .foregroundStyle(line.fromDefendant ? Color.white : Color.primary)
                                .background(RoundedRectangle(cornerRadius: 14)
                                    .fill(line.fromDefendant ? Color.blue : Theme.raised))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if !line.fromDefendant { Spacer(minLength: 40) }
                    }
                }
            }
        }
        .card()
    }

    // MARK: Transcript

    @ViewBuilder
    private func transcript(_ r: ExhibitReview) -> some View {
        particulars(r)
        VStack(alignment: .leading, spacing: 10) {
            ForEach(r.lines) { line in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if !line.stamp.isEmpty {
                            Text(line.stamp).font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                        }
                        if let speaker = line.speaker {
                            Text(speaker.uppercased()).font(.caption.weight(.bold))
                        }
                    }
                    Text(line.text).font(.system(.callout, design: .serif))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .card()
    }

    // MARK: Papers

    @ViewBuilder
    private func paper(_ r: ExhibitReview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            DocSection(title: r.format.label)
            ForEach(Array(r.particulars.enumerated()), id: \.offset) { _, item in
                DocField(label: item.label, value: item.value)
            }
            DocRule(double: true)
            ForEach(r.lines) { line in
                HStack(alignment: .top, spacing: 8) {
                    Text(line.stamp).font(.system(.caption, design: .serif).weight(.bold)).foregroundStyle(DocInk.faint)
                        .frame(width: 70, alignment: .leading)
                    DocText(line.text)
                }
            }
        }
        .foregroundStyle(DocInk.ink)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 4).fill(DocInk.paper))
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(DocInk.rule, lineWidth: 0.5))
    }

    @ViewBuilder
    private func particulars(_ r: ExhibitReview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(r.particulars.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top) {
                    Text(item.label).font(.caption.weight(.semibold)).foregroundStyle(.secondary).frame(width: 110, alignment: .leading)
                    Text(item.value).font(.caption).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .card()
    }

    private func considerations(_ r: ExhibitReview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "What to weigh", icon: "scalemass")
            ForEach(r.considerations, id: \.self) { line in
                Label(line, systemImage: "checkmark.circle").font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .card()
    }
}
