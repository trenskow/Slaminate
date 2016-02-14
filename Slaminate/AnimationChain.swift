//
//  AnimationChain.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 11/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

class AnimationChain: ConcreteAnimation, AnimationDelegate {
    
    var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation]) {
        self.animations = animations
        super.init()
        self.animations.forEach { (animation) -> () in
            animation.delegate = self
            animation.postpone()
        }
    }
    
    @objc override var duration: NSTimeInterval {
        get {
            return self.animations.reduce(0.0, combine: { (c, animation) -> NSTimeInterval in
                return c + animation.delay + animation.duration
            })
        }
    }
    
    @objc override var delay: NSTimeInterval {
        get {
            return 0.0
        }
    }
    
    @objc override var finished: Bool {
        @objc(isFinished) get {
            return self.animations.all({ $0.finished && $0.progressState == .End })
        }
    }
    
    override var position: NSTimeInterval {
        didSet {
            var total = 0.0
            animations.forEach { (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position - total))
                total += animation.delay + animation.duration
            }
        }
    }
    
    override func commitAnimation() {
        state = .Comited
        guard progressState.rawValue < AnimationProgressState.End.rawValue else { return }
        progressState = .InProgress
        animateNext()
    }
    
    override func then(animations animations: [Animation]) -> Animation {
        animations.forEach { animation in
            let animation = animation as! DelegatedAnimation
            animation.postpone()
            animation.delegate = self
            self.animations.append(animation)
        }
        return self
    }
    
    private func animateNext() {
        if let nextAnimation = animations.filter({ $0.progressState != .End }).first as? ConcreteAnimation {
            nextAnimation.commitAnimation()
        } else {
            progressState = .End
        }
    }
    
    func animation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        guard state == .Comited else { return }
        animateNext()
    }
    
    func animation(animation: Animation, didChangeProgressState: AnimationProgressState) {
        if animations.count == 0 || animations.first?.progressState == .Beginning {
            progressState = .Beginning
        } else if animations.last?.progressState == .End {
            progressState = .End
        }
        progressState = .InProgress
    }
    
}