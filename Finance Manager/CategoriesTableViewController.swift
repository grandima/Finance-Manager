//
//  CategoriesTableViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 08.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
enum categoryEnum : Int {
    case Source = 0
    case Destination = 1
}
class CategoriesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {



    @IBOutlet weak var categoryControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!


    lazy var fetchedSourcesController : NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Source")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        let moc = self.appDelegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    lazy var fetchedDestinationsController : NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Destination")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        let moc = self.appDelegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    //MARK: - UIViewcontroller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)

        do {
            try self.fetchedSourcesController.performFetch()
            try self.fetchedDestinationsController.performFetch()
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadTable"), name: NSManagedObjectContextDidSaveNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.categoryControl.selectedSegmentIndex {
        case categoryEnum.Source.rawValue:
            guard let objects = self.fetchedSourcesController.fetchedObjects else {
                return 0
            }
            return objects.count
        case categoryEnum.Destination.rawValue:
            guard let objects = self.fetchedDestinationsController.fetchedObjects else {
                return 0
            }
            return objects.count
        default: return 0
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch self.categoryControl.selectedSegmentIndex {
        case categoryEnum.Source.rawValue:
            cell = tableView.dequeueReusableCellWithIdentifier("SourceID", forIndexPath: indexPath)
            let source = self.fetchedSourcesController.objectAtIndexPath(indexPath)  as! Source
            cell.textLabel?.text = source.name
            cell.detailTextLabel?.textColor = UIColor.greenColor()
            cell.detailTextLabel?.text = String(format: "Balance = %@", source.balance!.stringValue)

        case categoryEnum.Destination.rawValue:
            cell = tableView.dequeueReusableCellWithIdentifier("DestinationID", forIndexPath: indexPath)
            cell.textLabel?.text = self.fetchedDestinationsController.objectAtIndexPath(indexPath).name
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("DestinationID", forIndexPath: indexPath)
            cell.textLabel?.text = "Something went wrong. There are no categories avaliable"
        }
        return cell
    }
    
    // MARK: - UISegmentedControl
    @IBAction func categoryChanged(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }

    // MARK: - UINavigationBar
    @IBAction func addCategory(sender: UIBarButtonItem) {
        if (self.categoryControl.selectedSegmentIndex == categoryEnum.Source.rawValue) {
            let alertController = UIAlertController(title: "Add source", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let nameTextField = alertController.textFields![0] as UITextField
            nameTextField.placeholder = "Source name"
            //nameTextField.becomeFirstResponder()

            alertController.addTextFieldWithConfigurationHandler(nil)
            let balanceTextField = alertController.textFields![1] as UITextField
            balanceTextField.placeholder = "Your balance"
            balanceTextField.keyboardType = .DecimalPad

            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { action -> Void in
                let moc = self.appDelegate.managedObjectContext
                let source = NSEntityDescription.insertNewObjectForEntityForName("Source", inManagedObjectContext: moc) as! Source
                source.name = nameTextField.text
                source.balance = NSNumber(double: ((balanceTextField.text! as NSString).doubleValue))
                self.appDelegate.saveContext()
            }))


            self.presentViewController(alertController, animated: true, completion: nil)
        } else if (self.categoryControl.selectedSegmentIndex == categoryEnum.Destination.rawValue) {
            let alertController = UIAlertController(title: "Add Destination", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let nameTextField = alertController.textFields![0] as UITextField
            nameTextField.placeholder = "Destination name"

            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { action -> Void in
                let moc = self.appDelegate.managedObjectContext
                let destination = NSEntityDescription.insertNewObjectForEntityForName("Destination", inManagedObjectContext: moc) as! Destination
                destination.name = nameTextField.text
                self.appDelegate.saveContext()
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
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
