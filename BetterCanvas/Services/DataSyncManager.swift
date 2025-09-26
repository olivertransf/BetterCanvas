import Combine
import CoreData
import Foundation

/// Manages data synchronization between Canvas API and local Core Data storage
@MainActor
class DataSyncManager: ObservableObject {

  // MARK: - Published Properties

  @Published var isSyncing: Bool = false
  @Published var lastSyncDate: Date?
  @Published var syncProgress: Double = 0.0
  @Published var syncStatus: String = ""
  @Published var syncError: Error?

  // MARK: - Private Properties

  private let apiService: CanvasAPIService
  private let coreDataManager: CoreDataManager
  private let userDefaults: UserDefaults
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Constants

  private enum UserDefaultsKeys {
    static let lastSyncDate = "lastSyncDate"
    static let syncInterval = "syncInterval"
  }

  private let defaultSyncInterval: TimeInterval = 300  // 5 minutes

  // MARK: - Initialization

  init(
    apiService: CanvasAPIService? = nil,
    coreDataManager: CoreDataManager? = nil,
    userDefaults: UserDefaults? = nil
  ) {
    if let apiService = apiService {
      self.apiService = apiService
    } else {
      self.apiService = CanvasAPIService()
    }

    if let coreDataManager = coreDataManager {
      self.coreDataManager = coreDataManager
    } else {
      let sharedCoreDataManager: CoreDataManager = CoreDataManager.shared
      self.coreDataManager = sharedCoreDataManager
    }

    if let userDefaults = userDefaults {
      self.userDefaults = userDefaults
    } else {
      self.userDefaults = UserDefaults.standard
    }

    loadLastSyncDate()
    setupAutoSync()
  }

  // MARK: - Public Methods

  /// Performs a full sync of all data
  func syncAll() async throws {
    guard !isSyncing else { return }

    isSyncing = true
    syncProgress = 0.0
    syncError = nil

    defer {
      isSyncing = false
      syncProgress = 1.0
    }

    do {
      syncStatus = "Syncing courses..."
      try await syncCourses()
      syncProgress = 0.2

      syncStatus = "Syncing assignments..."
      try await syncAllAssignments()
      syncProgress = 0.5

      syncStatus = "Syncing grades..."
      try await syncAllGrades()
      syncProgress = 0.7

      syncStatus = "Syncing discussions..."
      try await syncAllDiscussions()
      syncProgress = 0.9

      syncStatus = "Syncing user profile..."
      try await syncUserProfile()
      syncProgress = 1.0

      updateLastSyncDate()
      syncStatus = "Sync completed successfully"

    } catch {
      syncError = error
      syncStatus = "Sync failed: \(error.localizedDescription)"
      throw error
    }
  }

  /// Syncs only courses
  func syncCourses() async throws {
    let courses = try await apiService.getCourses()
    try await coreDataManager.saveCourses(courses)
  }

  /// Syncs assignments for a specific course
  func syncAssignments(for courseId: String) async throws {
    let assignments = try await apiService.getAssignments(courseId: courseId)
    try await coreDataManager.saveAssignments(assignments, for: courseId)
  }

  /// Syncs grades for a specific course
  func syncGrades(for courseId: String) async throws {
    let grades = try await apiService.getGrades(courseId: courseId)
    try await coreDataManager.saveGrades(grades, for: courseId)
  }

  /// Syncs discussions for a specific course
  func syncDiscussions(for courseId: String) async throws {
    let discussions = try await apiService.getDiscussions(courseId: courseId)
    try await coreDataManager.saveDiscussions(discussions, for: courseId)
  }

  /// Syncs user profile
  func syncUserProfile() async throws {
    let user = try await apiService.validateToken()
    try await coreDataManager.saveUser(user)
  }

  /// Checks if data needs to be synced based on last sync time
  func needsSync(maxAge: TimeInterval? = nil) -> Bool {
    let interval = maxAge ?? defaultSyncInterval

    guard let lastSync = lastSyncDate else {
      return true  // Never synced
    }

    return Date().timeIntervalSince(lastSync) > interval
  }

  /// Forces a sync if needed
  func syncIfNeeded() async throws {
    if needsSync() {
      try await syncAll()
    }
  }

  /// Handles offline modifications and conflict resolution
  func resolveConflicts() async throws {
    // This would implement conflict resolution logic
    // For now, we'll implement a simple "server wins" strategy

    syncStatus = "Resolving conflicts..."

    // Get all locally modified entities that haven't been synced
    let staleCourses = try getStaleEntities(CourseEntity.self)
    _ = try getStaleEntities(AssignmentEntity.self)  // staleAssignments - not used yet
    _ = try getStaleEntities(GradeEntity.self)  // staleGrades - not used yet

    // For each stale entity, fetch fresh data from server
    for course in staleCourses {
      if let courseId = course.id {
        do {
          let freshCourse = try await apiService.getCourse(id: courseId)
          try await coreDataManager.saveCourses([freshCourse])
        } catch {
          // Log error but continue with other entities
          print("Failed to resolve conflict for course \(courseId): \(error)")
        }
      }
    }

    // Similar logic for assignments and grades...
    syncStatus = "Conflicts resolved"
  }

  /// Gets sync statistics
  func getSyncStatistics() -> SyncStatistics {
    let coursesCount = (try? coreDataManager.fetchCourses().count) ?? 0

    return SyncStatistics(
      lastSyncDate: lastSyncDate,
      coursesCount: coursesCount,
      totalAssignmentsCount: getTotalAssignmentsCount(),
      totalGradesCount: getTotalGradesCount(),
      isSyncing: isSyncing,
      syncProgress: syncProgress
    )
  }

