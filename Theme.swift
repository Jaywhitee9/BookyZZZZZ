import SwiftUI

// MARK: - Theme Design System

struct Theme {
    // MARK: Colors
    static let primary = Color(hex: "0A84FF") // example brand blue
    static let secondary = Color(hex: "FF9500") // orange accent
    static let background = Color.white
    static let surface = Color(hex: "F5F5F5")
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color.gray
    static let glass = Color.white.opacity(0.15)
    
    // MARK: Typography (using system fonts, can replace with Google Fonts later)
    static let title = Font.system(size: 24, weight: .bold)
    static let subtitle = Font.system(size: 14, weight: .regular)
    static let button = Font.system(size: 15, weight: .semibold)
    static let caption = Font.system(size: 12, weight: .regular)
    
    // MARK: Spacing & Corner Radius
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 20
    static let smallPadding: CGFloat = 12
}

// Helper to create Color from hex string (already exists elsewhere, but kept for safety)
extension Color {
    // Legacy Premium Colors (kept for compatibility)
    static let premiumBackground = Color(hex: "f5f5f5")
    static let premiumDark = Color(hex: "0a0a0a")
    static let premiumSurface = Color.white
    static let premiumAccent = Color(hex: "c9a66b")
    static let premiumTextPrimary = Color(hex: "1a1a1a")
    static let premiumTextSecondary = Color(hex: "666666")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

func getGreetingByTime() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 12 { return "זמן לקפה ובוקר מצוין!" }
    if hour < 18 { return "צהריים טובים! קח הפסקה קצרה :)" }
    return "ערב נעים! זמן להירגע ולהתפנק"
}
