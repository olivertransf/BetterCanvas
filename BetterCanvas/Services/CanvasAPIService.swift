import Foundation

/// Service for interacting with Canvas API
class CanvasAPIService {

  // MARK: - Properties

  private let networkManager: NetworkManager
  private let keychainManager: KeychainManager

  private var baseURL: String? {
    keychainManager.getBaseURL()
  }

  private var apiToken: String? {
    keychainManager.getAPIToken()
  }

  // MARK: - Initialization

  init(
    networkManager: NetworkManager = NetworkManager(),
    keychainManager: KeychainManager = .shared
  ) {
    self.networkManager = networkManager
    self.keychainManager = keychainManager
  }

  // MARK: - Authentication

  /// Validates the current API token by fetching user profile
  func validateToken() async throws -> User {
    let endpoint = try createEndpoint(path: "api/v1/users/self")
    return try await networkManager.request(endpoint, responseType: User.self)
  }

  // MARK: - Courses

  /// Fetches all courses for the current user with pagination
  func getCourses() async throws -> [Course] {
    var allCourses: [Course] = []
    var page = 1
    let perPage = 100 // Maximum per page to reduce API calls
    
    while true {
      let endpoint = try createEndpoint(path: "api/v1/courses?page=\(page)&per_page=\(perPage)&include[]=enrollments&include[]=term&include[]=concluded")
      let courses = try await networkManager.request(endpoint, responseType: [Course].self)
      
      print("📄 Page \(page): Fetched \(courses.count) courses")
      
      // If we get an empty page, we've reached the end
      if courses.isEmpty {
        print("📄 Page \(page) is empty, stopping pagination")
        break
      }
      
      allCourses.append(contentsOf: courses)
      
      // If we got fewer courses than requested, we've reached the end
      if courses.count < perPage {
        print("📄 Page \(page) has fewer courses than requested (\(courses.count) < \(perPage)), stopping pagination")
        break
      }
      
      page += 1
    }
    
    print("📚 Fetched \(allCourses.count) total courses across \(page) pages")
    return allCourses
  }

  /// Fetches a specific course by ID
  func getCourse(id: String) async throws -> Course {
    let endpoint = try createEndpoint(
      path: "api/v1/courses/\(id)?include[]=enrollments&include[]=term")
    return try await networkManager.request(endpoint, responseType: Course.self)
  }

  /// Fetches courses with specific enrollment type with pagination
  func getCourses(enrollmentType: String? = nil, enrollmentState: String? = nil) async throws
    -> [Course]
  {
    var allCourses: [Course] = []
    var page = 1
    let perPage = 100 // Maximum per page to reduce API calls
    
    while true {
      var queryParams = [
        "include[]=enrollments",
        "include[]=term",
        "include[]=total_scores",
        "include[]=favorites",
        "include[]=concluded",
        "page=\(page)",
        "per_page=\(perPage)",
        // Remove state filters to get all courses
        // "state[]=available",
        // "state[]=completed",
      ]

      if let enrollmentType = enrollmentType {
        queryParams.append("enrollment_type=\(enrollmentType)")
      }

      if let enrollmentState = enrollmentState {
        queryParams.append("enrollment_state=\(enrollmentState)")
      }

      let queryString = queryParams.joined(separator: "&")
      let endpoint = try createEndpoint(path: "api/v1/courses?\(queryString)")
      let courses = try await networkManager.request(endpoint, responseType: [Course].self)
      
      print("📄 Page \(page) (filtered): Fetched \(courses.count) courses")
      
      // If we get an empty page, we've reached the end
      if courses.isEmpty {
        print("📄 Page \(page) is empty, stopping pagination")
        break
      }
      
      allCourses.append(contentsOf: courses)
      
      // If we got fewer courses than requested, we've reached the end
      if courses.count < perPage {
        print("📄 Page \(page) has fewer courses than requested (\(courses.count) < \(perPage)), stopping pagination")
        break
      }
      
      page += 1
    }
    
    print("📚 Fetched \(allCourses.count) total courses with filters across \(page) pages")
    return allCourses
  }