  // MARK: - Private Methods

  private func syncAllAssignments() async throws {
    let courses = try coreDataManager.fetchCourses()

    for course in courses {
      if let courseId = course.id {
        do {
          try await syncAssignments(for: courseId)
        } catch {
          // Log the error but continue with other courses
          print("⚠️ Failed to sync assignments for course \(courseId): \(error)")
          // Don't throw - continue with other courses
        }
      }
    }
  }

  private func syncAllGrades() async throws {
    let courses = try coreDataManager.fetchCourses()

    for course in courses {
      if let courseId = course.id {
        do {
          try await syncGrades(for: courseId)
        } catch {
          // Log the error but continue with other courses
          print("⚠️ Failed to sync grades for course \(courseId): \(error)")
          // Don't throw - continue with other courses
        }
      }
    }
  }

  private func syncAllDiscussions() async throws {
    let courses = try coreDataManager.fetchCourses()

    for course in courses {
      if let courseId = course.id {
        do {
          try await syncDiscussions(for: courseId)
        } catch {
          // Log the error but continue with other courses
          print("⚠️ Failed to sync discussions for course \(courseId): \(error)")
          // Don't throw - continue with other courses
        }
      }
    }
  }

  private func getStaleEntities<T: NSManagedObject>(_ entityType: T.Type) throws -> [T] {
    let request = NSFetchRequest<T>(entityName: String(describing: entityType))

    // Find entities that haven't been synced in the last hour
    let oneHourAgo = Date().addingTimeInterval(-3600)
    request.predicate = NSPredicate(
      format: "lastSyncDate < %@ OR lastSyncDate == nil", oneHourAgo as NSDate)

    return try coreDataManager.viewContext.fetch(request)
  }

  private func getTotalAssignmentsCount() -> Int {
    let courses = (try? coreDataManager.fetchCourses()) ?? []
    return courses.reduce(0) { total, course in
      let assignments = (try? coreDataManager.fetchAssignments(for: course.id ?? "")) ?? []
      return total + assignments.count
    }
  }

  private func getTotalGradesCount() -> Int {
    let courses = (try? coreDataManager.fetchCourses()) ?? []
    return courses.reduce(0) { total, course in
      let grades = (try? coreDataManager.fetchGrades(for: course.id ?? "")) ?? []
      return total + grades.count
    }
  }

  private func loadLastSyncDate() {
    if let date = userDefaults.object(forKey: UserDefaultsKeys.lastSyncDate) as? Date {
      lastSyncDate = date
    }
  }

  private func updateLastSyncDate() {
    let now = Date()
    lastSyncDate = now
    userDefaults.set(now, forKey: UserDefaultsKeys.lastSyncDate)
  }

  private func setupAutoSync() {
    // Set up a timer to check for sync needs periodically
    Timer.publish(every: 60, on: .main, in: .common)  // Check every minute
      .autoconnect()
      .sink { [weak self] _ in
        Task { @MainActor in
          guard let self = self else { return }

          if self.needsSync() && !self.isSyncing {
            do {
              try await self.syncIfNeeded()
            } catch {
              self.syncError = error
            }
          }
        }
      }
      .store(in: &cancellables)
  }
}

// MARK: - Supporting Types

struct SyncStatistics {
  let lastSyncDate: Date?
  let coursesCount: Int
  let totalAssignmentsCount: Int
  let totalGradesCount: Int
  let isSyncing: Bool
  let syncProgress: Double

  var formattedLastSyncDate: String {
    guard let lastSyncDate = lastSyncDate else {
      return "Never"
    }

    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(lastSyncDate) {
      formatter.dateFormat = "'Today at' h:mm a"
    } else if Calendar.current.isDateInYesterday(lastSyncDate) {
      formatter.dateFormat = "'Yesterday at' h:mm a"
    } else {
      formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
    }

    return formatter.string(from: lastSyncDate)
  }

  var syncStatusText: String {
    if isSyncing {
      return "Syncing... \(Int(syncProgress * 100))%"
    } else if lastSyncDate != nil {
      return "Last synced: \(formattedLastSyncDate)"
    } else {
      return "Not synced"
    }
  }
}

/// Represents different sync strategies
enum SyncStrategy {
  case serverWins  // Server data always overwrites local
  case clientWins  // Local data always overwrites server
  case mostRecent  // Most recently modified data wins
  case manual  // Require manual conflict resolution
}

/// Represents a sync conflict
struct SyncConflict {
  let entityId: String
  let entityType: String
  let localModifiedDate: Date
  let serverModifiedDate: Date
  let conflictType: ConflictType
}

enum ConflictType {
  case modified  // Both local and server versions modified
  case deleted  // One version deleted, other modified
  case created  // Created in both places with same ID
}

/// Errors that can occur during sync
enum SyncError: LocalizedError {
  case networkUnavailable
  case authenticationFailed
  case conflictResolutionFailed
  case dataCorruption
  case unknownError(Error)

  var errorDescription: String? {
    switch self {
    case .networkUnavailable:
      return "Network is unavailable. Please check your connection."
    case .authenticationFailed:
      return "Authentication failed. Please log in again."
    case .conflictResolutionFailed:
      return "Failed to resolve data conflicts."
    case .dataCorruption:
      return "Local data appears to be corrupted."
    case .unknownError(let error):
      return "An unknown error occurred: \(error.localizedDescription)"
    }
  }
}
