//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (finished: Bool) -> Void

@objc public enum AnimationPosition: Int {
    case Beginning = 0
    case InProgress
    case End
}

@objc public enum AnimationState: Int {
    case Waiting = 0
    case Comited
}

/*!
A protocol representing an animation.
*/
@objc public protocol Animation {
    var position: AnimationPosition { get }
    var state: AnimationState { get }
    var finished:Bool { @objc(isFinished) get }
    var duration:NSTimeInterval { get }
    var delay:NSTimeInterval { get }
    var offset:NSTimeInterval { get set }
    func then(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: CompletionHandler?) -> Animation
    func then(animation animation: Animation) -> Animation
    func then(completion completion: CompletionHandler) -> Animation
    func and(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: CompletionHandler?) -> Animation
    func and(animation animation: Animation) -> Animation
    func beginAnimation()
    func beginAnimation(reversed: Bool)
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
    
    @objc(isFinished) internal(set) var finished: Bool = true
    @objc internal(set) var duration: NSTimeInterval = 0.0
    @objc var delay: NSTimeInterval = 0.0
    
    @objc var offset: NSTimeInterval = 0.0 {
        didSet {
            if offset != oldValue {
                if offset <= 0.0 {
                    position = .Beginning
                } else if offset > 0.0 && offset < delay + duration {
                    position = .InProgress
                } else {
                    position = .End
                }
            }
        }
    }
    
    var position: AnimationPosition = .Beginning {
        didSet {
            if position != oldValue && position == .End {
                delegate?.animationCompleted(self, finished: finished)
                ongoingAnimations.remove(self)
            }
        }
    }
    
    var state: AnimationState = .Waiting
    
    weak var delegate: AnimationDelegate?
    
    @objc func then(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation {
        return then(animation: slaminate(
            duration: duration,
            delay: delay,
            curve: curve,
            animation: animation,
            completion: completion
            ) as! DelegatedAnimation
        )
    }
    
    @objc func then(animation animation: Animation) -> Animation {
        let ret = AnimationChain(animations: [self, animation as! DelegatedAnimation])
        ret.beginAnimation()
        return ret
    }
    
    @objc func then(completion completion: CompletionHandler) -> Animation {
        let ret = AnimationGroup(animations: [self], completion: completion)
        ret.beginAnimation()
        return ret
    }
    
    @objc func and(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: CompletionHandler?) -> Animation {
        return and(animation:
            slaminate(
                duration: duration,
                delay: delay,
                curve: curve,
                animation: animation,
                completion: completion
            )
        )
    }
    
    @objc func and(animation animation: Animation) -> Animation {
        let ret = AnimationGroup(
            animations: [
                self,
                animation as! DelegatedAnimation
            ],
            completion: nil
        )
        ret.beginAnimation()
        return ret;
    }
    
    func beginAnimation() {
        beginAnimation(false)
    }
    
    func beginAnimation(reversed: Bool) {
        if !reversed {
            ongoingAnimations.append(self)
            self.performSelector(Selector("commitAnimation"), withObject: nil, afterDelay: 0.0)
        } else {
            DirectAnimation(
                duration: offset,
                delay: 0.0,
                object: self,
                key: "offset",
                toValue: 0.0,
                curve: Curve.linear
            ).beginAnimation()
        }
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
