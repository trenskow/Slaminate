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
    
    override var position: AnimationPosition {
        didSet {
            if let completion = completion where position != oldValue && position == .End {
                completion(finished)
            }
        }
    }
    
    override var offset: NSTimeInterval {
        didSet {
            animations.forEach({ (animation) in
                animation.offset = max(0.0, min(animation.delay + animation.duration, offset))
            })
        }
    }
    
    override func commitAnimation() {
        state = .Comited
        position = .InProgress
        let nonCompleteAnimations = animations.filter { $0.position != .End }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { ($0 as! ConcreteAnimation).commitAnimation() }
        } else {
            completeAnimation(true)
        }
    }
    
    override func and(animation animation: Animation) -> Animation {
        animation.postponeAnimation()
        animations.append(animation as! DelegatedAnimation)
        return self
    }
    
    internal func completeAnimation(finished: Bool) {
        self.finished = finished
        self.position = .End
    }
    
    func animationCompleted(animation: Animation, finished: Bool) {
        let finished = self.finished && finished
        if animations.all({ $0.position == .End }) {
            completeAnimation(finished)
        }
    }
    
}
