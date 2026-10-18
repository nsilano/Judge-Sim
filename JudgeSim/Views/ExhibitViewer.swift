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
                    switch review.format {
                    case .video: videoPlayer(review)
                    case .messages: messageThread(review)
                    case .transcript: transcript(review)
                    case .document, .records, .lab, .property: paper(review)
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

    // MARK: Footage

    @ViewBuilder
    private func videoPlayer(_ r: ExhibitReview) -> some View {
        let lines = r.lines
        let index = min(moment, max(0, lines.count - 1))
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12).fill(Color.black)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("REC", systemImage: "record.circle").font(.caption2.weight(.bold)).foregroundStyle(.red)
                        Spacer()
                        Text(lines.isEmpty ? "" : lines[index].stamp)
                            .font(.caption.monospacedDigit()).foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer(minLength: 0)
                    Text(lines.isEmpty ? "No footage." : lines[index].text)
                        .font(.callout)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(.easeInOut(duration: 0.2), value: index)
                }
                .padding(12)
            }
            .frame(minHeight: 180)

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
