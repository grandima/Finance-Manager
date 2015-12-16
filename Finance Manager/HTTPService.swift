//
//  LoginService.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 09.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyJSON

struct HTTPService {

    static let httpbaseURL = "https://shrouded-everglades-4001.herokuapp.com/"
    static let httpapiToken = "api_token/"
    static let httpsignUp = "users/"

    static let jsonapiToken = "token"

    static let udisLoggedIn = "isLoggedIn"
    static let udtoken = "token"
    static let udexpirationDate = "expiresAt"
    

    enum HTTPRequestAuthType {
        case CredentialsAuth
        case TokenAuth
    }
    
    enum HTTPRequestContentType {
        case JsonContent
        case MultipartContent
    }

    static func GETRequestForClass(className: String, parameters: [String: String]?) -> NSMutableURLRequest {
        let urlComponents = NSURLComponents(string: (httpbaseURL + className + "/"))
        if let params = parameters {
            var queryItems = [NSURLQueryItem]()
            for (_, v) in params.enumerate() {
                queryItems.append(NSURLQueryItem(name: v.0, value: v.1))
            }
            urlComponents?.queryItems = queryItems
        }
        let request = NSMutableURLRequest(URL: urlComponents!.URL!)
        request.HTTPMethod = "GET"

        let token = Defaults[udtoken].stringValue
        request.allHTTPHeaderFields!["Authorization"] =  "Token " + token
        return request
    }

    static func GETRequestForAllRecordsOfClass(className: String, updatedAfter: NSDate?) -> NSMutableURLRequest {
        if let date = updatedAfter {
            let stringFromDate = SyncService.sharedEngine.dateStringForRequest(date)
            let parameters = ["updated": stringFromDate]
            return GETRequestForClass(className, parameters: parameters)
        }
        let request = GETRequestForClass(className, parameters: nil)
        return request
    }

    static func POSTRequestForClass(className: String, json: JSON) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: (httpbaseURL + className + "/"))!)
        do{
            print(json.dictionaryObject!)
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json.dictionaryObject!,options: NSJSONWritingOptions(rawValue: 0))
        }catch {
            print("Cannot serialize \(error)")
        }
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.allHTTPHeaderFields!["Authorization"] = "Token " + Defaults[udtoken].stringValue
        return request

    }

    static func PATCHRequestForClass(className: String, objectId: String, json: JSON) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: (httpbaseURL + className + "/" + objectId + "/"))!)
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json.dictionaryObject!,options: NSJSONWritingOptions(rawValue: 0))
        }catch {
            print("Cannot serialize \(error)")
        }
        request.HTTPMethod = "PATCH"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.allHTTPHeaderFields!["Authorization"] = "Token " + Defaults[udtoken].stringValue
        return request

    }

    static func DELETERequestForClass(className: String, objectId: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: (httpbaseURL + className + "/" + objectId + "/"))!)
        request.HTTPMethod = "DELETE"
        request.allHTTPHeaderFields!["Authorization"] = "Token " + Defaults[udtoken].stringValue
        return request
    }
}