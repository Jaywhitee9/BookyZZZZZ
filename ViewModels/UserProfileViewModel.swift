import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var showEditProfile = false
    @Published var showLogoutAlert = false
    
    init() {
        // Load user from UserDefaults or use default
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        } else {
            self.currentUser = User()
        }
    }
    
    func updateUser(_ user: User) {
        self.currentUser = user
        saveUser()
    }
    
    func updateNotifications(_ enabled: Bool) {
        currentUser.notificationsEnabled = enabled
        saveUser()
    }
    
    func logout() {
        // Clear user data
        UserDefaults.standard.removeObject(forKey: "currentUser")
        // Here you would typically navigate back to login
    }
    
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
}
