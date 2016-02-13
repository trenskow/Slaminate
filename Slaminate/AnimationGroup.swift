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
        
    var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation], completion: ((finished: Bool) -> Void)?) {
        self.animations = animations ?? []
        self.completion = completion
        super.init()
        animations.forEach({ $0.delegate = self })
    }
    
    override var progressState: AnimationProgressState {
        didSet {
            if let completion = completion where progressState != oldValue && progressState == .End {
                completion(finished)
            }
        }
    }
    
    override var position: NSTimeInterval {
        didSet {
            animations.forEach({ (animation) in
                animation.position = max(0.0, min(animation.delay + animation.duration, position))
            })
        }
    }
    
    override func commitAnimation() {
        state = .Comited
        progressState = .InProgress
        let nonCompleteAnimations = animations.filter { $0.progressState != .End }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { ($0 as! ConcreteAnimation).commitAnimation() }
        } else {
            completeAnimation(true)
        }
    }
    
    override func and(animation animation: Animation) -> Animation {
        animation.postpone()
        animations.append(animation as! DelegatedAnimation)
        return self
    }
    
    internal func completeAnimation(finished: Bool) {
        self.finished = finished
        self.progressState = .End
    }
    
    func animationCompleted(animation: Animation, finished: Bool) {
        let finished = self.finished && finished
        if animations.all({ $0.progressState == .End }) {
            completeAnimation(finished)
        }
    }
    
}
