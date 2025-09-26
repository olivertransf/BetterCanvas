//
//  DiscussionPostEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias DiscussionPostEntityCoreDataPropertiesSet = NSSet

extension DiscussionPostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiscussionPostEntity> {
        return NSFetchRequest<DiscussionPostEntity>(entityName: "DiscussionPostEntity")
    }

    @NSManaged public var authorName: String?
    @NSManaged public var id: String?
    @NSManaged public var message: String?
    @NSManaged public var postedAt: Date?
    @NSManaged public var discussion: DiscussionEntity?

}

extension DiscussionPostEntity : Identifiable {

}
