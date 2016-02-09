//
//  NSObject+Swizzle.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

extension NSObject {
    
    private static var instanceSwizzles:[InstanceSwizzle]!
    
    internal static var swizzled = false {
        didSet {
            if instanceSwizzles == nil {
                instanceSwizzles = [
                    InstanceSwizzle(cls: NSObject.classForCoder(), "willChangeValueForKey:"),
                    InstanceSwizzle(cls: NSObject.classForCoder(), "didChangeValueForKey:"),
                    
                    InstanceSwizzle(cls: NSLayoutConstraint.classForCoder(), "setConstant:"),
                    InstanceSwizzle(cls: NSLayoutConstraint.classForCoder(), "setActive:")
                    
                ]
            }
            instanceSwizzles.enabled = swizzled
        }
    }
    
    func slaminate_willChangeValueForKey(key: String) {
        AnimationBuilder.top.setObjectFromValue(self, key: key, value: valueForKey(key) as! NSObject)
    }
    
    func slaminate_didChangeValueForKey(key: String) {
        AnimationBuilder.top.setObjectToValue(self, key: key, value: valueForKey(key) as! NSObject)
    }
    
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
    
}
