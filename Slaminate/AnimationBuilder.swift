//
//  AnimationBuilder.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationBuilder: AnimationGroup {
    
    static var allAnimations = [AnimationGroup]()
    static var builders = [AnimationBuilder]()
    
    private static func updateSwizzle() {
        NSObject.swizzled = builders.reduce(false, combine: { $0 || $1.state == .Collecting })
    }
    
    static var top: AnimationBuilder {
        return builders.last!
    }
    
    enum AnimationBuilderState {
        case Waiting
        case Collecting
        case Resetting
        case Building
        case Done
    }
    
    var state = AnimationBuilderState.Waiting {
        didSet {
            AnimationBuilder.updateSwizzle()
        }
    }
    
    var propertyInfos = [PropertyInfo]()
    var constraintInfos = [PropertyInfo]()
    var constraintPresenceInfos = [ConstraintPresenceInfo]()
    
    let animation: Void -> Void
    var curve: Curve?
    
    init(duration: NSTimeInterval, delay: NSTimeInterval, animation: Void -> Void, curve: Curve?, completion: ((finished: Bool) -> Void)?) {
        self.animation = animation
        super.init(animations: [], completion: completion)
        self.duration = duration
        self.delay = delay
        self.curve = curve
    }
    
    deinit {
        print("deinit builder")
    }
    
    func setObjectFromValue(object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard state == .Collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue = propertyInfos[idx].fromValue ?? value
        
        return true
        
    }
    
    func setObjectToValue(object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard state == .Collecting else {
            return false
        }
        
        propertyInfos[propertyInfos.indexOf(object, key: key)].toValue = value
        
        return true
        
    }
    
    func setObjectFromToValue(object: NSObject, key: String, fromValue: NSObject?, toValue: NSObject?) -> Bool {
        
        guard state == .Collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue = propertyInfos[idx].fromValue ?? fromValue
        propertyInfos[idx].toValue = toValue
        
        return true
        
    }
    
    func setConstraintValue(object: NSLayoutConstraint, key: String, oldValue: NSObject, newValue: NSObject) {
        
        guard state == .Collecting else { return }
        
        let index = constraintInfos.indexOf(object, key: key)
        constraintInfos[index].fromValue = oldValue
        constraintInfos[index].toValue = newValue
        
    }
    
    func addConstraintPresence(view: UIView, constraint: NSLayoutConstraint, added: Bool) {
        
        guard state == .Collecting else { return }
        
        constraintPresenceInfos.append(ConstraintPresenceInfo(
            view: view,
            constraint: constraint,
            added: added)
        )
        
    }
    
    func collectAnimations() {
        
        guard state == .Collecting else {
            fatalError("Finalizing without collecting.")
        }
        
        constraintInfos.applyToValues()
        constraintPresenceInfos.applyPresent(true)
        
        var views: [(UIView, UIView?)] = constraintInfos.map({ (
                ($0.object as! NSLayoutConstraint).firstItem as! UIView,
                ($0.object as! NSLayoutConstraint).secondItem as? UIView
        ) })
        
        views.appendContentsOf(constraintPresenceInfos.map({ (
            ($0.constraint.firstItem as! UIView),
            ($0.constraint.secondItem as? UIView)
        ) }))
        
        if let first = views.first {
            
            var common = views.reduce(first.1 != nil ? first.0.commonAncestor(first.1!)! : first.0, combine: { (c, views) -> UIView in
                var first = c.commonAncestor(views.0)
                if let _ = views.1 {
                    first = first?.commonAncestor(views.1!)
                }
                return first!
            })
            
            common = common.superview ?? common
            
            common.updateConstraints()
            common.layoutSubviews()
            
            state = .Resetting
            
            constraintInfos.applyFromValues()
            constraintPresenceInfos.applyPresent(false)
            
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
        
        self.animations = animations
        
        self.animations.forEach { (animation) -> () in
            animation.delegate = self
            animation.postponeAnimation()
        }
        
        state = .Done
        
    }
    
    override func commitAnimation() {
        
        AnimationBuilder.builders.append(self)
        
        state = .Collecting
        
        animation()
        
        collectAnimations()
        
        AnimationBuilder.builders.removeLast()
        
        super.commitAnimation()
        
    }
    
    override func completeAnimation(finished: Bool) {
        constraintInfos.applyToValues()
        constraintPresenceInfos.applyPresent(true)
        super.completeAnimation(finished)
    }
    
}
