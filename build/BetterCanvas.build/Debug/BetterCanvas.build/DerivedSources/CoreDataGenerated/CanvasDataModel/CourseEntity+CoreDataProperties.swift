//
//  CourseEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias CourseEntityCoreDataPropertiesSet = NSSet

extension CourseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseEntity> {
        return NSFetchRequest<CourseEntity>(entityName: "CourseEntity")
    }

    @NSManaged public var courseCode: String?
    @NSManaged public var endAt: Date?
    @NSManaged public var enrollmentState: String?
    @NSManaged public var id: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var startAt: Date?
    @NSManaged public var assignments: NSSet?
    @NSManaged public var discussions: NSSet?
    @NSManaged public var grades: NSSet?

}

// MARK: Generated accessors for assignments
extension CourseEntity {

    @objc(addAssignmentsObject:)
    @NSManaged public func addToAssignments(_ value: AssignmentEntity)

    @objc(removeAssignmentsObject:)
    @NSManaged public func removeFromAssignments(_ value: AssignmentEntity)

    @objc(addAssignments:)
    @NSManaged public func addToAssignments(_ values: NSSet)

    @objc(removeAssignments:)
    @NSManaged public func removeFromAssignments(_ values: NSSet)

}

// MARK: Generated accessors for discussions
extension CourseEntity {

    @objc(addDiscussionsObject:)
    @NSManaged public func addToDiscussions(_ value: DiscussionEntity)

    @objc(removeDiscussionsObject:)
    @NSManaged public func removeFromDiscussions(_ value: DiscussionEntity)

    @objc(addDiscussions:)
    @NSManaged public func addToDiscussions(_ values: NSSet)

    @objc(removeDiscussions:)
    @NSManaged public func removeFromDiscussions(_ values: NSSet)

}

// MARK: Generated accessors for grades
extension CourseEntity {

    @objc(addGradesObject:)
    @NSManaged public func addToGrades(_ value: GradeEntity)

    @objc(removeGradesObject:)
    @NSManaged public func removeFromGrades(_ value: GradeEntity)

    @objc(addGrades:)
    @NSManaged public func addToGrades(_ values: NSSet)

    @objc(removeGrades:)
    @NSManaged public func removeFromGrades(_ values: NSSet)

}

extension CourseEntity : Identifiable {

}
