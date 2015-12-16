//
//  Income.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Income: SyncObject {

    //static let entityName = "Income"
    init(context: NSManagedObjectContext,
        amount: NSNumber,
        source: Source,
        createdAt: NSDate = NSDate(),
        updatedAt: NSDate? = nil,
        remoteID: String? = nil,
        syncStatus: NSNumber = NSNumber(int: 0)) {
            let entity = NSEntityDescription.entityForName(Income.className(), inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)

            self.amount = amount
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
        var result: [Income]
        result = try managedObjectContext.executeFetchRequest(request) as! [Income]
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
    }

    override func JSONToCreateObjectOnServer() -> JSON? {
        guard var json = super.JSONToCreateObjectOnServer() else {
            return nil
        }
        json["sum"] = JSON(amount.integerValue)
        json["source"] = JSON(source.remoteID!)
        return json
    }


}
extension Income {

}

extension Income: Trackable {
    func getMoney() -> NSNumber {
        return amount
    }
    func getDestinationObject() -> SyncObject {
        return source
    }
}