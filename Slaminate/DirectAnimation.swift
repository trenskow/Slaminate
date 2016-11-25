//
//  DirectAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class DirectAnimation: Animation, PropertyAnimation {
    
    class func canAnimate(_ object: NSObject, key: String) -> Bool {
        guard !(object is NSLayoutConstraint) else { return false }
        return (object.value(forKey: key) as? Interpolatable)?.canInterpolate == true
    }
    
    var object: NSObject
    var key: String
    var invalidatedFromValue = false
    var fromValue: Any?
    var fromValueIsConcrete: Bool = false
    var toValue: Any
    var curve: Curve
    
    var animationStart: Date?
    var displayLink: CADisplayLink?
    
    override func setPosition(_ position: TimeInterval, apply: Bool) {
        defer { super.setPosition(position, apply: apply) }
        guard apply else { return }
        guard position != _position else { return }
        if position == 0.0 && _position > 0.0 {
            if !fromValueIsConcrete {
                invalidatedFromValue = true
            }
        }
        update(position - delay)
    }
    
    required init(duration: TimeInterval, object: NSObject, key: String, fromValue: Any?, toValue: Any, curve: Curve) {
        self.object = object
        self.key = key
        self.fromValue = fromValue
        self.toValue = toValue
        self.curve = curve
        self.fromValueIsConcrete = (fromValue != nil)
        super.init(duration: duration)
    }
    
    override func commit() {
        animationStart = Date(timeIntervalSinceNow: -position + delay)
        displayLink = CADisplayLink(target: self, selector: #selector(DirectAnimation.displayDidUpdate))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    override func complete(_ finished: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
        super.complete(finished)
    }
    
    func update(_ position: Double) {
        
        if invalidatedFromValue {
            self.fromValue = nil
            invalidatedFromValue = false
        }
        
        self.fromValue ??= object.value(forKey: key)
        
        guard let fromValue = fromValue as? Interpolatable, let toValue = toValue as? Interpolatable else  {
            fatalError("Cannot interpolate non-interpolatable types.")
        }
        
        let position = position / duration * speed
        
        if position >= 1.0 {
            object.setValue(fromValue.interpolate(to: toValue, at: curve.transform(1.0)).objectValue, forKey: key)
            complete(true)
        }
        
        else if position > 0.0 {
            
            object.setValue(
                fromValue.interpolate(
                    to: toValue,
                    at: curve.transform(position)
                ).objectValue,
                forKey: key
            )
            
        } else {
            object.setValue(fromValue.interpolate(to: toValue, at: curve.transform(0.0)).objectValue, forKey: key)
        }
        
    }
    
    func displayDidUpdate() {
        self.position = abs(animationStart?.timeIntervalSinceNow ?? 0.0) - delay
    }
    
}
