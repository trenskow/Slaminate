//
//  AnimationGroup.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

class AnimationGroup: ConcreteAnimation {
    
    var completion: (Bool -> Void)?
    
    override convenience init() {
        self.init(animations: [], completion: nil)
    }
    
    convenience init(completion: ((finished: Bool) -> Void)?) {
        self.init(animations: [], completion: completion)
    }
        
    private var animations: [DelegatedAnimation]
    
    init(animations: [DelegatedAnimation], completion: ((finished: Bool) -> Void)?) {
        self.animations = animations ?? []
        self.completion = completion
        super.init()
        animations.forEach({ $0.owner = self })
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
    
    @objc(isFinished) override var finished: Bool {
        return animations.reduce(true, combine: { (c, animation) -> Bool in
            return c && animation.finished
        })
    }
    
    override var duration: NSTimeInterval {
        get {
            return animations.reduce(0.0) { (c, animation) -> NSTimeInterval in
                return max(c, animation.delay + animation.duration)
            } - delay
        }
    }
    
    override var delay: NSTimeInterval {
        get {
            guard animations.count > 0 else { return 0.0 }
            return animations.reduce(NSTimeInterval.infinity, combine: { (c, animation) -> NSTimeInterval in
                return min(c, animation.delay)
            })
        }
    }
    
    override func commit() {
        state = .Comited
        guard progressState.rawValue < AnimationProgressState.End.rawValue else { return }
        let nonCompleteAnimations = animations.map({ $0 as! ConcreteAnimation }).filter { $0.progressState != .End }
        if nonCompleteAnimations.count > 0 {
            animations.forEach { $0.commit() }
        } else {
            completeAnimation(true)
        }
    }
    
    override func and(animations animations: [Animation]) -> Animation {
        animations.map({ $0 as! DelegatedAnimation }).forEach { animation in
            self.animations.append(animation)
            animation.owner = self
        }
        return self
    }
    
    internal func completeAnimation(finished: Bool) {
        self.progressState = .End
    }
    
    func animation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        let finished = self.finished && finished
        if animations.all({ $0.progressState == .End }) {
            completeAnimation(finished)
        }
    }
    
    func animation(animation: Animation, didChangeProgressState: AnimationProgressState) {
        progressState = AnimationProgressState(rawValue: animations.reduce(AnimationProgressState.End.rawValue, combine: { (c, animation) -> Int in
            return min(c, animation.state.rawValue)
        }))!
    }
    
}
