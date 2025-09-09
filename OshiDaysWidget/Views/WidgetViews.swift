import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BigNumberWidgetView: View {
    let entry: EventSummary
    let accent: Color
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            accent.opacity(0.12)
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(1)
                Text(dString(to: entry.startAt))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                if let name = entry.oshiName {
                    Text(name)
                        .font(.footnote)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(accent.opacity(0.2), in: Capsule())
                }
                Spacer(minLength: 0)
                Text(entry.startAt, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
    }
}

struct PhotoCardWidgetView: View {
    let entry: EventSummary
    let accent: Color
    @Environment(\.widgetFamily) private var family
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base accent background to avoid any empty area (and to show oshi color on Free)
                LinearGradient(colors: [accent.opacity(0.6), accent.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: geo.size.width, height: geo.size.height)
                if let dbg = loadDebugImageIfAny() {
                    Image(uiImage: dbg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else if ProStatusReader.isProUnlocked(), let id = entry.imageID, let ui = loadImage(id: id) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                // Global scrim for readability
                Rectangle().fill(
                    LinearGradient(colors: [Color.black.opacity(0.10), Color.black.opacity(0.28)], startPoint: .top, endPoint: .bottom)
                )
                // Top date (bold, centered)
                VStack(spacing: 0) {
                    Text(todayString())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                    Spacer(minLength: 0)
                }
                // Bottom oshi-color band with title and remaining text
                VStack { Spacer(minLength: 0)
                    ZStack {
                        // oshi色の帯（下部のみ、角丸に沿ってオーバーレイ）
                        Rectangle()
                            .fill(accent.opacity(0.58))
                            .frame(height: bandHeight(for: geo.size.height))
                            .overlay(
                                LinearGradient(colors: [Color.white.opacity(0.04), Color.black.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                            )
                        HStack(spacing: 6) {
                            Text(entry.title + localizedColon())
                                .font(titleFont())
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text(remainingText(to: entry.startAt))
                                .font(remainingFont())
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                if !ProStatusReader.isProUnlocked(), entry.imageID != nil {
                    ProPhotoLockBadge()
                }
            }
        }
    }
}

private extension PhotoCardWidgetView {
    func bandHeight(for h: CGFloat) -> CGFloat {
        switch family {
        case .systemSmall: return max(24, h * 0.32)
        case .systemMedium: return max(26, h * 0.26)
        case .systemLarge: return max(28, h * 0.22)
        default: return max(26, h * 0.25)
        }
    }
    func titleFont() -> Font {
        switch family {
        case .systemSmall: return .system(size: 12, weight: .semibold)
        case .systemMedium: return .system(size: 14, weight: .semibold)
        default: return .headline
        }
    }
    func remainingFont() -> Font {
        switch family {
        case .systemSmall: return .system(size: 18, weight: .heavy, design: .rounded)
        case .systemMedium: return .system(size: 22, weight: .heavy, design: .rounded)
        default: return .system(size: 26, weight: .heavy, design: .rounded)
        }
    }
}

struct RingWidgetView: View {
    let entry: EventSummary
    let accent: Color
    var body: some View {
        ZStack {
            if !ProStatusReader.isProUnlocked() {
                ProLockOverlay()
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title).font(.headline).lineLimit(1)
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle().stroke(accent.opacity(0.2), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: CGFloat(progress(to: entry.startAt)))
                            .stroke(accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text(dString(to: entry.startAt))
                            .font(.system(.footnote, design: .rounded)).bold()
                    }
                    .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.startAt, style: .date).font(.subheadline)
                        Text(timeString(entry.startAt)).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }
}

struct ListWidgetView: View {
    let items: [EventSummary]
    let accent: Color
    @Environment(\.widgetFamily) private var family
    var body: some View {
        ZStack(alignment: .topLeading) {
            accent.opacity(0.08)
            VStack(alignment: .leading, spacing: 8) {
                // Today date header centered & bold
                Text(todayString())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                ForEach(items.prefix(3), id: \.eventId) { e in
                    HStack(spacing: 8) {
                        Text(remainingText(to: e.startAt))
                            .font(listBadgeFont())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .frame(width: listBadgeWidth(), alignment: .leading)
                            .background(accent.opacity(0.20), in: Capsule())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(e.title).lineLimit(1)
                            Text(e.startAt, style: .date).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
        }
    }
}

private func dString(to date: Date) -> String {
    let cal = Calendar.current
    let start = cal.startOfDay(for: Date())
    let dest = cal.startOfDay(for: date)
    if let days = cal.dateComponents([.day], from: start, to: dest).day {
        if days > 0 { return "D-\(days)" }
        if days == 0 { return "D‑DAY" }
        return "D+\(-days)"
    }
    return "—"
}

private func remainingText(to date: Date) -> String {
    let cal = Calendar.current
    let start = cal.startOfDay(for: Date())
    let dest = cal.startOfDay(for: date)
    let pref = Locale.preferredLanguages.first ?? Locale.current.identifier
    if let days = cal.dateComponents([.day], from: start, to: dest).day {
        if days > 0 {
            if pref.hasPrefix("ja") { return "あと\(days)日" } else { return days == 1 ? "in 1 day" : "in \(days) days" }
        } else if days == 0 {
            if pref.hasPrefix("ja") { return "今日" } else { return "today" }
        } else {
            let n = -days
            if pref.hasPrefix("ja") { return "\(n)日前" } else { return n == 1 ? "1 day ago" : "\(n) days ago" }
        }
    }
    return ""
}

private func todayString() -> String {
    let f = DateFormatter()
    f.locale = Locale.current
    f.setLocalizedDateFormatFromTemplate("yMMMdd")
    return f.string(from: Date())
}

private func localizedColon() -> String {
    let pref = Locale.preferredLanguages.first ?? Locale.current.identifier
    return pref.hasPrefix("ja") ? "：" : ":"
}

private extension ListWidgetView {
    func listBadgeFont() -> Font {
        switch family { case .systemSmall: return .system(.footnote, design: .rounded).bold()
        case .systemMedium: return .system(.subheadline, design: .rounded).bold()
        default: return .system(.headline, design: .rounded).bold() }
    }
    func listBadgeWidth() -> CGFloat {
        switch family {
        case .systemSmall: return 76
        case .systemMedium: return 90
        default: return 100
        }
    }
}

private func timeString(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .none
    f.timeStyle = .short
    return f.string(from: date)
}

// Progress fills up as event gets closer within 30 days window.
private func progress(to date: Date) -> Double {
    let now = Date()
    let window: TimeInterval = 30 * 24 * 3600
    let remaining = max(0, date.timeIntervalSince(now))
    let p = 1 - min(1, remaining / window)
    return p
}

private struct ProLockOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
            VStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.title2)
                Text("Pro only").font(.caption)
            }
            .foregroundStyle(.white)
        }
    }
}

private struct ProPhotoLockBadge: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Label("Photos are Pro-only", systemImage: "lock.fill")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.45), in: Capsule())
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(8)
    }
}

private func loadImage(id: String) -> UIImage? {
    #if canImport(UIKit)
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupId)
    let url = container?.appendingPathComponent(AppConstants.imagesDirectory, isDirectory: true).appendingPathComponent("\(id).jpg")
    if let url, let img = UIImage(contentsOfFile: url.path) {
        // Downscale at read time for archive safety (Widget image pixel area limit)
        let maxDim: CGFloat = 1536
        let w = img.size.width, h = img.size.height
        if max(w, h) <= maxDim { return img }
        let ratio = maxDim / max(w, h)
        let newSize = CGSize(width: w * ratio, height: h * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        defer { UIGraphicsEndImageContext() }
        img.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? img
    }
    #endif
    return nil
}

private func loadDebugImageIfAny() -> UIImage? {
    let idx = ProStatusReader.debugImageOverrideIndex()
    guard idx == 1 || idx == 2 else { return nil }
    #if canImport(UIKit)
    let path = idx == 1 ? AppConstants.debugImagePath1 : AppConstants.debugImagePath2
    return UIImage(contentsOfFile: path)
    #else
    return nil
    #endif
}
