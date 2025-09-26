import XCTest
@testable import BetterCanvas

final class CanvasAPIServiceTests: XCTestCase {
    
    var apiService: CanvasAPIService!
    var mockNetworkManager: MockNetworkManager!
    var mockKeychainManager: MockKeychainManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockKeychainManager = MockKeychainManager()
        mockKeychainManager.storedBaseURL = "https://test.instructure.com"
        mockKeychainManager.storedAPIToken = "test_token_123"
        
        apiService = CanvasAPIService(
            networkManager: mockNetworkManager,
            keychainManager: mockKeychainManager
        )
    }
    
    override func tearDown() {
        apiService = nil
        mockNetworkManager = nil
        mockKeychainManager = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    func testValidateToken() async throws {
        // Given
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        mockNetworkManager.mockResponse = expectedUser
        
        // When
        let user = try await apiService.validateToken()
        
        // Then
        XCTAssertEqual(user.id, expectedUser.id)
        XCTAssertEqual(user.name, expectedUser.name)
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.path, "api/v1/users/self")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.method, .GET)
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.headers["Authorization"], "Bearer test_token_123")
    }
    
    func testValidateTokenWithMissingCredentials() async {
        // Given
        mockKeychainManager.storedBaseURL = nil
        
        // When/Then
        do {
            _ = try await apiService.validateToken()
            XCTFail("Expected missing base URL error")
        } catch let error as CanvasAPIError {
            XCTAssertEqual(error, .missingBaseURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Courses Tests
    
    func testGetCourses() async throws {
        // Given
        let expectedCourses = [
            Course(
                id: "1",
                name: "Introduction to Computer Science",
                courseCode: "CS101",
                workflowState: "available",
                accountId: "1",
                startAt: nil,
                endAt: nil,
                enrollments: [
                    Enrollment(
                        id: "1",
                        courseId: "1",
                        courseSectionId: "1",
                        enrollmentState: "active",
                        limitPrivilegesToCourseSection: false,
                        role: "StudentEnrollment",
                        roleId: "1",
                        userId: "123",
                        type: "StudentEnrollment",
                        grades: nil
                    )
                ],
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
        
        mockNetworkManager.mockResponse = expectedCourses
        
        // When
        let courses = try await apiService.getCourses()
        
        // Then
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Introduction to Computer Science")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.path, "api/v1/courses")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.method, .GET)
    }
    
    func testGetCourse() async throws {
        // Given
        let expectedCourse = Course(
            id: "1",
            name: "Introduction to Computer Science",
            courseCode: "CS101",
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
        
        mockNetworkManager.mockResponse = expectedCourse
        
        // When
        let course = try await apiService.getCourse(id: "1")
        
        // Then
        XCTAssertEqual(course.id, "1")
        XCTAssertEqual(course.name, "Introduction to Computer Science")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.path, "api/v1/courses/1")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.method, .GET)
    }
    
    // MARK: - Assignments Tests
    
    func testGetAssignments() async throws {
        // Given
        let expectedAssignments = [
            Assignment(
                id: "1",
                name: "Homework 1",
                description: "First homework assignment",
                createdAt: Date(),
                updatedAt: Date(),
                dueAt: Date().addingTimeInterval(86400), // Tomorrow
                lockAt: nil,
                unlockAt: nil,
                courseId: "1",
                htmlUrl: "https://test.instructure.com/courses/1/assignments/1",
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
        
        mockNetworkManager.mockResponse = expectedAssignments
        
        // When
        let assignments = try await apiService.getAssignments(courseId: "1")
        
        // Then
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments.first?.id, "1")
        XCTAssertEqual(assignments.first?.name, "Homework 1")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.path, "api/v1/courses/1/assignments")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.method, .GET)
    }
    
    func testGetAssignment() async throws {
        // Given
        let expectedAssignment = Assignment(
            id: "1",
            name: "Homework 1",
            description: "First homework assignment",
            createdAt: Date(),
            updatedAt: Date(),
            dueAt: Date().addingTimeInterval(86400),
            lockAt: nil,
            unlockAt: nil,
            courseId: "1",
            htmlUrl: "https://test.instructure.com/courses/1/assignments/1",
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
        
        mockNetworkManager.mockResponse = expectedAssignment
        
        // When
        let assignment = try await apiService.getAssignment(courseId: "1", assignmentId: "1")
        
        // Then
        XCTAssertEqual(assignment.id, "1")
        XCTAssertEqual(assignment.name, "Homework 1")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.path, "api/v1/courses/1/assignments/1")
        XCTAssertEqual(mockNetworkManager.lastEndpoint?.method, .GET)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkError() async {
        // Given
        mockNetworkManager.shouldThrowError = true
        mockNetworkManager.errorToThrow = NetworkError.notFound
        
        // When/Then
        do {
            _ = try await apiService.getCourses()
            XCTFail("Expected network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRateLimitHandling() async {
        // Given
        mockNetworkManager.shouldThrowError = true
        mockNetworkManager.errorToThrow = NetworkError.rateLimited
        
        // When/Then
        do {
            _ = try await apiService.getCourses()
            XCTFail("Expected rate limit error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mock Network Manager

class MockNetworkManager: NetworkManager {
    var mockResponse: Any?
    var shouldThrowError = false
    var errorToThrow: Error?
    var lastEndpoint: APIEndpoint?
    
    override func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        lastEndpoint = endpoint
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.invalidResponse
        }
        
        return response
    }
    
    override func request(_ endpoint: APIEndpoint) async throws {
        lastEndpoint = endpoint
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
    }
    
    override func upload<T: Codable>(
        _ endpoint: APIEndpoint,
        data: Data,
        responseType: T.Type,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> T {
        lastEndpoint = endpoint
        
        if shouldThrowError {
            throw errorToThrow ?? NetworkError.unknownError(500)
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.invalidResponse
        }
        
        return response
    }
}

// MARK: - CanvasAPIError Equatable Extension

extension CanvasAPIError: Equatable {
    static func == (lhs: CanvasAPIError, rhs: CanvasAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.missingBaseURL, .missingBaseURL),
             (.missingAPIToken, .missingAPIToken),
             (.invalidResponse, .invalidResponse):
            return true
        default:
            return false
        }
    }
}