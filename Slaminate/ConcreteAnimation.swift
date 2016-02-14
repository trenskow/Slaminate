//
//  ConcreteAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 13/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

// Gets segmentation fault when trying to implement this as a protocol extension.

class ConcreteAnimation: NSObject, DelegatedAnimation {
    
    @objc(isFinished) internal(set) var finished: Bool = true
    @objc internal(set) var duration: NSTimeInterval = 0.0
    @objc var delay: NSTimeInterval = 0.0
    
    override init() {
        super.init()
        begin()
    }
    
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
            if progressState != oldValue && progressState == .End {
                delegate?.animationCompleted(self, finished: finished)
                ongoingAnimations.remove(self)
            }
        }
    }
    
    var state: AnimationState = .Waiting
    
    weak var delegate: AnimationDelegate?
    
    @objc func then(duration duration: NSTimeInterval, animation: Void -> Void, curve: Curve?, delay: NSTimeInterval, completion: ((finished: Bool) -> Void)?) -> Animation {
        return then(animation: slaminate(
            duration: duration,
            animation: animation,
            curve: curve,
            delay: delay,
            completion: completion
        ) as! DelegatedAnimation)
    }
    
    @objc func then(animation animation: Animation) -> Animation {
        return AnimationChain(animations: [self, animation as! DelegatedAnimation])
    }
    
    @objc func then(completion completion: CompletionHandler) -> Animation {
        return AnimationGroup(animations: [self], completion: completion)
    }
    
    @objc func and(duration duration: NSTimeInterval, animation: Void -> Void, curve: Curve?, delay: NSTimeInterval, completion: CompletionHandler?) -> Animation {
        return and(animation: slaminate(
            duration: duration,
            animation: animation,
            curve: curve,
            delay: delay,
            completion: completion
        ) as! DelegatedAnimation)
    }
    
    @objc func and(animation animation: Animation) -> Animation {
        return AnimationGroup(
            animations: [
                self,
                animation as! DelegatedAnimation
            ],
            completion: nil
        )
    }
    
    func begin() {
        begin(false)
    }
    
    func begin(reversed: Bool) {
        
        postpone()
        
        if !reversed {
            ongoingAnimations.append(self)
            self.performSelector(Selector("commitAnimation"), withObject: nil, afterDelay: 0.0)
        } else {
            _ = DirectAnimation(duration: position, delay: 0.0, object: self, key: "position", toValue: 0.0, curve: Curve.linear)
        }
        
    }
    
    func postpone() -> Animation {
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
