import Foundation

/// Protocol defining the Canvas API service interface
protocol CanvasAPIProtocol {
    /// Fetch all enrolled courses for the authenticated user
    func getCourses() async throws -> [Course]
    
    /// Fetch assignments for a specific course
    func getAssignments(courseId: String) async throws -> [Assignment]
    
    /// Fetch discussions for a specific course
    func getDiscussions(courseId: String) async throws -> [Discussion]
    
    /// Fetch grades for a specific course
    func getGrades(courseId: String) async throws -> [Grade]
    
    /// Fetch announcements for a specific course
    func getAnnouncements(courseId: String) async throws -> [Discussion] // Announcements are discussions
    
    /// Submit an assignment
    func submitAssignment(assignmentId: String, submission: AssignmentSubmission) async throws -> AssignmentSubmissionResponse
    
    /// Post a reply to a discussion
    func postDiscussionReply(discussionId: String, message: String) async throws -> DiscussionEntry
    
    /// Validate API token
    func validateToken() async throws -> Bool
}