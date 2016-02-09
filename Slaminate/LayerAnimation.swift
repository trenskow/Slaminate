//
//  LayerAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class LayerAnimation: NSObject, PropertyAnimation {
    
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
    
    @objc(isAnimating) var animating: Bool = false
    @objc(isComplete) var complete: Bool = false
    @objc(isFinished) var finished: Bool = false
    @objc var duration: NSTimeInterval
    @objc var delay: NSTimeInterval
    
    weak var delegate: AnimationDelegate?
    
    var object: NSObject
    var layer: CALayer
    var key: String
    var toValue: AnyObject
    var curve: Curve
    
    var delayTimer: NSTimer?
    
    var animation: CurvedAnimation?
    
    required init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve) {
        self.duration = duration
        self.delay = delay
        self.object = object
        self.layer = object as! CALayer
        self.key = key
        self.toValue = toValue
        self.curve = curve
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
    }
    
    func startAnimation() {
        
        animation = CurvedAnimation(keyPath: key)
        animation?.duration = duration
        animation?.fromValue = object.valueForKey(key) as? Interpolatable
        animation?.toValue = toValue as? Interpolatable
        animation?.curve = curve
        animation?.delegate = self
        
        animating = true
        
        layer.addAnimation(animation!, forKey: "animation_\(key)")
        
    }
    
    func beginAnimation() {
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