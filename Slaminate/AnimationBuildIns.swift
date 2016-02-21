//
//  BuildIns.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 14/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

@objc(SLAAnimationBuildIns)
public class AnimationBuildIns: AnimationGroup {
    
    private weak var view: UIView?
    private var hide: Bool
    private var curve: Curve
    private var _duration: NSTimeInterval
    
    private var doFade: Bool = false
    private var doMove: Bool = false
    private var doPop: Bool = false
    
    private var moveDirection: MoveDirection = .Top
    private var moveViewBounds: UIView?
    
    private var isBuild: Bool = false
    
    init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve?, delay: NSTimeInterval) {
        self.view = view
        self.hide = hide
        self._duration = duration
        self.curve = curve ?? Curve.linear
        super.init(animations: [])
    }
    
    override public var position: NSTimeInterval {
        didSet {
            if position > 0.0 {
                build()
            }
        }
    }
    
    public var fade: Void -> AnimationBuildIns {
        return {
            self.doFade = true
            return self
        }
    }
    
    @objc public enum MoveDirection: Int {
        case Top
        case Right
        case Bottom
        case Left
    }
    
    public var move: (direction: MoveDirection, fromOutsideViewBounds: UIView?) -> AnimationBuildIns {
        return { (direction, viewBounds) in
            self.doMove = true
            self.moveDirection = direction
            self.moveViewBounds = viewBounds ?? self.view
            return self
        }
    }
    
    public var pop: Void -> AnimationBuildIns {
        return {
            self.doPop = true
            return self
        }
    }
    
    private func buildFade() {
        if let view = self.view where view.hidden != self.hide {
            self.and(animation: LayerAnimation(
                duration: self._duration,
                object: view.layer,
                key: "opacity",
                fromValue: self.hide ? 1.0 : 0.0,
                toValue: self.hide ? 0.0 : 1.0,
                curve: self.curve
            ))
        }
    }
    
    private func buildMove() {
        if let view = self.view, superlayer = view.layer.superlayer where view.hidden != hide {
            let edges = UIEdgeInsets(
                top: view.layer.bounds.size.height * view.layer.anchorPoint.y,
                left: view.layer.bounds.size.width * view.layer.anchorPoint.x,
                bottom: view.layer.bounds.size.height * (1.0 - view.layer.anchorPoint.y),
                right: view.layer.bounds.size.width * (1.0 - view.layer.anchorPoint.x)
            )
            let layerBounds = (moveViewBounds ?? view).layer
            let bounds = superlayer.convertRect(layerBounds.bounds, fromLayer: layerBounds)
            let originalPosition = view.layer.position
            var fromValue = view.layer.position
            var toValue: CGPoint
            switch moveDirection {
            case .Top:
                toValue = CGPoint(
                    x: view.layer.position.x,
                    y: bounds.origin.y - edges.bottom
                )
            case .Right:
                toValue = CGPoint(
                    x: bounds.origin.x - edges.left,
                    y: view.layer.position.y
                )
            case .Bottom:
                toValue = CGPoint(
                    x: view.layer.position.x,
                    y: bounds.origin.y + bounds.size.height + edges.top
                )
            case .Left:
                toValue = CGPoint(
                    x: bounds.origin.x + bounds.size.width + edges.right,
                    y: view.layer.position.y
                )
            }
            if !hide { swap(&fromValue, &toValue) }
            and(animation: LayerAnimation(
                duration: _duration,
                object: view.layer,
                key: "position",
                fromValue: fromValue,
                toValue: toValue,
                curve: curve
            ))
            completed({ (finished) -> Void in
                view.layer.position = originalPosition
            })
            started({
                view.layer.position = originalPosition
            })
        }
    }
    
    private func buildPop() {
        if let view = self.view where view.hidden != self.hide {
            var fromValue: CGFloat = 0.9
            var toValue: CGFloat = 1.0
            if self.hide {
                swap(&fromValue, &toValue)
            }
            self.and(animation: LayerAnimation(
                duration: self._duration,
                object: view.layer,
                key: "transform.scale",
                fromValue: fromValue,
                toValue: toValue,
                curve: self.curve)
            );
        }
    }
    
    private func build() {
        guard !isBuild else { return }
        
        isBuild = true
        
        if let view = view {
            // We need to hide no matter what.
            self.and(animation: LayerAnimation(
                duration: self._duration,
                object: view.layer,
                key: "hidden",
                fromValue: false,
                toValue: true,
                curve: Curve(block: { t in
                    return self.hide ? (t == 1.0 ? 1.0 : 0.0) : 0.0
                })
                ))
            
            // Fade by default
            doFade = doFade || (!doMove && !doPop)
            
            if doFade {
                buildFade()
            }
            if doMove {
                buildMove()
            }
            if doPop {
                buildPop()
            }
        }
    }
    
    override func commit() {
        build()
        super.commit()
    }
    
}

extension UIView {
    public func setHidden(hidden: Bool, duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0) -> AnimationBuildIns {
        return AnimationBuildIns(view: self, hide: hidden, duration: duration, curve: curve, delay: delay)
    }
    public func show(duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0) -> AnimationBuildIns {
        return setHidden(false, duration: duration, curve: curve, delay: delay)
    }
    public func hide(duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0) -> AnimationBuildIns {
        return setHidden(true, duration: duration, curve: curve, delay: delay)
    }
}
