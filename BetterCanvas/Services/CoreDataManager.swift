import Foundation
import CoreData

/// Manages Core Data operations for the Canvas app
class CoreDataManager: DataManagerProtocol {
    
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CanvasDataModel")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, you should handle this error appropriately
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // Factory method to avoid ambiguous shared references
    static func createInstance() -> CoreDataManager {
        return shared
    }
    
    // MARK: - Core Data Operations
    
    /// Saves the view context
    func save() {
        save(context: viewContext)
    }
    
    /// Saves a specific context
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    /// Performs a background task
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let context = backgroundContext
            context.perform {
                do {
                    let result = try block(context)
                    try context.save()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Deletes all data for a specific entity
    func deleteAll<T: NSManagedObject>(entityType: T.Type) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try viewContext.execute(deleteRequest)
        try viewContext.save()
    }
    
    // MARK: - Course Operations
    
    /// Saves courses to Core Data
    func saveCourses(_ courses: [Course]) async throws {
        try await performBackgroundTask { context in
            for course in courses {
                let courseEntity = self.findOrCreateCourse(id: course.id, in: context)
                self.updateCourseEntity(courseEntity, with: course)
            }
        }
    }
    
    /// Fetches all courses from Core Data
    func fetchCourses() throws -> [CourseEntity] {
        let request: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CourseEntity.name, ascending: true)]
        
