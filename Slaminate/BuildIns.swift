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
    private var duration: NSTimeInterval
    private var curve: Curve
    private var delay: NSTimeInterval
    private var completion: CompletionHandler?
    
    private var animationGroup: AnimationGroup!
    
    public var animation: Animation { return animationGroup }
    
    internal init(view: UIView, hide: Bool, duration: NSTimeInterval, curve: Curve?, delay: NSTimeInterval, completion: CompletionHandler?) {
        self.view = view
        self.hide = hide
        self.duration = duration
        self.curve = curve ?? Curve.linear
        self.delay = delay
        self.completion = completion
        super.init()
        self.performSelector(Selector("fade"), withObject: nil, afterDelay: 0.0)
        self.animationGroup = AnimationGroup(completion: completion)
    }
    
    private func cancelFade() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    public func fade() -> BuildIns {
        cancelFade()
        if let view = self.view where view.hidden != hide {
            animation.and(animations:
                [
                    LayerAnimation(
                        duration: duration,
                        delay: delay,
                        object: view.layer,
                        key: "opacity",
                        fromValue: hide ? 1.0 : 0.0,
                        toValue: hide ? 0.0 : 1.0,
                        curve: curve
                    ),
                    LayerAnimation(
                        duration: duration,
                        delay: delay,
                        object: view.layer,
                        key: "hidden",
                        fromValue: false,
                        toValue: true,
                        curve: Curve(block: { t in
                            return t == (self.hide ? 1.0 : 0.0) ? 1.0 : 0.0
                        })
                    )
                ]
            )
        }
        return self
    }
    
    @objc public enum MoveDirection: Int {
        case Top
        case Right
        case Bottom
        case Left
    }
    
    public func move(direction: MoveDirection = .Top, fromOutsideViewBounds viewBounds: UIView? = nil) -> BuildIns {
        cancelFade()
        let animation = AnimationGroup(animations: [], completion: completion)
        if let view = view, superlayer = view.layer.superlayer where view.hidden != hide {
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
            if !hide { swap(&fromValue, &toValue) }
            animation.and(animations:
                [
                    LayerAnimation(
                        duration: duration,
                        delay: delay,
                        object: view.layer,
                        key: "position",
                        fromValue: fromValue,
                        toValue: toValue,
                        curve: curve
                    ),
                    LayerAnimation(
                        duration: duration,
                        delay: delay,
                        object: view.layer,
                        key: "hidden",
                        fromValue: false,
                        toValue: true,
                        curve: Curve(block: { t in
                            return t == (self.hide ? 1.0 : 0.0) ? 1.0 : 0.0
                        })
                    )
                ]
            )
            animation.on(.Begin, then: { _ in
                view.layer.position = originalPosition
            })
            animation.on(.End, then: { _ in
                view.layer.position = originalPosition
            })
        }
        return self
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
