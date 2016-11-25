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
    
    @objc public enum FlipDirection: Int {
        case topDown
        case bottomUp
        case rightToLeft
        case leftToRight
    }
    
    fileprivate var animations: Animation
    
    fileprivate weak var view: UIView!
    fileprivate var hide: Bool
    fileprivate var applyDuration: TimeInterval
    fileprivate var applyCurve: Curve?
    
    fileprivate var fades: (enabled: Bool, curve: Curve?) = (false, nil)
    fileprivate var moves: (enabled: Bool, direction: MoveDirection, offset: CGSize, curve: Curve?) = (false, .top, CGSize(), nil)
    fileprivate var flip: (enabled: Bool, direction: FlipDirection, curve: Curve?) = (false, .topDown, nil)
    
    fileprivate var preserveFromValueCurve: Curve! = nil
    
    fileprivate var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: TimeInterval, curve: Curve) {
        self.view = view
        self.hide = hide
        self.applyDuration = duration
        self.applyCurve = curve
        self.animations = AnimationGroup()
        super.init(duration: 0.0)
        self.preserveFromValueCurve = Curve(transform: { [unowned self] in
            self.hide ? ($0 == 1.0 ? 0.0 : $0) : ($0 == 0.0 ? 1.0 : $0) }
        )
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
    
    override open func on(_ event: AnimationEvent, then: @escaping (Animation) -> Void) -> AnimationBuildIns {
        return super.on(event, then: then) as! AnimationBuildIns
    }
        
    override open func delayed(_ delay: TimeInterval) -> AnimationBuildIns {
        return super.delayed(delay) as! AnimationBuildIns
    }
    
    override open func manual() -> AnimationBuildIns {
        return super.manual() as! AnimationBuildIns
    }
    
    open func fade(curve: Curve? = nil) -> AnimationBuildIns {
        fades = (true, curve)
        return self
    }
    
    fileprivate func buildFade() {
        guard view.isHidden != hide else { return }
        var fromValue: CGFloat = CGFloat(self.view.layer.stateLayer.opacity)
        var toValue: CGFloat = 0.0
        if !hide { swap(&fromValue, &toValue) }
        _ = animations.and(animation: LayerAnimation(
            duration: applyDuration,
            object: view.layer,
            key: "opacity",
            fromValue: fromValue,
            toValue: toValue,
            curve: (fades.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve
            ))
    }
    
    open func move(direction: MoveDirection, offset: CGSize, curve: Curve? = nil) -> AnimationBuildIns {
        moves = (true, direction, offset, curve)
        return self
    }
    
    open func move(direction: MoveDirection, outsideViewBounds viewBounds: UIView? = nil, curve: Curve? = nil) -> AnimationBuildIns {
        return move(direction: direction, offset: (viewBounds ?? view).layer.bounds.size, curve: nil)
    }
    
    open func move() -> AnimationBuildIns {
        return move(direction: .top, outsideViewBounds: nil)
    }
    
    fileprivate func buildMove() {
        guard view.isHidden != hide else { return }
        var fromValue = view.layer.stateLayer.position
        var toValue = fromValue
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
            curve: (moves.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve
            ))
    }
    
    open func flip(direction: FlipDirection, curve: Curve? = nil) -> AnimationBuildIns {
        flip = (true, direction, curve ?? flip.curve)
        return self
    }
    
    fileprivate func buildFlip() {
        guard view.isHidden != hide else { return }
        var keyPath = "transform.rotation.x"
        if flip.direction == .rightToLeft || flip.direction == .leftToRight {
            keyPath = "transform.rotation.y"
        }
        var fromValue = view.layer.stateLayer.value(forKeyPath: keyPath) as! Double
        var toValue = M_PI_2
        if flip.direction == .bottomUp || flip.direction == .leftToRight {
            toValue *= -1.0;
        }
        if !hide { swap(&fromValue, &toValue) }
        _ = animations.and(animation:
            LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: keyPath,
                fromValue: fromValue,
                toValue: toValue,
                curve: (flip.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve)
                .on(.delayed, then: { [weak self] (animation) in
                var transform = CATransform3DIdentity
                transform.m34 = 1.0 / -500.0
                self?.view.superview?.layer.sublayerTransform = transform
            })
                .on(.completed, then: { [weak self] (animation) in
                self?.view.superview?.layer.sublayerTransform = CATransform3DIdentity
            })
        )
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
            curve: (applyCurve ?? Curve.linear) * Curve(transform: { t in
                return self.hide ? (t == 1.0 ? 1.0 : 0.0) : (t == 0.0 ? 1.0 : 0.0)
            })
            ))
        
        if fades.enabled || (!moves.enabled && !flip.enabled) {
            buildFade()
        }
        if moves.enabled {
            buildMove()
        }
        if flip.enabled {
            buildFlip()
        }
    }
    
    override func commit() {
        build()
        animations.begin()
    }
    
    override func child(animation: Animation, didCompleteWithFinishState finished: Bool) {
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
