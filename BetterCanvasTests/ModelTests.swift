import XCTest
@testable import BetterCanvas

final class ModelTests: XCTestCase {
    
    func testAssignmentCreation() {
        // Test that Assignment can be created without recursive issues
        let assignment = Assignment(
            id: "1",
            name: "Test Assignment",
            courseId: "course1",
            pointsPossible: 100.0
        )
        
        XCTAssertEqual(assignment.id, "1")
        XCTAssertEqual(assignment.name, "Test Assignment")
        XCTAssertEqual(assignment.courseId, "course1")
        XCTAssertEqual(assignment.pointsPossible, 100.0)
    }
    
    func testCourseCreation() {
        // Test that Course can be created
        let course = Course(
            id: "1",
            name: "Test Course",
            courseCode: "TEST101"
        )
        
        XCTAssertEqual(course.id, "1")
        XCTAssertEqual(course.name, "Test Course")
        XCTAssertEqual(course.courseCode, "TEST101")
        XCTAssertTrue(course.isActive)
    }
    
    func testAssignmentSubmissionResponseCreation() {
        // Test that AssignmentSubmissionResponse can be created without recursive issues
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
        XCTAssertEqual(submission.assignmentId, "assign1")
        XCTAssertEqual(submission.score, 85.0)
    }
    
    func testGradeCreation() {
        // Test that Grade can be created from submission
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
            body: nil,
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
            workflowState: "graded",
            gradingPeriodId: nil,
            gradeMatchesCurrentSubmission: true,
            htmlUrl: nil,
            secondsLate: 0,
            enteredGrade: "B",
            enteredScore: 85.0,
            cachedDueDate: nil
        )
        
        let grade = Grade(from: submission)
        
        XCTAssertEqual(grade.id, "sub1")
        XCTAssertEqual(grade.assignmentId, "assign1")
        XCTAssertEqual(grade.score, 85.0)
        XCTAssertEqual(grade.grade, "B")
    }
}