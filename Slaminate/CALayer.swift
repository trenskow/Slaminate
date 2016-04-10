//
//  CALayer+Additions.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 23/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

protocol CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] { get }
    static func keyPathsForName(name: String) -> [String]
}

extension CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return []
    }
    static func keyPathsForName(name: String) -> [String] {
        return [name] + animatableKeyPaths.map({ "\(name).\($0)" })
    }
}

extension CATransform3D: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return [
            "rotation", "rotation.x", "rotation.y", "rotation.z",
            "scale", "scale.x", "scale.y", "scale.z",
            "translation", "translation.x", "translation.y", "translation.z"
        ]
    }
}

extension CGPoint: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return [ "x", "y" ]
    }
}

extension CGSize: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return ["width", "height"]
    }
}

extension CGRect: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return [String](union: [
            "origin".keyPathForType(CGPoint),
            "size".keyPathForType(CGSize)
        ])
    }
}

extension Bool: CoreAnimationKVCExtension {}
extension Float: CoreAnimationKVCExtension {}
extension Int: CoreAnimationKVCExtension {}
extension CGFloat: CoreAnimationKVCExtension {}
extension CGColorRef: CoreAnimationKVCExtension {}
extension CGPathRef: CoreAnimationKVCExtension {}
extension CFTimeInterval: CoreAnimationKVCExtension {}

private extension String {
    func keyPathForType(type: CoreAnimationKVCExtension.Type) -> [String] {
        return type.keyPathsForName(self)
    }
}

private extension Array {
    init(union: [[Element]]) {
        self.init(union.reduce([Element](), combine: { (elements, array) in return elements + array }))
    }
}

extension CALayer {
    
    var animatableKeyPaths: [String] {
        return [String](union: [
            "contentsCenter".keyPathForType(CGPoint),
            "contentsRect".keyPathForType(CGRect),
            "opacity".keyPathForType(CGFloat),
            "hidden".keyPathForType(Bool),
            "bounds".keyPathForType(CGRect),
            "masksToBounds".keyPathForType(Bool),
            "doubleSided".keyPathForType(Bool),
            "cornerRadius".keyPathForType(CGFloat),
            "borderWidth".keyPathForType(CGFloat),
            "borderColor".keyPathForType(CGColorRef),
            "backgroundColor".keyPathForType(CGColorRef),
            "shadowOffset".keyPathForType(CGSize),
            "shadowOpacity".keyPathForType(CGFloat),
            "shadowRadius".keyPathForType(CGFloat),
            "shadowColor".keyPathForType(CGColorRef),
            "shadowPath".keyPathForType(CGPathRef),
            "position".keyPathForType(CGPoint),
            "zPosition".keyPathForType(CGFloat),
            "anchorPoint".keyPathForType(CGPoint),
            "anchorPointZ".keyPathForType(CGFloat),
            "transform".keyPathForType(CATransform3D),
            "sublayerTransform".keyPathForType(CATransform3D)
        ])
    }
    
    var stateLayer: CALayer {
        return presentationLayer() as? CALayer ?? self
    }
    
}

extension CAEmitterCell: CoreAnimationKVCExtension {
    class var animatableKeyPaths: [String] {
        return [String](union: [
            "birthRate".keyPathForType(Float),
            "lifetime".keyPathForType(Float),
            "lifetimeRange".keyPathForType(Float),
            "emissionLatitude".keyPathForType(CGFloat),
            "emissionLongitude".keyPathForType(CGFloat),
            "emissionRange".keyPathForType(CGFloat),
            "velocity".keyPathForType(CGFloat),
            "velocityRange".keyPathForType(CGFloat),
            "xAcceleration".keyPathForType(CGFloat),
            "yAcceleration".keyPathForType(CGFloat),
            "zAcceleration".keyPathForType(CGFloat),
            "scale".keyPathForType(CGFloat),
            "scaleRange".keyPathForType(CGFloat),
            "scaleSpeed".keyPathForType(CGFloat),
            "spin".keyPathForType(CGFloat),
            "spinRange".keyPathForType(CGFloat),
            "color".keyPathForType(CGColor),
            "redRange".keyPathForType(Float),
            "greenRange".keyPathForType(Float),
            "blueRange".keyPathForType(Float),
            "alphaRange".keyPathForType(Float),
            "redSpeed".keyPathForType(Float),
            "greenSpeed".keyPathForType(Float),
            "blueSpeed".keyPathForType(Float),
            "alphaSpeed".keyPathForType(Float),
            "contentsRect".keyPathForType(CGRect)
        ])
    }
}

extension CAEmitterLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "birthRate".keyPathForType(Float),
            "lifetime".keyPathForType(Float),
            "emitterPosition".keyPathForType(CGPoint),
            "emitterZPosition".keyPathForType(CGFloat),
            "emitterSize".keyPathForType(CGSize),
            "emitterDepth".keyPathForType(CGFloat),
            "velocity".keyPathForType(Float),
            "scale".keyPathForType(Float),
            "spin".keyPathForType(Float)
            ]) + [String](union: emitterCells?.filter({ $0.name != nil }).map({ (cell) -> [String] in
                return "emitterCells.\(cell.name!)".keyPathForType(CAEmitterCell)
            }) ?? [])
    }
}

extension CAGradientLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "colors".keyPathForType(CGColorRef),
            "locations".keyPathForType(CGFloat),
            "startPoint".keyPathForType(CGPoint),
            "endPoint".keyPathForType(CGPoint)
        ])
    }
}

extension CAReplicatorLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "instanceCount".keyPathForType(Int),
            "instanceDelay".keyPathForType(CFTimeInterval),
            "instanceTransform".keyPathForType(CATransform3D),
            "instanceColor".keyPathForType(CGColor),
            "instanceRedOffset".keyPathForType(Float),
            "instanceGreenOffset".keyPathForType(Float),
            "instanceBlueOffset".keyPathForType(Float),
            "instanceAlphaOffset".keyPathForType(Float)
        ])
    }
}

extension CAShapeLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "path".keyPathForType(CGPath),
            "fillColor".keyPathForType(CGColor),
            "strokeColor".keyPathForType(CGColor),
            "strokeStart".keyPathForType(CGFloat),
            "strokeEnd".keyPathForType(CGFloat),
            "lineWidth".keyPathForType(CGFloat),
            "miterLimit".keyPathForType(CGFloat),
            "lineDashPhase".keyPathForType(CGFloat)
        ])
    }
}
