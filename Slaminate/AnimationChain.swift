//
//  AnimationChain.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 11/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationChain: Animation {
    
    var animations: [Animation]
    fileprivate var commited: Bool = false
    
    init(animations: [Animation]) {
        self.animations = animations
        super.init(duration: 0.0)
        self.animations.forEach { (animation) -> () in
            animation.owner = self
        }
    }
        
    @objc override var duration: TimeInterval {
        get {
            return self.animations.reduce(0.0, { (c, animation) -> TimeInterval in
                return c + animation.delay + animation.duration
            })
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
        
    override func setPosition(_ position: TimeInterval, apply: Bool) {
        defer { super.setPosition(position, apply: apply) }
        guard apply else { return }
        _ = animations.reduce(delay) { (total, animation) -> TimeInterval in
            let full = animation.delay + animation.duration
            animation.setPosition(max(0.0, min(full, position - total)), apply: apply)
            return total + full
        }
    }
    
    override func commit() {
        commited = true
        animateNext()
    }
    
    override func then(animations: [Animation]) -> Animation {
        animations.forEach { animation in
            animation.owner = self
            self.animations.append(animation)
        }
        return self
    }
    
    fileprivate func animateNext() {
        guard commited else { return }
        if let nextAnimation = animations.filter({ $0.position < $0.delay + $0.duration }).first {
            nextAnimation.begin()
        } else {
            complete(animations.reduce(true, { $0 && $1.finished }))
        }
    }
    
    override func child(animation: Animation, didCompleteWithFinishState finished: Bool) {
        animateNext()
    }
    
}
