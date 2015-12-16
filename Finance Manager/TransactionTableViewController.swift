//
//  TransactionTableViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit

class TransactionTableViewController: CoreViewController {


    //var stack: JSQCoreDataKit.CoreDataStack!
    @IBOutlet weak var tableView: TransactionTableView!

    var fetchedTransactionController: NSFetchedResultsController!

    var sources: [Source] = []
    var categories: [Category] = []

    var deleteTransactionIndexPath: NSIndexPath?

    var sourcesAndCategoriesAvaliable : Bool {
        get { return (self.sources.count > 0 && self.categories.count > 0)}}

       override func viewDidLoad() {
        super.viewDidLoad()
        initFetchDestinationController()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isLoggedIn {
            prefetchEssentialEntites()
            if sourcesAndCategoriesAvaliable {
                do {
                    try self.fetchedTransactionController.performFetch()
                }
                catch {
                    fatalError("Failed to fetch: \(error)")
                }
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    

}

// MARK: - Core Data methods
extension TransactionTableViewController: NSFetchedResultsControllerDelegate {

    private func initFetchDestinationController() {
        let request = NSFetchRequest(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: true)]
        fetchedTransactionController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedTransactionController.delegate = self
    }

    private func prefetchEssentialEntites() {
        do {
            try sources.appendContentsOf(Source.fetchAllObjects(managedObjectContext: managedObjectContext) as! [Source])
            try categories.appendContentsOf( Category.fetchAllObjects(managedObjectContext: managedObjectContext) as! [Category])
        }
        catch {
            print(error)
        }
    }
    //TODO: Delete Transaction
    private func confirmDelete(transaction: Transaction?) {
        if (transaction != nil) {
            let source = transaction!.source
            source.balance += transaction!.amount
            self.managedObjectContext.deleteObject(transaction!)
            saveContext(managedObjectContext)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
}

//MARK: - UI Handlers
extension TransactionTableViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Add transaction Segue") {
            let addTransactionVC = segue.destinationViewController as! AddTransactionViewController
            addTransactionVC.sourceArray = sources
            addTransactionVC.categoryArray = categories
            addTransactionVC.managedObjectContext = managedObjectContext
        }
    }

}


//MARK: - TableView DataSource & Delegate
extension TransactionTableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if sourcesAndCategoriesAvaliable && (self.fetchedTransactionController.fetchedObjects?.count > 0){
            let tableView = tableView as! TransactionTableView
            tableView.hideEmptyView()
            self.tableView.separatorStyle = .SingleLine;
            return 1
        }
//        if let res = self.fetchedTransactionController.fetchedObjects {
//            print("res")
//            return res.count
//        }

        let tableView = tableView as! TransactionTableView
        tableView.configureEmptyView(self.sources.count == 0, self.categories.count == 0)
        tableView.showEmptyView()
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedTransactionController.fetchedObjects!.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("transactionID", forIndexPath: indexPath) as! TransactionTableViewCell
        let transaction = self.fetchedTransactionController.objectAtIndexPath(indexPath) as! Transaction
        cell.configureCell(source: transaction.source.name, date: transaction.createdAt, category: transaction.category.name, amount: transaction.amount)

        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {
            self.deleteTransactionIndexPath = indexPath
            let transactionToDelete = self.fetchedTransactionController.fetchedObjects?[indexPath.row] as? Transaction
            confirmDelete(transactionToDelete)
        }
    }


}
