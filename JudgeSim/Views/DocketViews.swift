import SwiftUI

extension Urgency.Level {
    var color: Color {
        switch self {
        case .routine: return Theme.secondaryText
        case .soon: return Theme.gold
        case .urgent: return .orange
        case .critical: return Theme.bad
        }
    }
}

// MARK: - Cases awaiting a trial date

/// Every case set for trial that has no date yet, most urgent first. The judge sets each one's date.
struct AwaitingView: View {
    @EnvironmentObject private var game: GameState
    @State private var setting: AwaitingCase?
    @State private var caseFile: CourtCase?
    @State private var suggestions: [(id: UUID, date: Date)] = []
    @State private var showSuggestions = false
    @State private var reassigning: AwaitingCase?

    var body: some View {
        FixedWidthScroll {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Awaiting a trial date").font(.system(.title3, design: .serif).weight(.bold))
                    Text("New indictments, cases set for trial at the calendar call, people charged again and cases sent back by the Court of Appeals all land here. Nothing is tried until you give it a date. Cases left waiting get more urgent, and some waits do real harm.")
                        .font(.caption).foregroundStyle(.secondary)
                    if !game.awaiting.isEmpty {
                        Button {
                            Haptics.tap()
                            suggestions = game.suggestedDates()
                            showSuggestions = true
                        } label: {
                            Label("Suggest dates for all", systemImage: "wand.and.stars")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered).tint(Theme.gold)
                    }
                }
                .card()
                if game.awaiting.isEmpty {
                    Text("Nothing is waiting. New cases come in as the days go by.")
                        .font(.callout).foregroundStyle(.secondary).card()
                }
                ForEach(game.awaitingByUrgency) { item in
                    AwaitingRow(item: item, urgency: game.urgency(of: item), today: game.today?.date ?? game.currentDate,
                                onSet: { setting = item }, onFile: { caseFile = item.courtCase },
                                onReassign: { reassigning = item })
                }
            }
            .padding()
        }
        .background(Theme.background)
        .sheet(item: $setting) { item in
            SetDateSheet(item: item)
        }
        .sheet(isPresented: $showSuggestions) {
            SuggestionsSheet(suggestions: suggestions)
        }
        .confirmationDialog("Reassign this case to another judge?",
                            isPresented: Binding(get: { reassigning != nil }, set: { if !$0 { reassigning = nil } }),
                            titleVisibility: .visible, presenting: reassigning) { item in
            Button("Reassign \(item.courtCase?.caption ?? "the case")", role: .destructive) {
                Haptics.tap()
                game.reassign(awaitingID: item.id)
                reassigning = nil
            }
            Button("Keep it", role: .cancel) { reassigning = nil }
        } message: { _ in
            Text("Another judge tries it, and you'll read how it came out in the paper. You won't hear the case, and you can't take it back. An occasional handoff is ordinary; a habit of it shows up in the bar survey.")
        }
        .sheet(item: Binding(get: { caseFile.map { AwaitingFile(courtCase: $0) } }, set: { caseFile = $0?.courtCase })) { item in
            NavigationStack {
                PendingCaseFile(courtCase: item.courtCase)
                    .background(Theme.background)
                    .navigationTitle(item.courtCase.caption)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { caseFile = nil } } }
            }
        }
    }
}

private struct AwaitingFile: Identifiable {
    let courtCase: CourtCase
    var id: UUID { courtCase.id }
}

private struct AwaitingRow: View {
    let item: AwaitingCase
    let urgency: Urgency
    let today: Date
    let onSet: () -> Void
    let onFile: () -> Void
    let onReassign: () -> Void

