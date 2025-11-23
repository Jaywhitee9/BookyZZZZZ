import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Clean White Background
            Color.white.ignoresSafeArea()
            
            // Main Content - NO ScrollView, just VStack
            VStack(spacing: 0) {
                // Profile Header Section
                VStack(spacing: 16) {
                    // Avatar with glow effect
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Text(String(viewModel.currentUser.name.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Edit indicator
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            )
                            .offset(x: 35, y: 35)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 80)
                    
                    // Name and status
                    VStack(spacing: 4) {
                        Text(viewModel.currentUser.name)
                            .font(Theme.title)
                            .foregroundColor(Theme.textPrimary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("חבר פעיל")
                                .font(Theme.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Stats Cards
                HStack(spacing: 12) {
                    StatCard(
                        number: "\(viewModel.currentUser.totalAppointments)",
                        label: "תורים",
                        icon: "calendar.badge.checkmark",
                        color: .blue
                    )
                    StatCard(
                        number: "\(viewModel.currentUser.loyaltyPoints)",
                        label: "נקודות",
                        icon: "star.fill",
                        color: .yellow
                    )
                    StatCard(
                        number: viewModel.currentUser.membershipLevel,
                        label: "רמה",
                        icon: "crown.fill",
                        color: .purple
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // Quick Actions - Scrollable section
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Quick Action: New Appointment
                        QuickActionButton(
                            icon: "calendar.badge.plus",
                            title: "הזמן תור חדש",
                            subtitle: "הספר שלך פנוי היום",
                            color: .blue
                        ) {
                            selectedTab = 0 // Navigate to Home
                        }
                        
                        // Quick Action: Favorites
                        QuickActionButton(
                            icon: "heart.fill",
                            title: "המועדפים שלי",
                            subtitle: "\(viewModel.currentUser.totalAppointments) תורים",
                            color: .red
                        ) {
                            selectedTab = 1 // Navigate to Team
                        }
                        
                        // Personal Info Cards
                        VStack(spacing: 12) {
                            InfoCard(
                                icon: "phone.fill",
                                label: "טלפון",
                                value: viewModel.currentUser.phone,
                                color: .green
                            ) {
                                if let url = URL(string: "tel://\(viewModel.currentUser.phone)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            InfoCard(
                                icon: "envelope.fill",
                                label: "אימייל",
                                value: viewModel.currentUser.email,
                                color: .blue
                            ) {
                                if let url = URL(string: "mailto:\(viewModel.currentUser.email)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            InfoCard(
                                icon: "mappin.circle.fill",
                                label: "כתובת",
                                value: viewModel.currentUser.address,
                                color: .orange
                            ) {
                                // Could open maps
                            }
                        }
                        .padding(.top, 8)
                        
                        // Preferences
                        PreferenceToggle(
                            icon: "bell.fill",
                            title: "התראות",
                            subtitle: "קבל עדכונים על תורים",
                            isOn: viewModel.currentUser.notificationsEnabled
                        ) { enabled in
                            viewModel.updateNotifications(enabled)
                        }
                        
                        // Logout Button
                        Button(action: {
                            viewModel.showLogoutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("התנתק")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            // Sticky Header with Logo
            VStack(spacing: 0) {
                ZStack {
                    Color.black
                        .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        Spacer()
                        Text("BOOKYZ")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .tracking(5)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .frame(height: 60)
                
                Spacer()
            }
            .zIndex(100)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .alert("התנתקות", isPresented: $viewModel.showLogoutAlert) {
            Button("ביטול", role: .cancel) { }
            Button("התנתק", role: .destructive) {
                viewModel.logout()
                // Navigate to login screen
            }
        } message: {
            Text("האם אתה בטוח שברצונך להתנתק?")
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let number: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(hex: "f5f5f5"))
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.title.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(hex: "f5f5f5"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
    }
}

struct InfoCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "1a1a1a"))
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(Color(hex: "f5f5f5"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

struct PreferenceToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    let isOn: Bool
    let onToggle: (Bool) -> Void
    
    @State private var toggleState: Bool
    
    init(icon: String, title: String, subtitle: String, isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
        self.onToggle = onToggle
        self._toggleState = State(initialValue: isOn)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "1a1a1a"))
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $toggleState)
                .labelsHidden()
                .onChange(of: toggleState) { _, newValue in
                    onToggle(newValue)
                }
        }
        .padding()
        .background(Color(hex: "f5f5f5"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
