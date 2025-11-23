import SwiftUI

struct BookingFlowView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumBackground.ignoresSafeArea()
                
                VStack {
                    if viewModel.selectedStaff == nil {
                        SelectStaffView(viewModel: viewModel)
                    } else if viewModel.selectedService == nil {
                        SelectServiceView(viewModel: viewModel)
                    } else if viewModel.selectedTime == nil {
                        // Date and Time selection combined or sequential
                        SelectDateView(viewModel: viewModel)
                    } else {
                        // Confirmation or Summary
                        Text("Confirming...")
                            .onAppear {
                                viewModel.bookAppointment()
                                isPresented = false
                            }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if viewModel.selectedTime != nil {
                            viewModel.selectedTime = nil
                        } else if viewModel.selectedService != nil {
                            viewModel.selectedService = nil
                        } else if viewModel.selectedStaff != nil {
                            viewModel.selectedStaff = nil
                        } else {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "arrow.right") // RTL back arrow
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(headerTitle)
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    var headerTitle: String {
        if viewModel.selectedStaff == nil { return "בחירת איש צוות" }
        if viewModel.selectedService == nil { return "בחירת טיפול" }
        if viewModel.selectedTime == nil { return "בחירת תאריך ושעה" }
        return "אישור"
    }
}

struct SelectStaffView: View {
    @ObservedObject var viewModel: BookingViewModel
    
    var body: some View {
        VStack {
            Text("בחרת את LIAM לתספורת ב") // Placeholder text logic
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.staffMembers) { staff in
                        Button(action: { viewModel.selectedStaff = staff }) {
                            HStack {
                                Spacer()
                                Text(staff.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(staff.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct SelectServiceView: View {
    @ObservedObject var viewModel: BookingViewModel
    
    var body: some View {
        VStack {
            Text("בחרת את \(viewModel.selectedStaff?.name ?? "") ל")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.services) { service in
                        Button(action: { viewModel.selectedService = service }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(service.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Image(systemName: "scissors")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("זמן טיפול: \(service.duration) דק׳")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                // Price Tag
                                Text("₪ \(service.price)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct SelectDateView: View {
    @ObservedObject var viewModel: BookingViewModel
    @State private var showTimeSelection = false
    
    var body: some View {
        VStack {
            if !showTimeSelection {
                // Date Selection
                Text("בחרת את \(viewModel.selectedStaff?.name ?? "") ל\(viewModel.selectedService?.name ?? "") ב")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<7) { dayOffset in
                            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
                            let isToday = Calendar.current.isDateInToday(date)
                            let dateString = formatDate(date)
                            
                            Button(action: {
                                viewModel.selectedDate = date
                                showTimeSelection = true
                            }) {
                                HStack {
                                    Text(isToday ? "היום, \(dateString)" : dateString)
                                        .font(.headline)
                                        .foregroundColor(isToday ? .red : .primary)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Time Selection
                SelectTimeView(viewModel: viewModel)
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}

struct SelectTimeView: View {
    @ObservedObject var viewModel: BookingViewModel
    let times = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30"]
    
    var body: some View {
        VStack {
            Text("בחר שעה להזמנה")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(times, id: \.self) { time in
                        Button(action: { viewModel.selectedTime = time }) {
                            Text(time)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                
                // Waitlist Section
                VStack(spacing: 16) {
                    HStack {
                        Text("לא מצאת תור לזמן שלך?")
                        Spacer()
                        Text("חייב תור דחוף?")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Text("כניסה לרשימת המתנה")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.premiumAccent)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                        
                        Button(action: {}) {
                            Text("התורים הקרובים ביותר")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "b08d55")) // Darker gold
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                }
                .padding()
                .padding(.top, 20)
            }
        }
    }
}
