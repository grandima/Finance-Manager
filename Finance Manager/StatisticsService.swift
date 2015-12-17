//
//  IncomeService.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 07.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation
import UIKit

enum CalendarUnit : Int {
    case Year = 0
    case Month = 1
    case Day = 2
}
struct StatisticsData {
    var date: NSDate
    struct DestType{
        var name: String
        var count: Double
        var color: UIColor
        init(name: String = String(),count: Double = 0.0) {
            self.name = name
            self.count = count
            self.color = DestType.colors.removeFirst()
        }
        static var colors: [UIColor] = [
            UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0),
            UIColor(red:1.00, green:0.42, blue:0.00, alpha:1.0),
            UIColor(red:1.00, green:0.66, blue:0.00, alpha:1.0),
            UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0),
            UIColor(red:0.80, green:1.00, blue:0.00, alpha:1.0),
            UIColor(red:0.50, green:1.00, blue:0.00, alpha:1.0),
            UIColor(red:0.08, green:1.00, blue:0.00, alpha:1.0),
            UIColor(red:0.00, green:1.00, blue:0.82, alpha:1.0),
            UIColor(red:0.00, green:0.94, blue:1.00, alpha:1.0),
            UIColor(red:0.00, green:0.58, blue:1.00, alpha:1.0),
            UIColor(red:0.00, green:0.28, blue:1.00, alpha:1.0),
            UIColor(red:0.02, green:0.00, blue:1.00, alpha:1.0),
            UIColor(red:0.02, green:0.00, blue:1.00, alpha:1.0),
            UIColor(red:0.62, green:0.00, blue:1.00, alpha:1.0),
            UIColor(red:0.62, green:0.00, blue:1.00, alpha:1.0),
            UIColor(red:1.00, green:0.00, blue:0.84, alpha:1.0),
            UIColor(red:1.00, green:0.00, blue:0.36, alpha:1.0)]
    }

    init(date: NSDate = NSDate(), destinations: [DestType] = []) {
        self.date = date
        self.destinations = destinations

    }
    var destinations: [DestType]
}


extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255

        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

extension StatisticsViewController {

    func transactionsForCalendarUnit(syncObjects: [Transaction], unit: CalendarUnit) -> [[Transaction]] {
        let calendar = NSCalendar.currentCalendar()
        var sortedSyncObjects = [[Transaction]]()
        switch unit {
        case .Year:
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.last else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)
                    continue
                }
                let lastSyncObject = syncObjectsForUnit.last!
                let lastSyncObjectDate = lastSyncObject.getDate()
                let lastSyncObjectComponent = calendar.components([.Year], fromDate: lastSyncObjectDate)

                let transactionDate = transaction.getDate()
                let transactionComponent = calendar.components([.Year], fromDate: transactionDate)

