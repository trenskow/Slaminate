//
//  NSObject+Slaminate.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import ObjectiveC.runtime
import Foundation

public extension NSObject {
    
    public class func slaminate(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation {
        
        AnimationBuilder.pushBuilder()
        
        animation()
        
        return AnimationBuilder.top.finalize(duration, delay: delay, curve: curve, completion: completion)
        
    }
    
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: ((finished: Bool) -> Void)?) -> Animation? {
        
        return NSObject.slaminate(
            duration: duration,
            delay: delay,
            curve: curve,
            animation: { [weak self] in self?.setValue(value, forKey: key) },
            completion: completion
        )
        
    }

}
