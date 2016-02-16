//
//  ConstraintConstantAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 12/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class ConstraintConstantAnimation: DirectAnimation {
    
    override class func canAnimate(object: NSObject, key: String) -> Bool {
        return key == "constant" && object as? NSLayoutConstraint != nil
    }
    
    override func commit() {
        state = .Comited
        completeAnimation()
    }
    
}