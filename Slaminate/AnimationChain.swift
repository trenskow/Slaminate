//
//  AnimationChain.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 11/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationChain: ConcreteAnimation, AnimationDelegate {
    
    let animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation]) {
        self.animations = animations
        super.init()
        self.animations.forEach { (animation) -> () in
            animation.delegate = self
            animation.postponeAnimation()
        }
    }
    
    @objc override var duration: NSTimeInterval {
        get {
            return self.animations.reduce(0.0, combine: { (c, animation) -> NSTimeInterval in
                return c + animation.delay + animation.duration
            }) - (self.animations.first?.delay ?? 0.0)
        }
        set {}
    }
    
    @objc override var delay: NSTimeInterval {
        get {
            return self.animations.first?.delay ?? 0.0
        }
        set {}
    }
    
    @objc override var animating: Bool {
        @objc(isAnimating) get {
            return self.animations.reduce(false, combine: { (c, animation) -> Bool in
                return c || animation.animating
            })
        }
        set {}
    }
    
    @objc override var complete: Bool {
        @objc(isComplete) get {
            return self.animations.reduce(true, combine: { (c, animation) -> Bool in
                return c && animation.complete
            })
        }
        set {}
    }
    
    @objc override var finished: Bool {
        @objc(isFinished) get {
            return self.animations.reduce(true, combine: { (c, animation) -> Bool in
                return c && animation.complete && animation.finished
            })
        }
        set {}
    }
    
    override func commitAnimation() {
        if let first = animations.first {
            first.beginAnimation()
        } else {
            completeAnimation(true)
        }
    }
    
    func completeAnimation(finished: Bool) {
        delegate?.animationCompleted(self, finished: finished)
        ongoingAnimations.remove(self)
    }
    
    func animationCompleted(animation: Animation, finished: Bool) {
        if let nextAnimation = animations.filter({ !$0.animating && !$0.complete }).first {
            nextAnimation.beginAnimation()
        } else {
            completeAnimation(finished)
        }
    }
    
}