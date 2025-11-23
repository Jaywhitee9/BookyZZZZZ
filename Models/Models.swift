import Foundation

// MARK: - Staff & Stories

struct Staff: Identifiable, Codable {
    let id: Int
    let name: String
    let imageName: String
    var socialLinks: SocialLinks?
    var stories: [Story]? // Stories של הספר
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, socialLinks, stories
    }
    
    // האם יש סטוריז חדשים (לא נצפו)
    var hasNewStories: Bool {
        stories?.contains { !$0.isViewed } ?? false
    }
}

struct SocialLinks: Codable {
    var instagram: String?
    var whatsapp: String?
    var facebook: String?
    var tiktok: String?
}

// MARK: - Story

enum StoryMediaType: String, Codable {
    case image
    case video
}

struct Story: Identifiable, Codable {
    let id: String
    let mediaType: StoryMediaType
    let mediaURL: String // URL לתמונה או וידאו
    let thumbnailURL: String? // תמונה ממוזערת לוידאו
    let caption: String? // טקסט על הסטורי
    let createdAt: Date
    var isViewed: Bool = false // האם המשתמש הנוכחי צפה
    var isActive: Bool = true // האם הסטורי פעיל (לא נמחק)
    
    enum CodingKeys: String, CodingKey {
        case id, mediaType, mediaURL, thumbnailURL, caption, createdAt, isActive
    }
    
    // Highlights - הסטורי תמיד תקף עד שהספר מוחק אותו
    var isValid: Bool {
        isActive
    }
}

// MARK: - Service

struct Service: Identifiable, Codable {
    let id = UUID()
    let name: String
    let price: Int
    let duration: Int // in minutes
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case name, price, duration, icon
    }
}

// MARK: - Appointment

enum AppointmentStatus: String, Codable {
    case confirmed
    case completed
    case cancelled
}

struct Appointment: Identifiable, Codable {
    let id: UUID
    let staffId: Int
    let staffName: String
    let serviceName: String
    let price: Int
    let date: Date
    let time: String
    var status: AppointmentStatus
}

struct TimeSlot: Identifiable {
    let id = UUID()
    let time: String
    var isAvailable: Bool
}

// MARK: - Business Settings (CMS)

struct BusinessSettings: Codable {
    var businessName: String
    var logoURL: String
    var heroImageURL: String
    var location: String
    var phoneNumber: String
    var instagramUsername: String?
    var openingHours: [DaySchedule]
    var services: [Service]
    var staffMembers: [Staff]
    var theme: AppTheme
    
    enum CodingKeys: String, CodingKey {
        case businessName, logoURL, heroImageURL, location, phoneNumber
        case instagramUsername, openingHours, services, staffMembers, theme
    }
}

struct DaySchedule: Codable {
    let day: String // "Sunday", "Monday", etc.
    let dayHebrew: String // "ראשון", "שני", etc.
    let isOpen: Bool
    let openTime: String? // "09:00"
    let closeTime: String? // "19:00"
}

struct AppTheme: Codable {
    var primaryColor: String // Hex color
    var secondaryColor: String
    var accentColor: String
    var fontFamily: String
}
