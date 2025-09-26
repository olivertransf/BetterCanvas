//
//  GradeEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias GradeEntityCoreDataPropertiesSet = NSSet

extension GradeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GradeEntity> {
        return NSFetchRequest<GradeEntity>(entityName: "GradeEntity")
    }

    @NSManaged public var assignmentId: String?
    @NSManaged public var assignmentName: String?
    @NSManaged public var currentGrade: String?
    @NSManaged public var currentScore: Double
    @NSManaged public var id: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var pointsPossible: Double
    @NSManaged public var course: CourseEntity?

}

extension GradeEntity : Identifiable {

}
