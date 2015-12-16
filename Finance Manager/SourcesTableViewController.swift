//
//  SourcesTableViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit

class SourcesTableViewController: CoreViewController  {

    @IBOutlet weak var tableView: UITableView!
    var fetchedSourceController: NSFetchedResultsController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFetchSourceController()
        do {
            try fetchedSourceController.performFetch()
        } catch {
            fatalError("Error: \(error)")
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
}

// MARK: - Core Data methods
extension SourcesTableViewController: NSFetchedResultsControllerDelegate {

    private func initFetchSourceController() {
        let request = NSFetchRequest(entityName: "Source")
        request.sortDescriptors = [NSSortDescriptor(key: "balance", ascending: true)]
        request.relationshipKeyPathsForPrefetching = ["incomes"]
        fetchedSourceController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedSourceController.delegate = self
    }

    private func addMoney(indexPath: NSIndexPath, amount: Double) {
        let source = fetchedSourceController.objectAtIndexPath(indexPath) as! Source
        source.balance += amount
        let income = Income(context: managedObjectContext, amount: NSNumber(double: amount), source: source)
        source.syncStatus = SyncStatus.Updated.rawValue
        //source.updatedAt = income.updatedAt
        saveContext(managedObjectContext)
    }
    private func addSource(name: String, balance: Double) {
        print(name,balance)
        _ = Source(context: managedObjectContext, balance: NSNumber(double: balance), name: name)
        
        saveContext(managedObjectContext)
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}

// MARK: - UI Handlers
extension SourcesTableViewController {

    @IBAction func addSourceButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add source", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler {$0.placeholder = "Source name"}
        alertController.addTextFieldWithConfigurationHandler {
            $0.placeholder = "StartBalance"
            $0.keyboardType = .DecimalPad
        }
        alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { [unowned self] (action) -> Void in
            
            self.addSource(alertController.textFields!.first!.text!, balance: Double(alertController.textFields!.last!.text!)!)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addMoneyButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Add money", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Amount"
            textField.keyboardType = .DecimalPad
        }
        let action = UIAlertAction(title: "Save", style: .Default) { [unowned self](action)  -> Void in
            if let superView = sender.superview?.superview as? UITableViewCell {
                let indexPath = self.tableView.indexPathForCell(superView)
                self.addMoney(indexPath!, amount: Double(alertController.textFields!.first!.text!)!)
            }
        }
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
// MARK: - Table view data source
extension SourcesTableViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedSourceController.fetchedObjects != nil) ? 1 : 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedSourceController.fetchedObjects!.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Source ID", forIndexPath: indexPath) as! SourceTableViewCell

        let source = fetchedSourceController.objectAtIndexPath(indexPath) as? Source
        cell.configureCell(source?.name, balance: source?.balance.doubleValue)

        return cell
    }
}
