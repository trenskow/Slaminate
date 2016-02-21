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
        guard object as? NSLayoutConstraint == nil else { return false }
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
    
    var _duration: NSTimeInterval = 0.0
    
    override var duration: NSTimeInterval { return _duration }
    
    override var position: NSTimeInterval {
        didSet {
            guard position != oldValue else { return }
            if position == 0.0 && oldValue > 0.0 {
                if !fromValueIsConcrete {
                    invalidatedFromValue = true
                }
            }
            update(position)
        }
    }
    
    required init(duration: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve) {
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init()
        self._duration = duration
    }
    
    convenience init(duration: NSTimeInterval, object: NSObject, key: String, fromValue: Any, toValue: Any, curve: Curve) {
        self.init(duration: duration, object: object, key: key, toValue: toValue, curve: curve)
        self.fromValue = fromValue
        self.fromValueIsConcrete = true
    }
    
    override func commit() {
        animationStart = NSDate()
        displayLink = CADisplayLink(target: self, selector: Selector("displayDidUpdate"))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    override func complete(finished: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
        super.complete(finished)
    }
    
    func update(progress: Double) {
        
        if progress >= duration {
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, 1.0).objectValue!, forKey: key)
            complete(true)
        }
        
        else if progress >= 0.0 {
            
            let position = (progress - delay) / duration
            
            if invalidatedFromValue && position > 0.0 {
                fromValue = nil
                invalidatedFromValue = false
            }
            
            fromValue = fromValue ?? object.valueForKey(key)
            
            if let fromValue = fromValue {
                object.setValue(
                    (fromValue as! Interpolatable).interpolate(
                        toValue as! Interpolatable,
                        (curve ?? Curve.linear).block(position)
                    ).objectValue,
                    forKey: key
                )
            }
            
        } else if let fromValue = fromValue {
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, 0.0).objectValue!, forKey: key)
        }
        
    }
    
    func displayDidUpdate() {
        update(abs(animationStart?.timeIntervalSinceNow ?? 0.0) + position)
    }
    
}