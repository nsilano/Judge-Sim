import SwiftUI
import UIKit

// Paper court forms for the Records screens: caption, file number, form number, ruled fields,
// check boxes, the judge's signature, and the clerk's filing stamp.

enum DocInk {
    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light })
    }

    /// Off-white bond paper in light mode; a dim, warm sheet in dark mode.
    static let paper = dynamic(light: UIColor(red: 0.988, green: 0.978, blue: 0.950, alpha: 1),
                               dark: UIColor(red: 0.165, green: 0.158, blue: 0.145, alpha: 1))
    static let ink = dynamic(light: UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 1),
                             dark: UIColor(red: 0.91, green: 0.89, blue: 0.84, alpha: 1))
    static let faint = dynamic(light: UIColor(red: 0.38, green: 0.36, blue: 0.33, alpha: 1),
                               dark: UIColor(red: 0.66, green: 0.64, blue: 0.60, alpha: 1))
    static let rule = dynamic(light: UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 0.35),
                              dark: UIColor(red: 0.91, green: 0.89, blue: 0.84, alpha: 0.30))
    static let shade = dynamic(light: UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 0.07),
                               dark: UIColor(red: 0.91, green: 0.89, blue: 0.84, alpha: 0.08))
    /// Rubber-stamp red for the clerk's filing stamp.
    static let stamp = dynamic(light: UIColor(red: 0.66, green: 0.13, blue: 0.13, alpha: 1),
                               dark: UIColor(red: 0.96, green: 0.47, blue: 0.43, alpha: 1))
    /// Fountain-pen blue for signatures.
    static let pen = dynamic(light: UIColor(red: 0.10, green: 0.20, blue: 0.52, alpha: 1),
                             dark: UIColor(red: 0.58, green: 0.70, blue: 0.98, alpha: 1))
    /// The desk the papers sit on.
    static let desk = Theme.background

    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif).weight(weight)
    }
}

/// Which court's caption heads the document.
enum DocCaption {
    /// Hollis County Superior Court: "STATE OF NORTH CAROLINA / County of Hollis / In The General Court Of Justice".
    case superior(county: String)
    /// North Carolina Court of Appeals, on appeal from a superior court file.
    case appeals(county: String, trialFile: String)
    /// A records agency header, e.g. a criminal history summary.
    case agency(String)
}

/// A paper court document. Content goes between the caption and the signature block.
struct CourtDocument<Content: View>: View {
    var caption: DocCaption
    var formNumber: String?
    var title: String
    var subtitle: String?
    var fileNumber: String
    /// The defendant's name for the "STATE VERSUS" block; nil omits the block.
    var defendant: String?
    var signature: DocSignature?
    var filed: DocFiling?
    @ViewBuilder var content: () -> Content

