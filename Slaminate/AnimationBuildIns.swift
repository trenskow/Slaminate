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
    
    @objc public enum BlastDirection: Int {
        case Explode
        case Implode
    }
    
    private var animations: Animation
    
    private weak var view: UIView!
    private var hide: Bool
    private var applyDuration: NSTimeInterval
    private var applyCurve: Curve
    
    private var fades: Bool = false
    private var moves: (enabled: Bool, direction: MoveDirection, offset: CGSize) = (false, .Top, CGSize())
    private var blasts: (enabled: Bool, direction: BlastDirection) = (false, .Explode)
    
    private var preserveFromValue: Curve! = nil
    
    private var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve) {
        self.view = view
        self.hide = hide
        self.applyDuration = duration
        self.applyCurve = curve
        self.animations = AnimationGroup()
        super.init(duration: 0.0)
        self.preserveFromValue = Curve(transform: { self.hide ? ($0 == 1.0 ? 0.0 : $0) : ($0 == 0.0 ? 1.0 : $0) })
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
    
    public func fade() -> AnimationBuildIns {
        fades = true
        return self
    }
    
    public func move(direction direction: MoveDirection, offset: CGSize) -> AnimationBuildIns {
        moves = (true, direction, offset)
        return self
    }
    
    public func move(direction direction: MoveDirection, outsideViewBounds viewBounds: UIView? = nil) -> AnimationBuildIns {
        return move(direction: direction, offset: (viewBounds ?? view).layer.bounds.size)
    }
    
    public func move() -> AnimationBuildIns {
        return move(direction: .Top, outsideViewBounds: nil)
    }
    
    public func blast(direction: BlastDirection = .Implode) -> AnimationBuildIns {
        blasts = (true, direction)
        return self
    }
    
    private func buildFade() {
        if view.hidden != hide {
            var fromValue: CGFloat = CGFloat(self.view.layer.opacity)
            var toValue: CGFloat = 0.0
            if !hide { swap(&fromValue, &toValue) }
            animations.and(animation: LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: "opacity",
                fromValue: fromValue,
                toValue: toValue,
                curve: applyCurve + preserveFromValue
            ))
        }
    }
    
    private func buildMove() {
        if view.hidden != hide {
            var fromValue = view.layer.position
            var toValue = view.layer.position
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
                curve: applyCurve + preserveFromValue
            ))
        }
    }
    
    private func buildBlast() {
        if view.hidden != hide {
            var fromValue: CGFloat = CGFloat((self.view.layer.valueForKeyPath("transform.scale") as! NSNumber).doubleValue)
            var toValue: CGFloat = (blasts.direction == .Implode ? 0.0 : 2.0)
            if !hide { swap(&fromValue, &toValue) }
            animations.and(animation: LayerAnimation(
                duration: applyDuration,
                object: view.layer,
                key: "transform.scale",
                fromValue: fromValue,
                toValue: toValue,
                curve: applyCurve + preserveFromValue
            ))
        }
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
    
    override func childAnimation(animation: Animation, didCompleteWithFinishState finished: Bool) {
        complete(finished)
    }
    
}

extension UIView {
    public func setHidden(hidden: Bool, duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return AnimationBuildIns(view: self, hide: hidden, duration: duration, curve: curve ?? Curve.linear)
    }
    public func show(duration duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(false, duration: duration, curve: curve)
    }
    public func hide(duration duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(true, duration: duration, curve: curve)
    }
}
