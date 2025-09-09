import Foundation
import SwiftUI

struct Oshi: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var colorHex: String
    var logoImageID: String?
    var tags: [String] = []

    var color: Color { Color(hex: colorHex) ?? .accentColor }
}

