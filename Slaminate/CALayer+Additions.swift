//
//  CALayer+Additions.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 23/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

protocol CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] { get }
    static func keyPathsForName(_ name: String) -> [String]
}

extension CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return []
    }
    static func keyPathsForName(_ name: String) -> [String] {
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
            "origin".keyPathForType(CGPoint.self),
            "size".keyPathForType(CGSize.self)
        ])
    }
}

extension Bool: CoreAnimationKVCExtension {}
extension Float: CoreAnimationKVCExtension {}
extension Int: CoreAnimationKVCExtension {}
extension CGFloat: CoreAnimationKVCExtension {}
extension CGColor: CoreAnimationKVCExtension {}
extension CGPath: CoreAnimationKVCExtension {}
extension CFTimeInterval: CoreAnimationKVCExtension {}

private extension String {
    func keyPathForType(_ type: CoreAnimationKVCExtension.Type) -> [String] {
        return type.keyPathsForName(self)
    }
}

private extension Array {
    init(union: [[Element]]) {
        self.init(union.reduce([Element](), { (elements, array) in return elements + array }))
    }
}

extension CALayer {
    
    var animatableKeyPaths: [String] {
        return [String](union: [
            "contentsCenter".keyPathForType(CGPoint.self),
            "contentsRect".keyPathForType(CGRect.self),
            "opacity".keyPathForType(CGFloat.self),
            "hidden".keyPathForType(Bool.self),
            "bounds".keyPathForType(CGRect.self),
            "masksToBounds".keyPathForType(Bool.self),
            "doubleSided".keyPathForType(Bool.self),
            "cornerRadius".keyPathForType(CGFloat.self),
            "borderWidth".keyPathForType(CGFloat.self),
            "borderColor".keyPathForType(CGColor.self),
            "backgroundColor".keyPathForType(CGColor.self),
            "shadowOffset".keyPathForType(CGSize.self),
            "shadowOpacity".keyPathForType(CGFloat.self),
            "shadowRadius".keyPathForType(CGFloat.self),
            "shadowColor".keyPathForType(CGColor.self),
            "shadowPath".keyPathForType(CGPath.self),
            "position".keyPathForType(CGPoint.self),
            "zPosition".keyPathForType(CGFloat.self),
            "anchorPoint".keyPathForType(CGPoint.self),
            "anchorPointZ".keyPathForType(CGFloat.self),
            "transform".keyPathForType(CATransform3D.self),
            "sublayerTransform".keyPathForType(CATransform3D.self)
        ])
    }
    
}

extension CAEmitterCell: CoreAnimationKVCExtension {
    class var animatableKeyPaths: [String] {
        return [String](union: [
            "birthRate".keyPathForType(Float.self),
            "lifetime".keyPathForType(Float.self),
            "lifetimeRange".keyPathForType(Float.self),
            "emissionLatitude".keyPathForType(CGFloat.self),
            "emissionLongitude".keyPathForType(CGFloat.self),
            "emissionRange".keyPathForType(CGFloat.self),
            "velocity".keyPathForType(CGFloat.self),
            "velocityRange".keyPathForType(CGFloat.self),
            "xAcceleration".keyPathForType(CGFloat.self),
            "yAcceleration".keyPathForType(CGFloat.self),
            "zAcceleration".keyPathForType(CGFloat.self),
            "scale".keyPathForType(CGFloat.self),
            "scaleRange".keyPathForType(CGFloat.self),
            "scaleSpeed".keyPathForType(CGFloat.self),
            "spin".keyPathForType(CGFloat.self),
            "spinRange".keyPathForType(CGFloat.self),
            "color".keyPathForType(CGColor.self),
            "redRange".keyPathForType(Float.self),
            "greenRange".keyPathForType(Float.self),
            "blueRange".keyPathForType(Float.self),
            "alphaRange".keyPathForType(Float.self),
            "redSpeed".keyPathForType(Float.self),
            "greenSpeed".keyPathForType(Float.self),
            "blueSpeed".keyPathForType(Float.self),
            "alphaSpeed".keyPathForType(Float.self),
            "contentsRect".keyPathForType(CGRect.self)
        ])
    }
}

extension CAEmitterLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "birthRate".keyPathForType(Float.self),
            "lifetime".keyPathForType(Float.self),
            "emitterPosition".keyPathForType(CGPoint.self),
            "emitterZPosition".keyPathForType(CGFloat.self),
            "emitterSize".keyPathForType(CGSize.self),
            "emitterDepth".keyPathForType(CGFloat.self),
            "velocity".keyPathForType(Float.self),
            "scale".keyPathForType(Float.self),
            "spin".keyPathForType(Float.self)
            ]) + [String](union: emitterCells?.filter({ $0.name != nil }).map({ (cell) -> [String] in
                return "emitterCells.\(cell.name!)".keyPathForType(CAEmitterCell.self)
            }) ?? [])
    }
}

extension CAGradientLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "colors".keyPathForType(CGColor.self),
            "locations".keyPathForType(CGFloat.self),
            "startPoint".keyPathForType(CGPoint.self),
            "endPoint".keyPathForType(CGPoint.self)
        ])
    }
}

extension CAReplicatorLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "instanceCount".keyPathForType(Int.self),
            "instanceDelay".keyPathForType(CFTimeInterval.self),
            "instanceTransform".keyPathForType(CATransform3D.self),
            "instanceColor".keyPathForType(CGColor.self),
            "instanceRedOffset".keyPathForType(Float.self),
            "instanceGreenOffset".keyPathForType(Float.self),
            "instanceBlueOffset".keyPathForType(Float.self),
            "instanceAlphaOffset".keyPathForType(Float.self)
        ])
    }
}

extension CAShapeLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "path".keyPathForType(CGPath.self),
            "fillColor".keyPathForType(CGColor.self),
            "strokeColor".keyPathForType(CGColor.self),
            "strokeStart".keyPathForType(CGFloat.self),
            "strokeEnd".keyPathForType(CGFloat.self),
            "lineWidth".keyPathForType(CGFloat.self),
            "miterLimit".keyPathForType(CGFloat.self),
            "lineDashPhase".keyPathForType(CGFloat.self)
        ])
    }
}