    init(caption: DocCaption, formNumber: String? = nil, title: String, subtitle: String? = nil, fileNumber: String,
         defendant: String? = nil, signature: DocSignature? = nil, filed: DocFiling? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.caption = caption
        self.formNumber = formNumber
        self.title = title
        self.subtitle = subtitle
        self.fileNumber = fileNumber
        self.defendant = defendant
        self.signature = signature
        self.filed = filed
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if let defendant { partyBlock(defendant) }
            titleBlock
            DocRule(double: true)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            if signature != nil || filed != nil {
                footer
            }
            HStack(alignment: .firstTextBaseline) {
                Text(formNumber ?? " ")
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                Spacer()
                Text(footerNote)
                    .font(.system(.caption2, design: .serif))
                    .multilineTextAlignment(.trailing)
            }
            .foregroundStyle(DocInk.faint)
            .padding(.top, 2)
        }
        .foregroundStyle(DocInk.ink)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Rectangle()
                .fill(DocInk.paper)
                .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 1.5)
        )
        .overlay(Rectangle().strokeBorder(DocInk.rule.opacity(0.6), lineWidth: 0.5))
        .accessibilityElement(children: .contain)
    }

    private var footerNote: String {
        switch caption {
        case .superior: return "Original – File"
        case .appeals: return "N.C. Court of Appeals"
        case .agency: return "Not an official transcript"
        }
    }

    @ViewBuilder
    private var header: some View {
        switch caption {
        case .superior(let county):
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STATE OF NORTH CAROLINA")
                        .font(DocInk.serif(.footnote, weight: .bold))
                    Text("County of \(county)")
                        .font(DocInk.serif(.footnote))
                }
                Spacer(minLength: 8)
                fileBox
            }
            Text("In The General Court Of Justice\nSuperior Court Division")
                .font(DocInk.serif(.caption))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        case .appeals(let county, let trialFile):
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("IN THE COURT OF APPEALS")
                        .font(DocInk.serif(.footnote, weight: .bold))
                    Text("OF NORTH CAROLINA")
                        .font(DocInk.serif(.footnote, weight: .bold))
                }
                Spacer(minLength: 8)
                fileBox
            }
            Text("Appeal from \(county) County Superior Court\nNo. \(trialFile)")
                .font(DocInk.serif(.caption))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        case .agency(let name):
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STATE OF NORTH CAROLINA")
                        .font(DocInk.serif(.footnote, weight: .bold))
                    Text(name)
                        .font(DocInk.serif(.footnote))
                }
                Spacer(minLength: 8)
                fileBox
            }
        }
    }

    private var fileBox: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("File No.")
                .font(.system(size: 9, weight: .semibold, design: .serif))
                .foregroundStyle(DocInk.faint)
            Text(fileNumber)
                .font(.system(.footnote, design: .monospaced).weight(.bold))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .overlay(Rectangle().strokeBorder(DocInk.rule, lineWidth: 0.75))
    }

    private func partyBlock(_ name: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("STATE VERSUS")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1)
            Text(name)
                .font(DocInk.serif(.body, weight: .semibold))
            Rectangle().fill(DocInk.rule).frame(height: 0.75)
            Text("Name of Defendant")
                .font(.system(size: 9, design: .serif))
                .foregroundStyle(DocInk.faint)
        }
        .padding(8)
        .overlay(Rectangle().strokeBorder(DocInk.rule, lineWidth: 0.75))
    }

    private var titleBlock: some View {
        VStack(spacing: 3) {
            Text(title.uppercased())
                .font(DocInk.serif(.subheadline, weight: .bold))
                .tracking(0.6)
                .multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle)
                    .font(DocInk.serif(.caption))
                    .foregroundStyle(DocInk.faint)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var footer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if let signature {
                DocSignatureView(signature: signature)
            } else {
                Spacer(minLength: 0)
            }
            if let filed {
                FiledStamp(filing: filed)
                    .padding(.bottom, 4)
            }
        }
        .padding(.top, 6)
    }
}

// MARK: Pieces

/// A horizontal rule; double for the line under a form's title.
struct DocRule: View {
    var double = false

    var body: some View {
        VStack(spacing: 2) {
            Rectangle().fill(DocInk.rule).frame(height: double ? 1 : 0.5)
            if double { Rectangle().fill(DocInk.rule).frame(height: 0.5) }
        }
    }
}

/// A shaded section bar, as on printed AOC forms.
struct DocSection: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .serif).weight(.bold))
            .tracking(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(DocInk.shade)
            .overlay(Rectangle().strokeBorder(DocInk.rule.opacity(0.7), lineWidth: 0.5))
    }
}

/// A filled-in blank: the value written on a ruled line, with the printed label beneath it.
struct DocField: View {
    let label: String
    let value: String
    var monospaced = false

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value.isEmpty ? " " : value)
                .font(monospaced ? .system(.callout, design: .monospaced) : DocInk.serif(.callout))
                .fixedSize(horizontal: false, vertical: true)
            Rectangle().fill(DocInk.rule).frame(height: 0.75)
            Text(label)
                .font(.system(size: 9, design: .serif))
                .foregroundStyle(DocInk.faint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Two short fields side by side, e.g. date and file number.
struct DocFieldPair: View {
    let first: (label: String, value: String)
    let second: (label: String, value: String)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            DocField(label: first.label, value: first.value)
            DocField(label: second.label, value: second.value)
        }
    }
}

/// A printed check box line: ☒ when checked, ☐ when not.
struct DocCheck: View {
    let checked: Bool
    let text: String
    var detail: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(checked ? "☒" : "☐")
                .font(.system(.callout, design: .serif))
                .foregroundStyle(checked ? DocInk.ink : DocInk.faint)
            VStack(alignment: .leading, spacing: 1) {
                Text(text)
                    .font(DocInk.serif(.callout))
                    .foregroundStyle(checked ? DocInk.ink : DocInk.faint)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .font(DocInk.serif(.caption))
                        .foregroundStyle(DocInk.faint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel((checked ? "Checked: " : "Not checked: ") + text)
    }
}

/// Body text on a form.
struct DocText: View {
    let text: String
    var italic = false
    var weight: Font.Weight = .regular

