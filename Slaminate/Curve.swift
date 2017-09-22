//
//  Curve.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

public typealias CurveTransform = ((Double) -> Double)

open class Curve : NSObject {
    
    open let transform: CurveTransform
    
    open static let linear = Curve(transform: { $0 }).guarded
    open static let boolean = Curve(transform: { ($0 < 0.5 ? 0.0 : 1.0) }).guarded
    open static let reversed = Curve(transform: { 1.0 - $0 }).guarded
    
    open static let easeIn = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseIn).guarded
    open static let easeOut = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseOut).guarded
    open static let easeInOut = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut).guarded
    open static let easeDefault = Curve(mediaTimingFunction: kCAMediaTimingFunctionDefault).guarded
    
    open static let easeInQuad = Curve(transform: { pow($0, 2) }).guarded
    open static let easeOutQuad = Curve(transform: { Double(-1.0) * $0 * Double($0 - 2.0) }).guarded
    open static let easeInOutQuad = easeInQuad | easeOutQuad.guarded
    
    open static let easeInCubic = Curve(transform: { pow($0, 3.0) }).guarded
    open static let easeOutCubic = Curve(transform: { pow($0 - 1.0, 3.0) + 1.0 }).guarded
    open static let easeInOutCubic = easeInCubic | easeOutCubic
    
    open static let easeInQuart = Curve(transform: { pow($0, 4.0) }).guarded
    open static let easeOutQuart = Curve(transform: { -1.0 * (pow($0 - 1.0, 4.0) - 1.0) }).guarded
    open static let easeInOutQuart = easeInQuart | easeOutQuart
    
    open static let easeInQuint = Curve(transform: { pow($0, 5.0) }).guarded
    open static let easeOutQuint = Curve(transform: { 1.0 * (pow($0 - 1.0, 5.0) + 1.0) }).guarded
    open static let easeInOutQuint = easeInQuint | easeOutQuint
    
    open static let easeInSine = Curve(transform: { (-1.0 * cos($0 * .pi / 2) + 1.0) }).guarded
    open static let easeOutSine = Curve(transform: { sin($0 * .pi / 2) }).guarded
    open static let easeInOutSine = Curve(transform: { (-0.5 * cos(.pi * $0) + 0.5) }).guarded
    
    open static let easeInExpo = Curve(transform: { ($0 == 0.0 ? 0.0 : pow(2.0, 10.0 * ($0 - 1.0))) }).guarded
    open static let easeOutExpo = Curve(transform: { -pow(2.0, -10.0 * $0) + 1.0 }).guarded
    open static let easeInOutExpo = easeInExpo | easeOutExpo
    
    open static let easeInCirc = Curve(transform: { -1.0 * (sqrt(1.0 - pow($0, 2.0)) - 1.0) }).guarded
    open static let easeOutCirc = Curve(transform: { sqrt(1.0 - pow($0 - 1.0, 2.0)) }).guarded
    open static let easeInOutCirc = easeInCirc | easeOutCirc
    
    open static let easeInElastic = Curve(transform: {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if a < 1.0 {
            a = 1.0
            s = p / 4.0
        } else {
            s = p / (2.0 * .pi) * asin(1.0 / a)
        }
        
        return -(a * pow(2.0, 10.0 * ($0 - 1.0)) * sin((($0 - 1.0) - s) * (2.0 * .pi) / p))
        
    }).guarded
    open static let easeOutElastic = Curve(transform: {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if a < 1.0 {
            a = 1.0
            s = p/4
        } else {
            s = p / (2.0 * .pi) * asin(1.0 / a)
        }
        
        return a * pow(2.0, -10.0 * $0) * sin(($0 - s) * (2 * .pi) / p) + 1.0
        
    }).guarded
    open static let easeInOutElastic = Curve(transform: {
        
        var s = 1.70158
        var p = 0.3 * 1.5
        var a = 1.0
        
        var t = $0 / 0.5
        
        if a < 1.0 {
            a = 1.0
            s = p / 4.0
        } else {
            s = p / (2.0 * .pi) * asin (1.0 / a)
        }
        
        if t < 1 {
            t -= 1.0
            return -0.5 * (a * pow(2.0,10.0 * t) * sin((t - s) * (2.0 * .pi) / p))
        }
        
        t -= 1.0
        
        return a * pow(2.0, -10.0 * t) * sin((t - s) * (2.0 * .pi) / p) * 0.5 + 1.0
        
    }).guarded
    
    open static let easeInBack = Curve(transform: { $0 * $0 * (Double(2.70158) * $0 - Double(1.70158)) }).guarded
    open static var easeOutBack = Curve(transform: {
        let s = 1.70158
        let s2 = 2.70158
        let n = $0 - 1.0;
        return n * n * (s2 * n + s) + 1.0
    }).guarded
    open static let easeInOutBack = easeInBack | easeOutBack
    
    open static let easeInBounce = Curve(transform: { 1.0 - easeOutBounce.transform(1.0 - $0) }).guarded
    open static let easeOutBounce = Curve(transform: {
        
        var r = 0.0
        
        var t = $0
        
        if t < (1/2.75) {
            r = 7.5625 * t * t
        } else if t < 2.0 / 2.75 {
            t -= 1.5 / 2.75;
            r = 7.5625 * t * t + 0.75
        } else if t < 2.5 / 2.75 {
            t -= 2.25 / 2.75;
            r = 7.5625 * t * t + 0.9375;
        } else {
            t -= 2.625 / 2.75;
            r = 7.5625 * t * t + 0.984375;
        }
        
        return r;
    }).guarded
    open static let easeInOutBounce = easeInBounce | easeOutBounce
    
    public init(transform: @escaping CurveTransform) {
        self.transform = transform
        super.init()
    }
    
    open func or(curve: Curve) -> Curve {
        let linear = Curve.linear
        return Curve(transform: {
            return self.delta(curve: linear).transform($0) + curve.delta(curve: linear).transform($0) + linear.transform($0)
        })
    }
    
    open func multiply(curve: Curve) -> Curve {
        return Curve(transform: { return curve.transform(self.transform($0)) })
    }
    
    open func add(curve: Curve) -> Curve {
        return Curve(transform: {
            if ($0 < 0.5) { return self.transform($0 * 2.0) / 2.0}
            return curve.transform(($0 - 0.5) * 2.0) / 2.0 + 0.5
        })
    }
    
    open var guarded: Curve {
        return Curve(transform: {
            guard $0 > 0.0 && $0 < 1.0 else { return $0 <= 0.0 ? 0.0 : 1.0 }
            return self.transform($0)
        })
    }
    
    open var reversed: Curve {
        return Curve(transform: {
            return 1.0 - self.transform(1.0 - $0)
        })
    }
    
    public func delta(curve: Curve) -> Curve {
        return Curve(transform: {
            return self.transform($0) - curve.transform($0)
        })
    }
    
}

