//
//  Transaction.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Transaction: SyncObject {
    
    //static let entityName = "Transaction"
    init(context: NSManagedObjectContext,
        amount: NSNumber,
        category: Category,
        source: Source,
        createdAt: NSDate = NSDate(),
        updatedAt: NSDate? = nil,
        remoteID: String? = nil,
        syncStatus: NSNumber = NSNumber(int: 0)) {
            let entity = NSEntityDescription.entityForName(Transaction.className(), inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)

            self.amount = amount
            self.category = category
            self.source = source
            self.createdAt = createdAt

            if updatedAt == nil {
                self.updatedAt = createdAt
            } else {
                self.updatedAt = updatedAt!
            }
            self.remoteID = remoteID
            self.syncStatus = syncStatus
    }


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    override class func fetchAllObjects(sortDescriptors: [NSSortDescriptor]? = nil, managedObjectContext: NSManagedObjectContext) throws -> [NSManagedObject]{
        let request = NSFetchRequest(entityName: className())
        request.sortDescriptors = sortDescriptors
        var result: [Transaction]
        result = try managedObjectContext.executeFetchRequest(request) as! [Transaction]
        return result
    }

    override class func mostResentUpdatedEntity(managedObjectContext: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest(entityName: className())
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        let result: NSManagedObject?
        result = (try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]).first
        return result!
    }

    override func fillObject(json: JSON) {
        super.fillObject(json)
        amount = json["sum"].doubleValue
        print(amount)
    }

    override func JSONToCreateObjectOnServer() -> JSON? {
        guard var json = super.JSONToCreateObjectOnServer() else {
            return nil
        }
        json["sum"] = JSON(amount.doubleValue)
        json["source"] = JSON(source.remoteID!)
        json["category"] = JSON(category.remoteID!)
        return json
    }


}

extension Transaction: Trackable {
    func getMoney() -> NSNumber {
        return amount
    }
    func getDestinationObject() -> SyncObject {
        return source
    }
}
