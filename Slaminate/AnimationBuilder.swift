//
//  AnimationBuilder.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationBuilder {
    
    static var allAnimations = [AnimationGroup]()
    static var builders = [AnimationBuilder]()
    
    static var top: AnimationBuilder {
        return builders.last!
    }
    
    static func pushBuilder() {
        builders.append(AnimationBuilder())
        updateSwizzle()
    }
    
    private static func updateSwizzle() {
        NSObject.swizzled = builders.reduce(false, combine: { $0 || $1.state == .Collecting })
    }
    
    enum AnimationBuilderState {
        case Collecting
        case Resetting
        case Building
        case Done
    }
    
    var state = AnimationBuilderState.Collecting {
        didSet {
            AnimationBuilder.updateSwizzle()
        }
    }
    
    deinit {
        print("deinit builder")
    }
    
    var propertyInfos = [PropertyInfo]()
    var constraintInfos = [PropertyInfo]()
    
    func setObjectFromValue(object: NSObject, key: String, value: NSObject) {
        if state == .Collecting {
            let idx = propertyInfos.indexOf(object, key: key)
            propertyInfos[idx].fromValue = propertyInfos[idx].fromValue ?? value
        }
    }
    
    func setObjectToValue(object: NSObject, key: String, value: NSObject) {
        if state == .Collecting {
            propertyInfos[propertyInfos.indexOf(object, key: key)].toValue = value
        }
    }
    
    func setConstraintValue(object: NSLayoutConstraint, key: String, oldValue: NSObject, newValue: NSObject) {
        if state == .Collecting {
            let index = constraintInfos.indexOf(object, key: key)
            constraintInfos[index].fromValue = oldValue
            constraintInfos[index].toValue = newValue
        }
    }
    
    internal func finalize(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: ((finished: Bool) -> Void)?) -> AnimationGroup {
        
        constraintInfos.applyToValues()
        
        let views: [(UIView, UIView)] = constraintInfos.map({ (
                ($0.object as! NSLayoutConstraint).firstItem as! UIView,
                ($0.object as! NSLayoutConstraint).secondItem as! UIView
        ) })
        
        if let first = views.first {
            let common = views.reduce(first.0.commonAncestor(first.1)!, combine: { (c, views) -> UIView in
                return c.commonAncestor(views.0.commonAncestor(views.1)!)!
            })
            
            common.updateConstraints()
            common.layoutSubviews()
            
            state = .Resetting
            
            constraintInfos.applyFromValues()
            
            common.updateConstraints()
            common.layoutSubviews()
            
        }
        
        state = .Resetting
        
        propertyInfos.applyFromValues()
        
        state = .Building
        
        var animations = [DelegatedAnimation]()
        
        for propertyInfo in propertyInfos {
            
            var animation: DelegatedAnimation?
            
            if let value = propertyInfo.toValue {
                
                if LayerAnimation.canAnimate(propertyInfo.object, key: propertyInfo.key) {
                    animation = LayerAnimation(duration: duration, delay: delay, object: propertyInfo.object, key: propertyInfo.key, toValue: value, curve: curve ?? Curve.linear)
                }
                    
                else if DirectAnimation.canAnimate(propertyInfo.object, key: propertyInfo.key) {
                    animation = DirectAnimation(duration: duration, delay: delay, object: propertyInfo.object, key: propertyInfo.key, toValue: value, curve: curve ?? Curve.linear)
                }
                
            }
            
            if let animation = animation {
                animations.append(animation)
            } else {
                propertyInfo.applyToValue()
            }
            
        }
        
        AnimationBuilder.builders.removeLast()
        
        var animationGroup: AnimationGroup!
        
        let ci = self.constraintInfos
        
        animationGroup = AnimationGroup(animations: animations, completion: {
            ci.applyToValues()
            AnimationBuilder.allAnimations.removeAtIndex(AnimationBuilder.allAnimations.indexOf({ $0 === animationGroup })!)
            completion?(finished: $0)
        })
        
        animationGroup.beginAnimation()
        
        AnimationBuilder.allAnimations.append(animationGroup)
        
        state = .Done
        
        return animationGroup
        
    }
    
}