    var body: some View {
        let cal = CourtCalendar.calendar
        let waited = max(0, cal.dateComponents([.day], from: item.since, to: cal.startOfDay(for: today)).day ?? 0)
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Pill(text: urgency.level.label, color: urgency.level.color, icon: urgency.level >= .urgent ? "exclamationmark.triangle.fill" : nil)
                Spacer()
                Text(waited == 0 ? "New today" : "Waiting \(waited) day\(waited == 1 ? "" : "s")")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let c = item.courtCase {
                Text(c.caption).font(.subheadline.weight(.semibold))
                Text(item.entry.subtitle).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    if let cls = c.charges.first?.law.ncClass {
                        Label(cls.shortLabel, systemImage: "scalemass").font(.caption2)
                    }
                    Label(c.background?.isJailed == true ? "In jail" : "Out on release", systemImage: c.background?.isJailed == true ? "lock.fill" : "figure.walk")
                        .font(.caption2)
                    Label("~" + hoursText(item.entry.estimatedMinutes), systemImage: "clock").font(.caption2)
                }
                .foregroundStyle(Theme.quoteText)
            }
            if let earliest = item.earliest, earliest > cal.startOfDay(for: today) {
                Label("Ready from \(SentenceFormat.shortDate(earliest))" + (item.earliestReason.map { ": \($0.lowercased())" } ?? ""), systemImage: "hourglass")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            ForEach(urgency.reasons, id: \.self) { reason in
                Text("• " + reason).font(.caption2).foregroundStyle(urgency.level >= .urgent ? Theme.bad : Theme.quoteText)
            }
            if let note = item.entry.note, !note.isEmpty {
                Text(note).font(.caption2).foregroundStyle(.purple)
            }
            HStack(spacing: 8) {
                Button(action: onFile) { Label("Case file", systemImage: "folder.fill") }
                    .buttonStyle(.bordered).tint(.secondary)
                Button(action: onReassign) { Label("Reassign", systemImage: "person.2.badge.gearshape") }
                    .buttonStyle(.bordered).tint(.secondary)
                Spacer()
                Button(action: onSet) { Label("Set trial date", systemImage: "calendar.badge.plus") }
                    .buttonStyle(.borderedProminent).tint(Theme.gold)
            }
            .font(.caption.weight(.semibold))
        }
        .card(tint: urgency.level >= .urgent ? urgency.level.color : nil)
    }
}

