//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

@objc(SLAAnimationGroup)
public class AnimationGroup: Animation {
    
    private var animations: [Animation]
    
    public init(animations: [Animation]) {
        self.animations = animations ?? []
        super.init()
        animations.forEach({ $0.owner = self })
    }
    
    override public convenience init() {
        self.init(animations: [])
    }
    
    override public var position: NSTimeInterval {
        didSet {
            animations.forEach({ (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position))
            })
        }
    }
    
    @objc(isFinished) override public var finished: Bool {
        return animations.reduce(true, combine: { (c, animation) -> Bool in
            return c && animation.finished
        })
    }
    
    override public var duration: NSTimeInterval {
        get {
            return animations.reduce(0.0) { (c, animation) -> NSTimeInterval in
                return max(c, animation.delay + animation.duration)
            } - delay
        }
    }
    
    override public var delay: NSTimeInterval {
        get {
            guard animations.count > 0 else { return 0.0 }
            return animations.reduce(NSTimeInterval.infinity, combine: { (c, animation) -> NSTimeInterval in
                return min(c, animation.delay)
            })
        }
    }
    
    override func commit() {
        state = .Comited
        guard progressState.rawValue < AnimationProgressState.End.rawValue else { return }
        let nonCompleteAnimations = animations.filter { $0.progressState != .End }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { $0.commit() }
        } else {
            completeAnimation(true)
        }
    }
    
    override public func and(animations animations: [Animation]) -> Animation {
        animations.forEach { animation in
            self.animations.append(animation)
            animation.owner = self
        }
        return self
    }
    
    internal func completeAnimation(finished: Bool) {
        self.progressState = .End
    }
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        let finished = self.finished && finished
        if animations.all({ $0.progressState == .End }) {
            completeAnimation(finished)
        }
    }
    
    override func childAnimation(animation: Animation, didChangeProgressState: AnimationProgressState) {
        progressState = AnimationProgressState(rawValue: animations.reduce(AnimationProgressState.End.rawValue, combine: { (c, animation) -> Int in
            return min(c, animation.state.rawValue)
        }))!
    }
    
}
