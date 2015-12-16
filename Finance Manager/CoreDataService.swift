//
//  CoreDataHelper.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 14.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit
import SwiftyJSON

class CoreDataService {
    let managedObjectContext: NSManagedObjectContext
    enum ManagedObjectName: String {
        case Income
        case Source
        case Transaction
        case Category
    }

    init(moc: NSManagedObjectContext) {
        managedObjectContext = moc
    }
}

extension CoreDataService {

    func mostRecentUpdatedEntityDate(entityName: String) -> NSDate? {
        var date: NSDate?
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        weak var weakMOC = managedObjectContext
        managedObjectContext.performBlockAndWait { () -> Void in
            do {
                let result = try weakMOC!.executeFetchRequest(request)
                date = result.last?.valueForKey("updatedAt") as? NSDate
            }catch {
                print ("Couldn't fetch \(error)")
            }
        }
        return date
    }

    func newManagedObject(className: String, json: JSON) {
        if let managedObjectName = ManagedObjectName(rawValue: className) {

            switch managedObjectName {
            case .Income:
                let request = NSFetchRequest(entityName: ManagedObjectName.Source.rawValue)
                request.predicate = NSPredicate(format: "remoteID == %@", String(json["source"].intValue))
                var source: Source?
                managedObjectContext.performBlockAndWait({ [unowned self]() -> Void in
                    do{
                        source = try (self.managedObjectContext.executeFetchRequest(request) as! [Source]).first
                    }catch {
                        print("Failed to fetch entity \(error))")
                    }
                })

                if(source != nil) {
                    let entity = NSEntityDescription.insertNewObjectForEntityForName(managedObjectName.rawValue, inManagedObjectContext: managedObjectContext) as! Income

                    for (key, _) in json {
                        if key == "source" {
                            entity.setValue(source, forKey: "source")
                            break
                        }
                    }
                    entity.syncStatus = SyncStatus.Synced.rawValue
                    entity.fillObject(json)
                }
            case .Transaction:
                var request = NSFetchRequest(entityName: ManagedObjectName.Source.rawValue)
                request.predicate = NSPredicate(format: "remoteID == %@", String(json["source"].intValue))
                var source: Source?
                managedObjectContext.performBlockAndWait({ [unowned self]() -> Void in
                    do{
                        source = try (self.managedObjectContext.executeFetchRequest(request) as! [Source]).first
                    }catch {
                        print("Failed to fetch entity \(error))")
                    }
                })
                request = NSFetchRequest(entityName: ManagedObjectName.Category.rawValue)
                request.predicate = NSPredicate(format: "remoteID == %@", String(json["category"].intValue))
                var category: Category?
                managedObjectContext.performBlockAndWait({ [unowned self]() -> Void in
                    do{
                        category = try (self.managedObjectContext.executeFetchRequest(request) as! [Category]).first
                    }catch {
                        print("Failed to fetch entity \(error))")
                    }
                })
                if(source != nil && category != nil) {
                    let entity = NSEntityDescription.insertNewObjectForEntityForName(managedObjectName.rawValue, inManagedObjectContext: managedObjectContext) as! Transaction
                    for (key, _) in json {
                        if key == "source" {
                            entity.setValue(source, forKey: "source")
                        } else if key == "category" {
                            entity.setValue(category, forKey: "category")
                        }
                    }
                    entity.syncStatus = SyncStatus.Synced.rawValue
                    entity.fillObject(json)
                }
            case .Source:
            let entity = NSEntityDescription.insertNewObjectForEntityForName(managedObjectName.rawValue, inManagedObjectContext: managedObjectContext) as! Source
                entity.syncStatus = SyncStatus.Synced.rawValue
                entity.fillObject(json)
            case .Category:
                let entity = NSEntityDescription.insertNewObjectForEntityForName(managedObjectName.rawValue, inManagedObjectContext: managedObjectContext) as! Category
                entity.syncStatus = SyncStatus.Synced.rawValue
                entity.fillObject(json)
            }
        }
    }
//NSFetchRequest(entityName: "Category")
    func updateManagedObject(managedObject: NSManagedObject, json: JSON) {
        for (k,v) in json.dictionary! {
            //print(k)
            if(k == "soure_id") {
                let request = NSFetchRequest(entityName: "Source")
                request.predicate = NSPredicate(format: "remoteID == %@", v.stringValue)
                var result: [NSManagedObject]!
                do {
                    result = try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
                }
                catch {
                    print("Cannot fetch destination: \(error)")
                }
                if let source = result.first {
                    managedObject.setValue(source, forKey: "source")
                }
            }else if(k == "category_id") {
                let request = NSFetchRequest(entityName: "Category")
                request.predicate = NSPredicate(format: "remoteID == %@", v.stringValue)
                var result: [NSManagedObject]!
                do {
                    result = try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
                }
                catch {
                    print("Cannot fetch destination: \(error)")
                }
                if let category = result.first {
                    managedObject.setValue(category, forKey: "category")
                }
            }else if(k == "updated") {
                //print(SyncService.sharedEngine.dateUsingStringFromAPI(v.stringValue))
                managedObject.setValue(SyncService.sharedEngine.dateUsingStringFromAPI(v.stringValue), forKey: "updatedAt")
            }else if (k == "sum") {
                managedObject.setValue(v.numberValue, forKey: "amount")
            }else if (k == "balance") {
                managedObject.setValue(v.numberValue, forKey: k)
            }else if (k == "name") {
                managedObject.setValue(v.stringValue, forKey: "name")
            }

        }

    }

    func managedObjects(className: String, syncStatus: SyncStatus?) -> [NSManagedObject] {
        var results = [NSManagedObject]()
        let request = NSFetchRequest(entityName: className)
        if let s = syncStatus {
            request.predicate = NSPredicate(format: "syncStatus = %d", s.rawValue)
        }else {
            request.predicate = NSPredicate(format: "syncStatus != %d", SyncStatus.Synced.rawValue)
        }
        managedObjectContext.performBlockAndWait {[unowned self]() -> Void in
            do {
                results = try self.managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
            }catch {
                print("Failed to fetch for \(className) \n \(error)")
            }
        }
        return results
    }

    func managedObjects(className: String, sortedByKey key: String, idArray: [String], inIds: Bool) -> [NSManagedObject] {
        var results = [NSManagedObject]()
        let request = NSFetchRequest(entityName: className)
        if inIds {
            request.predicate = NSPredicate(format: "remoteID IN %@", idArray)
        }else {
            request.predicate = NSPredicate(format: "!(remoteID IN %@)", idArray)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "remoteID", ascending: true)]
        managedObjectContext.performBlockAndWait { () -> Void in
            do {
                results = try self.managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
            }catch {
                print("Failed to fetch for \(className) \n \(error)")
            }
        }
        return results
    }

//    func managedObjects(className: String, sortedByKey key: String, idArray: [Double], inIds: Bool) -> [NSManagedObject] {
//        var results = [NSManagedObject]()
//        let request = NSFetchRequest(entityName: className)
//        if inIds {
//            request.predicate = NSPredicate(format: "balance IN %@", idArray)
//        }else {
//            request.predicate = NSPredicate(format: "!(balance IN %@)", idArray)
//        }
//        request.sortDescriptors = [NSSortDescriptor(key: "remoteID", ascending: true)]
//        managedObjectContext.performBlockAndWait { () -> Void in
//            do {
//                results = try self.managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
//            }catch {
//                print("Failed to fetch for \(className) \n \(error)")
//            }
//        }
//        return results
//    }




}