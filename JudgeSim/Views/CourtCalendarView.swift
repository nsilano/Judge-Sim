import SwiftUI

/// How full a day or week is.
enum CalendarLoad {
    case closed, open, light, steady, busy, overbooked

    init(ratio: Double) {
        switch ratio {
        case ..<0.01: self = .open
        case ..<0.45: self = .light
        case ..<0.8: self = .steady
        case ...1.0: self = .busy
        default: self = .overbooked
        }
    }

    var label: String {
        switch self {
        case .closed: return "Closed"
        case .open: return "Open"
        case .light: return "Light"
        case .steady: return "Steady"
        case .busy: return "Busy"
        case .overbooked: return "Over limit"
        }
    }

    var color: Color {
        switch self {
        case .closed: return .secondary
        case .open: return Theme.secondaryText
        case .light: return Theme.good
        case .steady: return Theme.gold
        case .busy: return .orange
        case .overbooked: return Theme.bad
        }
    }
}

extension WeekPlan {
    var load: CalendarLoad {
        if courtDays.isEmpty { return .closed }
        if carryingOver > 0 { return .overbooked }
        // How full is counted in trials against your limits, nothing else.
        return CalendarLoad(ratio: Double(trialsSet) / Double(max(1, cap)))
    }

    func sits(_ day: Date) -> Bool { courtDays.contains { CourtCalendar.isSameDay($0, day) } }

    func dayLoad(_ day: Date) -> CalendarLoad {
        if !sits(day) { return .closed }
        let set = matters(on: day).filter { !$0.done }
        if set.contains(where: \.carriesOver) { return .overbooked }
        let limit = limit(on: day)
        let used = set.filter { $0.kind == .trial }.count + set.filter { $0.kind == .hearing }.count
        return CalendarLoad(ratio: Double(used) / Double(max(1, limit.trials + limit.hearings)))
    }
}

func hoursText(_ minutes: Int) -> String {
    let h = minutes / 60, m = minutes % 60
    if h == 0 { return "\(m)m" }
    return m == 0 ? "\(h)h" : "\(h)h \(m)m"
}

struct CourtCalendarView: View {
    @EnvironmentObject private var game: GameState
    @State private var selected: Date?
    @State private var month: Date?
    @State private var continuing: PlannedMatter?
    @State private var caseFile: CourtCase?
    @State private var tab = 0

    private let cal = CourtCalendar.calendar

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $tab) {
                    Text("Calendar").tag(0)
                    Text(game.awaiting.isEmpty ? "Awaiting" : "Awaiting (\(game.awaiting.count))").tag(1)
                    Text("My Schedule").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Theme.surface)
                switch tab {
                case 1: AwaitingView()
                case 2: ScheduleView()
                default: calendarBody
                }
            }
            .background(Theme.background)
            .navigationTitle("Court Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var calendarBody: some View {
        Group {
            let plans = game.weekPlans(count: 16)
            let today = cal.startOfDay(for: game.today?.clock ?? game.currentDate)
            let day = selected ?? today
            let shownMonth = month ?? today
            let horizon = plans.last.map { cal.date(byAdding: .day, value: 4, to: $0.monday) ?? $0.monday } ?? today
            let events = game.calendarEvents(from: plans.first?.monday ?? today, to: horizon)
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 16) {
                    MonthGrid(month: shownMonth, plans: plans, events: events, today: today, selected: day,
                              onSelect: { selected = $0 }, onMonth: { month = $0 })
                    CalendarLegend()
                    if let plan = plans.first(where: { cal.isDate(CourtCalendar.monday(onOrBefore: day), inSameDayAs: $0.monday) }) {
                        WeekSummaryCard(plan: plan, today: today)
                        DayDetailCard(day: day, plan: plan, events: events.filter { cal.isDate($0.date, inSameDayAs: day) }, today: today,
                                      onContinue: { continuing = $0 }, onCaseFile: { caseFile = $0 })
                    } else {
                        Text(day < today ? "That day has passed. Past cases are in Records." : "Nothing is set that far out yet.")
                            .font(.callout).foregroundStyle(.secondary).card()
                    }
                    UpcomingWeeks(plans: plans, selectedWeek: CourtCalendar.monday(onOrBefore: day)) { monday in
                        let first = game.nextSittingDay(onOrAfter: monday)
                        selected = first
                        month = first
                    }
                    UpcomingEvents(events: events.filter { $0.date >= today && $0.kind != .holiday }, orders: game.arrestOrders,
                                   on: game.currentDate)
                }
                .padding()
            }
            .background(Theme.background)
            .sheet(item: $continuing) { matter in
                ContinueSheet(matter: matter, plans: plans) { date in
                    game.resetForCongestion(matter, to: date)
                    continuing = nil
                }
            }
            .sheet(item: Binding(get: { caseFile.map { CaseFileItem(courtCase: $0) } }, set: { caseFile = $0?.courtCase })) { item in
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
}

