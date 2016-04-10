//
//  BuildIns.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 14/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

public class AnimationBuildIns: Animation {
    
    @objc public enum MoveDirection: Int {
        case Top
        case Right
        case Bottom
        case Left
    }
    
    @objc public enum FlipDirection: Int {
        case TopDown
        case BottomUp
        case RightToLeft
        case LeftToRight
    }
    
    private var animations: Animation
    
    private weak var view: UIView!
    private var hide: Bool
    private var applyDuration: NSTimeInterval
    private var applyCurve: Curve?
    
    private var fades: (enabled: Bool, curve: Curve?) = (false, nil)
    private var moves: (enabled: Bool, direction: MoveDirection, offset: CGSize, curve: Curve?) = (false, .Top, CGSize(), nil)
    private var flip: (enabled: Bool, direction: FlipDirection, curve: Curve?) = (false, .TopDown, nil)
    
    private var preserveFromValueCurve: Curve! = nil
    
    private var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve?) {
        self.view = view
        self.hide = hide
        self.applyDuration = duration
        self.applyCurve = curve
        self.animations = AnimationGroup()
        super.init(duration: 0.0)
        self.preserveFromValueCurve = Curve({ [unowned self] in
            self.hide ? ($0 == 1.0 ? 0.0 : $0) : ($0 == 0.0 ? 1.0 : $0) }
        )
        self.animations.owner = self
    }
    
    override public var duration: NSTimeInterval {
        get { return applyDuration }
        set {
            applyDuration = newValue
            animations.duration = newValue
        }
    }
    
    override public var position: NSTimeInterval {
        get { return animations.position }
        set { setPosition(newValue, apply: true) }
    }
    
    override func setPosition(position: NSTimeInterval, apply: Bool) {
        if position > 0.0 {
            build()
        }
        animations.setPosition(position, apply: apply)
        super.setPosition(position, apply: apply)
    }
    
    public override func on(event: AnimationEvent, then: (animation: Animation) -> Void) -> AnimationBuildIns {
        return super.on(event, then: then) as! AnimationBuildIns
    }
        
    public override func delayed(delay: NSTimeInterval) -> AnimationBuildIns {
        return super.delayed(delay) as! AnimationBuildIns
    }
    
    public override func manual() -> AnimationBuildIns {
        return super.manual() as! AnimationBuildIns
    }
    
    public func fade(curve curve: Curve? = nil) -> AnimationBuildIns {
        fades = (true, curve)
        return self
    }
    
    private func buildFade() {
        guard view.hidden != hide else { return }
        var fromValue: CGFloat = CGFloat(self.view.layer.stateLayer.opacity)
        var toValue: CGFloat = 0.0
        if !hide { swap(&fromValue, &toValue) }
        animations.and(animation: LayerAnimation(
            duration: applyDuration,
            object: view.layer,
            key: "opacity",
            fromValue: fromValue,
            toValue: toValue,
            curve: (fades.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve
            ))
    }
    
    public func move(direction direction: MoveDirection, offset: CGSize, curve: Curve? = nil) -> AnimationBuildIns {
        moves = (true, direction, offset, curve)
        return self
    }
    
    public func move(direction direction: MoveDirection, outsideViewBounds viewBounds: UIView? = nil, curve: Curve? = nil) -> AnimationBuildIns {
        return move(direction: direction, offset: (viewBounds ?? view).layer.bounds.size, curve: nil)
    }
    
    public func move() -> AnimationBuildIns {
        return move(direction: .Top, outsideViewBounds: nil)
    }
    
    private func buildMove() {
        guard view.hidden != hide else { return }
        var fromValue = view.layer.stateLayer.position
        var toValue = fromValue
        switch moves.direction {
        case .Top:
            toValue.y -= moves.offset.height
        case .Right:
            toValue.x += moves.offset.width
        case .Bottom:
            toValue.y += moves.offset.height
        case .Left:
            toValue.x -= moves.offset.width
        }
        if !hide { swap(&fromValue, &toValue) }
        animations.and(animation: LayerAnimation(
            duration: applyDuration,
            object: view.layer,
            key: "position",
            fromValue: fromValue,
            toValue: toValue,
            curve: (moves.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve
            ))
    }
    
    public func flip(direction direction: FlipDirection, curve: Curve? = nil) -> AnimationBuildIns {
        flip = (true, direction, curve ?? flip.curve)
        return self
    }
    
    public func buildFlip() {
        guard view.hidden != hide else { return }
        var keyPath = "transform.rotation.x"
        if flip.direction == .RightToLeft || flip.direction == .LeftToRight {
            keyPath = "transform.rotation.y"
        }
        var fromValue = view.layer.stateLayer.valueForKeyPath(keyPath) as! Double
        var toValue = M_PI_2
        if flip.direction == .BottomUp || flip.direction == .LeftToRight {
            toValue *= -1.0;
        }
        if !hide { swap(&fromValue, &toValue) }
        animations.and(animation:
            LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: keyPath,
                fromValue: fromValue,
                toValue: toValue,
                curve: (flip.curve ?? applyCurve ?? Curve.linear) * preserveFromValueCurve)
            .on(.Delay, then: { [weak self] (animation) in
                var transform = CATransform3DIdentity
                transform.m34 = 1.0 / -500.0
                self?.view.superview?.layer.sublayerTransform = transform
            })
            .on(.Complete, then: { [weak self] (animation) in
                self?.view.superview?.layer.sublayerTransform = CATransform3DIdentity
            })
        )
    }
    
    private func build() {
        guard !isBuild else { return }
        
        isBuild = true
        
        // We need to hide no matter what.
        animations.and(animation: LayerAnimation(
            duration: applyDuration,
            object: view.layer,
            key: "hidden",
            fromValue: false,
            toValue: true,
            curve: (applyCurve ?? Curve.linear) * Curve({ t in
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
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        complete(finished)
    }
    
}

extension UIView {
    public func setHidden(hidden: Bool, duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return AnimationBuildIns(view: self, hide: hidden, duration: duration, curve: curve)
    }
    public func show(duration duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(false, duration: duration, curve: curve)
    }
    public func hide(duration duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(true, duration: duration, curve: curve)
    }
}
