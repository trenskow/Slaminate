//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: ConcreteAnimation, PropertyAnimation {
    
    static func canAnimate(object: NSObject, key: String) -> Bool {
        return (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true
    }
    
    var object: NSObject
    var key: String
    var fromValue: AnyObject?
    var toValue: AnyObject
    var curve: Curve
    
    var animationStart: NSDate?
    var displayLink: CADisplayLink?
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init()
        self.duration = duration
        self.delay = delay
    }
    
    override func commitAnimation() {
        animating = true
        animationStart = NSDate()
        displayLink = CADisplayLink(target: self, selector: Selector("displayDidUpdate"))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func displayDidUpdate() {
        
        let progress = abs(animationStart?.timeIntervalSinceNow ?? 0.0)
        
        if progress >= delay + duration {
            object.setValue(toValue, forKey: key)
            displayLink?.invalidate()
            displayLink = nil
            animationStart = nil
            complete = true
            finished = true
            animating = false
            self.delegate?.animationCompleted(self, finished: true)
            ongoingAnimations.remove(self)
        }
        
        else if progress >= delay {
            
            let position = (progress - delay) / duration
            
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
        }
        
    }
        
}