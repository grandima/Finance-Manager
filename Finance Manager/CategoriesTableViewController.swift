//
//  CategoriesTableViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 08.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit

class CategoriesTableViewController: CoreViewController  {

    @IBOutlet weak var tableView: UITableView!
    var fetchedCategoryController: NSFetchedResultsController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFetchCategoryController()
        do {
            try fetchedCategoryController.performFetch()
        } catch {
            fatalError("Error: \(error)")
        }
    }

}

// MARK: - Core Data methods
extension CategoriesTableViewController: NSFetchedResultsControllerDelegate {

    func initFetchCategoryController() {
        let request = NSFetchRequest(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.relationshipKeyPathsForPrefetching = ["transactions"]
        fetchedCategoryController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedCategoryController.delegate = self
    }

    func addCategory(name: String) {
        _ = Category(context: managedObjectContext, name: name)
        saveContext(managedObjectContext)
        SyncService.sharedEngine.startSync()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }

}

// MARK: - UI Handlers
extension CategoriesTableViewController {

    @IBAction func addCategoryButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add category", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler {$0.placeholder = "Category name"}
        alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { [unowned self] (action) -> Void in
            self.addCategory(alertController.textFields!.first!.text!)
            }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

// MARK: - Table view data destination
extension CategoriesTableViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedCategoryController.fetchedObjects != nil) ? 1 : 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedCategoryController.fetchedObjects!.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Category ID", forIndexPath: indexPath)
        cell.textLabel?.text = fetchedCategoryController.objectAtIndexPath(indexPath).name

        return cell
    }
}