private struct SetDateSheet: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    let item: AwaitingCase
    @State private var choice: Date?

    var body: some View {
        NavigationStack {
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.courtCase?.caption ?? "Set a trial date").font(.system(.title3, design: .serif).weight(.bold))
                    Text(item.entry.subtitle).font(.caption).foregroundStyle(.secondary)
                    if let earliest = item.earliest {
                        Label("Not ready before \(SentenceFormat.shortDate(earliest))" + (item.earliestReason.map { ": \($0.lowercased())" } ?? ""), systemImage: "hourglass")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    DayPickerList(kind: .trial, earliest: item.earliest, count: 40, choice: $choice)
                    Button {
                        if let choice {
                            Haptics.gavel()
                            game.setTrialDate(item.id, to: choice)
                            dismiss()
                        }
                    } label: {
                        Text(choice.map { "Set for trial " + CourtCalendar.dayTitle($0) } ?? "Choose a day")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .disabled(choice == nil)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Set Trial Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

private struct SuggestionsSheet: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    let suggestions: [(id: UUID, date: Date)]

    var body: some View {
        NavigationStack {
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Most urgent first, on the first day with room under your limits once each case is ready. Nothing is set until you confirm.")
                        .font(.caption).foregroundStyle(.secondary)
                    if suggestions.isEmpty {
                        Text("No day in the next year has room under your limits. Raise your limits under My Schedule.")
                            .font(.callout).foregroundStyle(Theme.bad)
                    }
                    ForEach(suggestions, id: \.id) { s in
                        if let item = game.awaiting.first(where: { $0.id == s.id }) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.courtCase?.caption ?? "").font(.subheadline.weight(.semibold))
                                    Text(game.urgency(of: item).level.label).font(.caption2).foregroundStyle(game.urgency(of: item).level.color)
                                }
                                Spacer()
                                Text(CourtCalendar.dayTitle(s.date)).font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                        }
                    }
                    Button {
                        Haptics.gavel()
                        game.acceptSuggestions(suggestions)
                        dismiss()
                    } label: {
                        Text("Set all \(suggestions.count)").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).tint(Theme.gold)
                    .disabled(suggestions.isEmpty)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Suggested Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

// MARK: - The judge's schedule

/// Which days court sits, how much each day takes, and time off.
struct ScheduleView: View {
    @EnvironmentObject private var game: GameState
    @State private var offFrom = Date()
    @State private var offTo = Date()

    var body: some View {
        FixedWidthScroll {
            VStack(alignment: .leading, spacing: 14) {
                weekCard
                templatesCard
                timeOffCard
            }
            .padding()
        }
        .background(Theme.background)
        .onAppear {
            offFrom = game.nextCourtDate
            offTo = game.nextCourtDate
        }
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Your usual week", icon: "calendar")
            Text("Choose the days you sit and how many trials and probation hearings each day takes. The week's calendar call is held on the first day you sit.")
                .font(.caption).foregroundStyle(.secondary)
            ForEach([2, 3, 4, 5, 6], id: \.self) { weekday in
                WeekdayRow(weekday: weekday)
            }
            Divider()
            Text("\(game.schedule.weeklyTrials) trial\(game.schedule.weeklyTrials == 1 ? "" : "s") a week. \(game.trialsInPipeline) trial\(game.trialsInPipeline == 1 ? "" : "s") on the calendar or waiting for a date.")
                .font(.caption)
            if game.schedule.weeklyTrials == 0 {
                Label("With no trial days, cases will pile up and wait.", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption).foregroundStyle(Theme.bad)
            }
            Text("New cases come in at about the pace your schedule can take. Fewer trial days means a slower intake, but the cases already charged still have to be heard.")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .card()
    }

    private var templatesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Start from a template", icon: "square.grid.2x2")
            ForEach(CourtSchedule.Template.allCases) { template in
                Button {
                    Haptics.tap()
                    game.applyTemplate(template)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(template.title).font(.subheadline.weight(.semibold))
                        Text(template.detail).font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised.opacity(0.7)))
                }
                .buttonStyle(.plain)
            }
            Text("A template sets the trials and hearings for each weekday; you can adjust them after.")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .card()
    }

    private var timeOffCard: some View {
        let cal = CourtCalendar.calendar
        let upcoming = game.schedule.timeOff.compactMap(CourtSchedule.date)
            .filter { $0 >= cal.startOfDay(for: game.today?.date ?? game.currentDate) && CourtCalendar.isCourtDay($0) }
            .sorted()
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Time off", icon: "beach.umbrella.fill")
            Text("\(game.leaveLeft) of \(game.schedule.leavePerYear) court days of leave left this year. Matters set on days you take off move to the next days with room.")
                .font(.caption).foregroundStyle(.secondary)
            DatePicker("From", selection: $offFrom, in: game.nextCourtDate..., displayedComponents: .date)
            DatePicker("Through", selection: $offTo, in: offFrom..., displayedComponents: .date)
            Button {
                Haptics.gavel()
                game.bookTimeOff(from: offFrom, to: offTo)
            } label: {
                Label("Book these days off", systemImage: "calendar.badge.minus").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(Theme.defense)
            if !upcoming.isEmpty {
                Text("Booked").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                ForEach(upcoming, id: \.self) { day in
                    HStack {
                        Text(CourtCalendar.dayTitle(day)).font(.subheadline)
                        Spacer()
                        Button("Cancel") { Haptics.tap(); game.cancelTimeOff(day) }
                            .font(.caption.weight(.semibold))
                    }
                }
            }
        }
        .card()
    }
}

private struct WeekdayRow: View {
    @EnvironmentObject private var game: GameState
    let weekday: Int

    var body: some View {
        let sits = game.schedule.courtDays.contains(weekday)
        let limit = game.schedule.limits[weekday] ?? .closed
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: Binding(get: { sits }, set: { game.setCourtDay(weekday, sits: $0) })) {
                Text(CourtSchedule.weekdayNames[weekday] ?? "").font(.subheadline.weight(.semibold))
            }
            .tint(Theme.gold)
            if sits {
                HStack(spacing: 12) {
                    Stepper("Trials \(limit.trials)", value: Binding(get: { limit.trials },
                                                                    set: { game.setWeekdayLimit(weekday, DayLimit(trials: $0, hearings: limit.hearings)) }), in: 0...4)
                    Stepper("Hearings \(limit.hearings)", value: Binding(get: { limit.hearings },
                                                                        set: { game.setWeekdayLimit(weekday, DayLimit(trials: limit.trials, hearings: $0)) }), in: 0...4)
                }
                .font(.caption)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised.opacity(sits ? 0.7 : 0.3)))
    }
}
