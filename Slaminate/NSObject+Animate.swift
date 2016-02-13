//
//  NSObject+Animate.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import ObjectiveC.runtime
import Foundation

public extension NSObject {
    
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: ((finished: Bool) -> Void)?) -> Animation {
        
        return slaminate(
            duration: duration,
            delay: delay,
            curve: curve,
            animation: { [weak self] in self?.setValue(value, forKey: key) },
            completion: completion
        )
        
    }

}
