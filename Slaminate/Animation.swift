//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

/*!
A protocol representing an animation.
*/
@objc public protocol Animation {
    var animating:Bool { @objc(isAnimating) get }
    var complete:Bool { @objc(isComplete) get }
    var finished:Bool { @objc(isFinished) get }
    var duration:NSTimeInterval { get set }
    var delay:NSTimeInterval { get set }
}

protocol AnimationDelegate: class {
    func animationCompleted(animation: Animation, finished: Bool)
}

protocol DelegatedAnimation: Animation {
    weak var delegate: AnimationDelegate? { get set }
    func beginAnimation()
}

protocol PropertyAnimation: DelegatedAnimation {
    static func canAnimate(object: NSObject, key: String) -> Bool
    var object: NSObject { get }
    var key: String { get }
    var toValue: AnyObject { get }
    var curve: Curve { get }
    init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: AnyObject, curve: Curve)
}

extension Array where Element: Animation {
    func indexOf(element: Element) -> Array.Index? {
        for idx in self.indices {
            if self[idx] === element {
                return idx
            }
        }
        return nil
    }
}