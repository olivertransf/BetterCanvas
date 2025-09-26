import XCTest
import CoreData
@testable import BetterCanvas

final class CoreDataRelationshipTest: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "CanvasDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        testContext = container.viewContext
    }
    
    override func tearDown() {
        testContext = nil
        super.tearDown()
    }
    
    func testCoreDataRelationships() {
        // Test that Core Data entities can be created and relationships work
        let courseEntity = CourseEntity(context: testContext)
        courseEntity.id = "test-course"
        courseEntity.name = "Test Course"
        
        let gradeEntity = GradeEntity(context: testContext)
        gradeEntity.id = "test-grade"
        gradeEntity.assignmentName = "Test Assignment"
        gradeEntity.course = courseEntity
        
        // Verify the relationship
        XCTAssertEqual(gradeEntity.course?.id, "test-course")
        XCTAssertTrue(courseEntity.grades?.contains(gradeEntity) == true)
        
        // Test saving
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
    }
}