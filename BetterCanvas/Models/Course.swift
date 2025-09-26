import Foundation

/// Flexible ID type that can decode from either String or Int
struct FlexibleID: Codable, Hashable {
    let value: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            self.value = String(intValue)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Int"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/// Represents a Canvas course
struct Course: Codable, Identifiable, Hashable {
    let name: String?
    let courseCode: String?
    let workflowState: String?
    let startAt: Date?
    let endAt: Date?
    let enrollments: [Enrollment]?
    // Private properties for flexible decoding
    private let _id: FlexibleID?
    private let _accountId: FlexibleID?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case name
        case courseCode = "course_code"
        case workflowState = "workflow_state"
        case _accountId = "account_id"
        case startAt = "start_at"
        case endAt = "end_at"
        case enrollments
    }
    
    // Computed properties to expose the flexible IDs as strings
    var id: String { _id?.value ?? "unknown" }
    var accountId: String { _accountId?.value ?? "0" }
    

    
    // MARK: - Computed Properties
    
    var isActive: Bool {
        workflowState == "available"
    }
    
    var displayName: String {
        let courseName = name ?? "Unnamed Course"
        if let courseCode = courseCode, !courseCode.isEmpty && courseCode != courseName {
            return "\(courseCode): \(courseName)"
        }
        return courseName
    }
    
    var userRole: String? {
        enrollments?.first?.role
    }
    
    var isStudent: Bool {
        userRole?.lowercased().contains("student") == true
    }
    
    var isTeacher: Bool {
        userRole?.lowercased().contains("teacher") == true ||
        userRole?.lowercased().contains("instructor") == true
    }
    
    // Note: Canvas API doesn't have built-in favorites, so we use a local favorites manager
    var isFavorite: Bool {
        FavoritesManager.shared.isFavorite(courseId: self.id)
    }
}

/// Represents a course enrollment
struct Enrollment: Codable, Hashable {
    let role: String?
    let enrollmentState: String?
    let type: String?
    let grades: EnrollmentGrades?
    
    // Private properties for flexible decoding
    private let _id: FlexibleID?
    private let _courseId: FlexibleID?
    private let _userId: FlexibleID?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _courseId = "course_id"
        case _userId = "user_id"
        case enrollmentState = "enrollment_state"
        case role
        case type
        case grades
    }
    
    // Computed properties
    var id: String { _id?.value ?? "0" }
    var courseId: String { _courseId?.value ?? "0" }
    var userId: String { _userId?.value ?? "0" }
}

/// Represents enrollment grades
struct EnrollmentGrades: Codable, Hashable {
    let htmlUrl: String?
    let currentGrade: String?
    let currentScore: Double?
    let finalGrade: String?
    let finalScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case htmlUrl = "html_url"
        case currentGrade = "current_grade"
        case currentScore = "current_score"
        case finalGrade = "final_grade"
        case finalScore = "final_score"
    }
}

/// Represents a course term
struct Term: Codable, Hashable {
    let id: String
    let name: String
    let startAt: Date?
    let endAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case startAt = "start_at"
        case endAt = "end_at"
    }
}// MARK: - Course Extensions for Testing
extension Course {
    init(
        id: String,
        name: String?,
        courseCode: String? = nil,
        workflowState: String? = "available"
    ) {
        self._id = FlexibleID(value: id)
        self._accountId = FlexibleID(value: "1")
        self.name = name
        self.courseCode = courseCode
        self.workflowState = workflowState
        self.startAt = nil
        self.endAt = nil
        self.enrollments = nil
    }
}

// Extension for FlexibleID to support direct initialization
extension FlexibleID {
    init(value: String) {
        self.value = value
    }
}