  // MARK: - Assignments

  /// Fetches assignments for a specific course
  func getAssignments(courseId: String) async throws -> [Assignment] {
    let endpoint = try createEndpoint(path: "api/v1/courses/\(courseId)/assignments")
    return try await networkManager.request(endpoint, responseType: [Assignment].self)
  }

  /// Fetches a specific assignment
  func getAssignment(courseId: String, assignmentId: String) async throws -> Assignment {
    let endpoint = try createEndpoint(
      path: "api/v1/courses/\(courseId)/assignments/\(assignmentId)")
    return try await networkManager.request(endpoint, responseType: Assignment.self)
  }

  /// Fetches all assignments across all courses for the current user
  func getAllAssignments() async throws -> [Assignment] {
    let courses = try await getCourses()
    var allAssignments: [Assignment] = []
    
    for course in courses {
      do {
        let courseAssignments = try await getAssignments(courseId: course.id)
        allAssignments.append(contentsOf: courseAssignments)
      } catch {
        print("Failed to fetch assignments for course \(course.id): \(error)")
        // Continue with other courses
      }
    }
    
    return allAssignments
  }

  /// Submits an assignment
  func submitAssignment(
    courseId: String,
    assignmentId: String,
    submission: AssignmentSubmission
  ) async throws -> AssignmentSubmissionResponse {
    let endpoint = try createEndpoint(
      path: "api/v1/courses/\(courseId)/assignments/\(assignmentId)/submissions",
      method: .POST,
      body: submission
    )
    return try await networkManager.request(
      endpoint, responseType: AssignmentSubmissionResponse.self)
  }

  // MARK: - Grades

  /// Fetches grades for a specific course
  func getGrades(courseId: String) async throws -> [Grade] {
    // First get assignments for the course
    let assignments = try await getAssignments(courseId: courseId)
    var allGrades: [Grade] = []
    
    // For each assignment, try to get the submission
    for assignment in assignments {
      do {
        let submissionEndpoint = try createEndpoint(
          path: "api/v1/courses/\(courseId)/assignments/\(assignment.id)/submissions/self")
        let submission = try await networkManager.request(
          submissionEndpoint, responseType: AssignmentSubmissionResponse.self)
        
        // Create grade from submission and assignment data
        var grade = Grade(from: submission)
        // Update with assignment-specific data
        grade = Grade(
          id: grade.id,
          assignmentId: grade.assignmentId,
          courseId: courseId,
          userId: grade.userId,
          assignmentName: assignment.name,
          courseName: "", // Will be set by caller
          score: grade.score,
          grade: grade.grade,
          pointsPossible: assignment.pointsPossible,
          gradedAt: grade.gradedAt,
          submittedAt: grade.submittedAt,
          late: grade.late,
          missing: grade.missing,
          excused: grade.excused,
          workflowState: grade.workflowState,
          gradingPeriodId: grade.gradingPeriodId,
          gradeMatchesCurrentSubmission: grade.gradeMatchesCurrentSubmission,
          htmlUrl: grade.htmlUrl
        )
        allGrades.append(grade)
      } catch {
        // If no submission exists for this assignment, skip it
        // This is normal for assignments that haven't been submitted yet
        continue
      }
    }
    
    return allGrades
  }

  /// Fetches all grades for the current user
  func getAllGrades() async throws -> [Grade] {
    let courses = try await getCourses()
    var allGrades: [Grade] = []

    for course in courses {
      do {
        let courseGrades = try await getGrades(courseId: course.id)
        allGrades.append(contentsOf: courseGrades)
      } catch {
        // Continue with other courses if one fails
        print("Failed to fetch grades for course \(course.id): \(error)")
      }
    }

    return allGrades
  }

  // MARK: - Discussions

