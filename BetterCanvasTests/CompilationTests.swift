import XCTest
@testable import BetterCanvas

final class CompilationTests: XCTestCase {
    
    func testBasicModelCreation() {
        // Test that all models can be created without compilation errors
        
        let course = Course(id: "1", name: "Test Course", courseCode: "TEST101")
        XCTAssertEqual(course.id, "1")
        
        let assignment = Assignment(
            id: "1",
            name: "Test Assignment",
            courseId: "course1",
            pointsPossible: 100.0
        )
        XCTAssertEqual(assignment.id, "1")
        
        let submission = AssignmentSubmissionResponse(
            id: "sub1",
            assignmentId: "assign1",
            courseId: "course1",
            userId: "user1",
            submissionType: "online_text_entry",
            submittedAt: Date(),
            score: 85.0,
            grade: "B",
            attempt: 1,
            body: "Test submission",
            url: nil,
            previewUrl: nil,
            attachments: nil,
            gradedAt: Date(),
            graderComments: nil,
            rubricAssessment: nil,
            submissionComments: nil,
            late: false,
            missing: false,
            excused: false,
            workflowState: "submitted",
            gradingPeriodId: nil,
            gradeMatchesCurrentSubmission: true,
            htmlUrl: "https://example.com",
            secondsLate: 0,
            enteredGrade: "B",
            enteredScore: 85.0,
            cachedDueDate: nil
        )
        XCTAssertEqual(submission.id, "sub1")
        
        let grade = Grade(from: submission)
        XCTAssertEqual(grade.id, "sub1")
    }
    
    func testServiceCreation() {
        // Test that services can be created
        let keychainManager = KeychainManager()
        XCTAssertNotNil(keychainManager)
        
        let networkManager = NetworkManager()
        XCTAssertNotNil(networkManager)
        
        let apiService = CanvasAPIService()
        XCTAssertNotNil(apiService)
        
        let coreDataManager = CoreDataManager()
        XCTAssertNotNil(coreDataManager)
    }
    
    @MainActor
    func testViewModelCreation() {
        // Test that view models can be created
        let courseListViewModel = CourseListViewModel()
        XCTAssertNotNil(courseListViewModel)
        XCTAssertFalse(courseListViewModel.isLoading)
        XCTAssertTrue(courseListViewModel.courses.isEmpty)
    }
}