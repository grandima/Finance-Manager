//
//  SyncObject+CoreDataProperties.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SyncObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate?
    @NSManaged var remoteID: String?
    @NSManaged var syncStatus: NSNumber

}