    init(_ text: String, italic: Bool = false, weight: Font.Weight = .regular) {
        self.text = text
        self.italic = italic
        self.weight = weight
    }

    var body: some View {
        Text(text)
            .font(DocInk.serif(.callout, weight: weight))
            .italic(italic)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A numbered paragraph, as in findings and orders.
struct DocNumbered: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(number).")
                .font(DocInk.serif(.callout, weight: .semibold))
                .frame(minWidth: 20, alignment: .trailing)
            Text(text)
                .font(DocInk.serif(.callout))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// A row of a ruled table: left column label or date, right column text.
struct DocTableRow: View {
    let left: String
    let right: String
    var detail: String? = nil
    var leftWidth: CGFloat = 78

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(left)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(DocInk.faint)
                    .frame(width: leftWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(right)
                        .font(DocInk.serif(.callout))
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(DocInk.serif(.caption))
                            .foregroundStyle(DocInk.faint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            Rectangle().fill(DocInk.rule.opacity(0.6)).frame(height: 0.5)
        }
    }
}

/// Who signed the document.
struct DocSignature {
    var name: String
    var title: String = "Superior Court Judge"
    var date: Date
}

struct DocSignatureView: View {
    let signature: DocSignature

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(signature.name)
                .font(.custom("Snell Roundhand", size: 22, relativeTo: .title3))
                .foregroundStyle(DocInk.pen)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Rectangle().fill(DocInk.ink).frame(height: 0.75)
            Text("Signature of \(signature.title)")
                .font(.system(size: 9, design: .serif))
                .foregroundStyle(DocInk.faint)
            Text("\(signature.name.uppercased()), \(signature.title)")
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            Text("Date: \(SentenceFormat.date(signature.date))")
                .font(.system(size: 10, design: .serif))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The clerk's filing stamp.
struct DocFiling {
    var date: Date
    var office: String
}

struct FiledStamp: View {
    let filing: DocFiling

    var body: some View {
        VStack(spacing: 1) {
            Text("FILED")
                .font(.system(size: 15, weight: .black, design: .serif))
                .tracking(3)
            Text(filing.date.formatted(.dateTime.month(.abbreviated).day().year()).uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            Text(filing.office.uppercased())
                .font(.system(size: 7, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .frame(width: 112)
        .foregroundStyle(DocInk.stamp)
        .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(DocInk.stamp, lineWidth: 1.5))
        .padding(2)
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(DocInk.stamp.opacity(0.6), lineWidth: 0.75))
        .rotationEffect(.degrees(-6))
        .opacity(0.85)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Filed \(SentenceFormat.date(filing.date)), \(filing.office)")
    }
}

/// A stack of papers on the desk, for detail screens.
struct DocumentDesk<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(DocInk.desk)
    }
}

/// A small caption above a document on the desk, outside the paper.
struct DeskLabel: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        SectionTitle(text: text, icon: icon)
    }
}

/// A tappable slip on the desk that opens another record.
struct DeskLink<Destination: View>: View {
    let title: String
    let detail: String?
    let icon: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(Theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.leading)
                    if let detail {
                        Text(detail).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }
            .card()
        }
        .buttonStyle(.plain)
    }
}

enum CourtForms {
    /// "Hollis County" -> "Hollis".
    static func countyShortName(_ county: County?) -> String {
        let name = county?.name ?? "Hollis County"
        return name.hasSuffix(" County") ? String(name.dropLast(" County".count)) : name
    }

    static func clerkOffice(_ county: County?) -> String {
        "\(countyShortName(county)) Co. Clerk of Superior Court"
    }

    /// A stable Court of Appeals number for a trial file, e.g. "COA26-412".
    static func appealsNumber(for appeal: AppealTracker) -> String {
        let year = Calendar.current.component(.year, from: appeal.filed) % 100
        let digits = RecordText.integers(in: appeal.docket).last ?? 0
        return String(format: "COA%02d-%03d", year, 100 + digits % 900)
    }
}
