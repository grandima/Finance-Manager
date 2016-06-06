//
//  StatisticsCollectionViewCell.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 30.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import Charts


class StatisticsCollectionViewCell: UICollectionViewCell, ChartViewDelegate {

    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!

    var dataSource: StatisticsData?

    var colors = StatisticsData.DestType.colors
    func configureCell(dataSource: StatisticsData) {
        self.dataSource = dataSource
        self.configureChart()
    }

    func configureChart() {
        chartView.holeTransparent = true

        chartView.holeRadiusPercent = 0.40
        chartView.transparentCircleRadiusPercent = 0.43
        chartView.descriptionText = "";
        chartView.drawCenterTextEnabled = true;
//        var paragraphStyle = NSParagraphStyle.defaultParagraphStyle().copy() as! NSMutableParagraphStyle
//        paragraphStyle.lineBreakMode = .ByTruncatingTail
//        paragraphStyle.alignment = .Center

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle

        chartView.centerText = dateFormatter.stringFromDate(dataSource!.date)
        //chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .EaseOutBack)

        var dataEntries = [ChartDataEntry]()
        for i in 0..<dataSource!.destinations.count {
            let dataEntry = ChartDataEntry(value: dataSource!.destinations[i].count, xIndex: i)
            dataEntries.append(dataEntry)
        }

        let dataPoints = dataSource!.destinations.map {$0.name}
        let dataSet = PieChartDataSet(yVals: dataEntries, label: "Spend destinations")
        for i in 0..<dataSource!.destinations.count {
            dataSet.colors.append(dataSource!.dynamicType.DestType.colors[i])
        }
        //dataSet.colors = dataSource!.destinations.map{$0.color}

        let pieChartData = PieChartData(xVals: dataPoints, dataSet: dataSet)
        chartView.extraTopOffset = 45
        chartView.legend.position = .AboveChartCenter
        chartView.legend.enabled = false
//        chartView.legend.xEntrySpace = 0.0
//        chartView.legend.yEntrySpace = 0.0
//        chartView.legend.xOffset = 0.0

        //chartView.legend.enabled = false

        chartView.data = pieChartData
    }
}
extension StatisticsCollectionViewCell: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataSource != nil) ? self.dataSource!.destinations.count : 0

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RightDetailCellID",forIndexPath: indexPath)
        
        cell.textLabel?.text = self.dataSource!.destinations[indexPath.row].name as String
        cell.detailTextLabel?.text = String(self.dataSource!.destinations[indexPath.row].count)
        return cell
    }
}