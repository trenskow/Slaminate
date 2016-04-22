//
//  ReversedAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 22/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class ReversedAnimation: DirectAnimation {
    
    init(animation: Animation) {
        super.init(
            duration: animation.duration + animation.delay - animation.position,
            object: animation,
            key: "position",
            fromValue: nil,
            toValue: 0.0,
            curve: Curve.linear
        )
        animation.owner = self
    }
    
    required init(duration: NSTimeInterval, object: NSObject, key: String, fromValue: Any?, toValue: Any, curve: Curve) {
        super.init(duration: duration, object: object, key: key, fromValue: fromValue, toValue: toValue, curve: curve)
    }
    
    override var reversed: Bool {
        @objc(isReversed) get {
            return object is Animation
        }
    }
    
}
