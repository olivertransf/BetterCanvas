//
//  SubmissionEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias SubmissionEntityCoreDataPropertiesSet = NSSet

extension SubmissionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubmissionEntity> {
        return NSFetchRequest<SubmissionEntity>(entityName: "SubmissionEntity")
    }

    @NSManaged public var fileURL: String?
    @NSManaged public var id: String?
    @NSManaged public var submissionType: String?
    @NSManaged public var submittedAt: Date?
    @NSManaged public var textContent: String?
    @NSManaged public var assignment: AssignmentEntity?

}

extension SubmissionEntity : Identifiable {

}
