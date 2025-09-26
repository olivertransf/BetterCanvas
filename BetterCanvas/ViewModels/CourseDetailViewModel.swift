import Foundation
import SwiftUI
import Combine

/// ViewModel for managing course detail data
@MainActor
class CourseDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var assignments: [Assignment] = []
    @Published var grades: [Grade] = []
    @Published var discussions: [Discussion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let canvasAPIService: CanvasAPIService
    private let dataManager: DataManagerProtocol
    
    // MARK: - Initialization
    
    init(
        canvasAPIService: CanvasAPIService = CanvasAPIService(),
        dataManager: DataManagerProtocol? = nil
    ) {
        self.canvasAPIService = canvasAPIService
        self.dataManager = dataManager ?? CoreDataManager.shared
    }
    
    // MARK: - Public Methods
    
    /// Loads all course data (assignments, grades, discussions)
    func loadCourseData(courseId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load all data in parallel
            async let assignmentsTask = loadAssignments(courseId: courseId)
            async let gradesTask = loadGrades(courseId: courseId)
            async let discussionsTask = loadDiscussions(courseId: courseId)
            
            // Wait for all tasks to complete
            let (assignments, grades, discussions) = try await (assignmentsTask, gradesTask, discussionsTask)
            
            self.assignments = assignments
            self.grades = grades
            self.discussions = discussions
            
        } catch {
            errorMessage = "Failed to load course data: \(error.localizedDescription)"
            print("Error loading course data: \(error)")
        }
        
        isLoading = false
    }
    
    /// Refreshes all course data
    func refreshCourseData(courseId: String) async {
        await loadCourseData(courseId: courseId)
    }
    
    // MARK: - Private Methods
    
    private func loadAssignments(courseId: String) async throws -> [Assignment] {
        do {
            return try await canvasAPIService.getAssignments(courseId: courseId)
        } catch {
            print("Failed to load assignments for course \(courseId): \(error)")
            return []
        }
    }
    
    private func loadGrades(courseId: String) async throws -> [Grade] {
        do {
            return try await canvasAPIService.getGrades(courseId: courseId)
        } catch {
            print("Failed to load grades for course \(courseId): \(error)")
            return []
        }
    }
    
    private func loadDiscussions(courseId: String) async throws -> [Discussion] {
        do {
            return try await canvasAPIService.getDiscussions(courseId: courseId)
        } catch {
            print("Failed to load discussions for course \(courseId): \(error)")
            return []
        }
    }
    
    // MARK: - Computed Properties
    
    /// Gets assignments sorted by due date
    var sortedAssignments: [Assignment] {
        assignments.sorted { assignment1, assignment2 in
            switch (assignment1.dueAt, assignment2.dueAt) {
            case (nil, nil):
                return assignment1.name < assignment2.name
            case (nil, _):
                return false
            case (_, nil):
                return true
            case (let date1?, let date2?):
                return date1 < date2
            }
        }
    }
    
    /// Gets grades sorted by assignment name
    var sortedGrades: [Grade] {
        grades.sorted { $0.assignmentName < $1.assignmentName }
    }
    
    /// Gets discussions sorted by last reply date
    var sortedDiscussions: [Discussion] {
        discussions.sorted { discussion1, discussion2 in
            switch (discussion1.lastReplyAt, discussion2.lastReplyAt) {
            case (nil, nil):
                return discussion1.title < discussion2.title
            case (nil, _):
                return false
            case (_, nil):
                return true
            case (let date1?, let date2?):
                return date1 > date2 // Most recent first
            }
        }
    }
    
    /// Calculates average grade percentage
    var averageGrade: Double? {
        let gradedAssignments = grades.filter { $0.score != nil && $0.pointsPossible != nil && $0.pointsPossible! > 0 }
        guard !gradedAssignments.isEmpty else { return nil }
        
        let totalPercentage = gradedAssignments.reduce(0.0) { sum, grade in
            guard let score = grade.score, let points = grade.pointsPossible, points > 0 else { return sum }
            return sum + (score / points) * 100
        }
        
        return totalPercentage / Double(gradedAssignments.count)
    }
    
    /// Gets formatted average grade
    var formattedAverageGrade: String {
        guard let average = averageGrade else { return "No grades yet" }
        return String(format: "%.1f%%", average)
    }
}
