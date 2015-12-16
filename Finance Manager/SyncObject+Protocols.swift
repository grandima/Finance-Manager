//
//  Trackable.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

protocol SObjectExtenstion {
    func getDate() -> NSDate
}
protocol DestinationExtension: SObjectExtenstion {
    func getName() -> String
}
protocol Trackable: SObjectExtenstion {
    func getMoney() -> NSNumber
    func getDestinationObject() -> SyncObject
    func getSourceObject() -> SyncObject?
}
protocol JSONRepresentation {
    func JSONToCreateObjectOnServer() -> JSON?
    func fillObject(json: JSON)
}
    //func dateStringForAPIUsingDate(date: NSDate) -> String
extension SObjectExtenstion {
    func getDate() -> NSDate {
        let s = self as! SyncObject
        return s.createdAt
    }
}
extension Trackable {
    func getSourceObject() -> SyncObject? {
        return nil
    }
}

