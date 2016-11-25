//
//  CALayer+Additions.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 23/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

protocol CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] { get }
    var animatableKeyPaths: [String] { get }
    static func keyPaths(forName name: String) -> [String]
}

extension CoreAnimationKVCExtension {
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
}

extension CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return []
    }
    static func keyPaths(forName name: String) -> [String] {
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
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
}

extension CGPoint: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return [ "x", "y" ]
    }
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
}

extension CGSize: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return ["width", "height"]
    }
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
}

extension CGRect: CoreAnimationKVCExtension {
    static var animatableKeyPaths: [String] {
        return [String](union: [
            "origin".keyPath(forType: CGPoint.self),
            "size".keyPath(forType: CGSize.self)
        ])
    }
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
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
    func keyPath(forType type: CoreAnimationKVCExtension.Type) -> [String] {
        return type.keyPaths(forName: self)
    }
}

private extension Array {
    init(union: [[Element]]) {
        self.init(union.reduce([Element](), { (elements, array) in return elements + array }))
    }
}

extension CALayer: CoreAnimationKVCExtension {
    
    class var animatableKeyPaths: [String] {
        return [String](union: [
            "contentsCenter".keyPath(forType: CGPoint.self),
            "contentsRect".keyPath(forType: CGRect.self),
            "opacity".keyPath(forType: CGFloat.self),
            "hidden".keyPath(forType: Bool.self),
            "bounds".keyPath(forType: CGRect.self),
            "masksToBounds".keyPath(forType: Bool.self),
            "doubleSided".keyPath(forType: Bool.self),
            "cornerRadius".keyPath(forType: CGFloat.self),
            "borderWidth".keyPath(forType: CGFloat.self),
            "borderColor".keyPath(forType: CGColor.self),
            "backgroundColor".keyPath(forType: CGColor.self),
            "shadowOffset".keyPath(forType: CGSize.self),
            "shadowOpacity".keyPath(forType: CGFloat.self),
            "shadowRadius".keyPath(forType: CGFloat.self),
            "shadowColor".keyPath(forType: CGColor.self),
            "shadowPath".keyPath(forType: CGPath.self),
            "position".keyPath(forType: CGPoint.self),
            "zPosition".keyPath(forType: CGFloat.self),
            "anchorPoint".keyPath(forType: CGPoint.self),
            "anchorPointZ".keyPath(forType: CGFloat.self),
            "transform".keyPath(forType: CATransform3D.self),
            "sublayerTransform".keyPath(forType: CATransform3D.self)
        ])
    }
    
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
    
    var stateLayer: CALayer {
        return presentation() ?? self
    }
    
}

extension CAEmitterCell: CoreAnimationKVCExtension {
    class var animatableKeyPaths: [String] {
        return [String](union: [
            "birthRate".keyPath(forType: Float.self),
            "lifetime".keyPath(forType: Float.self),
            "lifetimeRange".keyPath(forType: Float.self),
            "emissionLatitude".keyPath(forType: CGFloat.self),
            "emissionLongitude".keyPath(forType: CGFloat.self),
            "emissionRange".keyPath(forType: CGFloat.self),
            "velocity".keyPath(forType: CGFloat.self),
            "velocityRange".keyPath(forType: CGFloat.self),
            "xAcceleration".keyPath(forType: CGFloat.self),
            "yAcceleration".keyPath(forType: CGFloat.self),
            "zAcceleration".keyPath(forType: CGFloat.self),
            "scale".keyPath(forType: CGFloat.self),
            "scaleRange".keyPath(forType: CGFloat.self),
            "scaleSpeed".keyPath(forType: CGFloat.self),
            "spin".keyPath(forType: CGFloat.self),
            "spinRange".keyPath(forType: CGFloat.self),
            "color".keyPath(forType: CGColor.self),
            "redRange".keyPath(forType: Float.self),
            "greenRange".keyPath(forType: Float.self),
            "blueRange".keyPath(forType: Float.self),
            "alphaRange".keyPath(forType: Float.self),
            "redSpeed".keyPath(forType: Float.self),
            "greenSpeed".keyPath(forType: Float.self),
            "blueSpeed".keyPath(forType: Float.self),
            "alphaSpeed".keyPath(forType: Float.self),
            "contentsRect".keyPath(forType: CGRect.self)
        ])
    }
    var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths;
    }
}

extension CAEmitterLayer {
    override class var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "birthRate".keyPath(forType: Float.self),
            "lifetime".keyPath(forType: Float.self),
            "emitterPosition".keyPath(forType: CGPoint.self),
            "emitterZPosition".keyPath(forType: CGFloat.self),
            "emitterSize".keyPath(forType: CGSize.self),
            "emitterDepth".keyPath(forType: CGFloat.self),
            "velocity".keyPath(forType: Float.self),
            "scale".keyPath(forType: Float.self),
            "spin".keyPath(forType: Float.self)
            ])
    }
    override var animatableKeyPaths: [String] {
        return type(of: self).animatableKeyPaths + [String](union: emitterCells?.filter({ $0.name != nil }).map({ (cell) -> [String] in
            return "emitterCells.\(cell.name!)".keyPath(forType: CAEmitterCell.self)
        }) ?? [])
    }
}

extension CAGradientLayer {
    override class var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "colors".keyPath(forType: CGColor.self),
            "locations".keyPath(forType: CGFloat.self),
            "startPoint".keyPath(forType: CGPoint.self),
            "endPoint".keyPath(forType: CGPoint.self)
        ])
    }
}

extension CAReplicatorLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "instanceCount".keyPath(forType: Int.self),
            "instanceDelay".keyPath(forType: CFTimeInterval.self),
            "instanceTransform".keyPath(forType: CATransform3D.self),
            "instanceColor".keyPath(forType: CGColor.self),
            "instanceRedOffset".keyPath(forType: Float.self),
            "instanceGreenOffset".keyPath(forType: Float.self),
            "instanceBlueOffset".keyPath(forType: Float.self),
            "instanceAlphaOffset".keyPath(forType: Float.self)
        ])
    }
}

extension CAShapeLayer {
    override var animatableKeyPaths: [String] {
        return super.animatableKeyPaths + [String](union: [
            "path".keyPath(forType: CGPath.self),
            "fillColor".keyPath(forType: CGColor.self),
            "strokeColor".keyPath(forType: CGColor.self),
            "strokeStart".keyPath(forType: CGFloat.self),
            "strokeEnd".keyPath(forType: CGFloat.self),
            "lineWidth".keyPath(forType: CGFloat.self),
            "miterLimit".keyPath(forType: CGFloat.self),
            "lineDashPhase".keyPath(forType: CGFloat.self)
        ])
    }
}
