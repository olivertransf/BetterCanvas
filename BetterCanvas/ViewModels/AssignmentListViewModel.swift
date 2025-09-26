import Foundation
import SwiftUI
import Combine

/// ViewModel for managing assignment data and state
@MainActor
class AssignmentListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCourse: Course?
    @Published var showAllAssignments = true
    @Published var sortOption: AssignmentSortOption = .dueDate
    @Published var filterOption: AssignmentFilterOption = .all
    
    // MARK: - Private Properties
    
    private let canvasAPIService: CanvasAPIService
    private let dataManager: DataManagerProtocol
    private var courseCache: [String: Course] = [:]
    
    // MARK: - Initialization
    
    init(
        canvasAPIService: CanvasAPIService = CanvasAPIService(),
        dataManager: DataManagerProtocol? = nil
    ) {
        self.canvasAPIService = canvasAPIService
        self.dataManager = dataManager ?? CoreDataManager.shared
    }
    
    // MARK: - Public Methods
    
    /// Loads assignments for all courses or a specific course
    func loadAssignments(for course: Course? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let course = course {
                // Load assignments for specific course
                let courseAssignments = try await canvasAPIService.getAssignments(courseId: course.id)
                assignments = courseAssignments
                selectedCourse = course
                showAllAssignments = false
            } else {
                // Load assignments for all courses
                assignments = try await canvasAPIService.getAllAssignments()
                // Also load courses for caching
                let courses = try await canvasAPIService.getCourses()
                courseCache = Dictionary(uniqueKeysWithValues: courses.map { ($0.id, $0) })
                selectedCourse = nil
                showAllAssignments = true
            }
            
            // Apply current filters and sorting
            applyFiltersAndSorting()
            
        } catch {
            errorMessage = "Failed to load assignments: \(error.localizedDescription)"
            print("Error loading assignments: \(error)")
        }
        
        isLoading = false
    }
    
    /// Refreshes the current assignment list
    func refresh() async {
        await loadAssignments(for: selectedCourse)
    }
    
    /// Sets the sort option and re-sorts assignments
    func setSortOption(_ option: AssignmentSortOption) {
        sortOption = option
        applyFiltersAndSorting()
    }
    
    /// Sets the filter option and re-filters assignments
    func setFilterOption(_ option: AssignmentFilterOption) {
        filterOption = option
        applyFiltersAndSorting()
    }
    
    /// Clears the current course selection and shows all assignments
    func loadAllAssignments() {
        selectedCourse = nil
        showAllAssignments = true
        Task {
            await loadAssignments()
        }
    }
    
    // MARK: - Private Methods
    
    /// Applies current filters and sorting to assignments
    private func applyFiltersAndSorting() {
        var filteredAssignments = assignments
        
        // First, filter to only show assignments with due dates that are today or in the future
        let today = Calendar.current.startOfDay(for: Date())
        filteredAssignments = assignments.filter { assignment in
            guard let dueAt = assignment.dueAt else {
                // If no due date, exclude the assignment
                return false
            }
            // Only include assignments due today or in the future
            return dueAt >= today
        }
        
        // Apply additional filters
        switch filterOption {
        case .all:
            break // No additional filtering
        case .dueSoon:
            filteredAssignments = filteredAssignments.filter { $0.isDueSoon }
        case .overdue:
            filteredAssignments = filteredAssignments.filter { $0.isOverdue }
        case .submitted:
            filteredAssignments = filteredAssignments.filter { $0.submissionStatus == .submitted }
        case .notSubmitted:
            filteredAssignments = filteredAssignments.filter { $0.submissionStatus == .notSubmitted }
        }
        
        // Apply sorting
        switch sortOption {
        case .dueDate:
            filteredAssignments.sort { assignment1, assignment2 in
                // Handle nil due dates by putting them at the end
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
        case .course:
            filteredAssignments.sort { assignment1, assignment2 in
                assignment1.courseId < assignment2.courseId
            }
        case .name:
            filteredAssignments.sort { assignment1, assignment2 in
                assignment1.name < assignment2.name
            }
        case .points:
            filteredAssignments.sort { assignment1, assignment2 in
                let points1 = assignment1.pointsPossible ?? 0
                let points2 = assignment2.pointsPossible ?? 0
                return points1 > points2
            }
        }
        
        assignments = filteredAssignments
    }
    
    /// Gets the course name for an assignment
    func getCourseName(for assignment: Assignment) -> String {
        if let course = courseCache[assignment.courseId] {
            return course.displayName
        }
        return "Course \(assignment.courseId)"
    }
}

// MARK: - Supporting Types

enum AssignmentSortOption: String, CaseIterable {
    case dueDate = "Due Date"
    case course = "Course"
    case name = "Name"
    case points = "Points"
    
    var displayName: String {
        return self.rawValue
    }
}

enum AssignmentFilterOption: String, CaseIterable {
    case all = "All"
    case dueSoon = "Due Soon"
    case overdue = "Overdue"
    case submitted = "Submitted"
    case notSubmitted = "Not Submitted"
    
    var displayName: String {
        return self.rawValue
    }
}
