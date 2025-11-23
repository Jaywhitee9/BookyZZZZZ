import Foundation
import SwiftUI

class BookingViewModel: ObservableObject {
    @Published var staffMembers: [Staff] = []
    @Published var services: [Service] = []
    @Published var appointments: [Appointment] = []
    
    // Booking Flow State
    @Published var selectedStaff: Staff?
    @Published var selectedService: Service?
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: String?
    
    init() {
        loadMockData()
    }
    
    func loadMockData() {
        // יצירת סטוריז דמו - Highlights קבועים
        let now = Date()
        
        let liamStories = [
            Story(
                id: "liam_1",
                mediaType: .image,
                mediaURL: "barber1",
                thumbnailURL: nil,
                caption: "תספורת חדשה שעשיתי היום! 💈✨",
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: now)!,
                isViewed: false,
                isActive: true
            ),
            Story(
                id: "liam_2",
                mediaType: .image,
                mediaURL: "barber1",
                thumbnailURL: nil,
                caption: "מחכה לכם במספרה! קבעו תור 🔥",
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now)!,
                isViewed: false,
                isActive: true
            )
        ]
        
        let yaronStories = [
            Story(
                id: "yaron_1",
                mediaType: .image,
                mediaURL: "barber2",
                thumbnailURL: nil,
                caption: "סגנון חדש לשבוע הזה 💇‍♂️",
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: now)!,
                isViewed: false,
                isActive: true
            )
        ]
        
        let amirStories = [
            Story(
                id: "amir_1",
                mediaType: .image,
                mediaURL: "barber3",
                thumbnailURL: nil,
                caption: "תספורת פרימיום ⭐",
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: now)!,
                isViewed: false,
                isActive: true
            ),
            Story(
                id: "amir_2",
                mediaType: .image,
                mediaURL: "barber3",
                thumbnailURL: nil,
                caption: "עבודות מהשבוע האחרון 🔥",
                createdAt: Calendar.current.date(byAdding: .hour, value: -12, to: now)!,
                isViewed: false,
                isActive: true
            )
        ]
        
        staffMembers = [
            Staff(
                id: 1,
                name: "LIAM",
                imageName: "barber1",
                socialLinks: SocialLinks(instagram: "liam_barber", whatsapp: "0500000000", facebook: nil, tiktok: "liamcuts"),
                stories: liamStories
            ),
            Staff(
                id: 2,
                name: "ירון",
                imageName: "barber2",
                socialLinks: SocialLinks(instagram: "yaron_style", whatsapp: "0500000001", facebook: "Yaron Barber", tiktok: nil),
                stories: yaronStories
            ),
            Staff(
                id: 3,
                name: "אמיר",
                imageName: "barber3",
                socialLinks: SocialLinks(instagram: "amir_cuts", whatsapp: "0500000002", facebook: nil, tiktok: nil),
                stories: amirStories
            ),
            Staff(
                id: 4,
                name: "עמית",
                imageName: "barber4",
                socialLinks: SocialLinks(instagram: "amit_hair", whatsapp: "0500000003", facebook: nil, tiktok: "amit_tok"),
                stories: nil // אין סטוריז
            ),
            Staff(
                id: 5,
                name: "קווין",
                imageName: "barber5",
                socialLinks: SocialLinks(instagram: nil, whatsapp: "0500000004", facebook: nil, tiktok: nil),
                stories: nil // אין סטוריז
            )
        ]
        
        services = [
            Service(name: "תספורת", price: 80, duration: 20, icon: "scissors"),
            Service(name: "תספורת וזקן", price: 90, duration: 20, icon: "mustache"),
            Service(name: "All Scissors", price: 120, duration: 30, icon: "scissors"),
            Service(name: "פרימיום (תור כפול)", price: 170, duration: 40, icon: "crown")
        ]
    }
    
    func bookAppointment() {
        guard let staff = selectedStaff,
              let service = selectedService,
              let time = selectedTime else { return }
        
        let newAppointment = Appointment(
            id: UUID(),
            staffId: staff.id,
            staffName: staff.name,
            serviceName: service.name,
            price: service.price,
            date: selectedDate,
            time: time,
            status: .confirmed
        )
        
        appointments.append(newAppointment)
        
        // Reset flow
        resetBooking()
    }
    
    func resetBooking() {
        selectedStaff = nil
        selectedService = nil
        selectedTime = nil
        // Keep date as is or reset to today
    }
    
    func getAvailableTimes() -> [String] {
        return [
            "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
            "12:00", "12:30", "13:00", "13:30", "14:00", "14:30"
        ]
    }
}
