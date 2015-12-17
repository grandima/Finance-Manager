//
//  SyncService.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 13.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON

enum RequestClassNames: String {
    case Income
    case Source
    case Transaction
    case Category

    func getUrlName () -> String {
        switch self {
        case .Income: return "income"
        case .Category: return "category"
        case .Transaction: return "transaction"
        case .Source: return "source"
        }
    }
}

enum SyncNotification: String {
    case SyncCompleted = "SyncCompleted", InitialSyncCompleted = "InitialSyncCompleted", StartSync = "StartSync"

    func postNotification() {
        switch self {
        case .SyncCompleted:
            NSNotificationCenter.defaultCenter().postNotificationName("SyncCompleted", object: nil)
        case .InitialSyncCompleted:
            NSNotificationCenter.defaultCenter().postNotificationName("InitialSyncCompleted", object: nil)
        case .StartSync:
            NSNotificationCenter.defaultCenter().postNotificationName(self.rawValue, object: nil)
        }
    }
}

enum SyncStatus: Int {
    case Created = 0, Deleted = 1, Updated = 2, Synced = 3

//    func getResponseClosure () -> ((Response<NSDictionary, NSError>) -> Void) {
//        switch self {
//        case .Created:
//            return {(response) -> Void in
//                response.
//                }
//        }
//    }
}
class SyncService {

    static let sharedEngine = SyncService()

    var syncInProgress = false
    var managedObjectContext: NSManagedObjectContext!

    private var registeredClassesToSync = [String]()

    private lazy var dateFormatter: NSDateFormatter! = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter
    }()
    private lazy var backgroundSyncQueue: dispatch_queue_t! = {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    }()

    //Unrelated Vars
    private lazy var applicationCacheDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last!
    }()

    private lazy var JSONDataRecordsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let url = NSURL(string: "JSONRecords/", relativeToURL: self.applicationCacheDirectory)!
        if (!fileManager.fileExistsAtPath(url.path!)) {
            do {
                try fileManager.createDirectoryAtPath(url.path!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Cannot create directory at path = \(url.path), \n reason \(error)")
            }
        }
        return url
    }()

    lazy var coreDataService: CoreDataService! = {
        return CoreDataService(moc: self.managedObjectContext)
    }()

    private lazy var initialSyncCompleted: Bool = {
        return Defaults[SyncNotification.InitialSyncCompleted.rawValue].boolValue
    }()


    @objc func startSync() {
        if (Defaults[HTTPService.udisLoggedIn].boolValue) {
            if !syncInProgress {
                syncInProgress = true

                dispatch_async(backgroundSyncQueue, { [unowned self] () -> Void in
                    self.downloadDataForRegisteredObjects(useUpdatedAtDate: true, toDeleteLocalRecords: false)
                    //TODO: - DOWNLOAD DATA
                    })
                }
        }
    }

    func registerToSync(className: String) {
        if registeredClassesToSync.contains(className) {
            print ("This class \(className) is already registered")
        } else {
            registeredClassesToSync.append(className)
        }
    }

    func setInitialSyncCompleted() {
        Defaults[SyncNotification.InitialSyncCompleted.rawValue] = true
        //NSUserDefaults.standardUserDefaults().synchronize()
    }

    func executeSyncCompletedOperations() {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] () -> Void in
            self.setInitialSyncCompleted()
            SyncNotification.InitialSyncCompleted.postNotification()
            self.syncInProgress = false
        }
    }
}

//MARK: - Sync methods
extension SyncService {

    func downloadDataForRegisteredObjects(useUpdatedAtDate useUpdatedAtDate: Bool, toDeleteLocalRecords toDelete: Bool) {
        let group: dispatch_group_t = dispatch_group_create()

        for className in registeredClassesToSync {
            dispatch_group_enter(group)

            var mostRecentUpdatedDate: NSDate?
            if (useUpdatedAtDate) {
                mostRecentUpdatedDate = coreDataService.mostRecentUpdatedEntityDate(className)
            }
            if (mostRecentUpdatedDate != nil) {
                mostRecentUpdatedDate = mostRecentUpdatedDate!.dateByAddingTimeInterval(1)
            }
            Alamofire.request(HTTPService.GETRequestForAllRecordsOfClass(className.lowercaseString, updatedAfter: mostRecentUpdatedDate)).validate().responseJSON(completionHandler: { (response) -> Void in
                switch response.result {
                case .Success:
                    self.writeJSONResponse(response.result.value! as! [String : AnyObject], className: className)
                case .Failure:
                    print(response.description)
                }


                //print(JSON(response.data))
                dispatch_group_leave(group)
            })
        }
        dispatch_group_notify(group, backgroundSyncQueue) { [unowned self]() -> Void in
            if(!toDelete) {
                self.processJSONDataRecordsIntoCoreData()
            } else {
                self.processJSONDataRecordsForDeletion()
            }

            
        }
    }

}

