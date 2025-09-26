import Foundation

/// Represents a grade for an assignment
struct Grade: Codable, Identifiable, Hashable {
    let id: String
    let assignmentId: String
    let courseId: String
    let userId: String
    let assignmentName: String
    let courseName: String
    let score: Double?
    let grade: String?
    let pointsPossible: Double?
    let gradedAt: Date?
    let submittedAt: Date?
    let late: Bool
    let missing: Bool
    let excused: Bool
    let workflowState: String
    let gradingPeriodId: String?
    let gradeMatchesCurrentSubmission: Bool
    let htmlUrl: String?
    
    // MARK: - Computed Properties
    
    var percentage: Double? {
        guard let score = score, let pointsPossible = pointsPossible, pointsPossible > 0 else {
            return nil
        }
        return (score / pointsPossible) * 100
    }
    
    var formattedScore: String {
        if excused {
            return "Excused"
        }
        
        if missing {
            return "Missing"
        }
        
        if let grade = grade, !grade.isEmpty {
            return grade
        }
        
        if let score = score, let pointsPossible = pointsPossible {
            return "\(score)/\(pointsPossible)"
        }
        
        return "Not Graded"
    }
    
    var formattedPercentage: String? {
        guard let percentage = percentage else { return nil }
        return String(format: "%.1f%%", percentage)
    }
    
    var letterGrade: String? {
        guard let percentage = percentage else { return nil }
        
        switch percentage {
        case 97...100:
            return "A+"
        case 93..<97:
            return "A"
        case 90..<93:
            return "A-"
        case 87..<90:
            return "B+"
        case 83..<87:
            return "B"
        case 80..<83:
            return "B-"
        case 77..<80:
            return "C+"
        case 73..<77:
            return "C"
        case 70..<73:
            return "C-"
        case 67..<70:
            return "D+"
        case 63..<67:
            return "D"
        case 60..<63:
            return "D-"
        default:
            return "F"
        }
    }
    
    var status: GradeStatus {
        if excused {
            return .excused
        } else if missing {
            return .missing
        } else if late {
            return .late
        } else if score != nil {
            return .graded
        } else {
            return .notGraded
        }
    }
    
    // MARK: - Initialization
    
    init(from submission: AssignmentSubmissionResponse) {
        self.id = submission.id
        self.assignmentId = submission.assignmentId
        self.courseId = submission.courseId ?? ""
        self.userId = submission.userId
        self.assignmentName = "Assignment \(submission.assignmentId)" // Simplified since assignment is not available
        self.courseName = "" // Will need to be populated separately
        self.score = submission.score
        self.grade = submission.grade
        self.pointsPossible = nil // Will need to be set separately
        self.gradedAt = submission.gradedAt
        self.submittedAt = submission.submittedAt
        self.late = submission.late ?? false
        self.missing = submission.missing ?? false
        self.excused = submission.excused ?? false
        self.workflowState = submission.workflowState
        self.gradingPeriodId = submission.gradingPeriodId
        self.gradeMatchesCurrentSubmission = submission.gradeMatchesCurrentSubmission ?? true
        self.htmlUrl = submission.htmlUrl
    }
    
    init(
        id: String,
        assignmentId: String,
        courseId: String,
        userId: String,
        assignmentName: String,
        courseName: String,
        score: Double?,
        grade: String?,
        pointsPossible: Double?,
        gradedAt: Date?,
        submittedAt: Date?,
        late: Bool,
        missing: Bool,
        excused: Bool,
        workflowState: String,
        gradingPeriodId: String?,
        gradeMatchesCurrentSubmission: Bool,
        htmlUrl: String?
    ) {
        self.id = id
        self.assignmentId = assignmentId
        self.courseId = courseId
        self.userId = userId
        self.assignmentName = assignmentName
        self.courseName = courseName
        self.score = score
        self.grade = grade
        self.pointsPossible = pointsPossible
        self.gradedAt = gradedAt
        self.submittedAt = submittedAt
        self.late = late
        self.missing = missing
        self.excused = excused
        self.workflowState = workflowState
        self.gradingPeriodId = gradingPeriodId
        self.gradeMatchesCurrentSubmission = gradeMatchesCurrentSubmission
        self.htmlUrl = htmlUrl
    }
}

