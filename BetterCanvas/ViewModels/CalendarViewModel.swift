import Foundation
import SwiftUI
import Combine

/// ViewModel for managing calendar data and assignments
@MainActor
class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var assignments: [Assignment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var currentMonth = Date()
    
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
    
    /// Loads assignments for the calendar
    func loadAssignments() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load assignments for all courses
            assignments = try await canvasAPIService.getAllAssignments()
            // Also load courses for caching
            let courses = try await canvasAPIService.getCourses()
            courseCache = Dictionary(uniqueKeysWithValues: courses.map { ($0.id, $0) })
            
        } catch {
            errorMessage = "Failed to load assignments: \(error.localizedDescription)"
            print("Error loading assignments: \(error)")
        }
        
        isLoading = false
    }
    
    /// Refreshes the assignment list
    func refresh() async {
        await loadAssignments()
    }
    
    /// Gets assignments for a specific date
    func getAssignments(for date: Date) -> [Assignment] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return assignments.filter { assignment in
            guard let dueAt = assignment.dueAt else { return false }
            return dueAt >= startOfDay && dueAt < endOfDay
        }
    }
    
    /// Gets assignments for the current month
    func getAssignmentsForCurrentMonth() -> [Date: [Assignment]] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        var assignmentsByDate: [Date: [Assignment]] = [:]
        
        // Get all dates in the current month
        var currentDate = startOfMonth
        while currentDate < endOfMonth {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayAssignments = assignments.filter { assignment in
                guard let dueAt = assignment.dueAt else { return false }
                return dueAt >= dayStart && dueAt < dayEnd
            }
            
            if !dayAssignments.isEmpty {
                assignmentsByDate[dayStart] = dayAssignments
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return assignmentsByDate
    }
    
    /// Navigates to the previous month
    func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    /// Navigates to the next month
    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    /// Gets the course name for an assignment
    func getCourseName(for assignment: Assignment) -> String {
        if let course = courseCache[assignment.courseId] {
            return course.displayName
        }
        return "Course \(assignment.courseId)"
    }
    
    /// Checks if a date has assignments
    func hasAssignments(for date: Date) -> Bool {
        return !getAssignments(for: date).isEmpty
    }
    
    /// Gets the number of assignments for a date
    func assignmentCount(for date: Date) -> Int {
        return getAssignments(for: date).count
    }
}