//MARK: File Management
extension SyncService {

    private func writeJSONResponse(response: [String: AnyObject], className: String) {
        let fileURL = NSURL(string: className, relativeToURL: JSONDataRecordsDirectory)
        if !(response as NSDictionary).writeToFile(fileURL!.path!, atomically: true) {
            var results = response
            if let records = results["results"] as? [[String: AnyObject]] {
                var nullFreeRecords = [[String: AnyObject]]()
                for record in records {
                    var nullFreeRecord = record
                    for (k,v) in record {
                        if v.isKindOfClass(NSNull) {
                            nullFreeRecord.removeValueForKey(k)
                        }
                    }
                    nullFreeRecords.append(nullFreeRecord)
                }
                let nullFreeDictionary = NSDictionary(object: nullFreeRecords, forKey: "results")
                if(!nullFreeDictionary.writeToFile(fileURL!.path!, atomically: true)) {
                    print("Failed all attempts to save response to disk: \(response)")
                }
            }

        }

    }
}
//MARK: Process remote service data into Core Data
extension SyncService {
    func deleteJSONDataRecords(className: String) {
        if let url = NSURL(string: className, relativeToURL: JSONDataRecordsDirectory){
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
            }catch {
                print("Error while deleting file for className \(className)")
            }
        }
    }

    func JSONDictionaryForClass(className: String) -> [String: NSObject]? {
        guard let fileURL = NSURL(string: className, relativeToURL: JSONDataRecordsDirectory) else { return nil}
        return NSDictionary(contentsOfURL: fileURL) as? [String: NSObject]

    }

    func JSONDataRecordsForClass(className: String, sortedByKey key: String) -> [[String: AnyObject]]? {
        if let dictionary = JSONDictionaryForClass(className){
            guard let records = dictionary["results"] as? [[String: AnyObject]] else {return nil}
            return records.sort { (left, right) -> Bool in
                return left[key]!.integerValue < right[key]!.integerValue
            }
        }
        return nil
    }

    func processJSONDataRecordsIntoCoreData() {
        for className in registeredClassesToSync {
            if(!initialSyncCompleted) {
                if let JSONDictionary = JSONDictionaryForClass(className) {
                    if let records = JSONDictionary["results"] as? [[String: AnyObject]]{
                        for dict in records {
                            //print(dict)
                            coreDataService.newManagedObject(className, json: JSON(dict))
                        }
                    }
                }
            }else {

                if let downloadedRecords = JSONDataRecordsForClass(className, sortedByKey: "id") {

                    if(downloadedRecords.last != nil) {
                        let strings = downloadedRecords.map{String($0["id"])}
                        let storedRecords = coreDataService.managedObjects(className, sortedByKey: "remoteID", idArray: strings, inIds: true)
                        var currentIndex = 0
                        for record in downloadedRecords {
                            var storedManagedObject: NSManagedObject?
                            if storedRecords.count > currentIndex {
                                storedManagedObject = storedRecords[currentIndex]
                            }
                            if storedManagedObject != nil {
                                if storedManagedObject!.valueForKey("remoteID")! as! String == String(record["id"]) {
                                    coreDataService.updateManagedObject(storedRecords[currentIndex], json: JSON(record))
                                }else {

                                }
                            }else {
                                coreDataService.newManagedObject(className, json: JSON(record))
                            }
                            currentIndex++
                        }

                    }
                }
            }
            saveContext(managedObjectContext)
            deleteJSONDataRecords(className)
        }
        downloadDataForRegisteredObjects(useUpdatedAtDate: false, toDeleteLocalRecords: true)
    }

    func processJSONDataRecordsForDeletion() {
        for className in registeredClassesToSync {
            if let JSONRecords = JSONDataRecordsForClass(className, sortedByKey: "id") {
                if JSONRecords.count > 0 {
                    var strings = [String]()
                    for record in JSONRecords {
                        strings.append((record["id"]?.stringValue)!)
                    }
                    let storedRecords = coreDataService.managedObjects(className, sortedByKey: "remoteID", idArray: strings, inIds: false)
                    for record in storedRecords {
                        print(record.valueForKey("remoteID"))
                    }
                    //for managedObject in storedRecords { managedObjectContext.deleteObject(managedObject)}
                    saveContext(managedObjectContext)
                }
            }
            deleteJSONDataRecords(className)
        }
        postChangedObjectsToServer()
    }

    func postChangedObjectsToServer() {

        for className in registeredClassesToSync {
            let lowName = className.lowercaseString
            let group = dispatch_group_create()

            let changedObjects = coreDataService.managedObjects(className, syncStatus: nil)
            print(className)
            for changedObject in changedObjects {
                if let block = SyncStatus(rawValue: (changedObject.valueForKey("syncStatus") as! NSNumber).integerValue) {
                    dispatch_group_enter(group)
                    switch block {
                    case .Created:
                        let syncObject = changedObject as! SyncObject
                        let json = syncObject.JSONToCreateObjectOnServer()
                        //print(json)
                        Alamofire.request(HTTPService.POSTRequestForClass(lowName, json: json!)).validate().responseJSON(completionHandler: {[unowned self] (response) -> Void in
                            switch response.result {
                            case .Success:
                                syncObject.syncStatus = SyncStatus.Synced.rawValue
                                syncObject.remoteID = JSON(response.result.value!)["id"].stringValue
                                print(syncObject.remoteID)
                                syncObject.updatedAt = self.dateUsingStringFromAPI(JSON(response.result.value!)["updated"].stringValue)
                            case .Failure:
                                print(response.description)
                                //print(response.result.value!)
                            }
                            dispatch_group_leave(group)
                        })

                        //TODO: Not tested
                    case .Updated:
                        let syncObject = changedObject as! SyncObject
                        let json = syncObject.JSONToCreateObjectOnServer()
                        Alamofire.request(HTTPService.PATCHRequestForClass(lowName,objectId: syncObject.remoteID!, json: json!)).validate().responseJSON(completionHandler: { (response) -> Void in
                            switch response.result {
                            case .Success:
                                syncObject.syncStatus = SyncStatus.Synced.rawValue
                                syncObject.updatedAt = self.dateUsingStringFromAPI(JSON(response.result.value!)["updated"].stringValue)
                            case .Failure:
                                print(response.description)
                            }
                            dispatch_group_leave(group)
                        })
                    case .Deleted:
                        let syncObject = changedObject as! SyncObject
                        Alamofire.request(HTTPService.DELETERequestForClass(lowName, objectId: syncObject.remoteID!)).validate().responseJSON(completionHandler: {[unowned self] (response) -> Void in
                            print(response.description)
                            switch response.result {
                            case .Success:
                                self.managedObjectContext.deleteObject(syncObject)
                            case .Failure:
                                print(response.description)
                            }

                            dispatch_group_leave(group)
                        })
                    default:
                        print("Sneaked syncedObject")
                    }
                }
            }
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            saveContext(self.managedObjectContext)
        }
        executeSyncCompletedOperations()

    }
}

//MARK: Date formatting
extension SyncService {

    func dateUsingStringFromAPI(var dateString: String) -> NSDate {
        if let start = dateString.rangeOfString(".")?.startIndex {
            let end = dateString.rangeOfString("Z")!.endIndex
            let range = Range(start: start,end: end)
            //let midRange = dateString.endIndex.advancedBy(-8)...dateString.endIndex.advancedBy(-2)
            dateString.removeRange(range)
        }
        return dateFormatter.dateFromString(dateString)!
    }
    func dateStringForAPIUsingDate(date: NSDate) -> String {
        var dateString = dateFormatter.stringFromDate(date)
        dateString = dateString.substringWithRange(0, location: dateString.characters.count - 1)
        return dateString
    }
    func dateStringForRequest(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter.stringFromDate(date)
    }
}