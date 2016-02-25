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

@objc(SLAAnimation)
public class Animation: NSObject {
    
    init(duration: NSTimeInterval = 0.0) {
        self.duration = duration
        super.init()
        ongoingAnimations.append(self)
        performSelector(Selector("go"), withObject: nil, afterDelay: 0.0, inModes: [NSRunLoopCommonModes])
    }
    
    @objc(isFinished) public var finished: Bool = false
    
    public var duration: NSTimeInterval
    public var delay: NSTimeInterval = 0.0
    
    public var reversed: Bool {
        @objc(isReversed) get {
            guard owner == nil else { return owner!.reversed }
            return false
        }
    }
    
    private var _speed: Double = 1.0
    var speed: Double {
        get {
            guard owner == nil else { return owner!.speed }
            return _speed
        }
        set {
            _speed = speed;
        }
    }
    
    var _position: NSTimeInterval = 0.0
    @objc public var position: NSTimeInterval {
        get { return _position }
        set {
            setPosition(newValue, apply: true)
        }
    }
    
    func setPosition(position: NSTimeInterval, apply: Bool = false) {
        guard position != _position else { return }
        if apply && ((position > 0.0 && _position == 0.0) || (position == 00 && _position > 0.0)) {
            emit(.Start)
        } else if position >= delay + duration {
            emit(.Completed)
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
    
    func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {}
    
    private enum AnimationEvent {
        case Start
        case Completed
    }
    
    private struct EventListener {
        var event: AnimationEvent
        var then: Animation -> Void
    }
    
    private var eventListeners = [EventListener]()
    
    private func emit(event: AnimationEvent) {
        eventListeners.filter({ $0.event == event }).forEach({ $0.then(self) })
    }
    
    private func on(event: AnimationEvent, then: (animation: Animation) -> Void) -> Animation {
        eventListeners.append(
            EventListener(
                event: event,
                then: then
            )
        )
        return self
    }
    
    public func completed(closure: (animation: Animation) -> Void) -> Animation {
        on(.Completed, then: closure)
        return self
    }
    
    public func started(closure: (animation: Animation) -> Void) -> Animation {
        on(.Start, then:  closure)
        return self
    }
    
    public func delayed(delay: NSTimeInterval) -> Animation {
        self.delay = delay
        return self
    }
    
    public func then(duration duration: NSTimeInterval, curve: Curve?, animation: Void -> Void) -> Animation {
        return then(
            animation: AnimationBuilder(
                duration: duration,
                curve: curve ?? Curve.linear,
                animation: animation
            )
        )
    }
    
    public func then(animation animation: Animation) -> Animation {
        return then(animations: [animation])
    }
    
    public func then(animations animations: [Animation]) -> Animation {
        return AnimationChain(animations: [self] + animations)
    }
    
    public func and(duration duration: NSTimeInterval, curve: Curve?, animation: Void -> Void) -> Animation {
        return and(
            animation: AnimationBuilder(
                duration: duration,
                curve: curve ?? Curve.linear,
                animation: animation
            )
        )
    }
    
    public func and(animation animation: Animation) -> Animation {
        return and(animations: [animation])
    }
    
    public func and(animations animations: [Animation]) -> Animation {
        return AnimationGroup(animations: [self] + animations)
    }
    
    func postpone() {
        NSObject.cancelPreviousPerformRequestsWithTarget(
            self,
            selector: Selector("go"),
            object: nil
        )
    }
    
    public func manual() -> Animation {
        guard owner == nil else { return owner!.manual() }
        postpone()
        return self
    }
    
    func complete(finished: Bool) {
        self.finished = finished
        setPosition(delay + duration)
        if let owner = owner {
            owner.childAnimation(self, didCompleteWithFinishState: finished)
        } else {
            ongoingAnimations.remove(self)
        }
        
    }
    
    func commit() {}
    
    func precommit() {
        setPosition(max(_position, delay))
        commit()
    }
    
    func preflight() {
        if delay - position > 0.0 {
            performSelector(Selector("precommit"), withObject: nil, afterDelay: (delay - position) / speed, inModes: [NSRunLoopCommonModes])
        } else {
            precommit()
        }
    }
    
    public func begin() {
        if position == 0.0 {
            emit(.Start)
        }
        preflight()
    }
    
    public func go() -> Animation {
        return go(speed: 1.0)
    }
    
    public func go(speed speed: Double) -> Animation {
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
    func indexOf(element: Element) -> Array.Index? {
        for idx in self.indices {
            if self[idx] === element {
                return idx
            }
        }
        return nil
    }
    mutating func remove(element: Element) {
        while let index = indexOf(element) {
            removeAtIndex(index)
        }
    }
}

public func Slaminate(duration duration: NSTimeInterval, curve: Curve?, animation: Void -> Void) -> Animation {
    return AnimationBuilder(
        duration: duration,
        curve: curve ?? Curve.linear,
        animation: animation
    )
}

extension NSObject {
    public class func slaminate(duration duration: NSTimeInterval, curve: Curve? = nil, animation: Void -> Void) -> Animation {
        return AnimationBuilder(
            duration: duration,
            curve: curve ?? Curve.linear,
            animation: animation
        )
    }
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, curve: Curve? = nil) -> Animation {
        return Slaminate(duration: duration, curve: curve, animation: { [weak self] in self?.setValue(value, forKey: key) })
    }
}
