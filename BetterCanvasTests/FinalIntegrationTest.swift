import XCTest
import SwiftUI
@testable import BetterCanvas

final class FinalIntegrationTest: XCTestCase {
    
    func testCompleteAppFlow() {
        // Test that the entire app can be instantiated without errors
        
        // 1. Test Core Services
        let keychain = KeychainManager()
        XCTAssertNotNil(keychain)
        
        let coreData = CoreDataManager.shared
        XCTAssertNotNil(coreData)
        
        let network = NetworkManager()
        XCTAssertNotNil(network)
        
        let api = CanvasAPIService()
        XCTAssertNotNil(api)
        
        // 2. Test Authentication
        let auth = AuthenticationManager()
        XCTAssertNotNil(auth)
        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertNil(auth.currentUser)
        
        // 3. Test Data Sync
        let sync = DataSyncManager()
        XCTAssertNotNil(sync)
        XCTAssertFalse(sync.isSyncing)
    }
    
    @MainActor
    func testViewModelIntegration() {
        // Test that view models work correctly
        let courseListVM = CourseListViewModel()
        XCTAssertNotNil(courseListVM)
        XCTAssertFalse(courseListVM.isLoading)
        XCTAssertTrue(courseListVM.courses.isEmpty)
        XCTAssertTrue(courseListVM.searchText.isEmpty)
    }
    
    @MainActor
    func testUIIntegration() {
        // Test that UI components can be created
        let authManager = AuthenticationManager()
        
        let contentView = ContentView()
            .environmentObject(authManager)
        XCTAssertNotNil(contentView)
        
        let loginView = LoginView()
            .environmentObject(authManager)
        XCTAssertNotNil(loginView)
        
        let mainTabView = MainTabView()
            .environmentObject(authManager)
        XCTAssertNotNil(mainTabView)
        
        let courseListView = CourseListView()
        XCTAssertNotNil(courseListView)
    }
    
    func testModelIntegration() {
        // Test that models work correctly together
        let course = Course(id: "course1", name: "Introduction to Swift", courseCode: "SWIFT101")
        XCTAssertEqual(course.displayName, "SWIFT101: Introduction to Swift")
        XCTAssertTrue(course.isActive)
        XCTAssertFalse(course.isStudent) // No enrollments
        
        let assignment = Assignment(
            id: "assign1",
            name: "Swift Basics",
            courseId: "course1",
            dueAt: Date().addingTimeInterval(86400), // Tomorrow
            pointsPossible: 100.0
        )
        XCTAssertTrue(assignment.isDueSoon)
        XCTAssertFalse(assignment.isOverdue)
        XCTAssertEqual(assignment.submissionStatus, .notSubmitted)
        
        let user = User(id: "user1", name: "John Doe", email: "john@example.com", avatarURL: nil)
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
    }
    
    func testDataPersistence() {
        // Test that Core Data models can be created
        let coreDataManager = CoreDataManager()
        XCTAssertNotNil(coreDataManager.viewContext)
        XCTAssertNotNil(coreDataManager.backgroundContext)
        
        // Test that we can create entities
        let context = coreDataManager.viewContext
        let courseEntity = CourseEntity(context: context)
        courseEntity.id = "test"
        courseEntity.name = "Test Course"
        
        XCTAssertEqual(courseEntity.id, "test")
        XCTAssertEqual(courseEntity.name, "Test Course")
    }
}