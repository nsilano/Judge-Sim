import SwiftUI
import UIKit

enum Theme {
    static func hex(_ v: UInt32) -> Color {
        Color(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }

    // Mahogany Bench palette.
    static let background = hex(0x1C130D)
    static let surface = hex(0x2A1B11)
    static let raised = hex(0x3A271A)
    static let border = hex(0x4A3322)
    static let text = hex(0xEFE6D6)
    static let secondaryText = hex(0xA8957C)
    static let quoteText = hex(0xCDBDA4)
    static let gold = hex(0xC9A46A)
    static let lightGold = hex(0xE8C98E)
    static let objectionFill = hex(0x3B1F17)
    static let objectionBorder = hex(0xA3543F)
    static let objectionLabel = hex(0xF0A48F)

    static let mahogany = hex(0x6B2E1C)
    static let prosecution = hex(0xE07A62)
    static let defense = hex(0x8FB3E0)
    static let good = hex(0x8CC084)
    static let bad = hex(0xE0705A)

    static func color(for side: Side) -> Color {
        side == .prosecution ? prosecution : defense
    }

    static let serif = Font.system(.title2, design: .serif).weight(.bold)

    /// UIKit chrome (navigation bars, tab bars, lists) in the walnut palette.
    static func applyAppearance() {
        let ui = { (v: UInt32) in UIColor(red: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255, blue: CGFloat(v & 0xFF) / 255, alpha: 1) }
        let surface = ui(0x2A1B11), text = ui(0xEFE6D6), gold = ui(0xC9A46A)
        func serif(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            return base.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: size) } ?? base
        }
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = surface
        nav.shadowColor = ui(0x4A3322)
        nav.titleTextAttributes = [.foregroundColor: text, .font: serif(18, .semibold)]
        nav.largeTitleTextAttributes = [.foregroundColor: text, .font: serif(32, .semibold)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = gold

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = surface
        tab.shadowColor = ui(0x4A3322)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = gold
        UITabBar.appearance().unselectedItemTintColor = ui(0xA8957C)

        UITableView.appearance().backgroundColor = ui(0x1C130D)
        UISegmentedControl.appearance().selectedSegmentTintColor = gold
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: ui(0x1C130D)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: text], for: .normal)
    }
}

extension View {
    /// Walnut backdrop for List/Form screens.
    func benchBackground() -> some View {
        scrollContentBackground(.hidden).background(Theme.background)
    }
}

struct CardModifier: ViewModifier {
    var tint: Color? = nil

    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(tint.map { $0.opacity(0.6) } ?? Theme.border, lineWidth: tint == nil ? 1 : 1.5)
            )
    }
}

extension View {
    func card(tint: Color? = nil) -> some View {
        modifier(CardModifier(tint: tint))
    }
}

struct SectionTitle: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon).foregroundStyle(Theme.gold)
            }
            Text(text.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

struct Pill: View {
    let text: String
    var color: Color = .secondary
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon) }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(color)
        .background(Capsule().fill(color.opacity(0.14)))
    }
}

struct Meter: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(value)")
                    .font(.subheadline.monospacedDigit().weight(.bold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.raised)
                    Capsule().fill(color)
                        .frame(width: proxy.size.width * CGFloat(max(0, min(100, value))) / 100)
                }
            }
            .frame(height: 8)
        }
    }
}

struct BulletList: View {
    let items: [String]
    var symbol: String = "circle.fill"
    var color: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: symbol == "circle.fill" ? 6 : 13))
                        .foregroundStyle(color)
                    Text(item)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// A tappable chip that opens a Law Library entry.
struct LawLink: View {
    let lawID: String

    var body: some View {
        if let law = LawLibrary.lawIfPresent(lawID) {
            NavigationLink {
                LawDetailView(law: law)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "book.closed.fill")
                    Text("Law: \(law.title)")
                        .lineLimit(1)
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.gold.opacity(0.18)))
                .foregroundStyle(Theme.gold)
            }
            .buttonStyle(.plain)
        }
    }
}

