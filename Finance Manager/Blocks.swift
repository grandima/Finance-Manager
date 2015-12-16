//
//  Blocks.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 25.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import Foundation

typealias CompletionBlock = ErrorType? -> Void
typealias BooleanCompletionBlock = (Bool?, ErrorType?) -> Void
typealias ObjectCompletionBlock = (AnyObject?, ErrorType?) -> Void
typealias ArrayCompletionBlock = (Array<Any>?, ErrorType?) -> Void
