//
//  BuildIns.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 14/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

@objc public class BuildIns: NSObject {
    
    private weak var view: UIView?
    private var hide: Bool
    private var curve: Curve
    private var duration: NSTimeInterval
    private var delay: NSTimeInterval
    
    private var animationGroup: AnimationGroup
    public var animation: Animation { return animationGroup }
    
    internal init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve?, delay: NSTimeInterval, completion: CompletionHandler?) {
        self.view = view
        self.hide = hide
        self.duration = duration
        self.curve = curve ?? Curve.linear
        self.delay = delay
        self.animationGroup = AnimationGroup(completion: completion)
        super.init()
        self.performSelector(Selector("fade"), withObject: nil, afterDelay: 0.0, inModes: [NSRunLoopCommonModes])
        self.animation.and(animation: LayerAnimation(
            duration: self.duration,
            delay: self.delay,
            object: view.layer,
            key: "hidden",
            fromValue: false,
            toValue: true,
            curve: Curve(block: { t in
                return self.hide ? (t == 1.0 ? 1.0 : 0.0) : 0.0
            })
        ))
    }
    
    private func cancelFade() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    public var fade: Void -> BuildIns {
        cancelFade()
        return {
            if let view = self.view where view.hidden != self.hide {
                self.animation.and(animation: LayerAnimation(
                    duration: self.duration,
                    delay: self.delay,
                    object: view.layer,
                    key: "opacity",
                    fromValue: self.hide ? 1.0 : 0.0,
                    toValue: self.hide ? 0.0 : 1.0,
                    curve: self.curve
                ))
            }
            return self
        }
    }
    
    @objc public enum MoveDirection: Int {
        case Top
        case Right
        case Bottom
        case Left
    }
    
    public var move: (direction: MoveDirection, fromOutsideViewBounds: UIView?) -> BuildIns {
        cancelFade()
        return { (direction, viewBounds) in
            if let view = self.view, superlayer = view.layer.superlayer where view.hidden != self.hide {
                let edges = UIEdgeInsets(
                    top: view.layer.bounds.size.height * view.layer.anchorPoint.y,
                    left: view.layer.bounds.size.width * view.layer.anchorPoint.x,
                    bottom: view.layer.bounds.size.height * (1.0 - view.layer.anchorPoint.y),
                    right: view.layer.bounds.size.width * (1.0 - view.layer.anchorPoint.x)
                )
                let layerBounds = (viewBounds ?? view).layer
                let bounds = superlayer.convertRect(layerBounds.bounds, fromLayer: layerBounds)
                let originalPosition = view.layer.position
                var fromValue = view.layer.position
                var toValue: CGPoint
                switch direction {
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
                if !self.hide { swap(&fromValue, &toValue) }
                self.animation.and(animation: LayerAnimation(
                    duration: self.duration,
                    delay: self.delay,
                    object: view.layer,
                    key: "position",
                    fromValue: fromValue,
                    toValue: toValue,
                    curve: self.curve
                ))
                self.animation.on(.Begin, then: { _ in
                    view.layer.position = originalPosition
                })
                self.animation.on(.End, then: { _ in
                    view.layer.position = originalPosition
                })
            }
            return self
        }
    }
    
    public var pop: Void -> BuildIns {
        cancelFade()
        return {
            if let view = self.view where view.hidden != self.hide {
                var fromValue: CGFloat = 0.9
                var toValue: CGFloat = 1.0
                if self.hide {
                    swap(&fromValue, &toValue)
                }
                self.animation.and(animation: LayerAnimation(
                    duration: self.duration,
                    delay: self.delay,
                    object: view.layer,
                    key: "transform.scale",
                    fromValue: fromValue,
                    toValue: toValue,
                    curve: self.curve)
                );
            }
            return self;
        }
    }
    
}

extension UIView {
    public func setHidden(hidden: Bool, duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0, completion: CompletionHandler? = nil) -> BuildIns {
        return BuildIns(view: self, hide: hidden, duration: duration, curve: curve, delay: delay, completion: completion)
    }
    public func show(duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0, completion: CompletionHandler? = nil) -> BuildIns {
        return setHidden(false, duration: duration, curve: curve, delay: delay, completion: completion)
    }
    public func hide(duration: NSTimeInterval, curve: Curve? = nil, delay: NSTimeInterval = 0.0, completion: CompletionHandler? = nil) -> BuildIns {
        return setHidden(true, duration: duration, curve: curve, delay: delay, completion: completion)
    }
}
