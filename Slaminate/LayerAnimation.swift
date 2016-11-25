//
//  LayerAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class LayerAnimation: DirectAnimation, CAAnimationDelegate {
    
    override class func canAnimate(_ object: NSObject, key: String) -> Bool {
        guard let layer = object as? CoreAnimationKVCExtension else { return false }
        guard (object.value(forKeyPath: key) as? Interpolatable)?.canInterpolate == true else { return false }
        return type(of: layer).animatableKeyPaths.contains(key)
    }
    
    var layer: CALayer
    
    var delayTimer: Timer?
    
    var animation: CurvedAnimation?
    
    required init(duration: TimeInterval, object: NSObject, key: String, fromValue: Any?, toValue: Any, curve: Curve) {
        self.layer = object as! CALayer
        super.init(duration: duration, object: object, key: key, fromValue: fromValue, toValue: toValue, curve: curve)
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        object.setValue((fromValue as! Interpolatable).interpolate(to: toValue as! Interpolatable, at: curve.transform(1.0)).objectValue, forKey: key)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animation?.delegate = nil
        complete(flag)
    }
    
    override func commit() {
        
        fromValue ??= (layer.presentation() ?? layer).value(forKey: key)
        
        animation = CurvedAnimation(keyPath: key)
        animation?.duration = duration
        animation?.position = max(0.0, position - delay)
        animation?.fromValue = fromValue as? Interpolatable
        animation?.toValue = toValue as? Interpolatable
        animation?.curve = curve
        animation?.speed = Float(speed)
        animation?.delegate = self
        animation?.isRemovedOnCompletion = true
        
        layer.add(animation!, forKey: "animation_\(key)")
        
    }
    
}
