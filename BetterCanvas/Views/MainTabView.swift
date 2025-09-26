import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var sidebarManager = SidebarStateManager.shared
    @State private var selectedTab: Tab = .courses
    
    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: Use NavigationSplitView for sidebar support
            if #available(iOS 16.0, *) {
                NavigationSplitView(
                    sidebar: {
                        sidebarContent
                    },
                    detail: {
                        detailContent
                    }
                )
                .navigationSplitViewStyle(.balanced)
            } else {
                // Fallback for older iOS versions
                TabView(selection: $selectedTab) {
                    tabContent
                }
                .accentColor(.primary)
            }
        } else {
            // iPhone: Use TabView
            TabView(selection: $selectedTab) {
                tabContent
            }
            .accentColor(.primary)
        }
        #else
        // macOS: Use TabView
        TabView(selection: $selectedTab) {
            tabContent
        }
        .accentColor(.primary)
        #endif
    }
    
    // MARK: - iPad Sidebar Content
    
    private var sidebarContent: some View {
        List {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    HStack {
                        Image(systemName: tab.icon)
                        Text(tab.rawValue)
                        Spacer()
                        if selectedTab == tab {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .foregroundColor(selectedTab == tab ? .accentColor : .primary)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("BetterCanvas")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    sidebarManager.toggleSidebar()
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    sidebarManager.toggleSidebar()
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            #endif
        }
    }
    
    // MARK: - iPad Detail Content
    
    private var detailContent: some View {
        Group {
            switch selectedTab {
            case .courses:
                CourseListView()
            case .assignments:
                AssignmentListView()
            case .calendar:
                CalendarView()
            case .profile:
                ProfileTab()
            }
        }
        .navigationTitle(selectedTab.rawValue)
    }
    
    // MARK: - Tab Content (iPhone/macOS)
    
    private var tabContent: some View {
        Group {
            CoursesTab()
                .tabItem {
                    Image(systemName: Tab.courses.icon)
                    Text(Tab.courses.rawValue)
                }
                .tag(Tab.courses)
            
            AssignmentsTab()
                .tabItem {
                    Image(systemName: Tab.assignments.icon)
                    Text(Tab.assignments.rawValue)
                }
                .tag(Tab.assignments)
            
            CalendarTab()
                .tabItem {
                    Image(systemName: Tab.calendar.icon)
                    Text(Tab.calendar.rawValue)
                }
                .tag(Tab.calendar)
            
            ProfileTab()
                .tabItem {
                    Image(systemName: Tab.profile.icon)
                    Text(Tab.profile.rawValue)
                }
                .tag(Tab.profile)
        }
    }
}

// MARK: - Tab Views

struct CoursesTab: View {
    var body: some View {
        CourseListView()
    }
}

struct AssignmentsTab: View {
    var body: some View {
        AssignmentListView()
    }
}

struct CalendarTab: View {
    var body: some View {
        CalendarView()
    }
}

struct ProfileTab: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
            VStack(spacing: 20) {
                // User Info Section
                if let user = authManager.currentUser {
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if let email = user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Settings Section
                VStack(spacing: 16) {
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        action: { /* TODO: Implement notifications settings */ }
                    )
                    
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "Sync Settings",
                        action: { /* TODO: Implement sync settings */ }
                    )
                    
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        action: { /* TODO: Implement help */ }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    Task {
                        try? await authManager.logout()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                        Text("Logout")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("Profile")
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}


// MARK: - Supporting Types

enum Tab: String, CaseIterable {
    case courses = "Courses"
    case assignments = "Assignments"
    case calendar = "Calendar"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .courses:
            return "book.fill"
        case .assignments:
            return "doc.text.fill"
        case .calendar:
            return "calendar"
        case .profile:
            return "person.fill"
        }
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
    }
}