import XCTest
import CoreData
@testable import BetterCanvas

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "CanvasDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        testContext = container.viewContext
        
        // Create a test instance with the in-memory container
        coreDataManager = TestCoreDataManager(container: container)
    }
    
    override func tearDown() {
        coreDataManager = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Course Tests
    
    func testSaveCourses() async throws {
        // Given
        let courses = [
            Course(
                id: "1",
                name: "Introduction to Computer Science",
                courseCode: "CS101",
                workflowState: "available",
                accountId: "1",
                startAt: Date(),
                endAt: Date().addingTimeInterval(86400 * 90), // 90 days
                enrollments: nil,
                needsGradingCount: nil,
                term: nil,
                teachers: nil,
                totalStudents: nil,
                syllabusBody: nil,
                publicSyllabus: nil,
                publicSyllabusToAuth: nil,
                storageQuotaMb: nil,
                isPublic: nil,
                isPublicToAuthUsers: nil,
                publicDescription: nil,
                calendarLink: nil,
                uuid: nil,
                imageDownloadUrl: nil,
                homePageUrl: nil
            ),
            Course(
                id: "2",
                name: "Advanced Mathematics",
                courseCode: "MATH201",
                workflowState: "available",
                accountId: "1",
                startAt: Date(),
                endAt: Date().addingTimeInterval(86400 * 90),
                enrollments: nil,
                needsGradingCount: nil,
                term: nil,
                teachers: nil,
                totalStudents: nil,
                syllabusBody: nil,
                publicSyllabus: nil,
                publicSyllabusToAuth: nil,
                storageQuotaMb: nil,
                isPublic: nil,
                isPublicToAuthUsers: nil,
                publicDescription: nil,
                calendarLink: nil,
                uuid: nil,
                imageDownloadUrl: nil,
                homePageUrl: nil
            )
        ]
        
        // When
        try await coreDataManager.saveCourses(courses)
        
        // Then
        let savedCourses = try coreDataManager.fetchCourses()
        XCTAssertEqual(savedCourses.count, 2)
        
        let course1 = savedCourses.first { $0.id == "1" }
        XCTAssertNotNil(course1)
        XCTAssertEqual(course1?.name, "Introduction to Computer Science")
        XCTAssertEqual(course1?.courseCode, "CS101")
        
        let course2 = savedCourses.first { $0.id == "2" }
        XCTAssertNotNil(course2)
        XCTAssertEqual(course2?.name, "Advanced Mathematics")
        XCTAssertEqual(course2?.courseCode, "MATH201")
    }
    
    func testFindCourse() throws {
        // Given
        let course = Course(
            id: "test-course",
            name: "Test Course",
            courseCode: "TEST101",
            workflowState: "available",
            accountId: "1",
            startAt: nil,
            endAt: nil,
            enrollments: nil,
            needsGradingCount: nil,
            term: nil,
            teachers: nil,
            totalStudents: nil,
            syllabusBody: nil,
            publicSyllabus: nil,
            publicSyllabusToAuth: nil,
            storageQuotaMb: nil,
            isPublic: nil,
            isPublicToAuthUsers: nil,
            publicDescription: nil,
            calendarLink: nil,
            uuid: nil,
            imageDownloadUrl: nil,
            homePageUrl: nil
        )
        
        // When
        Task {
            try await coreDataManager.saveCourses([course])
        }
        
        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let foundCourse = try coreDataManager.findCourse(id: "test-course")
        
        // Then
        XCTAssertNotNil(foundCourse)
        XCTAssertEqual(foundCourse?.id, "test-course")
        XCTAssertEqual(foundCourse?.name, "Test Course")
    }
    
    // MARK: - Assignment Tests
    
    func testSaveAssignments() async throws {
        // Given - First create a course
        let course = Course(
            id: "course-1",
            name: "Test Course",
            courseCode: "TEST101",
            workflowState: "available",
            accountId: "1",
            startAt: nil,
            endAt: nil,
            enrollments: nil,
            needsGradingCount: nil,
            term: nil,
            teachers: nil,
            totalStudents: nil,
            syllabusBody: nil,
            publicSyllabus: nil,
            publicSyllabusToAuth: nil,
            storageQuotaMb: nil,
            isPublic: nil,
            isPublicToAuthUsers: nil,
            publicDescription: nil,
            calendarLink: nil,
            uuid: nil,
            imageDownloadUrl: nil,
            homePageUrl: nil
        )
        
        try await coreDataManager.saveCourses([course])
        
        let assignments = [
            Assignment(
                id: "1",
                name: "Homework 1",
                description: "First assignment",
                createdAt: Date(),
                updatedAt: Date(),
                dueAt: Date().addingTimeInterval(86400), // Tomorrow
                lockAt: nil,
                unlockAt: nil,
                courseId: "course-1",
                htmlUrl: "https://test.com/assignments/1",
                submissionsDownloadUrl: nil,
                assignmentGroupId: "1",
                dueDateRequired: false,
                allowedExtensions: nil,
                maxNameLength: nil,
                turnitinEnabled: nil,
                vericiteEnabled: nil,
                turnitinSettings: nil,
                gradeGroupStudentsIndividually: false,
                externalToolTagAttributes: nil,
                peerReviews: false,
                automaticPeerReviews: nil,
                peerReviewCount: nil,
                peerReviewsAssignAt: nil,
                intraGroupPeerReviews: nil,
                groupCategoryId: nil,
                needsGradingCount: nil,
                needsGradingCountBySection: nil,
                position: nil,
                postToSis: nil,
                integrationId: nil,
                integrationData: nil,
                pointsPossible: 100.0,
                submissionTypes: ["online_text_entry"],
                hasSubmittedSubmissions: nil,
                gradingType: "points",
                gradingStandardId: nil,
                published: true,
                unpublishable: nil,
                onlyVisibleToOverrides: false,
                lockedForUser: nil,
                lockInfo: nil,
                lockExplanation: nil,
                quizId: nil,
                anonymousSubmissions: nil,
                discussionTopic: nil,
                freezeOnCopy: nil,
                frozen: nil,
                frozenAttributes: nil,
                submission: nil,
                useRubricForGrading: nil,
                rubricSettings: nil,
                rubric: nil,
                assignmentVisibility: nil,
                overrides: nil,
                omitFromFinalGrade: nil,
                hideInGradebook: nil,
                moderatedGrading: nil,
                graderCount: nil,
                finalGraderId: nil,
                graderCommentsVisibleToGraders: nil,
                gradersAnonymousToGraders: nil,
                graderNamesVisibleToFinalGrader: nil,
                anonymousGrading: nil,
                allowedAttempts: nil,
                postManually: nil,
                scoreStatistic: nil
            )
        ]
        
        // When
        try await coreDataManager.saveAssignments(assignments, for: "course-1")
        
        // Then
        let savedAssignments = try coreDataManager.fetchAssignments(for: "course-1")
        XCTAssertEqual(savedAssignments.count, 1)
        
        let assignment = savedAssignments.first
        XCTAssertNotNil(assignment)
        XCTAssertEqual(assignment?.id, "1")
        XCTAssertEqual(assignment?.name, "Homework 1")
        XCTAssertEqual(assignment?.pointsPossible, 100.0)
        XCTAssertEqual(assignment?.course?.id, "course-1")
    }
    
    // MARK: - Grade Tests
    
    func testSaveGrades() async throws {
        // Given - First create a course
        let course = Course(
            id: "course-1",
            name: "Test Course",
            courseCode: "TEST101",
            workflowState: "available",
            accountId: "1",
            startAt: nil,
            endAt: nil,
            enrollments: nil,
            needsGradingCount: nil,
            term: nil,
            teachers: nil,
            totalStudents: nil,
            syllabusBody: nil,
            publicSyllabus: nil,
            publicSyllabusToAuth: nil,
            storageQuotaMb: nil,
            isPublic: nil,
            isPublicToAuthUsers: nil,
            publicDescription: nil,
            calendarLink: nil,
            uuid: nil,
            imageDownloadUrl: nil,
            homePageUrl: nil
        )
        
        try await coreDataManager.saveCourses([course])
        
        let grades = [
            Grade(
                id: "grade-1",
                assignmentId: "assignment-1",
                courseId: "course-1",
                userId: "user-1",
                assignmentName: "Test Assignment",
                courseName: "Test Course",
                score: 85.0,
                grade: "B",
                pointsPossible: 100.0,
                gradedAt: Date(),
                submittedAt: Date(),
                late: false,
                missing: false,
                excused: false,
                workflowState: "graded",
                gradingPeriodId: nil,
                gradeMatchesCurrentSubmission: true,
                htmlUrl: nil
            )
        ]
        
        // When
        try await coreDataManager.saveGrades(grades, for: "course-1")
        
        // Then
        let savedGrades = try coreDataManager.fetchGrades(for: "course-1")
        XCTAssertEqual(savedGrades.count, 1)
        
        let grade = savedGrades.first
        XCTAssertNotNil(grade)
        XCTAssertEqual(grade?.id, "grade-1")
        XCTAssertEqual(grade?.assignmentName, "Test Assignment")
        XCTAssertEqual(grade?.currentScore, 85.0)
        XCTAssertEqual(grade?.currentGrade, "B")
        XCTAssertEqual(grade?.course?.id, "course-1")
    }
    
    // MARK: - User Tests
    
    func testSaveUser() async throws {
        // Given
        let user = User(
            id: "user-123",
            name: "Test User",
            email: "test@example.com",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        // When
        try await coreDataManager.saveUser(user)
        
        // Then
        let savedUser = try coreDataManager.fetchCurrentUser()
        XCTAssertNotNil(savedUser)
        XCTAssertEqual(savedUser?.id, "user-123")
        XCTAssertEqual(savedUser?.name, "Test User")
        XCTAssertEqual(savedUser?.email, "test@example.com")
        XCTAssertEqual(savedUser?.avatarURL, "https://example.com/avatar.jpg")
    }
    
    // MARK: - Cache Management Tests
    
    func testIsDataStale() async throws {
        // Given
        let course = Course(
            id: "stale-test",
            name: "Stale Test Course",
            courseCode: "STALE101",
            workflowState: "available",
            accountId: "1",
            startAt: nil,
            endAt: nil,
            enrollments: nil,
            needsGradingCount: nil,
            term: nil,
            teachers: nil,
            totalStudents: nil,
            syllabusBody: nil,
            publicSyllabus: nil,
            publicSyllabusToAuth: nil,
            storageQuotaMb: nil,
            isPublic: nil,
            isPublicToAuthUsers: nil,
            publicDescription: nil,
            calendarLink: nil,
            uuid: nil,
            imageDownloadUrl: nil,
            homePageUrl: nil
        )
        
        try await coreDataManager.saveCourses([course])
        
        // When
        let savedCourse = try coreDataManager.findCourse(id: "stale-test")
        XCTAssertNotNil(savedCourse)
        
        // Then - Fresh data should not be stale
        XCTAssertFalse(coreDataManager.isDataStale(for: savedCourse!, maxAge: 300))
        
        // Manually set an old sync date
        savedCourse?.setValue(Date().addingTimeInterval(-600), forKey: "lastSyncDate") // 10 minutes ago
        
        // Now it should be stale
        XCTAssertTrue(coreDataManager.isDataStale(for: savedCourse!, maxAge: 300))
    }
    
    // MARK: - Error Tests
    
    func testSaveAssignmentsWithNonexistentCourse() async {
        // Given
        let assignments = [
            Assignment(
                id: "1",
                name: "Test Assignment",
                description: nil,
                createdAt: Date(),
                updatedAt: Date(),
                dueAt: nil,
                lockAt: nil,
                unlockAt: nil,
                courseId: "nonexistent-course",
                htmlUrl: "https://test.com",
                submissionsDownloadUrl: nil,
                assignmentGroupId: "1",
                dueDateRequired: false,
                allowedExtensions: nil,
                maxNameLength: nil,
                turnitinEnabled: nil,
                vericiteEnabled: nil,
                turnitinSettings: nil,
                gradeGroupStudentsIndividually: false,
                externalToolTagAttributes: nil,
                peerReviews: false,
                automaticPeerReviews: nil,
                peerReviewCount: nil,
                peerReviewsAssignAt: nil,
                intraGroupPeerReviews: nil,
                groupCategoryId: nil,
                needsGradingCount: nil,
                needsGradingCountBySection: nil,
                position: nil,
                postToSis: nil,
                integrationId: nil,
                integrationData: nil,
                pointsPossible: 100.0,
                submissionTypes: ["online_text_entry"],
                hasSubmittedSubmissions: nil,
                gradingType: "points",
                gradingStandardId: nil,
                published: true,
                unpublishable: nil,
                onlyVisibleToOverrides: false,
                lockedForUser: nil,
                lockInfo: nil,
                lockExplanation: nil,
                quizId: nil,
                anonymousSubmissions: nil,
                discussionTopic: nil,
                freezeOnCopy: nil,
                frozen: nil,
                frozenAttributes: nil,
                submission: nil,
                useRubricForGrading: nil,
                rubricSettings: nil,
                rubric: nil,
                assignmentVisibility: nil,
                overrides: nil,
                omitFromFinalGrade: nil,
                hideInGradebook: nil,
                moderatedGrading: nil,
                graderCount: nil,
                finalGraderId: nil,
                graderCommentsVisibleToGraders: nil,
                gradersAnonymousToGraders: nil,
                graderNamesVisibleToFinalGrader: nil,
                anonymousGrading: nil,
                allowedAttempts: nil,
                postManually: nil,
                scoreStatistic: nil
            )
        ]
        
        // When/Then
        do {
            try await coreDataManager.saveAssignments(assignments, for: "nonexistent-course")
            XCTFail("Expected courseNotFound error")
        } catch let error as CoreDataError {
            XCTAssertEqual(error, .courseNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Test Core Data Manager

class TestCoreDataManager: CoreDataManager {
    private let testContainer: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.testContainer = container
        super.init()
    }
    
    override var persistentContainer: NSPersistentContainer {
        return testContainer
    }
}

// MARK: - CoreDataError Equatable Extension

extension CoreDataError: Equatable {
    static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
        switch (lhs, rhs) {
        case (.courseNotFound, .courseNotFound),
             (.assignmentNotFound, .assignmentNotFound),
             (.userNotFound, .userNotFound),
             (.saveFailed, .saveFailed),
             (.fetchFailed, .fetchFailed):
            return true
        default:
            return false
        }
    }
}