                if(transactionComponent.year > lastSyncObjectComponent.year) {
                    sortedSyncObjects.append([transaction])
                }
                else {
                    syncObjectsForUnit.append(transaction)
                }
            }
        case .Month:
            var endDate: NSDate = NSDate()
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.last else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)

                    let endComponents = calendar.components([.Year,.Month], fromDate: transaction.getDate())
                    endComponents.month += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!

                    continue
                }
                if (transaction.getDate().compare(endDate) == .OrderedDescending) {
                    sortedSyncObjects.append([transaction])

                    let endComponents = calendar.components([.Year,.Month], fromDate: transaction.getDate())
                    endComponents.month += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                }
                else {
                    syncObjectsForUnit.append(transaction)
                }
            }
        case .Day:
            var endDate = NSDate()
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.popLast() else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)

                    let endComponents = calendar.components([.Year,.Month,.Day], fromDate: transaction.getDate())
                    endComponents.day += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                    continue
                }
                if (transaction.getDate().compare(endDate) == .OrderedDescending) {
                    //print(transaction.createdAt)
                    //print(endDate)
                    sortedSyncObjects.append(syncObjectsForUnit)
                    sortedSyncObjects.append([transaction])

                    let endComponents = calendar.components([.Year,.Month,.Day], fromDate: transaction.getDate())
                    endComponents.day += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                    //print(endDate)
                }
                else {
                    syncObjectsForUnit.append(transaction)
                    sortedSyncObjects.append(syncObjectsForUnit)
                }

            }
        }
        return sortedSyncObjects
    }

    func convertTransactionsToStatisticsData(transactions: [Transaction], destinations: [Category]) -> [StatisticsData] {

        let categoriesByDate = transactionsForCalendarUnit(transactions, unit: .Day)

        let (categoriesForAllPeriod, dates) = trackableObjectsForAllPeriod(categoriesByDate, destinations: destinations)

        let statisticsDataArray = convertToStatisticsData(categoriesForAllPeriod, periods: dates)

        return statisticsDataArray
    }

    func trackableObjectsForAllPeriod (dividedtransactions: [[Transaction]], destinations: [Category]) -> ([[Category: [Transaction]]], [NSDate]) {
        var destinationsAndtransactionsForAllPeriods = [[Category: [Transaction]]]()

        var firstTOjbectsDates = [NSDate]()

        for array in dividedtransactions {
            var destinationsAndTObjectsForPeriod = [Category: [Transaction]]()
            for destination in destinations {
                let transactionsForDestination = array.filter{$0.category.isEqual(destination)}
                if(transactionsForDestination.count > 0) {
                    destinationsAndTObjectsForPeriod[destination] = transactionsForDestination
                }
            }
            firstTOjbectsDates.append(array.first!.getDate())
            destinationsAndtransactionsForAllPeriods.append(destinationsAndTObjectsForPeriod)
        }
        return (destinationsAndtransactionsForAllPeriods, firstTOjbectsDates)
    }


    func convertToStatisticsData(destsAndTObjectsForAllPeriods: [[Category: [Transaction]]], periods: [NSDate]) -> [StatisticsData] {
        var statisticsDataArray = [StatisticsData]()
        for var i = 0; i < periods.count; i++ {
            let currentPeriod = periods[i]
            let destAndTObjectsForPeriod = destsAndTObjectsForAllPeriods[i]
            let keys = destAndTObjectsForPeriod.keys
            var statisticsData = StatisticsData()
            statisticsData.date = currentPeriod
            var destinations: [StatisticsData.DestType] = []
            for key in keys {
                let transactions = destAndTObjectsForPeriod[key]
                guard let sum = transactions?.reduce(0.0, combine: { (count, destination) -> Double in
                    count + destination.getMoney().doubleValue
                })else {
                    destinations += (StatisticsData.DestType(name: key.getName(), count: 0.0))
                    break
                }
                destinations += (StatisticsData.DestType(name: key.getName(), count: sum))
            }
            statisticsData.destinations = destinations.sort{ return ($0.count > $1.count) ? true : false}
            statisticsDataArray.append(statisticsData)
        }
        return statisticsDataArray
    }







    func convertIncomesToStatisticsData(incomes: [Income], destinations: [Source]) -> [StatisticsData] {

        let sourcesByDate = incomesForCalendarUnit(incomes, unit: .Day)

        let (sourcesForAllPeriod, dates) = trackableObjectsForAllPeriod(sourcesByDate, destinations: destinations)

        let statisticsDataArray = convertToStatisticsData(sourcesForAllPeriod, periods: dates)
        return statisticsDataArray
    }


    func incomesForCalendarUnit(syncObjects: [Income], unit: CalendarUnit) -> [[Income]] {
        let calendar = NSCalendar.currentCalendar()
        var sortedSyncObjects = [[Income]]()
        switch unit {
        case .Year:
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.last else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)
                    continue
                }
                let lastSyncObject = syncObjectsForUnit.last!
                let lastSyncObjectDate = lastSyncObject.getDate()
                let lastSyncObjectComponent = calendar.components([.Year], fromDate: lastSyncObjectDate)

                let transactionDate = transaction.getDate()
                let transactionComponent = calendar.components([.Year], fromDate: transactionDate)

                if(transactionComponent.year > lastSyncObjectComponent.year) {
                    sortedSyncObjects.append([transaction])
                }
                else {
                    syncObjectsForUnit.append(transaction)
                }
            }
        case .Month:
            var endDate: NSDate = NSDate()
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.last else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)

                    let endComponents = calendar.components([.Year,.Month], fromDate: transaction.getDate())
                    endComponents.month += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!

                    continue
                }
                if (transaction.getDate().compare(endDate) == .OrderedDescending) {
                    sortedSyncObjects.append([transaction])

                    let endComponents = calendar.components([.Year,.Month], fromDate: transaction.getDate())
                    endComponents.month += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                }
                else {
                    syncObjectsForUnit.append(transaction)
                }
            }
        case .Day:
            var endDate = NSDate()
            for transaction in syncObjects {
                guard var syncObjectsForUnit = sortedSyncObjects.popLast() else {
                    let newTransctionsForUnit = [transaction]
                    sortedSyncObjects.append(newTransctionsForUnit)

                    let endComponents = calendar.components([.Year,.Month,.Day], fromDate: transaction.getDate())
                    endComponents.day += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                    continue
                }
                if (transaction.getDate().compare(endDate) == .OrderedDescending) {
                    //print(transaction.createdAt)
                    //print(endDate)
                    sortedSyncObjects.append(syncObjectsForUnit)
                    sortedSyncObjects.append([transaction])

                    let endComponents = calendar.components([.Year,.Month,.Day], fromDate: transaction.getDate())
                    endComponents.day += 1
                    endComponents.second -= 1
                    endDate = calendar.dateFromComponents(endComponents)!
                    //print(endDate)
                }
                else {
                    syncObjectsForUnit.append(transaction)
                    sortedSyncObjects.append(syncObjectsForUnit)
                }

            }
        }
        return sortedSyncObjects
    }


    func trackableObjectsForAllPeriod (dividedincomes: [[Income]], destinations: [Source]) -> ([[Source: [Income]]], [NSDate]) {
        var destinationsAndincomesForAllPeriods = [[Source: [Income]]]()

        var firstTOjbectsDates = [NSDate]()
        for d in dividedincomes {
            for x in d {
                x.getDestinationObject().isEqual(destinations.first)
            }
        }
        for array in dividedincomes {
            var destinationsAndTObjectsForPeriod = [Source: [Income]]()
            for destination in destinations {
                let incomesForDestination = array.filter{$0.source.isEqual(destination)}
                if(incomesForDestination.count > 0) {
                    destinationsAndTObjectsForPeriod[destination] = incomesForDestination
                }
            }
            firstTOjbectsDates.append(array.first!.getDate())
            destinationsAndincomesForAllPeriods.append(destinationsAndTObjectsForPeriod)
        }
        return (destinationsAndincomesForAllPeriods, firstTOjbectsDates)
    }


    func convertToStatisticsData(destsAndTObjectsForAllPeriods: [[Source: [Income]]], periods: [NSDate]) -> [StatisticsData] {
        var statisticsDataArray = [StatisticsData]()
        for var i = 0; i < periods.count; i++ {
            let currentPeriod = periods[i]
            let destAndTObjectsForPeriod = destsAndTObjectsForAllPeriods[i]
            let keys = destAndTObjectsForPeriod.keys
            var statisticsData = StatisticsData()
            statisticsData.date = currentPeriod
            var destinations: [StatisticsData.DestType] = []
            for key in keys {
                let incomes = destAndTObjectsForPeriod[key]
                guard let sum = incomes?.reduce(0.0, combine: { (count, destination) -> Double in
                    count + destination.getMoney().doubleValue
                })else {
                    destinations += (StatisticsData.DestType(name: key.getName(), count: 0.0))
                    break
                }
                destinations += (StatisticsData.DestType(name: key.getName(), count: sum))
            }
            statisticsData.destinations = destinations.sort{ return ($0.count > $1.count) ? true : false}
            statisticsDataArray.append(statisticsData)
        }
        return statisticsDataArray
    }

}
