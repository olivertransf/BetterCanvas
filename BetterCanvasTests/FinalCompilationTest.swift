import XCTest
import SwiftUI
@testable import BetterCanvas

final class FinalCompilationTest: XCTestCase {
    
    func testAllServicesCanBeCreated() {
        // Test that all core services can be instantiated
        let keychain = KeychainManager()
        XCTAssertNotNil(keychain)
        
        let coreData = CoreDataManager.shared
        XCTAssertNotNil(coreData)
        
        let network = NetworkManager()
        XCTAssertNotNil(network)
        
        let api = CanvasAPIService()
        XCTAssertNotNil(api)
    }
    
    @MainActor
    func testAllViewModelsCanBeCreated() {
        // Test that view models can be instantiated
        let courseListVM = CourseListViewModel()
        XCTAssertNotNil(courseListVM)
        XCTAssertFalse(courseListVM.isLoading)
        
        let authManager = AuthenticationManager()
        XCTAssertNotNil(authManager)
        XCTAssertFalse(authManager.isAuthenticated)
    }
    
    @MainActor
    func testAllViewsCanBeCreated() {
        // Test that SwiftUI views can be instantiated
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
    
    func testModelsCanBeCreated() {
        // Test that all models can be instantiated
        let course = Course(id: "1", name: "Test", courseCode: "TEST")
        XCTAssertEqual(course.id, "1")
        
        let assignment = Assignment(id: "1", name: "Test", courseId: "1")
        XCTAssertEqual(assignment.id, "1")
        
        let user = User(id: "1", name: "Test", email: nil, avatarURL: nil)
        XCTAssertEqual(user.id, "1")
    }
}