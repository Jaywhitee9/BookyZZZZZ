import SwiftUI

@main
struct omerv3App: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.layoutDirection, .rightToLeft) // Force RTL globally
        }
    }
}
