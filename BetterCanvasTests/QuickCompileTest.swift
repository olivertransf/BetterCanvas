import XCTest
@testable import BetterCanvas

final class QuickCompileTest: XCTestCase {
    
    func testBasicInstantiation() {
        // Test that basic services can be created
        let keychain = KeychainManager.shared
        XCTAssertNotNil(keychain)
        
        let coreData = CoreDataManager.shared
        XCTAssertNotNil(coreData)
        
        let auth = AuthenticationManager()
        XCTAssertNotNil(auth)
        XCTAssertFalse(auth.isAuthenticated)
    }
    
    @MainActor
    func testViewModelInstantiation() {
        let viewModel = CourseListViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.courses.isEmpty)
    }
    
    func testModelInstantiation() {
        let course = Course(id: "1", name: "Test Course", courseCode: "TEST")
        XCTAssertEqual(course.id, "1")
        XCTAssertEqual(course.name, "Test Course")
        XCTAssertTrue(course.isActive)
        
        let assignment = Assignment(id: "1", name: "Test Assignment", courseId: "1")
        XCTAssertEqual(assignment.id, "1")
        XCTAssertEqual(assignment.name, "Test Assignment")
        
        let user = User(id: "1", name: "Test User", email: "test@example.com", avatarURL: nil)
        XCTAssertEqual(user.id, "1")
        XCTAssertEqual(user.name, "Test User")
    }
}