private struct CaseFileItem: Identifiable {
    let courtCase: CourtCase
    var id: UUID { courtCase.id }
}

// MARK: - Month grid

private struct MonthGrid: View {
    let month: Date
    let plans: [WeekPlan]
    let events: [CalendarEvent]
    let today: Date
    let selected: Date
    let onSelect: (Date) -> Void
    let onMonth: (Date) -> Void

    private let cal = CourtCalendar.calendar

    private var firstOfMonth: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
    }

    /// The Mondays of every week that touches this month.
    private var mondays: [Date] {
        let first = firstOfMonth
        let end = cal.date(byAdding: DateComponents(month: 1, day: -1), to: first) ?? first
        var out: [Date] = []
        var monday = CourtCalendar.monday(onOrBefore: first)
        while monday <= end {
            out.append(monday)
            monday = cal.date(byAdding: .day, value: 7, to: monday) ?? end
        }
        return out
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { onMonth(cal.date(byAdding: .month, value: -1, to: firstOfMonth) ?? month) } label: {
                    Image(systemName: "chevron.left").padding(8)
                }
                Spacer()
                Text(firstOfMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(.title3, design: .serif).weight(.bold))
                Spacer()
                Button { onMonth(cal.date(byAdding: .month, value: 1, to: firstOfMonth) ?? month) } label: {
                    Image(systemName: "chevron.right").padding(8)
                }
            }
            HStack(spacing: 4) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri"], id: \.self) { name in
                    Text(name).font(.caption2.weight(.bold)).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            ForEach(mondays, id: \.self) { monday in
                let plan = plans.first { cal.isDate($0.monday, inSameDayAs: monday) }
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { offset in
                        let day = cal.date(byAdding: .day, value: offset, to: monday) ?? monday
                        DayCell(day: day, inMonth: cal.isDate(day, equalTo: firstOfMonth, toGranularity: .month), plan: plan,
                                events: events.filter { cal.isDate($0.date, inSameDayAs: day) && $0.kind != .holiday },
                                isToday: cal.isDate(day, inSameDayAs: today), isPast: day < today,
                                isSelected: cal.isDate(day, inSameDayAs: selected))
                            .onTapGesture { Haptics.tap(); onSelect(day) }
                    }
                }
            }
        }
        .card()
    }
}

private struct DayCell: View {
    let day: Date
    let inMonth: Bool
    let plan: WeekPlan?
    let events: [CalendarEvent]
    let isToday: Bool
    let isPast: Bool
    let isSelected: Bool

