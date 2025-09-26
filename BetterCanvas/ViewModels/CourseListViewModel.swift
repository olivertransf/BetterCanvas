import Combine
import CoreData
import Foundation

/// ViewModel for managing the course list view
@MainActor
class CourseListViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var courses: [Course] = []
  @Published var isLoading: Bool = false
  @Published var isRefreshing: Bool = false
  @Published var errorMessage: String?
  @Published var searchText: String = ""
  @Published var showOnlyStarred: Bool = false

  // MARK: - Private Properties

  private let apiService: CanvasAPIService
  private let coreDataManager: CoreDataManager
  private let dataSyncManager: DataSyncManager
  private let favoritesManager = FavoritesManager.shared
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Computed Properties

  var filteredCourses: [Course] {
    var filtered = courses

    // Apply starred filter if enabled
    if showOnlyStarred {
      filtered = filtered.filter { course in
        favoritesManager.isFavorite(courseId: course.id)
      }
    }

    // Apply search filter only if user is searching
    if !searchText.isEmpty {
      filtered = filtered.filter { course in
        (course.name?.localizedCaseInsensitiveContains(searchText) ?? false)
          || (course.courseCode?.localizedCaseInsensitiveContains(searchText) ?? false)
      }
    }

    return filtered.sorted { ($0.name ?? "") < ($1.name ?? "") }
  }

  var hasError: Bool {
    errorMessage != nil
  }

  // MARK: - Initialization

  init(
    apiService: CanvasAPIService? = nil,
    coreDataManager: CoreDataManager? = nil,
    dataSyncManager: DataSyncManager? = nil
  ) {
    if let apiService = apiService {
      self.apiService = apiService
    } else {
      self.apiService = CanvasAPIService()
    }

    if let coreDataManager = coreDataManager {
      self.coreDataManager = coreDataManager
    } else {
      // Use factory method to avoid ambiguous shared reference
      self.coreDataManager = CoreDataManager.createInstance()
    }

    if let dataSyncManager = dataSyncManager {
      self.dataSyncManager = dataSyncManager
    } else {
      self.dataSyncManager = DataSyncManager()
    }

    setupBindings()
    // Removed automatic loading - courses will only load when user clicks refresh
  }

  // MARK: - Public Methods

  /// Loads courses from cache and refreshes from API if needed
  func loadCourses() async {
    guard !isLoading else { return }

    isLoading = true
    errorMessage = nil

    defer {
      isLoading = false
    }

    do {
      // Try to sync if needed
      try await dataSyncManager.syncIfNeeded()

      // Load from cache
      loadCachedCourses()

    } catch {
      handleError(error)
    }
  }

  /// Refreshes courses from API
  func refreshCourses() async {
    guard !isRefreshing else { return }

    isRefreshing = true
    errorMessage = nil

    defer {
      isRefreshing = false
    }

    do {
      // Force sync from API to fetch all courses
      try await dataSyncManager.syncCourses()

      // Reload from cache
      loadCachedCourses()

    } catch {
      handleError(error)
    }
  }

  /// Fetches all courses from API (alias for refreshCourses for clarity)
  func fetchAllCourses() async {
    await refreshCourses()
  }

  /// Searches courses with the given text
  func searchCourses(with text: String) {
    searchText = text
  }

  /// Toggles the starred courses filter
  func toggleStarredFilter() {
    showOnlyStarred.toggle()
  }

  /// Toggles favorite status for a specific course
  func toggleFavorite(for courseId: String) {
    favoritesManager.toggleFavorite(courseId: courseId)
  }


  /// Gets course by ID
  func getCourse(by id: String) -> Course? {
    return courses.first { $0.id == id }
  }

  /// Clears any error messages
  func clearError() {
    errorMessage = nil
  }

  // MARK: - Private Methods

  private func setupBindings() {
    // Listen for sync manager updates
    dataSyncManager.$isSyncing
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isSyncing in
        if !isSyncing {
          self?.loadCachedCourses()
        }
      }
      .store(in: &cancellables)

    dataSyncManager.$syncError
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        if let error = error {
          self?.handleError(error)
        }
      }
      .store(in: &cancellables)
    
    // Listen for favorites changes to update UI
    favoritesManager.$favoriteCourseIds
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        // Trigger UI update when favorites change
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  private func loadCachedCourses() {
    do {
      let courseEntities = try coreDataManager.fetchCourses()
      courses = courseEntities.compactMap { entity in
        convertToModel(entity)
      }
    } catch {
      handleError(error)
    }
  }

  private func convertToModel(_ entity: CourseEntity) -> Course? {
    guard let id = entity.id else {
      return nil
    }

    return Course(
      id: id,
      name: entity.name,
      courseCode: entity.courseCode ?? "",
      workflowState: entity.enrollmentState ?? "available"
    )
  }

  private func handleError(_ error: Error) {
    print("❌ CourseListViewModel Error: \(error)")

    if let networkError = error as? NetworkError {
      errorMessage = networkError.localizedDescription
      print("❌ Network Error Details: \(networkError)")
    } else if let coreDataError = error as? CoreDataError {
      errorMessage = coreDataError.localizedDescription
      print("❌ CoreData Error Details: \(coreDataError)")
    } else {
      errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
      print("❌ Unknown Error Details: \(error)")
    }
  }
}

