import SwiftUI

struct TeamView: View {
    @ObservedObject var viewModel: BookingViewModel
    @State private var animateContent = false

    // זהה לגובה ה־Spacer שיש בעמוד הבית (350)
    private let heroSpacerHeight: CGFloat = 350

    var body: some View {
        ZStack(alignment: .top) {
            // Hero כמו בדף הבית
            HomeHeroSection()

            // ScrollView כמו בעמוד הבית, רק עם כרטיס צוות
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // אותו Spacer כמו ב-HomeView כדי שהכרטיס יישב על ההירו
                    Color.clear.frame(height: heroSpacerHeight)

                    teamCard
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
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.6)) {
                                animateContent = true
                            }
                        }
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            // Header צף כמו בדף הבית
            HomeStickyHeader()
        }
    }

    // MARK: - כרטיס הצוות

    private var teamCard: some View {
        VStack(spacing: 20) {

            // כותרת
            VStack(spacing: 10) {
                Text("BRAVENCE TEAM")
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .tracking(4)
                    .foregroundColor(Color.gray.opacity(0.6))

                Text("הצוות שלנו")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 24)

            // רשימת אנשי צוות
            VStack(spacing: 16) {
                ForEach(viewModel.staffMembers) { staff in
                    StaffRow(staff: staff)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Spacer דוחף את הפוטר למטה אם יש מעט אנשי צוות
            Spacer(minLength: 0)

            // פוטר
            VStack(spacing: 4) {
                Image("oz_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 14)

                Text("פותח ע״י עומר זנו")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.35))
            }
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - שורת איש צוות

struct StaffRow: View {
    let staff: Staff
    @State private var isExpanded = false

    var body: some View {
        HStack(spacing: 16) {
            // צד ימין (ב־RTL): תמונה + שם (תמונה נעלמת כשמורחבים)
            HStack(spacing: 12) {
                if !isExpanded {
                    Image(staff.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                }

                Text(staff.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()

            // צד שמאל (ב־RTL): כפתור "החלק לפרטים" / אייקוני סושיאל
            ZStack(alignment: .leading) {
                if isExpanded {
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring()) {
                                isExpanded = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }

                        if let _ = staff.socialLinks?.tiktok {
                            SocialButton(icon: "music.note", url: "tiktok://")
                        }
                        if let _ = staff.socialLinks?.facebook {
                            SocialButton(icon: "hand.thumbsup.fill", url: "fb://profile")
                        }
                        if let whatsapp = staff.socialLinks?.whatsapp {
                            SocialButton(icon: "phone.fill", url: "https://wa.me/\(whatsapp)")
                        }
                        if let instagram = staff.socialLinks?.instagram {
                            SocialButton(icon: "camera.fill", url: "instagram://user?username=\(instagram)")
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Button(action: {
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    }) {
                        Text("החלק לפרטים")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .environment(\.layoutDirection, .rightToLeft) // RTL בפנים
    }
}

// MARK: - כפתור סושיאל

struct SocialButton: View {
    let icon: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.black)
                .clipShape(Circle())
        }
    }
}