    var body: some View {
        let off = plan?.isOff(day) ?? false
        let closed = !CourtCalendar.isCourtDay(day) || off || (plan.map { !$0.sits(day) } ?? false)
        let load = plan?.dayLoad(day) ?? (closed ? .closed : .open)
        let matters = plan?.matters(on: day) ?? []
        let trials = matters.filter { $0.kind == .trial }.count
        let hearings = matters.filter { $0.kind == .hearing }.count
        let call = matters.contains { $0.kind == .calendarCall }
        VStack(spacing: 3) {
            Text(day.formatted(.dateTime.day()))
                .font(.subheadline.weight(isToday ? .bold : .regular).monospacedDigit())
                .foregroundStyle(isToday ? Theme.gold : (inMonth ? Theme.text : Theme.secondaryText))
            if off {
                Image(systemName: "beach.umbrella.fill").font(.system(size: 9)).foregroundStyle(Theme.defense)
            } else if !CourtCalendar.isCourtDay(day) {
                Image(systemName: "flag.fill").font(.system(size: 9)).foregroundStyle(Theme.gold)
            } else if closed {
                Text("—").font(.system(size: 9)).foregroundStyle(Theme.secondaryText)
            } else {
                Capsule().fill(load.color.opacity(plan == nil || isPast ? 0.25 : 0.9)).frame(height: 4)
            }
            HStack(spacing: 2) {
                if call { Circle().fill(Color.purple).frame(width: 5, height: 5) }
                if trials > 0 { Text("\(trials)").font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.gold) }
                if hearings > 0 { Circle().fill(Theme.defense).frame(width: 5, height: 5) }
                if !events.isEmpty { Circle().fill(Theme.secondaryText).frame(width: 5, height: 5) }
            }
            .frame(height: 9)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .opacity(isPast && !isToday ? 0.5 : 1)
        .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? Theme.raised : Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(isToday ? Theme.gold : Color.clear, lineWidth: 1.5))
        .contentShape(Rectangle())
        .accessibilityLabel("\(day.formatted(.dateTime.weekday(.wide).month().day())), \(off ? "day off" : (closed ? "court not sitting" : load.label))")
    }
}

private struct CalendarLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                ForEach([CalendarLoad.light, .steady, .busy, .overbooked], id: \.label) { load in
                    HStack(spacing: 4) {
                        Capsule().fill(load.color).frame(width: 14, height: 4)
                        Text(load.label).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            HStack(spacing: 10) {
                HStack(spacing: 4) { Circle().fill(Color.purple).frame(width: 6, height: 6); Text("Calendar call") }
                HStack(spacing: 4) { Text("2").bold().foregroundStyle(Theme.gold); Text("Trials") }
                HStack(spacing: 4) { Circle().fill(Theme.defense).frame(width: 6, height: 6); Text("Hearing") }
                HStack(spacing: 4) { Circle().fill(Theme.secondaryText).frame(width: 6, height: 6); Text("Other") }
            }
            .font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Week and day

private struct WeekSummaryCard: View {
    let plan: WeekPlan
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(CourtCalendar.weekTitle(plan.monday)).font(.system(.headline, design: .serif))
                Spacer()
                Pill(text: plan.load.label, color: plan.load.color)
            }
            if plan.courtDays.isEmpty {
                Text("The courthouse is closed all week.").font(.callout)
            } else {
                ProgressView(value: min(1, Double(plan.trialsSet) / Double(max(1, plan.cap))))
                    .tint(plan.load.color)
                Label("\(plan.trialsSet) of \(plan.cap) trial seats taken under your limits", systemImage: "scalemass.fill")
                    .font(.caption)
                if plan.openSeats > 0 {
                    Label("\(plan.openSeats) open trial seat\(plan.openSeats == 1 ? "" : "s") on the days ahead. Fill them from the cases awaiting a date.", systemImage: "plus.circle")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Label("New probation hearings go on the next day with hearing room as they come in.", systemImage: "person.badge.clock")
                    .font(.caption).foregroundStyle(.secondary)
                if plan.carryingOver > 0 {
                    Label("\(plan.carryingOver) matter\(plan.carryingOver == 1 ? " is" : "s are") set past a day's limit. Continue one to another day, or raise that day's limit.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(Theme.bad)
                }
                if !plan.daysOff.isEmpty {
                    Label("Days off: " + plan.daysOff.map { $0.formatted(.dateTime.weekday(.wide)) }.joined(separator: ", "), systemImage: "beach.umbrella.fill")
                        .font(.caption).foregroundStyle(Theme.defense)
                }
            }
            ForEach(plan.holidays, id: \.0) { holiday in
                Label("\(holiday.0.formatted(.dateTime.weekday(.wide))): \(holiday.1). The courthouse is closed.", systemImage: "flag.fill")
                    .font(.caption).foregroundStyle(Theme.gold)
            }
        }
        .card(tint: plan.load == .overbooked ? Theme.bad : nil)
    }
}

private struct DayDetailCard: View {
    @EnvironmentObject private var game: GameState
    let day: Date
    let plan: WeekPlan
    let events: [CalendarEvent]
    let today: Date
    let onContinue: (PlannedMatter) -> Void
    let onCaseFile: (CourtCase) -> Void

