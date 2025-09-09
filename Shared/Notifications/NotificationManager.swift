import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func schedule(for event: Event) async {
        cancel(for: event.id)
        let center = UNUserNotificationCenter.current()

        // 1) 前日21:00
        if let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: event.startAt),
           let at21 = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: dayBefore), at21 > Date() {
            let c = baseContent(event: event, subtitle: localized("ReminderDayBefore"))
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: at21)
            let trig = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: event.id.uuidString+"-pre", content: c, trigger: trig))
        }

        // 2) 当日8:00
        if let at8 = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: event.startAt), at8 > Date() {
            let c = baseContent(event: event, subtitle: localized("ReminderToday"))
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: at8)
            let trig = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: event.id.uuidString+"-day", content: c, trigger: trig))
        }

        // 3) 開始1時間前
        let before1h = Calendar.current.date(byAdding: .hour, value: -1, to: event.startAt) ?? event.startAt
        if before1h > Date() {
            let c = baseContent(event: event, subtitle: localized("ReminderOneHour"))
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: before1h)
            let trig = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: event.id.uuidString+"-hour", content: c, trigger: trig))
        }
    }

    static func cancel(for eventID: UUID) {
        let ids = ["-pre","-day","-hour"].map { eventID.uuidString + $0 }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private static func baseContent(event: Event, subtitle: String) -> UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.title = event.title
        c.subtitle = subtitle
        c.body = "\(localized("StartsAt")): \(event.startAt.formatted(date: .abbreviated, time: .shortened))"
        c.sound = .default
        return c
    }
}

private func localized(_ key: String) -> String { NSLocalizedString(key, comment: "") }
