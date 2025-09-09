import Foundation

enum EventType: String, Codable, CaseIterable, Identifiable {
    case live
    case release
    case stream
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .live: return NSLocalizedString("Live", comment: "")
        case .release: return NSLocalizedString("Release", comment: "")
        case .stream: return NSLocalizedString("Stream", comment: "")
        }
    }
}

struct Event: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var type: EventType
    var startAt: Date
    var endAt: Date?
    var venue: String?
    var memo: String?
    var imageID: String?
    var oshiID: UUID
    var pinned: Bool = false

    var isPast: Bool { startAt < Date() }
}

struct AppState: Codable {
    var oshis: [Oshi]
    var events: [Event]
}
