import SwiftUI

struct AppointmentsView: View {
    @ObservedObject var viewModel: BookingViewModel
    
    @State private var animateStats = false
    @State private var animateCards = false
    
    // גובה ה-Hero כמו בדף הבית
    private let heroSpacerHeight: CGFloat = 350
    
    // חישוב סטטיסטיקות
    private var activeAppointments: Int {
        viewModel.appointments.filter { $0.status == .confirmed && $0.date >= Date() }.count
    }
    
    private var completedAppointments: Int {
        viewModel.appointments.filter { $0.status == .completed }.count
    }
    
    private var cancelledAppointments: Int {
        viewModel.appointments.filter { $0.status == .cancelled }.count
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Hero Section כמו בדף הבית
            HomeHeroSection()
            
            // ScrollView עם תוכן
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Spacer לראייה של ה-Hero
                    Color.clear.frame(height: heroSpacerHeight)
                    
                    // כרטיס התוכן עם glassmorphism
                    VStack(spacing: 32) {
                        // כותרת
                        appointmentsHeader
                        
                        // סטטיסטיקות
                        statsSection
                        
                        // רשימת התורים
                        appointmentsList
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: UIScreen.main.bounds.height - heroSpacerHeight,
                        alignment: .top
                    )
                    .padding(.bottom, 24)
                    .background(
                        ZStack {
                            Color.white.opacity(0.75)
                            Rectangle().fill(.thinMaterial)
                        }
                    )
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.2), radius: 25, x: 0, y: -12)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            
            // Header צף
            HomeStickyHeader()
        }
        .navigationBarHidden(true)
        .background(Color.black)
    }
    
    // MARK: - כותרת
    
    private var appointmentsHeader: some View {
        VStack(spacing: 10) {
            Text("BRAVENCE")
                .font(.system(size: 11, weight: .regular, design: .serif))
                .tracking(4)
                .foregroundColor(Color.gray.opacity(0.6))
            
            Text("התורים שלי")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.top, 32)
    }
    
    // MARK: - סטטיסטיקות
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("סטטיסטיקת הגעה")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            HStack(spacing: 20) {
                AppointmentStatCard(
                    number: activeAppointments,
                    label: "התור שלי",
                    color: Color(hex: "4CAF50")
                )
                
                AppointmentStatCard(
                    number: completedAppointments,
                    label: "הגעתי בזמן",
                    color: Color(hex: "2196F3")
                )
                
                AppointmentStatCard(
                    number: cancelledAppointments,
                    label: "ביטול/מאוחר",
                    color: Color(hex: "FF5252")
                )
            }
            .padding(.horizontal, 20)
        }
        .opacity(animateStats ? 1 : 0)
        .offset(y: animateStats ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateStats = true
            }
        }
    }
    
    // MARK: - רשימת תורים
    
    private var appointmentsList: some View {
        VStack(spacing: 0) {
            if viewModel.appointments.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(viewModel.appointments.enumerated()), id: \.element.id) { index, appointment in
                        AppointmentCard(
                            appointment: appointment,
                            viewModel: viewModel
                        )
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateCards)
                    }
                }
                .padding(.horizontal, 20)
                .onAppear {
                    animateCards = true
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("אין תורים מתוזמנים")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Text("לחץ על 'הזמנת תור' כדי לקבוע תור חדש")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - כרטיס סטטיסטיקה

struct AppointmentStatCard: View {
    let number: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - כרטיס תור

struct AppointmentCard: View {
    let appointment: Appointment
    @ObservedObject var viewModel: BookingViewModel
    
    // צבע רקע לפי סטטוס
    private var cardBackgroundColor: Color {
        switch appointment.status {
        case .confirmed:
            return appointment.date >= Date() ? Color(hex: "E8F5E9") : Color(hex: "F5F5F5")
        case .completed:
            return Color(hex: "E3F2FD")
        case .cancelled:
            return Color(hex: "FFEBEE")
        }
    }
    
    // מציאת הספר
    private var staff: Staff? {
        viewModel.staffMembers.first { $0.id == appointment.staffId }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // שורה עליונה: תמונה + שם + סטטוס
            HStack(spacing: 12) {
                Spacer()
                
                // שם הטיפול
                VStack(alignment: .trailing, spacing: 4) {
                    Text(appointment.serviceName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 6) {
                        Text(appointment.staffName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
                
                // תמונת הספר
                if let staff = staff {
                    Image(staff.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            
            Divider()
                .background(Color.black.opacity(0.1))
            
            // פרטי התור
            VStack(spacing: 12) {
                // מיקום
                HStack(spacing: 8) {
                    Spacer()
                    Text("באר שבע, ס׳")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.5))
                }
                
                // תאריך ושעה
                HStack(spacing: 8) {
                    Spacer()
                    Text("\(formatDate(appointment.date)), \(appointment.time)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            
            // סטטוס התור
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Text(statusText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(statusColor)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 12))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.15))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var statusText: String {
        switch appointment.status {
        case .confirmed:
            return appointment.date >= Date() ? "מאושר" : "הסתיים"
        case .completed:
            return "הושלם"
        case .cancelled:
            return "בוטל"
        }
    }
    
    private var statusColor: Color {
        switch appointment.status {
        case .confirmed:
            return appointment.date >= Date() ? Color(hex: "4CAF50") : Color.gray
        case .completed:
            return Color(hex: "2196F3")
        case .cancelled:
            return Color(hex: "FF5252")
        }
    }
    
    private var statusIcon: String {
        switch appointment.status {
        case .confirmed:
            return "checkmark.circle.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "he_IL")
        formatter.dateFormat = "dd/MM/yy, EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - תצוגה ריקה (לא בשימוש כרגע אבל נשאיר לעתיד)

struct BookingHistoryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumBackground
                Text("היסטוריית הזמנות")
            }
            .navigationTitle("הזמנות")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
