//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: NSObject, PropertyAnimation {
    
    static func canAnimate(object: NSObject, key: String) -> Bool {
        return (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true
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
    
    var animationStart: NSDate?
    var displayLink: CADisplayLink?
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.duration = duration
        self.delay = delay
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
    }
    
    func beginAnimation() {
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