//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: Animation, PropertyAnimation {
    
    class func canAnimate(object: NSObject, key: String) -> Bool {
        guard !(object is NSLayoutConstraint) else { return false }
        return (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true
    }
    
    var object: NSObject
    var key: String
    var invalidatedFromValue = false
    var fromValue: Any?
    var fromValueIsConcrete: Bool = false
    var toValue: Any
    var curve: Curve
    
    var animationStart: NSDate?
    var displayLink: CADisplayLink?
    
    override func setPosition(position: NSTimeInterval, apply: Bool) {
        defer { super.setPosition(position, apply: apply) }
        guard apply else { return }
        if position == 0.0 && _position > 0.0 {
            if !fromValueIsConcrete {
                invalidatedFromValue = true
            }
        }
        update(position - delay)
    }
    
    required init(duration: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve) {
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init(duration: duration)
    }
    
    convenience init(duration: NSTimeInterval, object: NSObject, key: String, fromValue: Any, toValue: Any, curve: Curve) {
        self.init(duration: duration, object: object, key: key, toValue: toValue, curve: curve)
        self.fromValue = fromValue
        self.fromValueIsConcrete = true
    }
    
    override func commit() {
        animationStart = NSDate(timeIntervalSinceNow: -position + delay)
        displayLink = CADisplayLink(target: self, selector: Selector("displayDidUpdate"))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    override func complete(finished: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
        super.complete(finished)
    }
    
    func update(position: Double) {
        
        if invalidatedFromValue {
            fromValue = nil
            invalidatedFromValue = false
        }
        
        fromValue = fromValue ?? object.valueForKey(key)
        
        let position = position / duration * speed
        
        if position >= 1.0 {
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, curve.transform(1.0)).objectValue!, forKey: key)
            complete(true)
        }
        
        else if position > 0.0 {
            
            if let fromValue = fromValue {
                object.setValue(
                    (fromValue as! Interpolatable).interpolate(
                        toValue as! Interpolatable,
                        curve.transform(position)
                    ).objectValue,
                    forKey: key
                )
            }
            
        } else if let fromValue = fromValue {
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, curve.transform(0.0)).objectValue!, forKey: key)
        }
        
    }
    
    func displayDidUpdate() {
        self.position = abs(animationStart?.timeIntervalSinceNow ?? 0.0) - delay
    }
    
}