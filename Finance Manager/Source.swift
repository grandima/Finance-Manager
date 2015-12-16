//
//  Source.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Source: SyncObject {
    
    //static let entityName = "Source"
    init(context: NSManagedObjectContext,
        balance: NSNumber = NSNumber(double: 0),
        name: String,
        createdAt: NSDate = NSDate(),
        updatedAt: NSDate? = nil,
        remoteID: String? = nil,
        syncStatus: NSNumber = NSNumber(int: 0)) {
            let entity = NSEntityDescription.entityForName(Source.className(), inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)

            self.balance = balance
            self.name = name
            self.createdAt = createdAt

            self.remoteID = remoteID
            self.syncStatus = syncStatus
    }


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    override class func fetchAllObjects(sortDescriptors: [NSSortDescriptor]? = nil, managedObjectContext: NSManagedObjectContext) throws -> [NSManagedObject]{
        let request = NSFetchRequest(entityName: className())
        request.sortDescriptors = sortDescriptors
        request.relationshipKeyPathsForPrefetching = ["incomes"]
        var result: [Source]
        result = try managedObjectContext.executeFetchRequest(request) as! [Source]
        return result
    }

    override class func mostResentUpdatedEntity(managedObjectContext: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest(entityName: className())
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        let result: NSManagedObject?
        result = (try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]).first
        return result
    }

    override func fillObject(json: JSON) {
        super.fillObject(json)
        balance = json["balance"].doubleValue
        name = json["name"].stringValue


    }

    override func JSONToCreateObjectOnServer() -> JSON? {
        guard var json = super.JSONToCreateObjectOnServer() else {
            return nil
        }
        json["balance"] = JSON(balance)
        json["name"] = JSON(name)
        return json
    }

}

extension Source: DestinationExtension {
    func getName() -> String {
        return name
    }
}