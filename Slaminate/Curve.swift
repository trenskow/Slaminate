//
//  Curve.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

public typealias CurveBlock = (Double -> Double)

private func genericEaseInOut(inCurve: Curve, _ outCurve: Curve) -> Curve {
    return Curve(block: {
        if ($0 < 0.5) { return inCurve.block($0 * 2.0) / 2.0 }
        return outCurve.block($0 - 0.5 * 2.0) / 2.0 + 0.5
    })
}

public class Curve : NSObject {
    
    internal let block: CurveBlock
    
    public static let boolean = Curve(block: { ($0 < 0.5 ? 0.0 : 1.0) })
    
    public static let linear = Curve(block: { $0 } )
    
    public static let easeInQuad = Curve(block: { pow($0, 2) });
    public static let easeOutQuad = Curve { -1.0 * $0 * ($0 - 2.0) }
    public static let easeInOutQuad = genericEaseInOut(easeInQuad, easeOutQuad)
    
    public static let easeInCubic = Curve { pow($0, 3.0) }
    public static let easeOutCubic = Curve { pow($0 - 1.0, 3.0) + 1.0 }
    public static let easeInOutCubic = genericEaseInOut(easeInCubic, easeOutCubic)
    
    public init(block: CurveBlock) {
        self.block = block;
        super.init()
    }
    
    public func add(curve: Curve) -> Curve {
        return Curve(block: { curve.block(self.block($0)) } )
    }
    
}

public func +(lhs: Curve, rhs: Curve) -> Curve {
    return Curve(block: {
        return lhs.block(rhs.block($0))
    })
}
