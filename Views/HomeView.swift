import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Binding var selectedTab: Int

    @State private var showBookingFlow = false
    
    // Animation States
    @State private var animateWelcome = false
    @State private var animateCarousel = false
    @State private var animateAbout = false
    @State private var animateContact = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Hero Image with Gradient Overlay and Parallax Effect
                HomeHeroSection()
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Reduced spacer for Hero visibility
                        // Increased spacer for Hero visibility (restored to show more image)
                        Color.clear.frame(height: 350)
                        
                        // Content Container with Glassmorphism
                        VStack(spacing: 32) {
                            HomeWelcomeSection(showBookingFlow: $showBookingFlow, animateWelcome: $animateWelcome)
                            
                            StaffStoriesCarousel(viewModel: viewModel, showBookingFlow: $showBookingFlow, animateCarousel: $animateCarousel)
                            
                            HomeAboutSection(animateAbout: $animateAbout)
                            
                            HomeContactSection(animateContact: $animateContact)
                            
                            HomeFooterSection()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24) // Minimal bottom padding
                        .background(
                            // Enhanced Glassmorphism background
                            ZStack {
                                // Base white background with more opacity
                                Color.white.opacity(0.75)
                                
                                // Stronger blur effect
                                Rectangle()
                                    .fill(.thinMaterial)
                            }
                        )
                        .cornerRadius(30) // Rounded corners on ALL sides
                        .shadow(color: Color.black.opacity(0.2), radius: 25, x: 0, y: -12)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                // Sticky Header - Black bar from top with logo
                HomeStickyHeader()
            }
            .navigationBarHidden(true)
            .background(Color.black) // Black background for NavigationView
            .sheet(isPresented: $showBookingFlow) {
                BookingFlowView(viewModel: viewModel, isPresented: $showBookingFlow)
                    .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .navigationViewStyle(.stack) // Ensure proper background handling
    }
}

// MARK: - Subviews

struct HomeHeroSection: View {
    var body: some View {
        GeometryReader { geometry in
            let offset = geometry.frame(in: .global).minY
            let scaleFactor = offset > 0 ? 1 + (offset / 800) : 1
            
            ZStack(alignment: .bottom) {
                Image("hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: max(500 + offset, 500)
                    )
                    .scaleEffect(scaleFactor, anchor: .top)
                    .clipped()
                
                // Dark gradient overlay for better text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: max(500 + offset, 500))
                
                // Floating orbs animation (Canvas)
                Canvas { context, size in
                    let orbCount = 6
                    for i in 0..<orbCount {
                        let progress = (Date().timeIntervalSinceReferenceDate + Double(i) * 2).truncatingRemainder(dividingBy: 10) / 10
                        let x = size.width * CGFloat(progress)
                        let y = size.height * CGFloat(sin(progress * .pi * 2) * 0.3 + 0.5)
                        let orb = Path(ellipseIn: CGRect(x: x - 30, y: y - 30, width: 60, height: 60))
                        context.fill(orb, with: .color(Color.white.opacity(0.08)))
                    }
                }
                .ignoresSafeArea()
            }
            .frame(height: max(500 + offset, 500))
        }
        .frame(height: 500)
        .ignoresSafeArea(edges: .top)
    }
}

struct HomeWelcomeSection: View {
    @Binding var showBookingFlow: Bool
    @Binding var animateWelcome: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Greeting (Right)
            VStack(alignment: .leading, spacing: 6) {
                Text("שלום, עומר")
                    .font(Theme.title)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Text(getGreetingByTime())
                    .font(Theme.subtitle)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Button (Left) with enhanced shadow
            Button(action: { showBookingFlow = true }) {
                Text("הזמנת תור")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Color.white.opacity(0.2)
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .opacity(animateWelcome ? 1 : 0)
        .offset(y: animateWelcome ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateWelcome = true
            }
        }
    }
}

struct HomeStaffCarousel: View {
    @ObservedObject var viewModel: BookingViewModel
    @Binding var showBookingFlow: Bool
    @Binding var animateCarousel: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(viewModel.staffMembers) { staff in
                    Button(action: {
                        viewModel.selectedStaff = staff
                        showBookingFlow = true
                    }) {
                        VStack(spacing: 8) {
                            Image(staff.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text(staff.name)
                                .font(Theme.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .opacity(animateCarousel ? 1 : 0)
        .offset(y: animateCarousel ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateCarousel = true
            }
        }
    }
}

struct HomeAboutSection: View {
    @Binding var animateAbout: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("הכירו אותנו")
                    .font(Theme.title)
                    .foregroundColor(Theme.textPrimary.opacity(0.9))
                Spacer()
                Text("הצגה")
                    .font(Theme.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            // About Card with enhanced styling
            ZStack(alignment: .bottom) {
                Image("hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                // Gradient overlay for card
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                VStack(spacing: 0) {
                    // Logo Badge with better shadow
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                        Text("515")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                    .offset(y: -35)
                    .padding(.bottom, 20)
                    
                    Text("הכירו את 515 | BRAVENCE ב-BRAVENCE אנחנו לא רק מספרה - אנחנו בית ליצירתיות, סגנון, ואנשים שלא מתפשרים על פחות ממושלם.")
                        .font(Theme.subtitle)
                        .foregroundColor(Theme.textPrimary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .lineLimit(5)
                }
                .background(Color.white)
            }
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 10)
        }
        .padding(.horizontal, 20)
        .opacity(animateAbout ? 1 : 0)
        .offset(y: animateAbout ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                animateAbout = true
            }
        }
    }
}

struct HomeContactSection: View {
    @Binding var animateContact: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("דברו איתנו")
                .font(Theme.title)
                .foregroundColor(Theme.textPrimary.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Contact Card with enhanced styling
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "f8f8f8"))
                        .frame(width: 70, height: 70)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    Text("515")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.top, 8)
                
                Text("באר שבע")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 10)
        }
        .padding(.horizontal, 20)
        .opacity(animateContact ? 1 : 0)
        .offset(y: animateContact ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                animateContact = true
            }
        }
    }
}

struct HomeFooterSection: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text("מדיניות פרטיות")
                Text("|")
                Text("תנאי שימוש")
            }
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "999999"))
            .padding(.top, 12)
            
            // Availability
            HStack(spacing: 6) {
                Image(systemName: "clock")
                .font(.system(size: 12))
                Text("זמין בקרוב")
                .font(.system(size: 13))
            }
            .foregroundColor(Color(hex: "777777"))
            .padding(.bottom, 20)
            
            // Credit Section
            VStack(spacing: 8) {
                Image("oz_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                
                Text("פותח ע״י עומר זנו")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.black.opacity(0.4))
            }
            .padding(.bottom, 32)
        }
    }
}

struct HomeStickyHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Black background extending to safe area
                Color.black
                    .ignoresSafeArea(edges: .top)
                
                // Logo centered
                Text("BOOKYZ")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .tracking(5)
                    .foregroundColor(.white)
            }
            .frame(height: 60)
            
            Spacer()
        }
        .zIndex(100)
    }
}