/// Two-option ruling control, e.g. Sustain / Overrule, with an optional explanation of each.
struct RulingPicker: View {
    let first: String
    let second: String
    var firstDetail: String? = nil
    var secondDetail: String? = nil
    @Binding var selection: Bool?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            option(first, detail: firstDetail, value: true)
            option(second, detail: secondDetail, value: false)
        }
    }

    private func option(_ title: String, detail: String?, value: Bool) -> some View {
        let isSelected = selection == value
        return Button {
            Haptics.tap()
            withAnimation(.snappy) { selection = value }
        } label: {
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    if isSelected { Image(systemName: "checkmark.circle.fill") }
                    Text(title).font(.system(.body, design: .serif).weight(.bold))
                }
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Theme.gold : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Theme.gold, lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Theme.background : Theme.lightGold)
        }
        .buttonStyle(.plain)
    }
}

/// The main action at the bottom of each screen. When disabled, says what's still needed.
struct PrimaryButton: View {
    let title: String
    var icon: String = "chevron.right"
    var enabled: Bool = true
    var hint: String? = nil
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                HStack {
                    Text(title).font(.system(.headline, design: .serif))
                    Image(systemName: icon)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(enabled ? Theme.gold : Theme.raised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(enabled ? Theme.gold : Theme.border, lineWidth: 1)
                )
                .foregroundStyle(enabled ? Theme.background : Theme.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(!enabled)

            if !enabled, let hint {
                Label(hint, systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 4)
    }
}

/// A collapsible card section, used to keep long screens manageable.
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    var summary: String? = nil
    @State var expanded: Bool
    @ViewBuilder let content: () -> Content

    init(title: String, icon: String, summary: String? = nil, expanded: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.summary = summary
        self._expanded = State(initialValue: expanded)
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) { expanded.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon).foregroundStyle(Theme.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.headline)
                        if let summary, !expanded {
                            Text(summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(expanded ? 0 : -90))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                content()
            }
        }
        .card()
    }
}

enum Haptics {
    static func gavel() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

/// The app's marketing version and build number, read from the bundle.
struct VersionBadge: View {
    static var text: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "v\(version) (\(build))"
    }

    var body: some View {
        Text(Self.text)
            .font(.caption2.monospaced().weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Theme.raised))
            .accessibilityLabel("Version \(Self.text)")
    }
}

/// A numbered step heading, so long screens read as a short sequence.
struct StepHeader: View {
    let number: Int
    let title: String
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.heavy))
                .frame(width: 22, height: 22)
                .background(Circle().fill(Theme.gold))
                .foregroundStyle(Color.black)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.title3.weight(.bold))
                if let detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }
}

/// Counsel, the case file, and what to do next, in one compact row at the top of the courtroom.
struct CourtActionBar: View {
    let counselCount: Int
    let next: String?
    let onCounsel: () -> Void
    let onReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                button("Ask counsel", icon: "bubble.left.and.bubble.right.fill", badge: counselCount, action: onCounsel)
                button("Case file", icon: "folder.fill", badge: 0, action: onReview)
            }
            if let next {
                Label {
                    Text("Next: ").bold() + Text(next)
                } icon: {
                    Image(systemName: "arrow.right.circle.fill").foregroundStyle(Theme.gold)
                }
                .font(.footnote)
                .foregroundStyle(Theme.quoteText)
                .lineLimit(2)
            }
        }
    }

    private func button(_ title: String, icon: String, badge: Int, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(Theme.gold)
                Text(title).font(.subheadline.weight(.semibold))
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.gold.opacity(0.25)))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.background))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Theme.border, lineWidth: 1))
            .foregroundStyle(Theme.text)
        }
        .buttonStyle(.plain)
    }
}

/// A vertical scroll view whose content is held to the screen's width, so a page never pans side to side.
struct FixedWidthScroll<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView(.vertical) {
            content()
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }
}
