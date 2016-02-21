//
//  AnimationChain.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 11/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

@objc(SLAAnimationChain)
public class AnimationChain: Animation {
    
    var animations: [Animation]
    
    init(animations: [Animation]) {
        self.animations = animations
        super.init()
        self.animations.forEach { (animation) -> () in
            animation.owner = self
        }
    }
    
    @objc override public var duration: NSTimeInterval {
        get {
            return self.animations.reduce(0.0, combine: { (c, animation) -> NSTimeInterval in
                return c + animation.delay + animation.duration
            })
        }
    }
        
    override public var position: NSTimeInterval {
        didSet {
            var total = 0.0
            animations.forEach { (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position - total))
                total += animation.delay + animation.duration
            }
        }
    }
    
    override func commit() {
        animateNext()
    }
    
    override public func then(animations animations: [Animation]) -> Animation {
        animations.forEach { animation in
            animation.owner = self
            self.animations.append(animation)
        }
        return self
    }
    
    private func animateNext() {
        if let nextAnimation = animations.filter({ $0.state == .Waiting }).first {
            nextAnimation.begin()
        } else {
            complete(animations.reduce(true, combine: { $0 && $1.finished }))
        }
    }
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        guard state == .Animating else { return }
        animateNext()
    }
    
}