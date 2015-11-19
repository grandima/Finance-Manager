//
//  TransactionTableViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import UIKit
class TransactionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var sources = [Source]?()
    var destinations = [Destination]?()

    var sourcesAndDestinationsAvaliable : Bool {
        get { return (sources != nil && destinations != nil)}
    }
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Transaction")
        let nameSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [nameSort]
        let moc = self.appDelegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")
        let dividedCategories = self.fetchAndDivideCategories()
        sources = dividedCategories.0
        destinations = dividedCategories.1

        self.navigationItem.rightBarButtonItem?.enabled = sourcesAndDestinationsAvaliable

        if sourcesAndDestinationsAvaliable {
            do {
                try self.fetchedResultsController.performFetch()
            }
            catch {
                fatalError("Failed to fetch: \(error)")
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if sourcesAndDestinationsAvaliable && (self.fetchedResultsController.fetchedObjects?.count > 0){
            self.tableView.separatorStyle = .SingleLine;
            return 1
        }

        let tableView = self.tableView as! TransactionTableView
        tableView.configureEmptyView(self.sources == nil, self.destinations == nil)
        tableView.showEmptyView()
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddTransactionID", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }


    @IBAction func addTransactionButtonPressed(sender: UIBarButtonItem) {
        let addTransactionVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddTransactionVCID") as! AddTransactionViewController
        addTransactionVC.sourceArray = self.sources!
        
        self.navigationController?.pushViewController(addTransactionVC, animated: true)
    }

    //

    //MARK: - Core Data

    func fetchAndDivideCategories() -> ([Source]?,[Destination]?){

        let sourceRequest = NSFetchRequest(entityName: "Source")
        sourceRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var categories = []
        var sourceArray = Array<Source>()
        var destinationArray = Array<Destination>()
        do {
            categories = try self.appDelegate.managedObjectContext.executeFetchRequest(sourceRequest)
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
        for category in categories {
            if category.isMemberOfClass(Source) {
                sourceArray.append(category as! Source)
            }
            else if category.isMemberOfClass(Destination){
                destinationArray.append(category as! Destination)
            }
        }
        return (sourceArray, destinationArray)
    }

    override func viewWillAppear(animated: Bool) {
        print("viewwillAppear")
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
