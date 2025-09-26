import Foundation
import CoreData

/// Protocol defining the data management interface for local storage and caching
protocol DataManagerProtocol {
    /// Save courses to local storage
    func saveCourses(_ courses: [Course]) async throws
    
    /// Retrieve cached courses from local storage
    func getCachedCourses() async throws -> [Course]
    
    /// Save assignments to local storage
    func saveAssignments(_ assignments: [Assignment], for courseId: String) async throws
    
    /// Retrieve cached assignments for a course
    func getCachedAssignments(for courseId: String) async throws -> [Assignment]
    
    /// Save discussions to local storage
    func saveDiscussions(_ discussions: [Discussion], for courseId: String) async throws
    
    /// Retrieve cached discussions for a course
    func getCachedDiscussions(for courseId: String) async throws -> [Discussion]
    
    /// Save grades to local storage
    func saveGrades(_ grades: [Grade], for courseId: String) async throws
    
    /// Retrieve cached grades for a course
    func getCachedGrades(for courseId: String) async throws -> [Grade]
    
    /// Clear all cached data
    func clearCache() async throws
    
    /// Sync data when online
    func syncWhenOnline() async throws
    
    /// Check if data is available offline
    func isDataAvailableOffline(for courseId: String) async -> Bool
}