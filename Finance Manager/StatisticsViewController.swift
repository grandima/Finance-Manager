//
//  StatisticsViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 29.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import CoreData
import JSQCoreDataKit
import EZLoadingActivity
import SwiftyUserDefaults


class StatisticsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    //TODO: - Чот з цим придумать
    var currentSegmentSelectedSelected: String {
        get {
            return (segmentedControl.selectedSegmentIndex == 0) ? Category.className() : Source.className()
        }
    }

    var isLoggedIn: Bool {
        get {
            return Defaults[HTTPService.udisLoggedIn].boolValue
        }
    }

    var managedObjectContext: NSManagedObjectContext!

    var period: CalendarUnit = CalendarUnit.Day

    var sources = [Source]()
    var categories = [Category]()
    var incomes = [Income]()
    var transactions = [Transaction]()

    //TODO: In future, MVVM maybe?
    var categoryStatistics: [StatisticsData]?
    var sourceStatistics: [StatisticsData]?

    var currentStatistics: [StatisticsData]? {
        didSet{
            EZLoadingActivity.hide()
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(isLoggedIn) {
            EZLoadingActivity.show("Loading...", disableUI: false)
            fetchAllData()
            categoryStatistics = convertTransactionsToStatisticsData(transactions, destinations: categories)
            sourceStatistics = convertIncomesToStatisticsData(incomes, destinations: sources)
            currentStatistics = categoryStatistics
        }


    }

}

//MARK: - Collection DataSource & Delegate
extension StatisticsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.currentStatistics != nil) ? self.currentStatistics!.count : 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StatisticsCellID", forIndexPath: indexPath) as! StatisticsCollectionViewCell
        cell.configureCell(self.currentStatistics![indexPath.row])
        return cell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let statsCell = cell as? StatisticsCollectionViewCell else {return}

        statsCell.tableView.dataSource = statsCell
        statsCell.tableView.delegate = statsCell
        statsCell.tableView.reloadData()
    }

    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return self.collectionView.frame.size
    }
}

//MARK: - Core Data Helper
extension StatisticsViewController {

    func fetchAllData() {

        var request = FetchRequest<SyncObject>(entity: entity(name: "Category", context: managedObjectContext))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        categories = try! fetch(request: request, inContext: managedObjectContext) as! [Category]

        request = FetchRequest(entity: entity(name: "Source", context: managedObjectContext))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        sources = try! fetch(request: request, inContext: managedObjectContext) as! [Source]

        request = FetchRequest(entity: entity(name: "Transaction", context: managedObjectContext))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        transactions = try! fetch(request: request, inContext: managedObjectContext) as![Transaction]

        request = FetchRequest(entity: entity(name: "Income", context: managedObjectContext))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        incomes = try! fetch(request: request, inContext: managedObjectContext) as![Income]


    }
//TODO: - Deprecated, think what to do!
    func fetchTransactions(managedObjectContext: NSManagedObjectContext) -> Void {
        let request = NSFetchRequest(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { [unowned self](result) -> Void in
            //self.transactions = result.finalResult as! [Transaction]
            if((result.operationError) != nil) {
            }else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.transactions = result.finalResult as! [Transaction]
                })

            }
        }
        do {
            try managedObjectContext.executeRequest(asyncRequest) as! NSPersistentStoreAsynchronousResult
        }catch {
            fatalError("Hello \(error)")
        }
    }
}

//MARK: - UI Handlers
extension StatisticsViewController {

    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentStatistics = categoryStatistics
        } else if sender.selectedSegmentIndex == 1 {
            currentStatistics = sourceStatistics
        }
    }


}


