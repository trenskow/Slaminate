//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

@objc(SLAAnimationGroup)
public class AnimationGroup: Animation {
    
    var animations: [Animation]
    
    public init(animations: [Animation]) {
        self.animations = animations ?? []
        super.init()
        animations.forEach({ $0.owner = self })
    }
    
    public convenience init() {
        self.init(animations: [])
    }
        
    override func setPosition(position: NSTimeInterval, apply: Bool) {
        defer { super.setPosition(position, apply: apply) }
        guard apply else { return }
        animations.forEach({
            $0.setPosition(
                max(0.0, min($0.delay + $0.duration, position - delay)),
                apply: apply
            )
        })
    }
    
    override public var duration: NSTimeInterval {
        get {
            return animations.reduce(0.0) { (c, animation) -> NSTimeInterval in
                return max(c, animation.delay + animation.duration)
            }
        }
        set {
            let duration = self.duration
            let delta = newValue - duration
            animations.forEach { (animation) -> () in
                let animationPart = (animation.delay + animation.duration) / duration
                animation.delay += (delta * animationPart) * (animation.delay / (animation.delay + animation.duration))
                animation.duration += (delta * animationPart) * (animation.duration / (animation.delay + animation.duration))
            }
        }
    }
    
    override func commit() {
        let nonCompleteAnimations = animations.filter { $0.position < 1.0 }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { $0.begin() }
        } else {
            complete(true)
        }
    }
    
    override public func and(animations animations: [Animation]) -> Animation {
        guard !(self is AnimationBuilder) && !(self is AnimationBuildIns) else {
            return super.and(animations: animations)
        }
        animations.forEach { animation in
            self.animations.append(animation)
            animation.owner = self
        }
        return self
    }
    
    override func complete(finished: Bool) {
        super.complete(finished)
    }
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        if animations.all({ $0.position >= $0.delay + $0.duration }) {
            complete(animations.reduce(true, combine: { $0 && $1.finished } ))
        }
    }
    
}
