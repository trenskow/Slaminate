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
    var duration:NSTimeInterval { get }
    var delay:NSTimeInterval { get }
    func then(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation
    func beginAnimation()
    func postponeAnimation() -> Animation
}

protocol AnimationDelegate: class {
    func animationCompleted(animation: Animation, finished: Bool)
}

protocol DelegatedAnimation: Animation {
    weak var delegate: AnimationDelegate? { get set }
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
    mutating func remove(element: Element) {
        if let index = indexOf(element) {
            removeAtIndex(index)
        }
    }
}

// Gets segmentation fault when trying to implement this as a protocol extension.

class ConcreteAnimation: NSObject, DelegatedAnimation {
    
    @objc(isAnimating) internal(set) var animating: Bool = false
    @objc(isComplete) internal(set) var complete: Bool = false
    @objc(isFinished) internal(set) var finished: Bool = true
    @objc internal(set) var duration: NSTimeInterval = 0.0
    @objc var delay: NSTimeInterval = 0.0
    
    weak var delegate: AnimationDelegate?
    
    @objc func then(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation {
        let ret = AnimationChain(animations: [
            self,
            slaminate(
                duration: duration,
                delay: delay,
                curve: curve,
                animation: animation,
                completion: completion
                ) as! DelegatedAnimation
            ])
        ret.beginAnimation()
        return ret;
    }
    
    func beginAnimation() {
        ongoingAnimations.append(self)
        self.performSelector(Selector("commitAnimation"), withObject: nil, afterDelay: 0.0)
    }
    
    func postponeAnimation() -> Animation {
        ongoingAnimations.remove(self)
        NSObject.cancelPreviousPerformRequestsWithTarget(
            self,
            selector: Selector("commitAnimation"),
            object: nil
        )
        return self
    }
    
    func commitAnimation() {}
    
}

internal var ongoingAnimations = [Animation]()