private let cp0 = CGPoint(x: 0.0, y: 0.0)
private let cp3 = CGPoint(x: 1.0, y: 1.0)

extension Curve {
    
    fileprivate static func evaluateAtParameterWithCoefficients(_ t: CGFloat, coefficients: [CGFloat]) -> CGFloat {
        return coefficients[0] + t * coefficients[1] + t * t * coefficients[2] + t * t * t * coefficients[3]
    }
    
    fileprivate static func evaluateDerivationAtParameterWithCoefficients(_ t: CGFloat, coefficients: [CGFloat]) -> CGFloat {
        return coefficients[1] + 2 * t * coefficients[2] + 3 * t * t * coefficients[3]
    }
    
    fileprivate static func calcParameterViaNewtonRaphsonUsingXAndCoefficientsForX(_ x: CGFloat, coefficientX: [CGFloat]) -> CGFloat {
        
        var t: CGFloat = x
        for _ in 0..<10 {
            let x2 = evaluateAtParameterWithCoefficients(t, coefficients: coefficientX) - x
            let d = evaluateDerivationAtParameterWithCoefficients(t, coefficients: coefficientX)
            let dt = x2 / d
            t -= dt
        }
        return !t.isNaN ? t : 1.0
    }
    
    public convenience init(cp1: CGPoint, cp2: CGPoint) {
        let coefficientsX = [
            cp0.x,
            -3.0 * cp0.x + 3.0 * cp1.x,
            3.0 * cp0.x - 6.0 * cp1.x + 3.0 * cp2.x,
            -cp0.x + 3.0 * cp1.x - 3.0 * cp2.x + cp3.x
        ]
        let coefficientsY = [
            cp0.y,
            -3.0 * cp0.y + 3.0 * cp1.y,
            3.0 * cp0.y - 6.0 * cp1.y + 3.0 * cp2.y,
            -cp0.y + 3.0 * cp1.y - 3.0 * cp2.y + cp3.y
        ]
        self.init(transform: { position in
            let t = Curve.calcParameterViaNewtonRaphsonUsingXAndCoefficientsForX(CGFloat(position), coefficientX: coefficientsX);
            return Double(Curve.evaluateAtParameterWithCoefficients(t, coefficients: coefficientsY))
        })
    }
    
    public convenience init(mediaTimingFunction: String) {
        switch mediaTimingFunction {
        case kCAMediaTimingFunctionDefault:
            self.init(cp1: CGPoint(x: 0.25, y: 0.1), cp2: CGPoint(x: 0.25, y: 1.0))
        case kCAMediaTimingFunctionEaseIn:
            self.init(cp1: CGPoint(x: 0.42, y: 0.0), cp2: CGPoint(x: 1.0, y: 1.0))
        case kCAMediaTimingFunctionEaseOut:
            self.init(cp1: CGPoint(x: 0.0, y: 0.0), cp2: CGPoint(x: 0.58, y: 1.0))
        case kCAMediaTimingFunctionEaseInEaseOut:
            self.init(cp1: CGPoint(x: 0.42, y: 0.0), cp2: CGPoint(x: 1.0, y: 1.0))
        default:
            self.init(transform: { $0 })
        }
    }
    
    public convenience init(viewAnimationCurve: UIViewAnimationCurve) {
        switch viewAnimationCurve {
        case .linear:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionLinear)
        case .easeIn:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseIn)
        case .easeOut:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseOut)
        case .easeInOut:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
        }
    }
    
}
