//
//  SyncObject.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
//enum Error
class SyncObject: NSManagedObject, JSONRepresentation {
    
    class func fetchAllObjects(sortDescriptors: [NSSortDescriptor]? = nil, managedObjectContext: NSManagedObjectContext) throws -> [NSManagedObject]{
        throw NSError(domain: "Override this method", code: 0, userInfo: nil)
    }

    class func mostResentUpdatedEntity(managedObjectContext: NSManagedObjectContext) throws -> NSManagedObject? {
        throw NSError(domain: "Override this method", code: 0, userInfo: nil)
    }

    func JSONToCreateObjectOnServer() -> JSON? {
        return JSON(["created" : JSON(SyncService.sharedEngine.dateStringForAPIUsingDate(createdAt))])

    }
    func fillObject(json: JSON) {
        self.createdAt = SyncService.sharedEngine.dateUsingStringFromAPI(json["created"].string!)
        self.updatedAt = SyncService.sharedEngine.dateUsingStringFromAPI(json["updated"].string!)
        self.remoteID = String(json["id"].intValue)
//        print(self.remoteID)
//        print(self.createdAt)
//        print(updatedAt)
    }

}

extension SyncObject: SObjectExtenstion {
    func getDate() -> NSDate {
        return createdAt
    }
}

