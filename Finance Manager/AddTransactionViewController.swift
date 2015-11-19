//
//  AddTransactionViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
class AddTransactionViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate {

    static let STATIC_CELLS_COUNT = 3

    @IBOutlet weak var amountLabel: UITextField!
    @IBOutlet weak var sourcePicker: UIPickerView!
    @IBOutlet weak var destinationPicker: UIPickerView!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var sourceArray = [Source]()
    var destinationArray = [Destination]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.alwaysBounceVertical = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    //MARK: - UIPickerView DataSource

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.sourcePicker:
            return self.sourceArray.count
        case self.destinationPicker:
            print(self.destinationArray.count)
            return self.destinationArray.count
        default:
            return 0
        }
    }

    //MARK: - UIPickerView Delegate

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.sourcePicker:
            let souce = self.sourceArray[row]
            return souce.name
        case self.destinationPicker:
            let destination = self.destinationArray[row]
            return destination.name
        default:
            return nil
        }
    }

    //MARK: - Core Data

    func fetchCategories(){

        let sourceRequest = NSFetchRequest(entityName: "Source")
        sourceRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var categories = []
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
