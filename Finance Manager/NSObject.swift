//
//  NSObject.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 05.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation

extension NSObject {
    static func className() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}