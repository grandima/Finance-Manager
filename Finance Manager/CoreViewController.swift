//
//  CoreViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit
import SwiftyUserDefaults

class CoreViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    var isLoggedIn: Bool {
        get {
            return Defaults[HTTPService.udisLoggedIn].boolValue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (!isLoggedIn) {
            let storyBoard = storyboard!
            let loginVC = storyBoard.instantiateViewControllerWithIdentifier("Login ID")
            presentViewController(loginVC, animated: true, completion: nil)
        } else {
            //self.usernameLabel.text = prefs.valueForKey("USERNAME") as? String
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
