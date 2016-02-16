//
//  LayerAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class LayerAnimation: DirectAnimation {
    
    override class func canAnimate(object: NSObject, key: String) -> Bool {
        guard (object as? CALayer) != nil && (object.valueForKey(key) as? Interpolatable)?.canInterpolate == true else {
            return false;
        }
        return [
            // CALayer Properties
            "contentsRect",
            "conetntsCenter",
            "opacity",
            "hidden",
            "masksToBounds",
            "doubleSided",
            "cornerRadius",
            "borderWidth",
            "borderColor",
            "backgroundColor",
            "shadowOpacity",
            "shadowRadius",
            "shadowOffset",
            "shadowColor",
            "shadowPath",
            "bounds",
            "position",
            "zPosition",
            "anchorPointZ",
            "anchorPoint",
            "transform",
            "sublayerTransform"
        ].contains(key);
    }
    
    var layer: CALayer
    
    var delayTimer: NSTimer?
    
    var animation: CurvedAnimation?
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve) {
        self.layer = object as! CALayer
        super.init(duration: duration, delay: delay, object: object, key: key, toValue: toValue, curve: curve)
    }
    
    override func animationDidStart(anim: CAAnimation) {
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animation?.delegate = nil
        _finished = flag
        progressState = .End
    }
    
    func startAnimation() {
        
        fromValue = fromValue ?? object.valueForKey(key)
        
        animation = CurvedAnimation(keyPath: key)
        animation?.duration = duration
        animation?.position = max(0.0, position - delay)
        animation?.fromValue = fromValue as? Interpolatable
        animation?.toValue = toValue as? Interpolatable
        animation?.curve = curve
        animation?.delegate = self
        animation?.removedOnCompletion = true
        
        layer.addAnimation(animation!, forKey: "animation_\(key)")
        
        progressState = .InProgress
        
        object.setValue((fromValue as! Interpolatable).interpolate(toValue as! Interpolatable, curve.block(1.0)).objectValue!, forKey: key)
        
    }
    
    override func commit() {
        state = .Comited
        guard progressState.rawValue < AnimationProgressState.End.rawValue else { return }
        if (delay - position) > 0.0 {
            delayTimer = NSTimer(
                timeInterval: delay - position,
                target: self,
                selector: Selector("startAnimation"),
                userInfo: nil,
                repeats: false
            )
            NSRunLoop.mainRunLoop().addTimer(delayTimer!, forMode: NSRunLoopCommonModes)
        } else {
            startAnimation()
        }
    }
    
}