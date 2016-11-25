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
    
    fileprivate static func updateSwizzle() {
        NSObject.swizzled = builders.some({ $0.buildState == .collecting })
    }
    
    static var top: AnimationBuilder! {
        return builders.last
    }
    
    enum AnimationBuilderState {
        case waiting
        case collecting
        case resetting
        case building
        case done
    }
    
    var buildState = AnimationBuilderState.building {
        didSet {
            AnimationBuilder.updateSwizzle()
        }
    }
    
    var propertyInfos = [PropertyInfo]()
    var constraintInfos = [PropertyInfo]()
    var constraintPresenceInfos = [ConstraintPresenceInfo]()
    
    let animation: (Void) -> Void
    var applyDuration: TimeInterval
    var applyCurve: Curve
    
    init(duration: TimeInterval, curve: Curve, animation: @escaping (Void) -> Void) {
        self.animation = animation
        self.applyCurve = curve
        self.applyDuration = duration
        super.init(animations: [])
    }
    
    override var duration: TimeInterval {
        get { return applyDuration }
        set {
            applyDuration = newValue
            animations.forEach({ $0.duration = newValue })
        }
    }
        
    override func setPosition(_ position: TimeInterval, apply: Bool) {
        if position > 0.0 {
            build()
        }
        super.setPosition(position, apply: apply)
    }
    
    func setObjectFromValue(_ object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard buildState == .collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue ??= value
        
        return true
        
    }
    
    func setObjectToValue(_ object: NSObject, key: String, value: NSObject?) -> Bool {
        
        guard buildState == .collecting else {
            return false
        }
        
        propertyInfos[propertyInfos.indexOf(object, key: key)].toValue = value
        
        return true
        
    }
    
    func setObjectFromToValue(_ object: NSObject, key: String, fromValue: NSObject?, toValue: NSObject?) -> Bool {
        
        guard buildState == .collecting else {
            return false
        }
        
        let idx = propertyInfos.indexOf(object, key: key)
        propertyInfos[idx].fromValue ??= fromValue
        propertyInfos[idx].toValue = toValue
        
        return true
        
    }
    
    func setConstraintValue(_ object: NSLayoutConstraint, key: String, fromValue: NSObject, toValue: NSObject) {
        
        guard buildState == .collecting else { return }
        
        let index = constraintInfos.indexOf(object, key: key)
        constraintInfos[index].fromValue ??= fromValue
        constraintInfos[index].toValue = toValue
        
        if key == "constant" {
            _ = setObjectFromToValue(object, key: key, fromValue: fromValue, toValue: toValue)
        }

    }
    
    func addConstraintPresence(_ view: UIView, constraint: NSLayoutConstraint, added: Bool) {
        
        guard buildState == .collecting else { return }
        
        constraintPresenceInfos.append(ConstraintPresenceInfo(
            view: view,
            constraint: constraint,
            added: added)
        )
        
    }
    
    func collectAnimations() {
        
        guard buildState == .collecting else {
            fatalError("Finalizing without collecting.")
        }
        
        constraintInfos.applyToValues()
        constraintPresenceInfos.applyPresent(true)
        
        var views: [(UIView, UIView?)] = constraintInfos.map({ (
                ($0.object as! NSLayoutConstraint).firstItem as! UIView,
                ($0.object as! NSLayoutConstraint).secondItem as? UIView
        ) })
        
        views.append(contentsOf: constraintPresenceInfos.map({ (
            ($0.constraint.firstItem as! UIView),
            ($0.constraint.secondItem as? UIView)
        ) }))
        
        if let first = views.first {
            
            var common = views.reduce(first.1 != nil ? first.0.commonAncestor(first.1!)! : first.0, { (c, views) -> UIView in
                var first = c.commonAncestor(views.0)
                if let _ = views.1 {
                    first = first?.commonAncestor(views.1!)
                }
                return first!
            })
            
            if let superview = common.superview , superview as? UIWindow == nil {
                common = superview
            }
            
            common.updateConstraints()
            common.layoutSubviews()
            
            buildState = .resetting
            
            constraintInfos.applyFromValues()
            constraintPresenceInfos.applyPresent(false)
            
            common.updateConstraints()
            common.layoutSubviews()
            
        }
        
        buildState = .resetting
        
        // Apply from value to all but constraints constants.
        propertyInfos.filter({
            $0.key != "constant" && !($0.object is NSLayoutConstraint)
        }).applyFromValues()
        
        buildState = .building
        
        for propertyInfo in propertyInfos {
            guard let object = propertyInfo.object, let toValue = propertyInfo.toValue else { continue }
            
            let animation = object.pick(
                animationForKey: propertyInfo.key,
                fromValue: nil,
                toValue: toValue,
                duration: duration,
                curve: applyCurve)
            
            if let animation = animation {
                add(animation)
            } else {
                propertyInfo.applyToValue()
            }
            
        }
        
        buildState = .done
        
    }
    
    func build() {
        guard buildState == .building else { return }
        AnimationBuilder.builders.append(self)
        buildState = .collecting
        let enabled = UIView.areAnimationsEnabled
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
    
    override func complete(_ finished: Bool) {
        constraintInfos.applyToValues()
        constraintPresenceInfos.applyPresent(true)
        super.complete(finished)
    }
    
}
