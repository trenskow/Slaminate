//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class AnimationGroup: ConcreteAnimation, AnimationDelegate {
    
    var completion: (Bool -> Void)?
    
    override convenience init() {
        self.init(animations: [], completion: nil)
    }
    
    convenience init(completion: ((finished: Bool) -> Void)?) {
        self.init(animations: [], completion: completion)
    }
    
    deinit {
        print("deinit group")
    }
    
    var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation], completion: ((finished: Bool) -> Void)?) {
        self.animations = animations ?? []
        self.completion = completion
        super.init()
        animations.forEach({ $0.delegate = self })
    }
    
    override func commitAnimation() {
        self.animating = true
        if animations.count > 0 {
            animations.forEach { $0.beginAnimation() }
        } else {
            completeAnimation(true)
        }
    }
        
    internal func completeAnimation(finished: Bool) {
        self.complete = true
        self.finished = finished
        self.animating = false
        self.delegate?.animationCompleted(self, finished: self.finished)
        self.completion?(finished)
        ongoingAnimations.remove(self)
    }
    
    func animationCompleted(animation: Animation, finished: Bool) {
        let finished = self.finished && finished
        let complete = animations.reduce(true) { (c, animation) -> Bool in
            return c && animation.complete
        }
        if complete {
            completeAnimation(finished)
        }
    }
    
}
