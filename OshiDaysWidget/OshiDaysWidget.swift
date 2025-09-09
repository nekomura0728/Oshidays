import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EventSummary {
        EventSummary(date: Date(), eventId: nil, title: "Next Live", startAt: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, oshiName: "OSHI", colorHex: nil, imageID: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (EventSummary) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EventSummary>) -> ()) {
        let (entry, _) = StoreSnapshotReader.nextEvent()
        // Refresh at next midnight or event date, whichever comes first
        let nextMidnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 5), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(3600)
        let refresh = min(entry.startAt, nextMidnight)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct BigNumberWidget: Widget {
    let kind: String = "com.lizaria.oshidays.widget.bignumber"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            let (_, accent) = StoreSnapshotReader.nextEvent()
            BigNumberWidgetView(entry: entry, accent: accent)
                .widgetURL(entry.eventId.flatMap { URL(string: "oshidays://edit?eventId=\($0.uuidString)") })
        }
        .configurationDisplayName("OshiDays — Big Number")
        .description("D‑day number with oshi badge")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct PhotoCardWidget: Widget {
    let kind: String = "com.lizaria.oshidays.widget.photo"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            let (_, accent) = StoreSnapshotReader.nextEvent()
            let base = PhotoCardWidgetView(entry: entry, accent: accent)
                .widgetURL(entry.eventId.flatMap { URL(string: "oshidays://edit?eventId=\($0.uuidString)") })
            if #available(iOS 17.0, *) {
                base
                    .containerBackground(.clear, for: .widget)
            } else {
                base
            }
        }
        .configurationDisplayName("OshiDays — Photo Card")
        .description("Photo-friendly card with D‑day")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RingProvider: TimelineProvider {
    func placeholder(in context: Context) -> EventSummary {
        EventSummary(date: Date(), eventId: nil, title: "Next Live", startAt: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, oshiName: "OSHI", colorHex: nil, imageID: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (EventSummary) -> ()) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EventSummary>) -> ()) {
        let (entry, _) = StoreSnapshotReader.nextEvent()
        let nextMidnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 5), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(3600)
        let refresh = min(entry.startAt, nextMidnight)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct RingWidget: Widget {
    let kind: String = "com.lizaria.oshidays.widget.ring"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RingProvider()) { entry in
            let (_, accent) = StoreSnapshotReader.nextEvent()
            RingWidgetView(entry: entry, accent: accent)
                .widgetURL(entry.eventId.flatMap { URL(string: "oshidays://edit?eventId=\($0.uuidString)") })
        }
        .configurationDisplayName("OshiDays — Ring")
        .description("Progress ring toward event day")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ListProvider: TimelineProvider {
    func placeholder(in context: Context) -> EventListEntry {
        EventListEntry(date: Date(), items: [EventSummary(date: Date(), eventId: nil, title: "Next Live", startAt: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, oshiName: "OSHI", colorHex: nil, imageID: nil)])
    }
    func getSnapshot(in context: Context, completion: @escaping (EventListEntry) -> ()) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EventListEntry>) -> ()) {
        let (items, _) = StoreSnapshotReader.upcoming(limit: 3)
        let nextMidnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 5), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [EventListEntry(date: Date(), items: items)], policy: .after(nextMidnight)))
    }
}

struct ListWidget: Widget {
    let kind: String = "com.lizaria.oshidays.widget.list"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ListProvider()) { entry in
            let (_, accent) = StoreSnapshotReader.upcoming(limit: 3)
            let base = ListWidgetView(items: entry.items, accent: accent)
                .widgetURL(entry.items.first?.eventId.flatMap { URL(string: "oshidays://edit?eventId=\($0.uuidString)") })
            if #available(iOS 17.0, *) {
                base
                    .containerBackground(.clear, for: .widget)
            } else {
                base
            }
        }
        .configurationDisplayName("OshiDays — List")
        .description("Upcoming events list")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct OshiDaysWidgetBundle: WidgetBundle {
    var body: some Widget { PhotoCardWidget(); ListWidget() }
}