  /// Fetches discussion topics for a course
  func getDiscussions(courseId: String) async throws -> [Discussion] {
    let endpoint = try createEndpoint(path: "api/v1/courses/\(courseId)/discussion_topics")
    return try await networkManager.request(endpoint, responseType: [Discussion].self)
  }

  /// Fetches a specific discussion with entries
  func getDiscussion(courseId: String, discussionId: String) async throws -> DiscussionDetail {
    let endpoint = try createEndpoint(
      path: "api/v1/courses/\(courseId)/discussion_topics/\(discussionId)")
    return try await networkManager.request(endpoint, responseType: DiscussionDetail.self)
  }

  /// Posts a reply to a discussion
  func postDiscussionReply(
    courseId: String,
    discussionId: String,
    message: String,
    parentId: String? = nil
  ) async throws -> DiscussionEntry {
    var body: [String: Any] = ["message": message]
    if let parentId = parentId {
      body["parent_id"] = parentId
    }

    let endpoint = try createEndpoint(
      path: "api/v1/courses/\(courseId)/discussion_topics/\(discussionId)/entries",
      method: .POST,
      body: DiscussionReplyRequest(message: message, parentId: parentId)
    )
    return try await networkManager.request(endpoint, responseType: DiscussionEntry.self)
  }

  // MARK: - File Upload

  /// Uploads a file to Canvas
  func uploadFile(
    data: Data,
    fileName: String,
    contentType: String,
    progressHandler: @escaping (Double) -> Void = { _ in }
  ) async throws -> FileUploadResponse {
    // Canvas file upload is a two-step process
    // Step 1: Get upload URL and parameters
    let uploadInfoEndpoint = try createEndpoint(
      path: "api/v1/users/self/files",
      method: .POST,
      body: FileUploadRequest(name: fileName, size: data.count, contentType: contentType)
    )

    let uploadInfo = try await networkManager.request(
      uploadInfoEndpoint, responseType: FileUploadInfo.self)

    // Step 2: Upload file to the provided URL
    let uploadEndpoint = APIEndpoint(
      baseURL: uploadInfo.uploadUrl,
      path: "",
      method: .POST,
      body: nil
    )

    return try await networkManager.upload(
      uploadEndpoint,
      data: data,
      responseType: FileUploadResponse.self,
      progressHandler: progressHandler
    )
  }

  // MARK: - Private Methods

  private func createEndpoint(
    path: String,
    method: HTTPMethod = .GET,
    body: Codable? = nil
  ) throws -> APIEndpoint {
    guard let baseURL = baseURL else {
      throw CanvasAPIError.missingBaseURL
    }

    guard let token = apiToken else {
      throw CanvasAPIError.missingAPIToken
    }

    let headers = [
      "Authorization": "Bearer \(token)",
      "Accept": "application/json",
    ]

    return APIEndpoint(
      baseURL: baseURL,
      path: path,
      method: method,
      headers: headers,
      body: body
    )
  }
}

// MARK: - Canvas API Errors

enum CanvasAPIError: LocalizedError {
  case missingBaseURL
  case missingAPIToken
  case invalidResponse

  var errorDescription: String? {
    switch self {
    case .missingBaseURL:
      return "Canvas base URL not configured"
    case .missingAPIToken:
      return "API token not available"
    case .invalidResponse:
      return "Invalid response from Canvas API"
    }
  }
}

// MARK: - Request Models

struct FileUploadRequest: Codable {
  let name: String
  let size: Int
  let contentType: String

  enum CodingKeys: String, CodingKey {
    case name
    case size
    case contentType = "content_type"
  }
}

struct FileUploadInfo: Codable {
  let uploadUrl: String
  let uploadParams: [String: String]

  enum CodingKeys: String, CodingKey {
    case uploadUrl = "upload_url"
    case uploadParams = "upload_params"
  }
}

struct DiscussionReplyRequest: Codable {
  let message: String
  let parentId: String?

  enum CodingKeys: String, CodingKey {
    case message
    case parentId = "parent_id"
  }
}
