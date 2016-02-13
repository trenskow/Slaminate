//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: ConcreteAnimation, PropertyAnimation {
    
    class func canAnimate(object: NSObject, key: String) -> Bool {
        guard object as? NSLayoutConstraint == nil else { return false }
        return (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true
    }
    
    var object: NSObject
    var key: String
    var invalidatedFromValue = false
    var fromValue: AnyObject?
    var toValue: AnyObject
    var curve: Curve
    
    var animationStart: NSDate?
    var displayLink: CADisplayLink?
    
    override var position: AnimationPosition {
        didSet {
            if position != oldValue {
                if position == .Beginning {
                    invalidatedFromValue = true
                }
            }
        }
    }
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init()
        self.duration = duration
        self.delay = delay
    }
    
    override var offset: NSTimeInterval {
        didSet {
            if offset != oldValue {
                update(offset)
            }
        }
    }
    
    override func commitAnimation() {
        position = .InProgress
        animationStart = NSDate()
        displayLink = CADisplayLink(target: self, selector: Selector("displayDidUpdate"))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func completeAnimation() {
        state = .Comited
        object.setValue(toValue, forKey: key)
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
        finished = true
        position = .End
    }
    
    func update(progress: Double) {
        
        if progress >= delay + duration {
            completeAnimation()
        }
            
        else if progress >= delay {
            
            let position = (progress - delay) / duration
            
            if invalidatedFromValue && position > 0.0 {
                fromValue = nil
                invalidatedFromValue = false
            }
            
            fromValue = fromValue ?? object.valueForKey(key)
            
            if let fromValue = fromValue {
                object.setValue(
                    (fromValue as! Interpolatable).interpolate(
                        toValue,
                        (curve ?? Curve.linear).block(position)
                    ) as? AnyObject,
                    forKey: key
                )
            }
        } else if let fromValue = fromValue {
            object.setValue(fromValue, forKey: key)
        }
        
    }
    
    func displayDidUpdate() {
        
        update(abs(animationStart?.timeIntervalSinceNow ?? 0.0) + offset)
        
    }
    
}