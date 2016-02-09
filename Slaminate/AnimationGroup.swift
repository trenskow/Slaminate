//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class AnimationGroup: DelegatedAnimation, AnimationDelegate {
    
    @objc(isAnimating) var animating: Bool = false
    @objc(isComplete) var complete: Bool = false
    @objc(isFinished) var finished: Bool = true
    @objc var duration: NSTimeInterval = 0.0
    @objc var delay: NSTimeInterval = 0.0
    
    var completion: (Bool -> Void)?
    
    weak var delegate: AnimationDelegate?
    
    convenience init(completion: ((finished: Bool) -> Void)?) {
        self.init(animations: nil, completion: completion)
    }
    
    deinit {
        print("deinit group")
    }
    
    var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation]?, completion: ((finished: Bool) -> Void)?) {
        self.animations = animations ?? []
        self.completion = completion
        animations?.forEach({ $0.delegate = self })
    }
    
    func beginAnimation() {
        animations.forEach { $0.beginAnimation() }
    }
        
    func animationCompleted(animation: Animation, finished: Bool) {
        self.finished = self.finished && finished
        let complete = animations.reduce(true) { (c, animation) -> Bool in
            return c && animation.complete
        }
        if complete {
            self.delegate?.animationCompleted(self, finished: self.finished)
            self.completion?(finished)
        }
    }
    
}
