//
//  Operators.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 25/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

// Operator to only assign if nil.
infix operator ??= { associativity right precedence 90 assignment }
infix operator |= { associativity right precedence 90 assignment }

func ??=<T>(inout lhs: T?, rhs: T?) {
    lhs = lhs ?? rhs
}

public func +(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.and(animation: rhs)
}

public func |(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.then(animation: rhs)
}

public func +=(inout lhs: Animation, rhs: Animation) {
    lhs = lhs.and(animation: rhs)
}

public func |=(inout lhs: Animation, rhs: Animation) {
    lhs = lhs.then(animation: rhs)
}

public func +(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.and(rhs)
}

public func |(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.then(rhs)
}

public func +=(inout lhs: Curve, rhs: Curve) {
    lhs = lhs.and(rhs)
}

public func |=(inout lhs: Curve, rhs: Curve) {
    lhs = lhs.then(rhs)
}