    var body: some View {
        let matters = plan.matters(on: day)
        let load = plan.dayLoad(day)
        let future = day > today
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(CourtCalendar.dayTitle(day)).font(.system(.headline, design: .serif))
                Spacer()
                if plan.sits(day) && day >= today { Pill(text: load.label, color: load.color) }
            }
            if let holiday = CourtCalendar.holiday(on: day) {
                Label("\(holiday). The courthouse is closed.", systemImage: "flag.fill")
                    .font(.callout).foregroundStyle(Theme.gold)
            } else if CourtCalendar.isWeekend(day) {
                Text("Court doesn't sit on weekends.").font(.callout).foregroundStyle(.secondary)
            } else if day < today {
                Text("This day has passed.").font(.callout).foregroundStyle(.secondary)
            } else if plan.isOff(day) {
                Label("You're off this day. Nothing is set for it.", systemImage: "beach.umbrella.fill")
                    .font(.callout).foregroundStyle(Theme.defense)
            } else if !plan.sits(day) {
                Text("You don't sit on \(day.formatted(.dateTime.weekday(.wide)))s. Change that under My Schedule.")
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                let limit = plan.limit(on: day)
                let set = matters.filter { !$0.done }
                let trials = set.filter { $0.kind == .trial }.count, hearings = set.filter { $0.kind == .hearing }.count
                Text("\(trials) of \(limit.trials) trial\(limit.trials == 1 ? "" : "s") and \(hearings) of \(limit.hearings) hearing\(limit.hearings == 1 ? "" : "s") set"
                     + (game.schedule.hasOverride(day) ? " (limits changed for this day)" : "")
                     + "." + (load == .overbooked ? " Over your limit." : ""))
                    .font(.caption).foregroundStyle(load == .overbooked ? Theme.bad : .secondary)
                if matters.isEmpty {
                    Text("Nothing set for this day yet. Set cases from the Awaiting list.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                ForEach(matters.filter { !$0.done }) { matter in
                    MatterRow(matter: matter, onContinue: onContinue, onCaseFile: onCaseFile)
                }
                let done = matters.filter(\.done)
                if !done.isEmpty {
                    Text("Already heard today").font(.caption.weight(.bold)).foregroundStyle(.secondary).padding(.top, 4)
                    ForEach(done) { matter in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(matter.title).font(.subheadline.weight(.semibold))
                            if let outcome = matter.outcome { Text(outcome).font(.caption2).foregroundStyle(.secondary).lineLimit(2) }
                        }
                        .opacity(0.7)
                    }
                }
            }
            if future && CourtCalendar.isCourtDay(day) {
                DayControls(day: day, limit: plan.limit(on: day), sits: plan.sits(day), off: plan.isOff(day))
            }
            if !events.isEmpty {
                Divider()
                ForEach(events) { event in EventRow(event: event) }
            }
        }
        .card()
    }
}

