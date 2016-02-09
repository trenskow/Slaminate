//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: PropertyAnimation {
    
    static func canAnimate(object: NSObject, key: String) -> Bool {
        return (object as? Interpolatable)?.canInterpolate == true
    }
    
    @objc(isAnimating) var animating: Bool = false
    @objc(isComplete) var complete: Bool = false
    @objc(isFinished) var finished: Bool = false
    @objc var duration: NSTimeInterval
    @objc var delay: NSTimeInterval
    
    weak var delegate: AnimationDelegate?
    
    var object: NSObject
    var key: String
    var fromValue: AnyObject?
    var toValue: AnyObject
    var curve: Curve
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.duration = duration
        self.delay = delay
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
    }
    
    func startAnimation() {
        
    }
    
    func beginAnimation() {
    }
        
}