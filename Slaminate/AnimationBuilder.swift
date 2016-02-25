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
        NSObject.swizzled = builders.some({ $0.buildState == .Collecting })
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
    
    var buildState = AnimationBuilderState.Building {
        didSet {
            AnimationBuilder.updateSwizzle()
        }
    }
    
    var propertyInfos = [PropertyInfo]()
    var constraintInfos = [PropertyInfo]()
    var constraintPresenceInfos = [ConstraintPresenceInfo]()
    
    let animation: Void -> Void
    var applyDuration: NSTimeInterval
    var applyCurve: Curve
    
    init(duration: NSTimeInterval, curve: Curve, animation: Void -> Void) {
        self.animation = animation
        self.applyCurve = curve
        self.applyDuration = duration
        super.init(animations: [])
    }
    
    override var duration: NSTimeInterval {
        get { return applyDuration }
        set {
            applyDuration = newValue
            animations.forEach({ $0.duration = newValue })
        }
    }
        
    override func setPosition(position: NSTimeInterval, apply: Bool) {
        if position > 0.0 {
            build()
        }
        super.setPosition(position, apply: apply)
    }
    
    func setObjectFromValue(object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard buildState == .Collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue ??= value
        
        return true
        
    }
    
    func setObjectToValue(object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard buildState == .Collecting else {
            return false
        }
        
        propertyInfos[propertyInfos.indexOf(object, key: key)].toValue = value
        
        return true
        
    }
    
    func setObjectFromToValue(object: NSObject, key: String, fromValue: NSObject?, toValue: NSObject?) -> Bool {
        
        guard buildState == .Collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue ??= fromValue
        propertyInfos[idx].toValue = toValue
        
        return true
        
    }
    
    func setConstraintValue(object: NSLayoutConstraint, key: String, fromValue: NSObject, toValue: NSObject) {
        
        guard buildState == .Collecting else { return }
        
        let index = constraintInfos.indexOf(object, key: key)
        constraintInfos[index].fromValue ??= fromValue
        constraintInfos[index].toValue = toValue
        
        if key == "constant" {
            setObjectFromToValue(object, key: key, fromValue: fromValue, toValue: toValue)
        }

    }
    
    func addConstraintPresence(view: UIView, constraint: NSLayoutConstraint, added: Bool) {
        
        guard buildState == .Collecting else { return }
        
        constraintPresenceInfos.append(ConstraintPresenceInfo(
            view: view,
            constraint: constraint,
            added: added)
        )
        
    }
    
    func collectAnimations() {
        
        guard buildState == .Collecting else {
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
            
            if let superview = common.superview where superview as? UIWindow == nil {
                common = superview
            }
            
            common.updateConstraints()
            common.layoutSubviews()
            
            buildState = .Resetting
            
            constraintInfos.applyFromValues()
            constraintPresenceInfos.applyPresent(false)
            
            common.updateConstraints()
            common.layoutSubviews()
            
        }
        
        buildState = .Resetting
        
        // Apply from value to all but constraints constants.
        propertyInfos.filter({
            $0.key != "constant" && !($0.object is NSLayoutConstraint)
        }).applyFromValues()
        
        buildState = .Building
        
        for propertyInfo in propertyInfos {
            
            var animation: Animation?
            
            if let value = propertyInfo.toValue {
                
                if LayerAnimation.canAnimate(propertyInfo.object, key: propertyInfo.key) {
                    animation = LayerAnimation(duration: applyDuration, object: propertyInfo.object, key: propertyInfo.key, toValue: value, curve: applyCurve ?? Curve.linear)
                }
                
                else if ConstraintConstantAnimation.canAnimate(propertyInfo.object, key: propertyInfo.key) {
                    animation = ConstraintConstantAnimation(duration: applyDuration, object: propertyInfo.object, key: propertyInfo.key, toValue: value, curve: applyCurve ?? Curve.linear)
                }
                    
                else if DirectAnimation.canAnimate(propertyInfo.object, key: propertyInfo.key) {
                    animation = DirectAnimation(duration: applyDuration, object: propertyInfo.object, key: propertyInfo.key, toValue: value, curve: applyCurve ?? Curve.linear)
                }
                
            }
            
            if let animation = animation {
                add(animation)
            } else {
                propertyInfo.applyToValue()
            }
            
        }
        
        buildState = .Done
        
    }
    
    func build() {
        guard buildState == .Building else { return }
        AnimationBuilder.builders.append(self)
        buildState = .Collecting
        let enabled = UIView.areAnimationsEnabled()
        UIView.setAnimationsEnabled(false)
        animation()
        collectAnimations()
        UIView.setAnimationsEnabled(enabled)
        AnimationBuilder.builders.removeLast()
    }
    
    override func commit() {
        build()
        super.commit()
    }
    
    override func complete(finished: Bool) {
        constraintInfos.applyToValues()
        constraintPresenceInfos.applyPresent(true)
        super.complete(finished)
    }
    
}
