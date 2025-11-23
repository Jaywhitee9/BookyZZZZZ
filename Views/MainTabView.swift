import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = BookingViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global Black Background
            Color.black.ignoresSafeArea()
            
            // Content Area
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                    .tag(0)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }
                
                TeamView(viewModel: viewModel)
                    .tag(1)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }
                
                AppointmentsView(viewModel: viewModel)
                    .tag(2)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }
                
                ProfileView(selectedTab: $selectedTab)
                    .tag(3)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 20)
                    }
                

            }
            .environment(\.layoutDirection, .rightToLeft)
            .toolbar(.hidden, for: .tabBar)
            
            // Bottom Navigation Bar - Overlay
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {

            TabBarButton(imageName: "person", text: "פרופיל", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            TabBarButton(imageName: "doc.text", text: "תורים", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            TabBarButton(imageName: "person.3", text: "הצוות", isSelected: selectedTab == 1, activeColor: .blue) {
                selectedTab = 1
            }
            TabBarButton(imageName: "house", text: "לובי", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 2)
        .background(
            Color.black
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let imageName: String
    let text: String
    let isSelected: Bool
    var activeColor: Color = .white // Default active color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? imageName + ".fill" : imageName)
                    .font(.system(size: 22))
                Text(text)
                    .font(.caption2)
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .foregroundColor(isSelected ? activeColor : .gray)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}
