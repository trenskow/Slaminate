//
//  LayerAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class LayerAnimation: ConcreteAnimation, PropertyAnimation {
    
    static func canAnimate(object: NSObject, key: String) -> Bool {
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
    
    var object: NSObject
    var layer: CALayer
    var key: String
    var toValue: AnyObject
    var curve: Curve
    
    var delayTimer: NSTimer?
    
    var animation: CurvedAnimation?
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.object = object
        self.layer = object as! CALayer
        self.key = key
        self.toValue = toValue
        self.curve = curve
        super.init()
        self.duration = duration
        self.delay = delay
    }
    
    deinit {
        print("deinit layeranimation")
    }
    
    override func animationDidStart(anim: CAAnimation) {
        object.setValue(toValue, forKey: key)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animation?.delegate = nil
        animating = false
        complete = true
        finished = flag
        delegate?.animationCompleted(self, finished: flag)
        ongoingAnimations.remove(self)
    }
    
    func startAnimation() {
        
        animation = CurvedAnimation(keyPath: key)
        animation?.duration = duration
        animation?.fromValue = object.valueForKey(key) as? Interpolatable
        animation?.toValue = toValue as? Interpolatable
        animation?.curve = curve
        animation?.delegate = self
        animation?.removedOnCompletion = true
        
        animating = true
        
        layer.addAnimation(animation!, forKey: "animation_\(key)")
        
    }
    
    override func commitAnimation() {
        if delay > 0.0 {
            delayTimer = NSTimer(
                timeInterval: delay,
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