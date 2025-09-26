import XCTest
import CoreData
@testable import BetterCanvas

final class DataSyncManagerTests: XCTestCase {
    
    var dataSyncManager: DataSyncManager!
    var mockAPIService: MockCanvasAPIService!
    var mockCoreDataManager: MockCoreDataManager!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        mockAPIService = MockCanvasAPIService()
        mockCoreDataManager = MockCoreDataManager()
        mockUserDefaults = UserDefaults(suiteName: "test")!
        
        dataSyncManager = DataSyncManager(
            apiService: mockAPIService,
            coreDataManager: mockCoreDataManager,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() {
        // Clean up test user defaults
        mockUserDefaults.removePersistentDomain(forName: "test")
        
        dataSyncManager = nil
        mockAPIService = nil
        mockCoreDataManager = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Sync All Tests
    
    @MainActor
    func testSyncAll() async throws {
        // Given
        let expectedCourses = [
            Course(
                id: "1",
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
        ]
        
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        
        mockAPIService.mockCourses = expectedCourses
        mockAPIService.mockUser = expectedUser
        mockAPIService.mockAssignments = []
        mockAPIService.mockGrades = []
        mockAPIService.mockDiscussions = []
        
        // When
        try await dataSyncManager.syncAll()
        
        // Then
        XCTAssertFalse(dataSyncManager.isSyncing)
        XCTAssertEqual(dataSyncManager.syncProgress, 1.0)
        XCTAssertEqual(dataSyncManager.syncStatus, "Sync completed successfully")
        XCTAssertNotNil(dataSyncManager.lastSyncDate)
        XCTAssertNil(dataSyncManager.syncError)
        
        // Verify API calls were made
        XCTAssertTrue(mockAPIService.getCoursesWasCalled)
        XCTAssertTrue(mockAPIService.validateTokenWasCalled)
        
        // Verify data was saved
        XCTAssertTrue(mockCoreDataManager.saveCoursesWasCalled)
        XCTAssertTrue(mockCoreDataManager.saveUserWasCalled)
    }
    
    @MainActor
    func testSyncAllWithError() async {
        // Given
        mockAPIService.shouldThrowError = true
        mockAPIService.errorToThrow = NetworkError.networkError(URLError(.notConnectedToInternet))
        
        // When/Then
        do {
            try await dataSyncManager.syncAll()
            XCTFail("Expected sync to fail")
        } catch {
            XCTAssertFalse(dataSyncManager.isSyncing)
            XCTAssertNotNil(dataSyncManager.syncError)
            XCTAssertTrue(dataSyncManager.syncStatus.contains("Sync failed"))
        }
    }
    
    // MARK: - Individual Sync Tests
    
    func testSyncCourses() async throws {
        // Given
        let expectedCourses = [
            Course(
                id: "1",
                name: "Course 1",
                courseCode: "C1",
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
        ]
        
        mockAPIService.mockCourses = expectedCourses
        
        // When
        try await dataSyncManager.syncCourses()
        
        // Then
        XCTAssertTrue(mockAPIService.getCoursesWasCalled)
        XCTAssertTrue(mockCoreDataManager.saveCoursesWasCalled)
        XCTAssertEqual(mockCoreDataManager.savedCourses?.count, 1)
        XCTAssertEqual(mockCoreDataManager.savedCourses?.first?.id, "1")
    }
    
    func testSyncAssignments() async throws {
        // Given
        let courseId = "course-1"
        let expectedAssignments = [
            Assignment(
                id: "1",
                name: "Assignment 1",
                description: nil,
                createdAt: Date(),
                updatedAt: Date(),
                dueAt: nil,
                lockAt: nil,
                unlockAt: nil,
                courseId: courseId,
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
        
        mockAPIService.mockAssignments = expectedAssignments
        
        // When
        try await dataSyncManager.syncAssignments(for: courseId)
        
        // Then
        XCTAssertTrue(mockAPIService.getAssignmentsWasCalled)
        XCTAssertEqual(mockAPIService.lastCourseIdForAssignments, courseId)
        XCTAssertTrue(mockCoreDataManager.saveAssignmentsWasCalled)
    }
    
    func testSyncUserProfile() async throws {
        // Given
        let expectedUser = User(id: "user-123", name: "Test User", email: "test@example.com", avatarURL: nil)
        mockAPIService.mockUser = expectedUser
        
        // When
        try await dataSyncManager.syncUserProfile()
        
        // Then
        XCTAssertTrue(mockAPIService.validateTokenWasCalled)
        XCTAssertTrue(mockCoreDataManager.saveUserWasCalled)
        XCTAssertEqual(mockCoreDataManager.savedUser?.id, "user-123")
    }
    
    // MARK: - Sync Logic Tests
    
    @MainActor
    func testNeedsSync() {
        // Given - No previous sync
        XCTAssertTrue(dataSyncManager.needsSync())
        
        // When - Set recent sync date
        dataSyncManager.lastSyncDate = Date().addingTimeInterval(-60) // 1 minute ago
        
        // Then - Should not need sync (default interval is 5 minutes)
        XCTAssertFalse(dataSyncManager.needsSync())
        
        // When - Set old sync date
        dataSyncManager.lastSyncDate = Date().addingTimeInterval(-600) // 10 minutes ago
        
        // Then - Should need sync
        XCTAssertTrue(dataSyncManager.needsSync())
    }
    
    @MainActor
    func testSyncIfNeeded() async throws {
        // Given - Old sync date
        dataSyncManager.lastSyncDate = Date().addingTimeInterval(-600) // 10 minutes ago
        
        mockAPIService.mockCourses = []
        mockAPIService.mockUser = User(id: "123", name: "Test", email: nil, avatarURL: nil)
        mockAPIService.mockAssignments = []
        mockAPIService.mockGrades = []
        mockAPIService.mockDiscussions = []
        
        // When
        try await dataSyncManager.syncIfNeeded()
        
        // Then
        XCTAssertTrue(mockAPIService.getCoursesWasCalled)
        XCTAssertNotNil(dataSyncManager.lastSyncDate)
        
        // Reset mocks
        mockAPIService.reset()
        
        // When - Try sync again immediately
        try await dataSyncManager.syncIfNeeded()
        
        // Then - Should not sync again
        XCTAssertFalse(mockAPIService.getCoursesWasCalled)
    }
    
    // MARK: - Statistics Tests
    
    @MainActor
    func testGetSyncStatistics() {
        // Given
        dataSyncManager.lastSyncDate = Date()
        dataSyncManager.isSyncing = false
        dataSyncManager.syncProgress = 1.0
        
        mockCoreDataManager.mockCoursesCount = 5
        
        // When
        let stats = dataSyncManager.getSyncStatistics()
        
        // Then
        XCTAssertNotNil(stats.lastSyncDate)
        XCTAssertEqual(stats.coursesCount, 5)
        XCTAssertFalse(stats.isSyncing)
        XCTAssertEqual(stats.syncProgress, 1.0)
        XCTAssertTrue(stats.syncStatusText.contains("Last synced"))
    }
}

// MARK: - Mock Classes

class MockCanvasAPIService: CanvasAPIService {
    var mockCourses: [Course] = []
    var mockAssignments: [Assignment] = []
    var mockGrades: [Grade] = []
    var mockDiscussions: [Discussion] = []
    var mockUser: User?
    var shouldThrowError = false
    var errorToThrow: Error?
    
    var getCoursesWasCalled = false
    var getAssignmentsWasCalled = false
    var getGradesWasCalled = false
    var getDiscussionsWasCalled = false
    var validateTokenWasCalled = false
    
    var lastCourseIdForAssignments: String?
    var lastCourseIdForGrades: String?
    var lastCourseIdForDiscussions: String?
    
    override func getCourses() async throws -> [Course] {
        getCoursesWasCalled = true
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        return mockCourses
    }
    
    override func getAssignments(courseId: String) async throws -> [Assignment] {
        getAssignmentsWasCalled = true
        lastCourseIdForAssignments = courseId
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        return mockAssignments
    }
    
    override func getGrades(courseId: String) async throws -> [Grade] {
        getGradesWasCalled = true
        lastCourseIdForGrades = courseId
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        return mockGrades
    }
    
    override func getDiscussions(courseId: String) async throws -> [Discussion] {
        getDiscussionsWasCalled = true
        lastCourseIdForDiscussions = courseId
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        return mockDiscussions
    }
    
    override func validateToken() async throws -> User {
        validateTokenWasCalled = true
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        guard let user = mockUser else {
            throw NetworkError.invalidResponse
        }
        
        return user
    }
    
    func reset() {
        getCoursesWasCalled = false
        getAssignmentsWasCalled = false
        getGradesWasCalled = false
        getDiscussionsWasCalled = false
        validateTokenWasCalled = false
        lastCourseIdForAssignments = nil
        lastCourseIdForGrades = nil
        lastCourseIdForDiscussions = nil
        shouldThrowError = false
        errorToThrow = nil
    }
}

class MockCoreDataManager: CoreDataManager {
    var savedCourses: [Course]?
    var savedAssignments: [Assignment]?
    var savedGrades: [Grade]?
    var savedDiscussions: [Discussion]?
    var savedUser: User?
    
    var saveCoursesWasCalled = false
    var saveAssignmentsWasCalled = false
    var saveGradesWasCalled = false
    var saveDiscussionsWasCalled = false
    var saveUserWasCalled = false
    
    var mockCoursesCount = 0
    
    override func saveCourses(_ courses: [Course]) async throws {
        saveCoursesWasCalled = true
        savedCourses = courses
    }
    
    override func saveAssignments(_ assignments: [Assignment], for courseId: String) async throws {
        saveAssignmentsWasCalled = true
        savedAssignments = assignments
    }
    
    override func saveGrades(_ grades: [Grade], for courseId: String) async throws {
        saveGradesWasCalled = true
        savedGrades = grades
    }
    
    override func saveDiscussions(_ discussions: [Discussion], for courseId: String) async throws {
        saveDiscussionsWasCalled = true
        savedDiscussions = discussions
    }
    
    override func saveUser(_ user: User) async throws {
        saveUserWasCalled = true
        savedUser = user
    }
    
    override func fetchCourses() throws -> [CourseEntity] {
        // Return mock course entities
        return []
    }
}