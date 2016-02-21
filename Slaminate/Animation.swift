//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

var ongoingAnimations = [Animation]()

private struct EventListener {
    var event: AnimationEvent
    var then: Animation -> Void
}

enum AnimationState: Int {
    case Waiting = 0
    case Delayed
    case Animating
    case Complete
}

public enum AnimationEvent {
    case Start
    case Completed
}

public typealias CompletionHandler = (finished: Bool) -> Void

@objc(SLAAnimation)
public class Animation: NSObject {
    
    override init() {
        super.init()
        ongoingAnimations.append(self)
        performSelector(Selector("go"), withObject: nil, afterDelay: 0.0, inModes: [NSRunLoopCommonModes])
    }
    
    @objc(isFinished) public var finished: Bool = false
    
    public var duration: NSTimeInterval { return 0.0 }
    public var delay: NSTimeInterval = 0.0
    
    @objc public var position: NSTimeInterval = 0.0
    
    var state: AnimationState = .Waiting
    
    weak var owner: Animation? {
        didSet {
            if owner != nil {
                ongoingAnimations.remove(self)
                postpone()
            }
        }
    }
    
    func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {}
    
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
    
    public func completed(completion: (finished: Bool) -> Void) -> Animation {
        on(.Completed) { [weak self] (animation) -> Void in
            completion(finished: self?.finished ?? true)
        }
        return self
    }
    
    public func started(closure: Void -> Void) -> Animation {
        on(.Start) { (animation) -> Void in
            closure()
        }
        return self
    }
    
    public func delayed(delay: NSTimeInterval) -> Animation {
        self.delay = delay
        return self
    }
    
    public func then(duration duration: NSTimeInterval, curve: Curve?, animation: Void -> Void) -> Animation {
        return then(animation: AnimationBuilder(
            duration: duration,
            curve: curve,
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
        return AnimationChain(
            animations: [
                self,
                AnimationBuilder(
                    duration: duration,
                    curve: curve,
                    animation: animation
                )
            ]
        )
    }
    
    public func and(animation animation: Animation) -> Animation {
        return and(animations: [animation])
    }
    
    public func and(animations animations: [Animation]) -> Animation {
        return AnimationGroup(animations: [self] + animations)
    }
    
    public func postpone() -> Animation {
        NSObject.cancelPreviousPerformRequestsWithTarget(
            self,
            selector: Selector("go"),
            object: nil
        )
        return self
    }
        
    func complete(finished: Bool) {
        self.finished = finished
        state = .Complete
        emit(.Completed)
        owner?.childAnimation(self, didCompleteWithFinishState: finished)
    }
    
    func commit() {}
    
    func precommit() {
        state = .Animating
        emit(.Start)
        commit()
    }
    
    func preflight() {
        if delay - position > 0.0 {
            state = .Delayed
            performSelector(Selector("precommit"), withObject: nil, afterDelay: delay - position, inModes: [NSRunLoopCommonModes])
        } else {
            precommit()
        }
    }
    
    public func begin() {
        preflight()
    }
    
    public func go() -> Animation {
        guard owner == nil else { return owner!.go() }
        guard state == .Waiting else { fatalError("Cannot start an animation that is already started.") }
        postpone()
        begin()
        return self
    }
    
}

protocol PropertyAnimation {
    static func canAnimate(object: NSObject, key: String) -> Bool
    var object: NSObject { get }
    var key: String { get }
    var toValue: Any { get }
    var curve: Curve { get }
    init(duration: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve)
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
        curve: curve,
        animation: animation
    )
}

extension NSObject {
    public class func slaminate(duration duration: NSTimeInterval, curve: Curve? = nil, animation: Void -> Void) -> Animation {
        return AnimationBuilder(
            duration: duration,
            curve: curve,
            animation: animation
        )
    }
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, curve: Curve? = nil) -> Animation {
        return Slaminate(duration: duration, curve: curve, animation: { [weak self] in self?.setValue(value, forKey: key) })
    }
}