        return try viewContext.fetch(request)
    }
    
    /// Finds a course by ID
    func findCourse(id: String) throws -> CourseEntity? {
        let request: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        return try viewContext.fetch(request).first
    }
    
    // MARK: - Assignment Operations
    
    /// Saves assignments to Core Data
    func saveAssignments(_ assignments: [Assignment], for courseId: String) async throws {
        try await performBackgroundTask { context in
            guard let courseEntity = try? self.findCourse(id: courseId, in: context) else {
                throw CoreDataError.courseNotFound
            }
            
            for assignment in assignments {
                let assignmentEntity = self.findOrCreateAssignment(id: assignment.id, in: context)
                self.updateAssignmentEntity(assignmentEntity, with: assignment, course: courseEntity)
            }
        }
    }
    
    /// Fetches assignments for a course
    func fetchAssignments(for courseId: String) throws -> [AssignmentEntity] {
        let request: NSFetchRequest<AssignmentEntity> = AssignmentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "course.id == %@", courseId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AssignmentEntity.dueAt, ascending: true)]
        
        return try viewContext.fetch(request)
    }
    
    // MARK: - Grade Operations
    
    /// Saves grades to Core Data
    func saveGrades(_ grades: [Grade], for courseId: String) async throws {
        try await performBackgroundTask { context in
            guard let courseEntity = try? self.findCourse(id: courseId, in: context) else {
                throw CoreDataError.courseNotFound
            }
            
            for grade in grades {
                let gradeEntity = self.findOrCreateGrade(id: grade.id, in: context)
                self.updateGradeEntity(gradeEntity, with: grade, course: courseEntity)
            }
        }
    }
    
    /// Fetches grades for a course
    func fetchGrades(for courseId: String) throws -> [GradeEntity] {
        let request: NSFetchRequest<GradeEntity> = GradeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "course.id == %@", courseId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GradeEntity.assignmentName, ascending: true)]
        
        return try viewContext.fetch(request)
    }
    
    // MARK: - Discussion Operations
    
    /// Saves discussions to Core Data
    func saveDiscussions(_ discussions: [Discussion], for courseId: String) async throws {
        try await performBackgroundTask { context in
            guard let courseEntity = try? self.findCourse(id: courseId, in: context) else {
                throw CoreDataError.courseNotFound
            }
            
            for discussion in discussions {
                let discussionEntity = self.findOrCreateDiscussion(id: discussion.id, in: context)
                self.updateDiscussionEntity(discussionEntity, with: discussion, course: courseEntity)
            }
        }
    }
    
    /// Fetches discussions for a course
    func fetchDiscussions(for courseId: String) throws -> [DiscussionEntity] {
        let request: NSFetchRequest<DiscussionEntity> = DiscussionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "course.id == %@", courseId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DiscussionEntity.postedAt, ascending: false)]
        
        return try viewContext.fetch(request)
    }
    
    // MARK: - User Operations
    
    /// Saves user to Core Data
    func saveUser(_ user: User) async throws {
        try await performBackgroundTask { context in
            let userEntity = self.findOrCreateUser(id: user.id, in: context)
            self.updateUserEntity(userEntity, with: user)
        }
    }
    
    /// Fetches current user
    func fetchCurrentUser() throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
        
        return try viewContext.fetch(request).first
    }
    
    // MARK: - Cache Management
    
    /// Checks if data is stale and needs refresh
    func isDataStale(for entity: NSManagedObject, maxAge: TimeInterval = 300) -> Bool {
        guard let lastSyncDate = entity.value(forKey: "lastSyncDate") as? Date else {
            return true // No sync date means stale
        }
        
        return Date().timeIntervalSince(lastSyncDate) > maxAge
    }
    
    /// Updates last sync date for an entity
    func updateLastSyncDate(for entity: NSManagedObject) {
        entity.setValue(Date(), forKey: "lastSyncDate")
    }
    
    // MARK: - Private Helper Methods
    
    private func findOrCreateCourse(id: String, in context: NSManagedObjectContext) -> CourseEntity {
        if let existing = try? findCourse(id: id, in: context) {
            return existing
        }
        
        let courseEntity = CourseEntity(context: context)
        courseEntity.id = id
        return courseEntity
    }
    
    private func findCourse(id: String, in context: NSManagedObjectContext) throws -> CourseEntity? {
        let request: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func updateCourseEntity(_ entity: CourseEntity, with course: Course) {
        entity.name = course.name
        entity.courseCode = course.courseCode
        entity.startAt = course.startAt
        entity.endAt = course.endAt
        entity.enrollmentState = course.workflowState
        updateLastSyncDate(for: entity)
    }
    
    private func findOrCreateAssignment(id: String, in context: NSManagedObjectContext) -> AssignmentEntity {
        let request: NSFetchRequest<AssignmentEntity> = AssignmentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let assignmentEntity = AssignmentEntity(context: context)
        assignmentEntity.id = id
        return assignmentEntity
    }
    
    private func updateAssignmentEntity(_ entity: AssignmentEntity, with assignment: Assignment, course: CourseEntity) {
        entity.name = assignment.name
        entity.assignmentDescription = assignment.description
        entity.dueAt = assignment.dueAt
        entity.pointsPossible = assignment.pointsPossible ?? 0
        entity.submissionTypes = assignment.submissionTypes as NSObject?
        entity.hasSubmittedSubmissions = assignment.hasSubmittedSubmissions ?? false
        entity.course = course
        updateLastSyncDate(for: entity)
    }
    
    private func findOrCreateGrade(id: String, in context: NSManagedObjectContext) -> GradeEntity {
        let request: NSFetchRequest<GradeEntity> = GradeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let gradeEntity = GradeEntity(context: context)
        gradeEntity.id = id
        return gradeEntity
    }
    
    private func updateGradeEntity(_ entity: GradeEntity, with grade: Grade, course: CourseEntity) {
        entity.assignmentId = grade.assignmentId
        entity.assignmentName = grade.assignmentName
        entity.currentScore = grade.score ?? 0
        entity.currentGrade = grade.grade
        entity.pointsPossible = grade.pointsPossible ?? 0
        entity.course = course
        updateLastSyncDate(for: entity)
    }
    
    private func findOrCreateDiscussion(id: String, in context: NSManagedObjectContext) -> DiscussionEntity {
        let request: NSFetchRequest<DiscussionEntity> = DiscussionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let discussionEntity = DiscussionEntity(context: context)
        discussionEntity.id = id
        return discussionEntity
    }
    
    private func updateDiscussionEntity(_ entity: DiscussionEntity, with discussion: Discussion, course: CourseEntity) {
        entity.title = discussion.title
        entity.message = discussion.message
        entity.postedAt = discussion.postedAt
        entity.authorName = discussion.authorName
        entity.repliesCount = Int32(discussion.repliesCount ?? 0)
        entity.course = course
        updateLastSyncDate(for: entity)
    }
    
    private func findOrCreateUser(id: String, in context: NSManagedObjectContext) -> UserEntity {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let userEntity = UserEntity(context: context)
        userEntity.id = id
        return userEntity
    }
    
    private func updateUserEntity(_ entity: UserEntity, with user: User) {
        entity.name = user.name
        entity.email = user.email
        entity.avatarURL = user.avatarURL
        updateLastSyncDate(for: entity)
    }
    
    // MARK: - DataManagerProtocol Implementation
    
    func getCachedCourses() async throws -> [Course] {
        let courseEntities = try fetchCourses()
        return courseEntities.compactMap { entity in
            Course(
                id: entity.id ?? "",
                name: entity.name,
                courseCode: entity.courseCode,
                workflowState: entity.enrollmentState
            )
        }
    }
    
    func getCachedAssignments(for courseId: String) async throws -> [Assignment] {
        let assignmentEntities = try fetchAssignments(for: courseId)
        return assignmentEntities.compactMap { entity in
            Assignment(
                id: entity.id ?? "",
                name: entity.name ?? "",
                description: entity.assignmentDescription,
                courseId: courseId,
                dueAt: entity.dueAt,
                pointsPossible: entity.pointsPossible > 0 ? entity.pointsPossible : nil,
                submissionTypes: entity.submissionTypes as? [String]
            )
        }
    }
    
    func getCachedDiscussions(for courseId: String) async throws -> [Discussion] {
        let discussionEntities = try fetchDiscussions(for: courseId)
        return discussionEntities.compactMap { entity in
            // Create a minimal Discussion object with required fields
            // Note: This is a simplified version since we don't have all the fields in Core Data
            let jsonData = """
            {
                "id": "\(entity.id ?? "")",
                "title": "\(entity.title ?? "")",
                "html_url": "https://example.com/discussions/\(entity.id ?? "")",
                "message": \(entity.message != nil ? "\"\(entity.message!)\"" : "null"),
                "posted_at": \(entity.postedAt != nil ? "\"\(ISO8601DateFormatter().string(from: entity.postedAt!))\"" : "null"),
                "user_name": \(entity.authorName != nil ? "\"\(entity.authorName!)\"" : "null"),
                "discussion_subentry_count": \(entity.repliesCount)
            }
            """.data(using: .utf8)!
            
            do {
                return try JSONDecoder().decode(Discussion.self, from: jsonData)
            } catch {
                print("Failed to decode discussion: \(error)")
                return nil
            }
        }
    }
    
    func getCachedGrades(for courseId: String) async throws -> [Grade] {
        let gradeEntities = try fetchGrades(for: courseId)
        return gradeEntities.compactMap { entity in
            Grade(
                id: entity.id ?? "",
                assignmentId: entity.assignmentId ?? "",
                courseId: courseId,
                userId: "", // Not stored in entity
                assignmentName: entity.assignmentName ?? "",
                courseName: "", // Not stored in entity
                score: entity.currentScore > 0 ? entity.currentScore : nil,
                grade: entity.currentGrade,
                pointsPossible: entity.pointsPossible > 0 ? entity.pointsPossible : nil,
                gradedAt: nil, // Not stored in entity
                submittedAt: nil, // Not stored in entity
                late: false, // Default value since not stored in entity
                missing: false, // Default value since not stored in entity
                excused: false, // Default value since not stored in entity
                workflowState: "submitted", // Default value since not stored in entity
                gradingPeriodId: nil, // Not stored in entity
                gradeMatchesCurrentSubmission: true, // Default value since not stored in entity
                htmlUrl: nil // Not stored in entity
            )
        }
    }
    
    func clearCache() async throws {
        try deleteAll(entityType: CourseEntity.self)
        try deleteAll(entityType: AssignmentEntity.self)
        try deleteAll(entityType: DiscussionEntity.self)
        try deleteAll(entityType: GradeEntity.self)
        try deleteAll(entityType: UserEntity.self)
    }
    
    func syncWhenOnline() async throws {
        // This would typically trigger a sync with the API
        // For now, we'll just update the last sync date
        print("Sync when online - implementation needed")
    }
    
    func isDataAvailableOffline(for courseId: String) async -> Bool {
        do {
            let course = try findCourse(id: courseId)
            return course != nil
        } catch {
            return false
        }
    }
}

// MARK: - Core Data Errors

enum CoreDataError: LocalizedError {
    case courseNotFound
    case assignmentNotFound
    case userNotFound
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .courseNotFound:
            return "Course not found in local database"
        case .assignmentNotFound:
            return "Assignment not found in local database"
        case .userNotFound:
            return "User not found in local database"
        case .saveFailed:
            return "Failed to save data to local database"
        case .fetchFailed:
            return "Failed to fetch data from local database"
        }
    }
}
