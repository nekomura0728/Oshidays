import WidgetKit
import SwiftUI

struct EventSummary: TimelineEntry {
    let date: Date
    let eventId: UUID?
    let title: String
    let startAt: Date
    let oshiName: String?
    let colorHex: String?
    let imageID: String?
}

struct EventListEntry: TimelineEntry {
    let date: Date
    let items: [EventSummary]
}

struct StoreSnapshotReader {
    static func loadState() -> AppState? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupId)?.appendingPathComponent(AppConstants.storeFileName)
        if let url, let data = try? Data(contentsOf: url) {
            return try? JSONDecoder().decode(AppState.self, from: data)
        }
        return nil
    }

    static func nextEvent() -> (EventSummary, Color) {
        if let state = loadState() {
            let now = Date()
            let events = state.events.filter { $0.startAt >= now }.sorted { $0.startAt < $1.startAt }
            if let e = events.first {
                let oshi = state.oshis.first { $0.id == e.oshiID }
                let color = Color(hex: oshi?.colorHex ?? "#FF2D55") ?? .pink
                return (
                    EventSummary(date: Date(), eventId: e.id, title: e.title, startAt: e.startAt, oshiName: oshi?.name, colorHex: oshi?.colorHex, imageID: e.imageID),
                    color
                )
            }
        }
        return (EventSummary(date: Date(), eventId: nil, title: "Next Live", startAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, oshiName: "OSHI", colorHex: nil, imageID: nil), .accentColor)
    }

    static func upcoming(limit: Int) -> ([EventSummary], Color) {
        if let state = loadState() {
            let now = Date()
            let events = state.events.filter { $0.startAt >= now }.sorted { $0.startAt < $1.startAt }
            let items: [EventSummary] = events.prefix(limit).map { e in
                let oshi = state.oshis.first { $0.id == e.oshiID }
                return EventSummary(date: Date(), eventId: e.id, title: e.title, startAt: e.startAt, oshiName: oshi?.name, colorHex: oshi?.colorHex, imageID: e.imageID)
            }
            let accent = items.first.flatMap { Color(hex: $0.colorHex ?? "#FF2D55") } ?? .accentColor
            return (items, accent)
        }
        return ([EventSummary(date: Date(), eventId: nil, title: "Next Live", startAt: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, oshiName: "OSHI", colorHex: nil, imageID: nil)], .accentColor)
    }
}

struct ProStatusReader {
    static func isProUnlocked() -> Bool {
        let d = UserDefaults(suiteName: AppConstants.appGroupId)
        return d?.bool(forKey: "pro_unlocked") ?? false
    }
    static func debugImageOverrideIndex() -> Int {
        let d = UserDefaults(suiteName: AppConstants.appGroupId)
        return d?.integer(forKey: "debug_widget_image_index") ?? 0 // 0:none, 1:image1, 2:image2
    }
}
