import SwiftUI

/// An administrative session: several short matters, each decided with one ruling.
struct CalendarCallView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    let call: CalendarCall
    @State private var choices: [UUID: Int] = [:]
    @State private var showLibrary = false
    @State private var confirmLeave = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ADMINISTRATIVE SESSION · CALENDAR CALL")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(Theme.gold)
                        Text(SentenceFormat.date(call.date)).font(.caption.monospaced()).foregroundStyle(.secondary)
                        Text("The courtroom is full. The clerk calls the calendar, and the matters come up one at a time.")
                            .font(.callout)
                    }

                    ForEach(call.matters) { matter in
                        MatterCard(matter: matter, choice: Binding(get: { choices[matter.id] }, set: { choices[matter.id] = $0 }))
                    }

                    PrimaryButton(title: "Adjourn the Session", icon: "hammer.fill",
                                  enabled: call.matters.allSatisfy { choices[$0.id] != nil },
                                  hint: "Rule on every matter on the calendar.") {
                        Haptics.gavel()
                        game.completeCalendar(call, choices: choices)
                        dismiss()
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Calendar Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { confirmLeave = true } label: {
                        Label("Leave", systemImage: "chevron.left").labelStyle(.titleAndIcon)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showLibrary = true } label: {
                        Label("Laws", systemImage: "books.vertical.fill").labelStyle(.titleAndIcon)
                    }
                }
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: call.matters.compactMap(\.lawID) + ["pjc", "dispositions", "crv"], showsDoneButton: true)
            }
            .confirmationDialog("Leave the calendar call?", isPresented: $confirmLeave, titleVisibility: .visible) {
                Button("Leave; resume later") { dismiss() }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("The session stays on your docket. Your rulings so far won't be kept.")
            }
        }
        .interactiveDismissDisabled()
    }
}

private struct MatterCard: View {
    let matter: CalendarMatter
    @Binding var choice: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(matter.kind.label, systemImage: matter.kind.icon).font(.headline)
                Spacer()
                Text(matter.docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Text("State v. \(matter.personName)").font(.system(.subheadline, design: .serif).weight(.bold))
            Text(matter.summary).font(.callout)
            Label(matter.stateAsk, systemImage: "building.columns.fill")
                .font(.caption)
                .foregroundStyle(Theme.prosecution)
            Label(matter.defenseAsk, systemImage: "shield.fill")
                .font(.caption)
                .foregroundStyle(Theme.defense)
            if let note = matter.lawNote {
                Text(note).font(.caption).foregroundStyle(.orange)
            }
            ForEach(Array(matter.options.enumerated()), id: \.offset) { index, option in
                ChoiceRow(title: option, selected: choice == index) { choice = index }
            }
            if let lawID = matter.lawID {
                LawLink(lawID: lawID)
            }
        }
        .card(tint: choice == nil ? nil : Theme.gold)
    }
}
