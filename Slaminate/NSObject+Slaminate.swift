//
//  NSObject+Slaminate.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import ObjectiveC.runtime
import Foundation

public func slaminate(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation {
    
    let ret = AnimationBuilder(
        duration: duration,
        delay: delay,
        animation: animation,
        curve: curve,
        completion: completion
    )
    
    ret.beginAnimation()
    
    return ret
    
}

public extension NSObject {
    
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: ((finished: Bool) -> Void)?) -> Animation? {
        
        return slaminate(
            duration: duration,
            delay: delay,
            curve: curve,
            animation: { [weak self] in self?.setValue(value, forKey: key) },
            completion: completion
        )
        
    }

}
