//
//  CurvedAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

class CurvedAnimation: CAKeyframeAnimation {
    
    private func applyInterpolation() {
        if let fromValue = fromValue, toValue = toValue where duration > 0.0 {
            
            var keyTimes = [NSNumber]()
            var values = [AnyObject]()
            let curve = self.curve ?? Curve.linear
            
            for var position: NSTimeInterval = 0.0 ; position <= 1.0 ; position += 1.0 / 60.0 * (duration / NSTimeInterval(speed)) {
                keyTimes.append(position)
                values.append(fromValue.interpolate(toValue, curve.block(position)) as! AnyObject)
            }
            
            self.keyTimes = keyTimes
            self.values = values
            
        }
    }
    
    override var duration: NSTimeInterval {
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