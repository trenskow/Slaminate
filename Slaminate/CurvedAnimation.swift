//
//  CurvedAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

class CurvedAnimation: CAKeyframeAnimation {
    
    fileprivate func applyInterpolation() {
        if let fromValue = fromValue, let toValue = toValue , duration > 0.0 {
            
            var keyTimes = [NSNumber]()
            var values = [AnyObject]()
            let curve = self.curve ?? Curve.linear
            
            for time in stride(from: position, to: duration, by: TimeInterval(1.0 / (60.0 / speed))) {
                keyTimes.append(NSNumber(value: (time - self.position) / self.duration))
                values.append(fromValue.interpolate(toValue, curve.transform(time / self.duration)).objectValue!)
            }
            
            keyTimes.append(1.0)
            values.append(fromValue.interpolate(toValue, curve.transform(1.0)).objectValue!)
            
            self.keyTimes = keyTimes
            self.values = values
            
        }
    }
    
    override var duration: TimeInterval {
        didSet {
            applyInterpolation()
        }
    }
    
    var position: TimeInterval = 0.0 {
        didSet {
            applyInterpolation()
        }
    }
    
    override var speed: Float {
        didSet {
            applyInterpolation()
        }
    }
    
    var curve: Curve? {
        didSet {
            applyInterpolation()
        }
    }
    
    var fromValue: Interpolatable? {
        didSet {
            applyInterpolation()
        }
    }
    
    var toValue: Interpolatable? {
        didSet {
            applyInterpolation()
        }
    }
    
}
