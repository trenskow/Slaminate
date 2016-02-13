//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

internal var ongoingAnimations = [Animation]()

public func slaminate(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: ((finished: Bool) -> Void)?) -> Animation {
    return AnimationBuilder(
        duration: duration,
        delay: delay,
        animation: animation,
        curve: curve,
        completion: completion
    )
}

public typealias CompletionHandler = (finished: Bool) -> Void

@objc public enum AnimationState: Int {
    case Waiting = 0
    case Comited
}

@objc public enum AnimationProgressState: Int {
    case Beginning = 0
    case InProgress
    case End
}

/*!
A protocol representing an animation.
*/
@objc public protocol Animation {
    var state: AnimationState { get }
    var progressState: AnimationProgressState { get }
    var finished:Bool { @objc(isFinished) get }
    var duration:NSTimeInterval { get }
    var delay:NSTimeInterval { get }
    var position:NSTimeInterval { get set }
    func then(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: CompletionHandler?) -> Animation
    func then(animation animation: Animation) -> Animation
    func then(completion completion: CompletionHandler) -> Animation
    func and(duration duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, animation: Void -> Void, completion: CompletionHandler?) -> Animation
    func and(animation animation: Animation) -> Animation
    func begin()
    func begin(reversed: Bool)
    func postpone() -> Animation
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

@objc protocol BuildInAnimations {
    func fadeIn(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: CompletionHandler?) -> Animation
    func fadeOut(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: CompletionHandler?) -> Animation
}

extension CALayer: BuildInAnimations {
    func fadeIn(duration: NSTimeInterval, delay: NSTimeInterval = 0.0, curve: Curve? = nil, completion: CompletionHandler? = nil) -> Animation {
        return self.setValue(1.0, forKey: "opacity", duration: duration, delay: delay, curve: curve, completion: completion)
    }
    func fadeOut(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: CompletionHandler?) -> Animation {
        return self.setValue(0.0, forKey: "opacity", duration: duration, delay: delay, curve: curve, completion: completion)
    }
}

extension UIView: BuildInAnimations {
    func fadeIn(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: CompletionHandler?) -> Animation {
        return self.layer.fadeIn(duration, delay: delay, curve: curve, completion: completion)
    }
    func fadeOut(duration: NSTimeInterval, delay: NSTimeInterval, curve: Curve?, completion: CompletionHandler?) -> Animation {
        return self.layer.fadeIn(duration, delay: delay, curve: curve, completion: completion)
    }
}
