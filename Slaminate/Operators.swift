//
//  Operators.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 25/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

// Operator to only assign if nil.
infix operator ??=
func ??=<T>(lhs: inout T?, rhs: T?) {
    lhs = lhs ?? rhs
}