// MARK: - Supporting Types

enum GradeStatus {
    case notGraded
    case graded
    case late
    case missing
    case excused
    
    var displayText: String {
        switch self {
        case .notGraded:
            return "Not Graded"
        case .graded:
            return "Graded"
        case .late:
            return "Late"
        case .missing:
            return "Missing"
        case .excused:
            return "Excused"
        }
    }
    
    var color: String {
        switch self {
        case .notGraded:
            return "gray"
        case .graded:
            return "green"
        case .late:
            return "orange"
        case .missing:
            return "red"
        case .excused:
            return "blue"
        }
    }
}



/// Represents an assignment submission for API requests
struct AssignmentSubmission: Codable {
    let submissionType: String
    let body: String?
    let url: String?
    let fileIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case submissionType = "submission_type"
        case body
        case url
        case fileIds = "file_ids"
    }
    
    static func textSubmission(body: String) -> AssignmentSubmission {
        return AssignmentSubmission(
            submissionType: "online_text_entry",
            body: body,
            url: nil,
            fileIds: nil
        )
    }
    
    static func urlSubmission(url: String) -> AssignmentSubmission {
        return AssignmentSubmission(
            submissionType: "online_url",
            body: nil,
            url: url,
            fileIds: nil
        )
    }
    
    static func fileSubmission(fileIds: [String]) -> AssignmentSubmission {
        return AssignmentSubmission(
            submissionType: "online_upload",
            body: nil,
            url: nil,
            fileIds: fileIds
        )
    }
}

/// Represents a file attachment
struct Attachment: Codable, Hashable {
    let id: String
    let uuid: String?
    let folderId: String?
    let displayName: String
    let filename: String
    let contentType: String
    let url: String
    let size: Int
    let createdAt: Date
    let updatedAt: Date
    let unlockAt: Date?
    let locked: Bool
    let hidden: Bool
    let lockAt: Date?
    let hiddenForUser: Bool
    let thumbnailUrl: String?
    let modifiedAt: Date
    let mimeClass: String
    let mediaEntryId: String?
    let lockedForUser: Bool
    let lockInfo: LockInfo?
    let lockExplanation: String?
    let previewUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case folderId = "folder_id"
        case displayName = "display_name"
        case filename
        case contentType = "content-type"
        case url
        case size
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case unlockAt = "unlock_at"
        case locked
        case hidden
        case lockAt = "lock_at"
        case hiddenForUser = "hidden_for_user"
        case thumbnailUrl = "thumbnail_url"
        case modifiedAt = "modified_at"
        case mimeClass = "mime_class"
        case mediaEntryId = "media_entry_id"
        case lockedForUser = "locked_for_user"
        case lockInfo = "lock_info"
        case lockExplanation = "lock_explanation"
        case previewUrl = "preview_url"
    }
}

/// Represents a submission comment
struct SubmissionComment: Codable, Hashable {
    let id: String
    let authorId: String
    let authorName: String
    let comment: String
    let createdAt: Date
    let editedAt: Date?
    let mediaComment: MediaComment?
    let attachments: [Attachment]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case authorName = "author_name"
        case comment
        case createdAt = "created_at"
        case editedAt = "edited_at"
        case mediaComment = "media_comment"
        case attachments
    }
}

/// Represents a media comment
struct MediaComment: Codable, Hashable {
    let mediaId: String
    let mediaType: String
    let url: String?
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case mediaType = "media_type"
        case url
        case displayName = "display_name"
    }
}

/// Represents a rubric assessment
struct RubricAssessment: Codable, Hashable {
    let points: Double?
    let rating: String?
    let comments: String?
    
    enum CodingKeys: String, CodingKey {
        case points
        case rating
        case comments
    }
}

/// Represents a file upload response
struct FileUploadResponse: Codable {
    let id: String
    let uuid: String?
    let displayName: String
    let filename: String
    let contentType: String
    let url: String
    let size: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case displayName = "display_name"
        case filename
        case contentType = "content-type"
        case url
        case size
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}