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
    
    private var apply: (fade: Bool, move: Bool, blast: Bool) = (false, false, false)
    private var applyMoveOptions: (direction: MoveDirection, moveViewBounds: UIView?) = (.Top, nil)
    private var applyBlastOptionsDirection: BlastDirection = .Explode
    
    private var preserveFromValue: Curve! = nil
    
    private var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve) {
        self.view = view
        self.hide = hide
        self.applyDuration = duration
        self.applyCurve = curve
        self.animations = AnimationGroup()
        super.init()
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
        
    public func fade() -> AnimationBuildIns {
        apply.fade = true
        return self
    }
    
    public func move(direction direction: MoveDirection, outsideViewBounds viewBounds: UIView? = nil) -> AnimationBuildIns {
        apply.move = true
        applyMoveOptions.direction = direction
        applyMoveOptions.moveViewBounds = viewBounds ?? view
        return self
    }
    
    public func blast(direction: BlastDirection = .Implode) -> AnimationBuildIns {
        apply.blast = true
        applyBlastOptionsDirection = direction
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
        if let superlayer = view.layer.superlayer where view.hidden != hide {
            let edges = UIEdgeInsets(
                top: view.layer.bounds.size.height * view.layer.anchorPoint.y,
                left: view.layer.bounds.size.width * view.layer.anchorPoint.x,
                bottom: view.layer.bounds.size.height * (1.0 - view.layer.anchorPoint.y),
                right: view.layer.bounds.size.width * (1.0 - view.layer.anchorPoint.x)
            )
            let layerBounds = (applyMoveOptions.moveViewBounds ?? view).layer
            let bounds = superlayer.convertRect(layerBounds.bounds, fromLayer: layerBounds)
            var fromValue = view.layer.position
            var toValue: CGPoint
            switch applyMoveOptions.direction {
            case .Top:
                toValue = CGPoint(
                    x: view.layer.position.x,
                    y: bounds.origin.y - edges.bottom
                )
            case .Left:
                toValue = CGPoint(
                    x: bounds.origin.x - edges.left,
                    y: view.layer.position.y
                )
            case .Bottom:
                toValue = CGPoint(
                    x: view.layer.position.x,
                    y: bounds.origin.y + bounds.size.height + edges.top
                )
            case .Right:
                toValue = CGPoint(
                    x: bounds.origin.x + bounds.size.width + edges.right,
                    y: view.layer.position.y
                )
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
            var toValue: CGFloat = (applyBlastOptionsDirection == .Implode ? 0.0 : 2.0)
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
        
        if apply.fade || (!apply.move && !apply.blast) {
            buildFade()
        }
        if apply.move {
            buildMove()
        }
        if apply.blast {
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
    public func show(duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(false, duration: duration, curve: curve)
    }
    public func hide(duration: NSTimeInterval, curve: Curve? = nil) -> AnimationBuildIns {
        return setHidden(true, duration: duration, curve: curve)
    }
}
