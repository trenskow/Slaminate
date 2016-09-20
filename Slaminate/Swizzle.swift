//
//  Swizzle.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

protocol MethodInfo {
    var method: Method { get }
    var implementation: IMP { get }
    init(cls: AnyClass, selector: Selector);
}

struct InstanceMethod: MethodInfo {
    var method: Method
    var implementation: IMP
    init(cls: AnyClass, selector: Selector) {
        method = class_getInstanceMethod(cls, selector)
        implementation = method_getImplementation(method)
    }
}

struct ClassMethod: MethodInfo {
    var method: Method
    var implementation: IMP
    init(cls: AnyClass, selector: Selector) {
        method = class_getClassMethod(cls, selector)
        implementation = method_getImplementation(method)
    }
}

protocol Swizzled {
    var enabled: Bool { get set }
}

struct Swizzle<T>: Swizzled where T: MethodInfo {
    var foundation: MethodInfo
    var slaminate: MethodInfo
    init(cls: AnyClass, _ selectorName: String) {
        foundation = T(cls: cls, selector: Selector(selectorName))
        slaminate = T(cls: cls, selector: Selector("slaminate_\(selectorName)"))
    }
    var enabled: Bool = false {
        didSet {
            method_setImplementation(foundation.method, (enabled ? slaminate.implementation : foundation.implementation))
            method_setImplementation(slaminate.method, (enabled ? foundation.implementation : slaminate.implementation))
        }
    }
}

typealias InstanceSwizzle = Swizzle<InstanceMethod>
typealias ClassSwizzle = Swizzle<ClassMethod>

extension Array where Element: Swizzled {
    
    var enabled: Bool {
        get {
            return first?.enabled ?? false
        }
        set {
            for var swizzle in self {
                swizzle.enabled = newValue
            }
        }
    }
    
}
