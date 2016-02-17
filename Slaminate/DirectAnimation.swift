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
    
    var _finished: Bool = false
    var _duration: NSTimeInterval = 0.0
    var _delay: NSTimeInterval = 0.0
    
    @objc(isFinished) override var finished: Bool { return _finished }
    override var duration: NSTimeInterval { return _duration }
    override var delay: NSTimeInterval { return _delay }
    
    override var progressState: AnimationProgressState {
        didSet {
            if progressState != oldValue {
                if !fromValueIsConcrete && progressState == .Beginning {
                    invalidatedFromValue = true
                }
            }
        }
    }
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve) {
        self.object = object
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init()
        self._duration = duration
        self._delay = delay
    }
    
    internal convenience init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, fromValue: Any, toValue: Any, curve: Curve) {
        self.init(duration: duration, delay: delay, object: object, key: key, toValue: toValue, curve: curve)
        self.fromValue = fromValue
        self.fromValueIsConcrete = true
    }
    
    override var position: NSTimeInterval {
        didSet {
            if position != oldValue {
                update(position)
            }
        }
    }
    
    override func commit() {
        state = .Comited
        guard progressState.rawValue < AnimationProgressState.End.rawValue else { return }
        animationStart = NSDate()
        displayLink = CADisplayLink(target: self, selector: Selector("displayDidUpdate"))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func completeAnimation() {
        if let fromValue = fromValue {
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, 1.0).objectValue!, forKey: key)
        }
        progressState = .End
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
        _finished = true
    }
    
    func update(progress: Double) {
        
        if progress >= delay + duration {
            completeAnimation()
        }
        
        else if progress >= delay {
            
            progressState = .InProgress
            
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
            progressState = .Beginning
            object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, 0.0).objectValue!, forKey: key)
        }
        
    }
    
    func displayDidUpdate() {
        update(abs(animationStart?.timeIntervalSinceNow ?? 0.0) + position)
    }
    
}