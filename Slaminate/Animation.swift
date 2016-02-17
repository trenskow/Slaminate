//
//  Animation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

internal var ongoingAnimations = [Animation]()

private struct EventListener {
    var event: AnimationEvent
    var then: Animation -> Void
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

@objc public enum AnimationEvent: Int {
    case Begin
    case End
}

/*!
A protocol representing an animation.
*/
@objc public class Animation: NSObject {
    
    override init() {
        super.init()
        ongoingAnimations.append(self)
        begin()
    }
    
    @objc(isFinished) var finished: Bool { return false }
    
    var duration: NSTimeInterval { return 0.0 }
    var delay: NSTimeInterval { return 0.0 }
    
    @objc var position: NSTimeInterval = 0.0 {
        didSet {
            if position != oldValue {
                if position <= 0.0 {
                    progressState = .Beginning
                } else if position > 0.0 && position < delay + duration {
                    progressState = .InProgress
                } else {
                    progressState = .End
                }
            }
        }
    }
    
    var progressState: AnimationProgressState = .Beginning {
        didSet {
            if progressState != oldValue {
                owner?.childAnimation(self, didChangeProgressState: progressState)
                if progressState == .End {
                    owner?.childAnimation(self, didCompleteWithFinishState: finished)
                    emit(.End)
                    ongoingAnimations.remove(self)
                } else if oldValue == .Beginning && progressState == .InProgress || oldValue == .InProgress && progressState == .Beginning {
                    emit(.Begin)
                }
            }
        }
    }
    
    var state: AnimationState = .Waiting
    
    internal weak var owner: Animation? {
        didSet {
            if owner != nil {
                ongoingAnimations.remove(self)
                postpone()
            }
        }
    }
    
    internal func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {}
    internal func childAnimation(animation: Animation, didChangeProgressState: AnimationProgressState) {}
    internal func commit() {}
    
    private var eventListeners = [EventListener]()
    
    private func emit(event: AnimationEvent) {
        eventListeners.filter({ $0.event == event }).forEach({ $0.then(self) })
    }
    
    @objc func on(event: AnimationEvent, then: Animation -> Void) -> Animation {
        eventListeners.append(
            EventListener(
                event: event,
                then: then
            )
        )
        return self
    }
        
    public func then(duration duration: NSTimeInterval, animation: Void -> Void, curve: Curve?, delay: NSTimeInterval, completion: CompletionHandler?) -> Animation {
        return then(animation: AnimationBuilder(
            duration: duration,
            delay: delay,
            animation: animation,
            curve: curve,
            completion: completion
            )
        )
    }
    
    public func then(animation animation: Animation) -> Animation {
        return then(animations: [animation])
    }
    
    public func then(animations animations: [Animation]) -> Animation {
        return AnimationChain(animations: [self] + animations)
    }
    
    public func then(completion completion: CompletionHandler) -> Animation {
        return AnimationGroup(animations: [self], completion: completion)
    }
    
    public func and(duration duration: NSTimeInterval, animation: Void -> Void, curve: Curve?, delay: NSTimeInterval, completion: CompletionHandler?) -> Animation {
        return AnimationChain(
            animations: [
                self,
                AnimationBuilder(
                    duration: duration,
                    delay: delay,
                    animation: animation,
                    curve: curve,
                    completion: completion
                )
            ]
        )
    }
    
    public func and(animation animation: Animation) -> Animation {
        return and(animations: [animation])
    }
    
    public func and(animations animations: [Animation]) -> Animation {
        return AnimationGroup(
            animations: [self] + animations,
            completion: nil
        )
    }
    
    func begin() {
        begin(false)
    }
    
    func begin(reversed: Bool) {
        
        guard owner == nil else {
            fatalError("Cannot begin a non-independent animation.")
        }
        
        postpone()
        
        if !reversed {
            self.performSelector(Selector("go"), withObject: nil, afterDelay: 0.0, inModes: [NSRunLoopCommonModes])
        } else {
            _ = DirectAnimation(duration: position, delay: 0.0, object: self, key: "position", toValue: 0.0, curve: Curve.linear)
        }
        
    }
    
    public func postpone() -> Animation {
        NSObject.cancelPreviousPerformRequestsWithTarget(
            self,
            selector: Selector("go"),
            object: nil
        )
        return self
    }
    
    public func go() {
        guard owner == nil else {
            owner?.go()
            return
        }
        commit()
    }
    
}

protocol PropertyAnimation {
    static func canAnimate(object: NSObject, key: String) -> Bool
    var object: NSObject { get }
    var key: String { get }
    var toValue: Any { get }
    var curve: Curve { get }
    init(duration: NSTimeInterval, delay: NSTimeInterval, object: NSObject, key: String, toValue: Any, curve: Curve)
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

extension NSObject {
    public class func slaminate(duration duration: NSTimeInterval, animation: Void -> Void, curve: Curve? = nil, delay: NSTimeInterval = 0.0, completion: ((finished: Bool) -> Void)? = nil) -> Animation {
        return AnimationBuilder(
            duration: duration,
            delay: delay,
            animation: animation,
            curve: curve,
            completion: completion
        )
    }
    public func setValue(value: AnyObject?, forKey key: String, duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0, completion: ((finished: Bool) -> Void)? = nil) -> Animation {
        return NSObject.slaminate(duration: duration, animation: { [weak self] in self?.setValue(value, forKey: key) }, curve: curve, delay: delay, completion: completion)
    }
}
