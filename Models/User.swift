import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String
    var email: String
    var address: String
    var totalAppointments: Int
    var loyaltyPoints: Int
    var membershipLevel: String
    var notificationsEnabled: Bool
    var profileImageName: String?
    
    init(
        id: UUID = UUID(),
        name: String = "עומר זנו",
        phone: String = "050-1234567",
        email: String = "omer@example.com",
        address: String = "באר שבע",
        totalAppointments: Int = 12,
        loyaltyPoints: Int = 650,
        membershipLevel: String = "VIP",
        notificationsEnabled: Bool = true,
        profileImageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.totalAppointments = totalAppointments
        self.loyaltyPoints = loyaltyPoints
        self.membershipLevel = membershipLevel
        self.notificationsEnabled = notificationsEnabled
        self.profileImageName = profileImageName
    }
}
