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
infix operator |=

func ??=<T>(lhs: inout T?, rhs: T?) {
    lhs = lhs ?? rhs
}

public func +(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.and(animation: rhs)
}

public func |(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.then(animation: rhs)
}

public func +=(lhs: inout Animation, rhs: Animation) {
    lhs = lhs.and(animation: rhs)
}

public func |=(lhs: inout Animation, rhs: Animation) {
    lhs = lhs.then(animation: rhs)
}

public func +(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.add(curve: rhs)
}

public func *(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.multiply(curve: rhs)
}

public func |(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.or(curve: rhs)
}

public func +=(lhs: inout Curve, rhs: Curve) {
    lhs = lhs + rhs
}

public func *=(lhs: inout Curve, rhs: Curve) {
    lhs = lhs * rhs
}

public func |=(lhs: inout Curve, rhs: Curve) {
    lhs = lhs | rhs
}
