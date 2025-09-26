//
//  DiscussionEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias DiscussionEntityCoreDataPropertiesSet = NSSet

extension DiscussionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiscussionEntity> {
        return NSFetchRequest<DiscussionEntity>(entityName: "DiscussionEntity")
    }

    @NSManaged public var authorName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var message: String?
    @NSManaged public var postedAt: Date?
    @NSManaged public var repliesCount: Int32
    @NSManaged public var title: String?
    @NSManaged public var course: CourseEntity?
    @NSManaged public var posts: NSSet?

}

// MARK: Generated accessors for posts
extension DiscussionEntity {

    @objc(addPostsObject:)
    @NSManaged public func addToPosts(_ value: DiscussionPostEntity)

    @objc(removePostsObject:)
    @NSManaged public func removeFromPosts(_ value: DiscussionPostEntity)

    @objc(addPosts:)
    @NSManaged public func addToPosts(_ values: NSSet)

    @objc(removePosts:)
    @NSManaged public func removeFromPosts(_ values: NSSet)

}

extension DiscussionEntity : Identifiable {

}
