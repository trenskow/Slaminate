//
//  PropertyAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 21/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

protocol PropertyAnimation {
    static func canAnimate(_ object: NSObject, key: String) -> Bool
    var object: NSObject { get }
    var key: String { get }
    var toValue: Any { get }
    var curve: Curve { get }
    init(duration: TimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve)
}
