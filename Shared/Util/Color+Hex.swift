import SwiftUI

extension Color {
    init?(hex: String) {
        let r, g, b, a: CGFloat
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        switch hexColor.count {
        case 8:
            r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00FF) / 255
        case 6:
            r = CGFloat((hexNumber & 0xFF00_00) >> 16) / 255
            g = CGFloat((hexNumber & 0x00FF_00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000_FF) / 255
            a = 1
        default:
            return nil
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        switch hexColor.count {
        case 8:
            self.init(
                red: CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255,
                green: CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255,
                blue: CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255,
                alpha: CGFloat(hexNumber & 0x0000_00FF) / 255
            )
        case 6:
            self.init(
                red: CGFloat((hexNumber & 0xFF00_00) >> 16) / 255,
                green: CGFloat((hexNumber & 0x00FF_00) >> 8) / 255,
                blue: CGFloat((hexNumber & 0x0000_FF) >> 0) / 255,
                alpha: 1
            )
        default:
            return nil
        }
    }
}

extension Color {
    func toHex(alpha: Bool = false) -> String? {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        if alpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255)),
                lroundf(Float(a * 255))
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255))
            )
        }
        #else
        return nil
        #endif
    }
}

