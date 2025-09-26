//
//  UserEntity+CoreDataProperties.swift
//  
//
//  Created by Oliver Tran on 9/21/25.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias UserEntityCoreDataPropertiesSet = NSSet

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var avatarURL: String?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var lastSyncDate: Date?
    @NSManaged public var name: String?

}

extension UserEntity : Identifiable {

}
