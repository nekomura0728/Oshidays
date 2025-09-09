import Foundation
import Combine
import WidgetKit

final class DataStore: ObservableObject {
    @Published private(set) var oshis: [Oshi] = []
    @Published private(set) var events: [Event] = []

    static let shared = DataStore()

    private let queue = DispatchQueue(label: "DataStore")

    private init() {
        load()
    }

    // MARK: - Public API
    func allOshis() -> [Oshi] { oshis }
    func allEvents() -> [Event] { events }

    func upsert(oshi: Oshi) {
        if let idx = oshis.firstIndex(where: { $0.id == oshi.id }) {
            oshis[idx] = oshi
        } else {
            oshis.append(oshi)
        }
        saveAndReload()
    }

    func deleteOshi(id: UUID) {
        oshis.removeAll { $0.id == id }
        events.removeAll { $0.oshiID == id }
        saveAndReload()
    }

    func upsert(event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            events[idx] = event
        } else {
            events.append(event)
        }
        saveAndReload()
    }

    func deleteEvent(id: UUID) {
        events.removeAll { $0.id == id }
        saveAndReload()
    }

    // MARK: - Persistence
    private func saveAndReload() {
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func save() {
        queue.async {
            do {
                let state = AppState(oshis: self.oshis, events: self.events)
                let data = try JSONEncoder().encode(state)
                let url = Self.storeURL()
                let dir = url.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                try data.write(to: url, options: .atomic)
            } catch {
                print("[DataStore] save error: \(error)")
            }
        }
    }

    func load() {
        queue.async {
            do {
                let url = Self.storeURL()
                guard FileManager.default.fileExists(atPath: url.path) else { return }
                let data = try Data(contentsOf: url)
                let state = try JSONDecoder().decode(AppState.self, from: data)
                DispatchQueue.main.async {
                    self.oshis = state.oshis
                    self.events = state.events
                }
            } catch {
                print("[DataStore] load error: \(error)")
            }
        }
    }

    static func storeURL() -> URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupId) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return container.appendingPathComponent(AppConstants.storeFileName)
    }
}

