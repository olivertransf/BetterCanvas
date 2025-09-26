//
//  AssignmentEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias AssignmentEntityCoreDataPropertiesSet = NSSet

extension AssignmentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssignmentEntity> {
        return NSFetchRequest<AssignmentEntity>(entityName: "AssignmentEntity")
    }

    @NSManaged public var assignmentDescription: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var hasSubmittedSubmissions: Bool
    @NSManaged public var id: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var pointsPossible: Double
    @NSManaged public var submissionTypes: [String]?
    @NSManaged public var course: CourseEntity?
    @NSManaged public var submissions: NSSet?

}

// MARK: Generated accessors for submissions
extension AssignmentEntity {

    @objc(addSubmissionsObject:)
    @NSManaged public func addToSubmissions(_ value: SubmissionEntity)

    @objc(removeSubmissionsObject:)
    @NSManaged public func removeFromSubmissions(_ value: SubmissionEntity)

    @objc(addSubmissions:)
    @NSManaged public func addToSubmissions(_ values: NSSet)

    @objc(removeSubmissions:)
    @NSManaged public func removeFromSubmissions(_ values: NSSet)

}

extension AssignmentEntity : Identifiable {

}
