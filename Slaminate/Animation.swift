//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

var ongoingAnimations = [Animation]()

public func +(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.and(animation: rhs)
}

public func |(lhs: Animation, rhs: Animation) -> Animation {
    return lhs.then(animation: rhs)
}

public func +=(lhs: inout Animation, rhs: Animation) {
    lhs = lhs.and(animation: rhs)
}

infix operator |=
public func |=(lhs: inout Animation, rhs: Animation) {
    lhs = lhs.then(animation: rhs)
}

open class Animation: NSObject {
    
    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
        ongoingAnimations.append(self)
        perform(#selector(Animation.go as (Animation) -> () -> Animation), with: nil, afterDelay: 0.0, inModes: [RunLoopMode.commonModes])
    }
    
    public convenience override init() {
        self.init(duration: 0.0)
    }
    
    @objc(isFinished) open var finished: Bool = false
    
    open var duration: TimeInterval
    open internal(set) var delay: TimeInterval = 0.0
    
    open var reversed: Bool {
        @objc(isReversed) get {
            guard owner == nil else { return owner!.reversed }
            return false
        }
    }
    
    fileprivate var _speed: Double = 1.0
    var speed: Double {
        get {
            guard owner == nil else { return owner!.speed }
            return _speed
        }
        set {
            _speed = speed;
        }
    }
    
    var _position: TimeInterval = 0.0
    @objc open var position: TimeInterval {
        get { return _position }
        set {
            setPosition(newValue, apply: true)
        }
    }
    
    func setPosition(_ position: TimeInterval, apply: Bool = false) {
        guard position != _position else { return }
        if apply && ((position > 0.0 && _position == 0.0) || (position == 00 && _position > 0.0)) {
            emit(.started)
        } else if position >= delay + duration {
            emit(.completed)
        }
        _position = position
        if apply { postpone() }
    }
    
    weak var owner: Animation? {
        didSet {
            if owner != nil {
                ongoingAnimations.remove(self)
                postpone()
            }
        }
    }
    
    func childAnimation(_ animation: Animation, didCompleteWithFinishState finished: Bool) {}
    
    enum AnimationEvent {
        case started
        case completed
    }
    
    fileprivate struct EventListener {
        var event: AnimationEvent
        var then: (Animation) -> Void
    }
    
    fileprivate var eventListeners = [EventListener]()
    
    fileprivate func emit(_ event: AnimationEvent) {
        eventListeners.filter({ $0.event == event }).forEach({ $0.then(self) })
    }
    
    func on(_ event: AnimationEvent, then: @escaping (_ animation: Animation) -> Void) -> Animation {
        eventListeners.append(
            EventListener(
                event: event,
                then: then
            )
        )
        return self
    }
    
    open func completed(_ closure: @escaping (_ animation: Animation) -> Void) -> Animation {
        return on(.completed, then: closure)
    }
    
    open func started(_ closure: @escaping (_ animation: Animation) -> Void) -> Animation {
        return on(.started, then:  closure)
    }
    
    open func delayed(_ delay: TimeInterval) -> Animation {
        self.delay = delay
        return self
    }
    
    open func then(duration: TimeInterval, curve: Curve?, animation: @escaping (Void) -> Void) -> Animation {
        return then(
            animation: AnimationBuilder(
                duration: duration,
                curve: curve ?? Curve.linear,
                animation: animation
            )
        )
    }
    
    open func then(animation: Animation) -> Animation {
        return then(animations: [animation])
    }
    
    open func then(animations: [Animation]) -> Animation {
        return AnimationChain(animations: [self] + animations)
    }
    
    open func and(duration: TimeInterval, curve: Curve?, animation: @escaping (Void) -> Void) -> Animation {
        return and(
            animation: AnimationBuilder(
                duration: duration,
                curve: curve ?? Curve.linear,
                animation: animation
            )
        )
    }
    
    open func and(animation: Animation) -> Animation {
        return and(animations: [animation])
    }
    
    open func and(animations: [Animation]) -> Animation {
        return AnimationGroup(animations: [self] + animations)
    }
    
    func postpone() {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(Animation.go as (Animation) -> () -> Animation),
            object: nil
        )
    }
    
    open func manual() -> Animation {
        guard owner == nil else { return owner!.manual() }
        postpone()
        return self
    }
    
    func complete(_ finished: Bool) {
        self.finished = finished
        setPosition(delay + duration)
        if let owner = owner {
            owner.childAnimation(self, didCompleteWithFinishState: finished)
        } else {
            ongoingAnimations.remove(self)
        }
        
    }
    
    // This is a dummy method which just ends the animation.
    // Overridden by subclasses to do their own stuff - do not call super.
    // Used only by null animations.
    func commit() {
        complete(true)
    }
    
    func precommit() {
        setPosition(max(_position, delay))
        commit()
    }
    
    func preflight() {
        if delay - position > 0.0 {
            perform(#selector(Animation.precommit), with: nil, afterDelay: (delay - position) / speed, inModes: [RunLoopMode.commonModes])
        } else {
            precommit()
        }
    }
    
    open func begin() {
        if position == 0.0 {
            emit(.started)
        }
        preflight()
    }
    
    open func go() -> Animation {
        return go(speed: 1.0)
    }
    
    open func go(speed: Double) -> Animation {
        var speed = speed
        if speed < 0.01 && speed > -0.01 { speed = 1.0 }
        guard owner == nil else {
            return owner!.go(speed: speed)
        }
        guard speed > 0.0 else { return reverse().go(speed: -speed) }
        _speed = speed
        postpone()
        begin()
        return self
    }
    
    func reverse() -> Animation {
        return ReversedAnimation(animation: self)
    }
        
}

extension Array where Element: Animation {
    func indexOf(_ element: Element) -> Array.Index? {
        for idx in self.indices {
            if self[idx] === element {
                return idx
            }
        }
        return nil
    }
    mutating func remove(_ element: Element) {
        while let index = indexOf(element) {
            self.remove(at: index)
        }
    }
}

public func Slaminate(duration: TimeInterval, curve: Curve?, animation: @escaping (Void) -> Void) -> Animation {
    return AnimationBuilder(
        duration: duration,
        curve: curve ?? Curve.linear,
        animation: animation
    )
}

extension NSObject {
    public class func slaminate(duration: TimeInterval, curve: Curve? = nil, animation: @escaping (Void) -> Void) -> Animation {
        return AnimationBuilder(
            duration: duration,
            curve: curve ?? Curve.linear,
            animation: animation
        )
    }
    public func setValue(_ value: AnyObject?, forKey key: String, duration: TimeInterval, curve: Curve? = nil) -> Animation {
        return Slaminate(duration: duration, curve: curve, animation: { [weak self] in self?.setValue(value, forKey: key) })
    }
}
