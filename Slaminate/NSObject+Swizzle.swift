//
//  NSObject+Swizzle.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

extension NSObject {
    
    private static var instanceSwizzles:[InstanceSwizzle]!
    
    internal static var swizzled = false {
        didSet {
            if instanceSwizzles == nil {
                instanceSwizzles = [
                    InstanceSwizzle(cls: NSObject.classForCoder(), "willChangeValueForKey:"),
                    InstanceSwizzle(cls: NSObject.classForCoder(), "didChangeValueForKey:"),
                    InstanceSwizzle(cls: NSObject.classForCoder(), "setValue:forKey:"),
                    
                    InstanceSwizzle(cls: NSLayoutConstraint.classForCoder(), "setConstant:"),
                    InstanceSwizzle(cls: NSLayoutConstraint.classForCoder(), "setActive:"),
                    
                    InstanceSwizzle(cls: UIView.classForCoder(), "addConstraint:"),
                    InstanceSwizzle(cls: UIView.classForCoder(), "removeConstraint:"),
                    InstanceSwizzle(cls: UIView.classForCoder(), "addConstraints:"),
                    InstanceSwizzle(cls: UIView.classForCoder(), "removeConstraints:")
                    
                ]
            }
            instanceSwizzles.enabled = swizzled
        }
    }
    
    // NSObject
    
    func slaminate_willChangeValueForKey(key: String) {
        
        defer {
            slaminate_willChangeValueForKey(key)
        }
        
        guard self as? NSLayoutConstraint == nil else { return }
        guard AnimationBuilder.top.setObjectFromValue(self, key: key, value: valueForKey(key) as? NSObject) else {
            return;
        }
        
    }
    
    func slaminate_didChangeValueForKey(key: String) {
        
        defer {
            slaminate_didChangeValueForKey(key)
        }
        
        guard self as? NSLayoutConstraint == nil else { return }
        guard AnimationBuilder.top.setObjectToValue(self, key: key, value: valueForKey(key) as? NSObject) else {
            return
        }
        
    }
    
    func slaminate_setValue(value: AnyObject?, forKey key: String) {
        
        defer {
            slaminate_setValue(value, forKey: key)
        }
        
        guard self as? NSLayoutConstraint == nil else { return }
        
        guard AnimationBuilder.top.setObjectFromToValue(self, key: key, fromValue: valueForKey(key) as? NSObject, toValue: value as? NSObject) else {
            return;
        }
        
    }
    
    // NSLayoutContraint
    
    private func setConstraintValue(key: String, newValue: AnyObject) {
        AnimationBuilder.top.setConstraintValue(
            self as! NSLayoutConstraint,
            key: key,
            oldValue: valueForKey(key) as! NSObject,
            newValue: newValue as! NSObject
        )
    }
    
    func slaminate_setActive(active: Bool) {
        setConstraintValue("active", newValue: active)
        slaminate_setActive(active)
    }
    
    func slaminate_setConstant(constant: CGFloat) {
        setConstraintValue("constant", newValue: constant)
        slaminate_setConstant(constant)
    }
    
    // UIView
    
    func slaminate_addConstraint(constraint: NSLayoutConstraint) {
        AnimationBuilder.top.addConstraintPresence(self as! UIView, constraint: constraint, added: true)
        slaminate_addConstraint(constraint)
    }
    
    func slaminate_removeConstraint(constraint: NSLayoutConstraint) {
        AnimationBuilder.top.addConstraintPresence(self as! UIView, constraint: constraint, added: false)
        slaminate_removeConstraint(constraint)
    }
    
    func slaminate_addConstraints(constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            AnimationBuilder.top.addConstraintPresence(self as! UIView, constraint: constraint, added: true)
        }
        slaminate_addConstraints(constraints)
    }
    
    func slaminate_removeConstraints(constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            AnimationBuilder.top.addConstraintPresence(self as! UIView, constraint: constraint, added: false)
        }
        slaminate_removeConstraints(constraints)
    }
    
}