/// Changing one day: its limits, or taking it off.
private struct DayControls: View {
    @EnvironmentObject private var game: GameState
    let day: Date
    let limit: DayLimit
    let sits: Bool
    let off: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            if off {
                Button { Haptics.tap(); game.cancelTimeOff(day) } label: {
                    Label("Come back to court this day", systemImage: "arrow.uturn.backward")
                }
                .buttonStyle(.bordered).tint(Theme.gold)
            } else if sits {
                Text("Just this day").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                Stepper("Trials: \(limit.trials)", value: Binding(get: { limit.trials }, set: { game.setDayLimit(day, DayLimit(trials: $0, hearings: limit.hearings)) }), in: 0...4)
                    .font(.subheadline)
                Stepper("Hearings: \(limit.hearings)", value: Binding(get: { limit.hearings }, set: { game.setDayLimit(day, DayLimit(trials: limit.trials, hearings: $0)) }), in: 0...4)
                    .font(.subheadline)
                HStack {
                    if game.schedule.hasOverride(day) {
                        Button("Use my usual limits") { Haptics.tap(); game.setDayLimit(day, nil) }
                            .buttonStyle(.bordered).tint(.secondary)
                    }
                    Spacer()
                    Button { Haptics.tap(); game.bookTimeOff(from: day, to: day) } label: {
                        Label("Take this day off", systemImage: "beach.umbrella.fill")
                    }
                    .buttonStyle(.bordered).tint(Theme.defense)
                }
                .font(.caption.weight(.semibold))
                Text("\(game.leaveLeft) court days of leave left this year. Anything set on a day off moves to the next day with room.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

private struct MatterRow: View {
    @EnvironmentObject private var game: GameState
    let matter: PlannedMatter
    let onContinue: (PlannedMatter) -> Void
    let onCaseFile: (CourtCase) -> Void

    private var icon: String {
        switch matter.kind {
        case .calendarCall: return "list.bullet.rectangle.portrait.fill"
        case .trial: return "scalemass.fill"
        case .hearing: return "person.badge.clock.fill"
        }
    }

    private var tint: Color {
        switch matter.kind {
        case .calendarCall: return .purple
        case .trial: return Theme.gold
        case .hearing: return Theme.defense
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: icon).foregroundStyle(tint).frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if case .expected = matter.source { Pill(text: "Expected", color: .secondary) }
                    }
                    Text(matter.title).font(.subheadline.weight(.semibold))
                    Text(matter.subtitle).font(.caption).foregroundStyle(.secondary)
                    ForEach(matter.notes, id: \.self) { note in
                        Text("• " + note).font(.caption2).foregroundStyle(note.hasPrefix("Over your limit") ? Theme.bad : Theme.quoteText)
                    }
                }
            }
            if matter.canContinue || matter.courtCase != nil {
                HStack(spacing: 8) {
                    if let c = matter.courtCase {
                        Button { onCaseFile(c) } label: { Label("Case file", systemImage: "folder.fill") }
                            .buttonStyle(.bordered).tint(.secondary)
                    }
                    if matter.canContinue {
                        Button { onContinue(matter) } label: { Label("Move", systemImage: "calendar.badge.clock") }
                            .buttonStyle(.bordered).tint(Theme.gold)
                    }
                    if matter.kind == .trial, case .scheduled(let id) = matter.source {
                        Menu {
                            Button { Haptics.tap(); game.unschedule(id) } label: { Label("Back to the waiting list", systemImage: "tray.and.arrow.up") }
                            Button(role: .destructive) { Haptics.tap(); game.reassign(scheduledID: id) } label: {
                                Label("Reassign to another judge", systemImage: "person.2.badge.gearshape")
                            }
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                        .buttonStyle(.bordered).tint(.secondary)
                    }
                }
                .font(.caption.weight(.semibold))
                .padding(.leading, 32)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised.opacity(matter.carriesOver ? 0.4 : 0.7)))
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: event.icon).foregroundStyle(Theme.gold).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.subheadline.weight(.semibold))
                Text(event.detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Looking ahead

private struct UpcomingWeeks: View {
    let plans: [WeekPlan]
    let selectedWeek: Date
    let onSelect: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Weeks ahead", icon: "calendar")
            ForEach(plans.prefix(10)) { plan in
                Button { Haptics.tap(); onSelect(plan.monday) } label: {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2).fill(plan.load.color).frame(width: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(CourtCalendar.weekTitle(plan.monday)).font(.subheadline.weight(.semibold))
                            Text(weekLine(plan)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(plan.load.label).font(.caption.weight(.semibold)).foregroundStyle(plan.load.color)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(CourtCalendar.isSameDay(plan.monday, selectedWeek) ? Theme.raised : Theme.surface))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func weekLine(_ plan: WeekPlan) -> String {
        if plan.courtDays.isEmpty { return plan.daysOff.isEmpty ? "Court not sitting" : "Week off" }
        var parts = ["\(plan.trialsSet)/\(plan.cap) trials"]
        if plan.carryingOver > 0 { parts.append("\(plan.carryingOver) over limit") }
        if !plan.daysOff.isEmpty { parts.append("\(plan.daysOff.count) day\(plan.daysOff.count == 1 ? "" : "s") off") }
        if !plan.holidays.isEmpty { parts.append("\(plan.courtDays.count)-day week") }
        let hearings = plan.matters.filter { $0.kind == .hearing }.count
        if hearings > 0 { parts.append("\(hearings) hearing\(hearings == 1 ? "" : "s")") }
        return parts.joined(separator: " · ")
    }
}

private struct UpcomingEvents: View {
    let events: [CalendarEvent]
    let orders: [ArrestOrder]
    let on: Date

    var body: some View {
        let outstanding = orders.filter { !$0.resolved && !$0.served && $0.servedOn > on }
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Also coming up", icon: "bell.fill")
            if events.isEmpty && outstanding.isEmpty {
                Text("No appeals, releases or other dates in the next few months.").font(.caption).foregroundStyle(.secondary)
            }
            ForEach(events.prefix(20)) { event in
                HStack(alignment: .top, spacing: 10) {
                    Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption.monospacedDigit().weight(.semibold)).foregroundStyle(Theme.gold)
                        .frame(width: 48, alignment: .leading)
                    EventRow(event: event)
                }
            }
            if !outstanding.isEmpty {
                Label("\(outstanding.count) order\(outstanding.count == 1 ? "" : "s") for arrest not yet served. When one is served, the case is set for trial.", systemImage: "exclamationmark.shield.fill")
                    .font(.caption).foregroundStyle(.orange)
            }
        }
        .card()
    }
}

// MARK: - Continuing a matter

private struct ContinueSheet: View {
    @EnvironmentObject private var game: GameState
    let matter: PlannedMatter
    let plans: [WeekPlan]
    let onChoose: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var choice: Date?

    var body: some View {
        NavigationStack {
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 12) {
                    Text(matter.title).font(.system(.title3, design: .serif).weight(.bold))
                    Text(matter.subtitle).font(.caption).foregroundStyle(.secondary)
                    Text("The court moves this matter to another day because the calendar is too full. Neither side asked for it, so it doesn't count against either one. Pick a day with room.")
                        .font(.callout)
                    if matter.courtCase?.background?.isJailed == true {
                        Label("The defendant is in jail. Every day of delay is another day held before trial.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    DayPickerList(kind: matter.kind == .hearing ? .hearing : .trial, excluding: matter.day, choice: $choice)
                    Button {
                        if let choice { Haptics.gavel(); onChoose(choice) }
                    } label: {
                        Text(choice.map { "Move to " + CourtCalendar.dayTitle($0) } ?? "Choose a day")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .disabled(choice == nil)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Move to Another Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

/// The next days the judge sits, each with what's set against its limits, to pick one.
struct DayPickerList: View {
    enum Kind { case trial, hearing }
    @EnvironmentObject private var game: GameState
    let kind: Kind
    var excluding: Date? = nil
    /// Days before this aren't offered: a case not ready yet, for one.
    var earliest: Date? = nil
    /// How many sitting days ahead can be picked (at least about six months' worth).
    var count = 30
    /// Days that don't work for someone the trial needs, with the reason.
    var conflicts: [String: String] = [:]
    @Binding var choice: Date?
    /// The month on screen, as its first day.
    @State private var month: Date?

    /// The court's current date, which every choice is measured from.
    private var today: Date { game.today?.date ?? game.currentDate }

    /// The sitting days that can be chosen.
    private var allowed: Set<Date> {
        var out = Set<Date>()
        var day = game.nextSittingDay(onOrAfter: max(earliest ?? game.nextCourtDate, game.nextCourtDate))
        while out.count < max(count, 130) {
            out.insert(CourtCalendar.calendar.startOfDay(for: day))
            day = game.nextSittingDay(after: day)
        }
        return out
    }

    /// "tomorrow", "in 9 days", "in 3 weeks (22 days)", "in about 2 months (61 days)".
    static func distance(from today: Date, to day: Date) -> String {
        let cal = CourtCalendar.calendar
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: today), to: cal.startOfDay(for: day)).day ?? 0
        if days <= 0 { return "today" }
        if days == 1 { return "tomorrow" }
        if days < 14 { return "in \(days) days" }
        if days < 60 { return "in \(days / 7) weeks (\(days) days)" }
        return "in about \(Int((Double(days) / 30.4).rounded())) months (\(days) days)"
    }

    private static func firstOfMonth(_ date: Date) -> Date {
        let cal = CourtCalendar.calendar
        return cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    var body: some View {
        let open = allowed
        let first = month ?? Self.firstOfMonth(choice ?? open.min() ?? today)
        VStack(alignment: .leading, spacing: 10) {
            Label("Today is \(SentenceFormat.date(today))", systemImage: "calendar")
                .font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
            PickerMonthHeader(month: first, canGoBack: first > Self.firstOfMonth(today)) { step in
                month = CourtCalendar.calendar.date(byAdding: .month, value: step, to: first)
            }
            PickerMonthGrid(month: first, today: today, allowed: open, choice: $choice, cell: cellState)
            if let day = choice {
                PickerDayDetail(day: day, today: today, kind: kind, conflict: conflicts[CourtSchedule.key(day)],
                          current: excluding.map { CourtCalendar.isSameDay($0, day) } ?? false)
            } else {
                Text("Pick a day. Green has room, red is full, orange has a conflict for someone the case needs; gray days the court doesn't sit or the case isn't ready.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    /// How a day looks on the grid.
    private func cellState(_ day: Date) -> PickerDayCell.Status {
        if let excluding, CourtCalendar.isSameDay(excluding, day) { return .current }
        if conflicts[CourtSchedule.key(day)] != nil { return .conflict }
        let limit = game.schedule.limit(on: day)
        let set = game.counts(on: day)
        let used = kind == .trial ? set.trials : set.hearings
        let cap = kind == .trial ? limit.trials : limit.hearings
        return used >= cap ? .full : .open
    }
}

private struct PickerMonthHeader: View {
    let month: Date
    let canGoBack: Bool
    let step: (Int) -> Void

    var body: some View {
        HStack {
            Button { step(-1) } label: { Image(systemName: "chevron.left") }
                .disabled(!canGoBack)
            Spacer()
            Text(month.formatted(.dateTime.month(.wide).year())).font(.headline)
            Spacer()
            Button { step(1) } label: { Image(systemName: "chevron.right") }
        }
        .buttonStyle(.bordered)
        .tint(Theme.gold)
    }
}

struct PickerDayCell: View {
    enum Status { case open, full, conflict, current }
    let day: Date
    let number: Int
    let selectable: Bool
    let state: Status
    let selected: Bool
    let isToday: Bool

    private var dot: Color {
        switch state {
        case .open: return Theme.good
        case .full: return Theme.bad
        case .conflict: return .orange
        case .current: return Theme.gold
        }
    }

    private var textColor: Color {
        if selected { return Theme.background }
        return selectable ? Theme.text : Color.secondary.opacity(0.45)
    }

    private var fillColor: Color {
        if selected { return Theme.gold }
        return selectable ? Theme.surface : Color.clear
    }

    private var dotColor: Color { selectable ? dot : Color.clear }

    private var ringColor: Color { isToday ? Theme.gold : Color.clear }

    var body: some View {
        VStack(spacing: 3) {
            Text("\(number)")
                .font(.subheadline.monospacedDigit())
                .fontWeight(selected ? .bold : .regular)
                .foregroundStyle(textColor)
            Circle().fill(dotColor).frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(RoundedRectangle(cornerRadius: 8).fill(fillColor))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(ringColor, lineWidth: 1.5))
    }
}

private struct PickerMonthGrid: View {
    let month: Date
    let today: Date
    let allowed: Set<Date>
    @Binding var choice: Date?
    let cell: (Date) -> PickerDayCell.Status

    private var slots: [Date?] {
        let cal = CourtCalendar.calendar
        let count = cal.range(of: .day, in: .month, for: month)?.count ?? 30
        let lead = (cal.component(.weekday, from: month) - cal.firstWeekday + 7) % 7
        var out: [Date?] = Array(repeating: nil, count: lead)
        for d in 0..<count { out.append(cal.date(byAdding: .day, value: d, to: month)) }
        return out
    }

    @ViewBuilder
    private func slot(_ day: Date?) -> some View {
        if let day {
            dayButton(CourtCalendar.calendar.startOfDay(for: day))
        } else {
            Color.clear.frame(height: 40)
        }
    }

    private func dayButton(_ key: Date) -> some View {
        let status: PickerDayCell.Status = cell(key)
        let selectable: Bool = allowed.contains(key) && status != .current
        let isChosen: Bool = choice.map { CourtCalendar.isSameDay($0, key) } ?? false
        let number: Int = CourtCalendar.calendar.component(.day, from: key)
        let isToday: Bool = CourtCalendar.isSameDay(key, today)
        return Button {
            Haptics.tap()
            choice = key
        } label: {
            PickerDayCell(day: key, number: number, selectable: selectable, state: status, selected: isChosen, isToday: isToday)
        }
        .buttonStyle(.plain)
        .disabled(!selectable)
    }

    private var weekdayLetters: [String] {
        let cal = CourtCalendar.calendar
        let symbols = cal.veryShortWeekdaySymbols
        return (0..<7).map { symbols[(cal.firstWeekday - 1 + $0) % 7] }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<7, id: \.self) { i in
                Text(weekdayLetters[i]).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
            }
            ForEach(Array(slots.enumerated()), id: \.offset) { item in
                slot(item.element)
            }
        }
    }
}

/// What the chosen day looks like: how far out, what's already on it, and any conflict.
private struct PickerDayDetail: View {
    @EnvironmentObject private var game: GameState
    let day: Date
    let today: Date
    let kind: DayPickerList.Kind
    let conflict: String?
    let current: Bool

    private var used: Int {
        let set = game.counts(on: day)
        return kind == .trial ? set.trials : set.hearings
    }

    private var cap: Int {
        let limit = game.schedule.limit(on: day)
        return kind == .trial ? limit.trials : limit.hearings
    }

    private var full: Bool { used >= cap }

    private var openText: String { full ? "Full" : "\(cap - used) open" }

    private var loadText: String {
        let set = game.counts(on: day)
        let limit = game.schedule.limit(on: day)
        return "\(set.trials)/\(limit.trials) trials · \(set.hearings)/\(limit.hearings) hearings"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(CourtCalendar.dayTitle(day)).font(.subheadline.weight(.semibold))
                Text(DayPickerList.distance(from: today, to: day)).font(.caption).foregroundStyle(Theme.gold)
                Spacer()
                Text(openText).font(.caption.weight(.semibold)).foregroundStyle(full ? Theme.bad : Theme.good)
            }
            Text(loadText).font(.caption).foregroundStyle(.secondary)
            if let conflict {
                Label("Conflict: \(conflict)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2).foregroundStyle(.orange)
            }
            if full {
                Text("A full day can still take it; you'll be over your limit and the day will run long.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised))
    }
}

private extension String {
    /// "Week of …" → "week of …"
    var lowercasedFirstWord: String {
        guard let first = self.first else { return self }
        return first.lowercased() + String(self.dropFirst())
    }
}
