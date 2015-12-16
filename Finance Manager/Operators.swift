//
//  NSNumberExtension.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit

infix operator + {}
func + (lhs: NSNumber, rhs: NSNumber)-> NSNumber {
    let l = lhs.doubleValue
    let r = rhs.doubleValue
    return NSNumber(double: l+r)
}

func - (lhs: NSNumber, rhs: NSNumber)-> NSNumber {
    let l = lhs.doubleValue
    let r = rhs.doubleValue
    return NSNumber(double: l-r)
}

func + (lhs: NSNumber, rhs: Double) -> NSNumber {
    let l = lhs.doubleValue
    return NSNumber(double: l + rhs)
}

func += (inout lhs: NSNumber, rhs: NSNumber) {
    lhs = lhs + rhs
}
func -= (inout lhs: NSNumber, rhs: NSNumber) {
    lhs = lhs - rhs
}

func += (inout lhs: NSNumber, rhs: Double) {
    lhs = lhs + rhs
}


func += (inout lhs: [StatisticsData.DestType], var rhs: StatisticsData.DestType) {
    rhs.color = StatisticsData.DestType.colors.removeFirst()
    lhs.append(rhs)
}