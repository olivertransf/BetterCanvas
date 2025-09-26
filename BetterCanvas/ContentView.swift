import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainAppView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            // Check for existing authentication when app launches
            Task {
                try? await authManager.validateStoredToken()
            }
        }
    }
}

// Main app content with tab navigation
struct MainAppView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
}
