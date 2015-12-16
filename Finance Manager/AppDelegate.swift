//
//  AppDelegate.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit
import SwiftyUserDefaults
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var stack: JSQCoreDataKit.CoreDataStack!
  

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let bundle = NSBundle(identifier: "MD.Finance-Manager")!
        let model = CoreDataModel(name: "Finance_Manager", bundle: bundle)
        
        let factory = CoreDataStackFactory(model: model)

        self.stack = factory.createStack().stack()        

        for tabBarController in (application.windows[0].rootViewController as! UITabBarController).viewControllers! {
            if let navigationController =  tabBarController as? UINavigationController{
                (navigationController.topViewController as! CoreViewController).managedObjectContext = self.stack.mainContext
            }
        }
        let statisticsVC = (application.windows[0].rootViewController as! UITabBarController).viewControllers![4] as! StatisticsViewController
        statisticsVC.managedObjectContext = stack.mainContext

//        Defaults.remove(HTTPService.udtoken)
//        Defaults[HTTPService.udisLoggedIn] = false
        SyncService.sharedEngine.managedObjectContext = stack.childContext()
        SyncService.sharedEngine.registerToSync("Category")
        SyncService.sharedEngine.registerToSync("Source")
        SyncService.sharedEngine.registerToSync("Transaction")
        SyncService.sharedEngine.registerToSync("Income")
        NSNotificationCenter.defaultCenter().addObserver(SyncService.sharedEngine, selector: "startSync", name: SyncNotification.StartSync.rawValue, object: nil)
        //SyncService.sharedEngine.coreDataService.managedObjects("Source", sortedByKey: "remoteID", idArray: ["2","3","10","11"], inIds: false)

        SyncService.sharedEngine.startSync()


        return true
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.sharedStack.saveContext()

    }
}



