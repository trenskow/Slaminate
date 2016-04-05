//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class AnimationGroup: Animation {
    
    var animations: [Animation]
    
    init(animations: [Animation]) {
        self.animations = animations ?? []
        super.init(duration: 0.0)
        animations.forEach({ $0.owner = self })
    }
    
    convenience init() {
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
    
    override var duration: NSTimeInterval {
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
    
    func add(animation: Animation) {
        animations.append(animation)
        animation.owner = self
    }
    
    override func and(animations animations: [Animation]) -> Animation {
        guard !(self is AnimationBuilder) else {
            return super.and(animations: animations)
        }
        animations.forEach(add)
        return self
    }
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        if animations.all({ $0.position >= $0.delay + $0.duration }) {
            complete(animations.reduce(true, combine: { $0 && $1.finished } ))
        }
    }
    
}
