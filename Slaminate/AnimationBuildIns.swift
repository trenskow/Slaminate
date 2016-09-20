//
//  BuildIns.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 14/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

open class AnimationBuildIns: Animation {
    
    @objc public enum MoveDirection: Int {
        case top
        case right
        case bottom
        case left
    }
    
    @objc public enum BlastDirection: Int {
        case explode
        case implode
    }
    
    fileprivate var animations: Animation
    
    fileprivate weak var view: UIView!
    fileprivate var hide: Bool
    fileprivate var applyDuration: TimeInterval
    fileprivate var applyCurve: Curve
    
    fileprivate var fades: Bool = false
    fileprivate var moves: (enabled: Bool, direction: MoveDirection, offset: CGSize) = (false, .top, CGSize())
    fileprivate var blasts: (enabled: Bool, direction: BlastDirection) = (false, .explode)
    
    fileprivate var preserveFromValue: Curve! = nil
    
    fileprivate var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: TimeInterval, curve: Curve) {
        self.view = view
        self.hide = hide
        self.applyDuration = duration
        self.applyCurve = curve
        self.animations = AnimationGroup()
        super.init(duration: 0.0)
        self.preserveFromValue = Curve(transform: { self.hide ? ($0 == 1.0 ? 0.0 : $0) : ($0 == 0.0 ? 1.0 : $0) })
        self.animations.owner = self
    }
    
    override open var duration: TimeInterval {
        get { return applyDuration }
        set {
            applyDuration = newValue
            animations.duration = newValue
        }
    }
    
    override open var position: TimeInterval {
        get { return animations.position }
        set { setPosition(newValue, apply: true) }
    }
    
    override func setPosition(_ position: TimeInterval, apply: Bool) {
        if position > 0.0 {
            build()
        }
        animations.setPosition(position, apply: apply)
        super.setPosition(position, apply: apply)
    }
    
    open override func completed(_ closure: @escaping (_ animation: Animation) -> Void) -> AnimationBuildIns {
        return super.completed(closure) as! AnimationBuildIns
    }
    
    open override func started(_ closure: @escaping (_ animation: Animation) -> Void) -> AnimationBuildIns {
        return super.started(closure) as! AnimationBuildIns
    }
    
    open override func delayed(_ delay: TimeInterval) -> AnimationBuildIns {
        return super.delayed(delay) as! AnimationBuildIns
    }
    
    open override func manual() -> AnimationBuildIns {
        return super.manual() as! AnimationBuildIns
    }
    
    open func fade() -> AnimationBuildIns {
        fades = true
        return self
    }
    
    open func move(direction: MoveDirection, offset: CGSize) -> AnimationBuildIns {
        moves = (true, direction, offset)
        return self
    }
    
    open func move(direction: MoveDirection, outsideViewBounds viewBounds: UIView? = nil) -> AnimationBuildIns {
        return move(direction: direction, offset: (viewBounds ?? view).layer.bounds.size)
    }
    
    open func move() -> AnimationBuildIns {
        return move(direction: .top, outsideViewBounds: nil)
    }
    
    open func blast(_ direction: BlastDirection = .implode) -> AnimationBuildIns {
        blasts = (true, direction)
        return self
    }
    
    fileprivate func buildFade() {
        if view.isHidden != hide {
            var fromValue: CGFloat = CGFloat(self.view.layer.opacity)
            var toValue: CGFloat = 0.0
            if !hide { swap(&fromValue, &toValue) }
            _ = animations.and(animation: LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: "opacity",
                fromValue: fromValue,
                toValue: toValue,
                curve: applyCurve + preserveFromValue
            ))
        }
    }
    
    fileprivate func buildMove() {
        if view.isHidden != hide {
            var fromValue = view.layer.position
            var toValue = view.layer.position
            switch moves.direction {
            case .top:
                toValue.y -= moves.offset.height
            case .right:
                toValue.x += moves.offset.width
            case .bottom:
                toValue.y += moves.offset.height
            case .left:
                toValue.x -= moves.offset.width
            }
            if !hide { swap(&fromValue, &toValue) }
            _ = animations.and(animation: LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: "position",
                fromValue: fromValue,
                toValue: toValue,
                curve: applyCurve + preserveFromValue
            ))
        }
    }
    
    fileprivate func buildBlast() {
        if view.isHidden != hide {
            var fromValue: CGFloat = CGFloat((self.view.layer.value(forKeyPath: "transform.scale") as! NSNumber).doubleValue)
            var toValue: CGFloat = (blasts.direction == .implode ? 0.0 : 2.0)
            if !hide { swap(&fromValue, &toValue) }
            _ = animations.and(animation: LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: "transform.scale",
                fromValue: fromValue,
                toValue: toValue,
                curve: applyCurve + preserveFromValue
            ))
        }
    }
    
    fileprivate func build() {
        guard !isBuild else { return }
        
        isBuild = true
        
        // We need to hide no matter what.
        _ = animations.and(animation: LayerAnimation(
            duration: applyDuration,
            object: view.layer,
            key: "hidden",
            fromValue: false,
            toValue: true,
            curve: applyCurve + Curve(transform: { t in
                return self.hide ? (t == 1.0 ? 1.0 : 0.0) : (t == 0.0 ? 1.0 : 0.0)
            })
            ))
        
        if fades || (!moves.enabled && !blasts.enabled) {
            buildFade()
        }
        if moves.enabled {
            buildMove()
        }
        if blasts.enabled {
            buildBlast()
        }
    }
    
    override func commit() {
        build()
        animations.begin()
    }
    
    override func childAnimation(_ animation: Animation, didCompleteWithFinishState finished: Bool) {
        complete(finished)
    }
    
}

extension UIView {
    public func setHidden(_ hidden: Bool, duration: TimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return AnimationBuildIns(view: self, hide: hidden, duration: duration, curve: curve ?? Curve.linear)
    }
    public func show(duration: TimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(false, duration: duration, curve: curve)
    }
    public func hide(duration: TimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(true, duration: duration, curve: curve)
    }
}
