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
    
    public convenience override init() {
        self.init(animations: [])
    }
    
    override public var position: NSTimeInterval {
        didSet {
            animations.forEach({ (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position))
            })
        }
    }
    
    override public var duration: NSTimeInterval {
        get {
            return animations.reduce(0.0) { (c, animation) -> NSTimeInterval in
                return max(c, animation.delay + animation.duration)
            } - delay
        }
    }
    
    override func commit() {
        let nonCompleteAnimations = animations.filter { $0.state == .Waiting }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { $0.begin() }
        } else {
            complete(true)
        }
    }
    
    override public func and(animations animations: [Animation]) -> Animation {
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
        if animations.all({ $0.state == .Complete }) {
            complete(animations.reduce(true, combine: { $0 && $1.finished } ))
        }
    }
    
}
