import SwiftUI

// MARK: - Staff Stories Carousel (במקום הקרוסלה הרגילה)

struct StaffStoriesCarousel: View {
    @ObservedObject var viewModel: BookingViewModel
    @Binding var showBookingFlow: Bool
    @Binding var animateCarousel: Bool
    @State private var selectedStaff: Staff?
    @State private var showStoryViewer = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // כותרת
            Text("עדכונים מהצוות")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 20)
            
            // סקרול אופקי של הספרים
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(viewModel.staffMembers) { staff in
                        StoryCircle(
                            staff: staff,
                            onTap: {
                                selectedStaff = staff
                                if hasValidStories(staff) {
                                    showStoryViewer = true
                                } else {
                                    // אם אין סטוריז, פשוט פותח את תהליך ההזמנה
                                    viewModel.selectedStaff = staff
                                    showBookingFlow = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .opacity(animateCarousel ? 1 : 0)
        .offset(y: animateCarousel ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateCarousel = true
            }
        }
        .fullScreenCover(isPresented: $showStoryViewer) {
            if let staff = selectedStaff {
                StoryViewer(
                    staff: staff,
                    isPresented: $showStoryViewer,
                    onBookAppointment: {
                        showStoryViewer = false
                        viewModel.selectedStaff = staff
                        showBookingFlow = true
                    }
                )
            }
        }
    }
    
    private func hasValidStories(_ staff: Staff) -> Bool {
        staff.stories?.contains { $0.isValid } ?? false
    }
}

// MARK: - Story Circle (עיגול של ספר עם Stories)

struct StoryCircle: View {
    let staff: Staff
    let onTap: () -> Void
    
    private var hasNewStories: Bool {
        staff.stories?.contains { $0.isValid && !$0.isViewed } ?? false
    }
    
    private var hasStories: Bool {
        staff.stories?.contains { $0.isValid } ?? false
    }
    
    var body: some View {
        Button(action: {
            print("🔵 Tapped on staff: \(staff.name)")
            print("🔵 Has stories: \(hasStories)")
            print("🔵 Has new stories: \(hasNewStories)")
            if let stories = staff.stories {
                print("🔵 Stories count: \(stories.count)")
                print("🔵 Valid stories: \(stories.filter { $0.isValid }.count)")
            }
            onTap()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // טבעת צבעונית אם יש סטוריז חדשים
                    if hasNewStories {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "FF6B6B"),
                                        Color(hex: "FFA06B"),
                                        Color(hex: "FFD06B")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 82, height: 82)
                    } else if hasStories {
                        // טבעת אפורה אם כל הסטוריז נצפו
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 82, height: 82)
                    }
                    
                    // תמונת הספר
                    Image(staff.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                
                Text(staff.name)
                    .font(.system(size: 13, weight: hasNewStories ? .semibold : .medium))
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Story Viewer (תצוגת סטוריז במסך מלא)

struct StoryViewer: View {
    let staff: Staff
    @Binding var isPresented: Bool
    let onBookAppointment: () -> Void
    
    var body: some View {
        ZStack {
            // רקע שחור
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // כפתור סגירה
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // תוכן
                VStack(spacing: 20) {
                    // עיגול צבעוני במקום תמונה
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue, .cyan]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Text(String(staff.name.prefix(2)))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(staff.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("דף סטוריז")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // הודעה
                    VStack(spacing: 12) {
                        Text("✨")
                            .font(.system(size: 60))
                        
                        Text("הסטוריז עובדים!")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("זה רק גרסת בדיקה")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(30)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // כפתור קבע תור
                Button(action: {
                    onBookAppointment()
                }) {
                    Text("קבע תור עם \(staff.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            print("✅✅✅ StoryViewer DID APPEAR for \(staff.name)")
        }
    }
}

