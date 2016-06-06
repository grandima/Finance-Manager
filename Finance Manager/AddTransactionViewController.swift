//
//  AddTransactionViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit

class AddTransactionViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var sourcePicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!

    var stack: JSQCoreDataKit.CoreDataStack!
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.stack.mainContext
    }()

    var sourceArray: [Source]!
    var categoryArray: [Category]!

    //MARK: - UIViewController methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.amountField.keyboardType = .DecimalPad

        self.tableView.alwaysBounceVertical = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        if (self.amountField?.text != nil) {

            sourceArray[self.sourcePicker.selectedRowInComponent(0)].balance -= NSNumber(double: (self.amountField.text! as NSString).doubleValue)
            sourceArray[self.sourcePicker.selectedRowInComponent(0)].syncStatus = SyncStatus.Updated.rawValue
            _ = Transaction(context: managedObjectContext, amount: NSNumber(double: (self.amountField.text! as NSString).doubleValue), category: categoryArray[self.categoryPicker.selectedRowInComponent(0)], source: sourceArray[self.sourcePicker.selectedRowInComponent(0)], syncStatus: NSNumber(int: 0))
            saveContext(self.managedObjectContext)
            SyncService.sharedEngine.startSync()
        }

        self.navigationController?.popToViewController(
            self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2],
            animated: true)
    }
}

//MARK: - Helper methods
extension AddTransactionViewController {


//    func fetchCategories(){
//
//        let sourceRequest = NSFetchRequest(entityName: "Source")
//        sourceRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        var categories : [AnyObject]
//        do {
//            categories = try self.managedObjectContext.executeFetchRequest(sourceRequest)
//        } catch {
//            fatalError("Failed to fetch: \(error)")
//        }
//        for category in categories {
//            if category.isMemberOfClass(Source) {
//                sourceArray.append(category as! Source)
//            }
//            else if category.isMemberOfClass(Category){
//                categoryArray.append(category as! Category)
//            }
//        }
//    }
}

//MARK: - UIPickerView DataSource & Delegate
extension AddTransactionViewController :  UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.categoryPicker:
            return self.categoryArray.count
        case self.sourcePicker:
            return self.sourceArray.count

        default:
            return 0
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.sourcePicker:
            let souce = self.sourceArray[row]
            return souce.name
        case self.categoryPicker:
            let category = self.categoryArray[row]
            return category.name
        default:
            return nil
        }
    }
}
