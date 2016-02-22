//
//  Curve.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

public typealias CurveBlock = (Double -> Double)

public func +(lhs: Curve, rhs: Curve) -> Curve {
    return lhs.add(rhs)
}

private func combineInOut(inCurve: Curve, _ outCurve: Curve) -> Curve {
    return Curve(block: {
        if ($0 < 0.5) { return inCurve.block($0 * 2.0) / 2.0}
        return outCurve.block(($0 - 0.5) * 2.0) / 2.0 + 0.5
    })
}

@objc(SLACurve)
public class Curve : NSObject {
    
    let block: CurveBlock
    
    public static let boolean = Curve(guardedBlock: { ($0 < 0.5 ? 0.0 : 1.0) })
    public static let reversed = Curve(guardedBlock: { 1.0 - $0 })
    
    public static let linear = Curve(guardedBlock: { $0 } )
    
    public static let easeIn = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseIn)
    public static let easeOut = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseOut)
    public static let easeInOut = Curve(mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
    public static let easeDefault = Curve(mediaTimingFunction: kCAMediaTimingFunctionDefault)
    
    public static let easeInQuad = Curve(guardedBlock: { pow($0, 2) });
    public static let easeOutQuad = Curve(guardedBlock: { -1.0 * $0 * ($0 - 2.0) })
    public static let easeInOutQuad = combineInOut(easeInQuad, easeOutQuad)
    
    public static let easeInCubic = Curve(guardedBlock: { pow($0, 3.0) })
    public static let easeOutCubic = Curve(guardedBlock: { pow($0 - 1.0, 3.0) + 1.0 })
    public static let easeInOutCubic = combineInOut(easeInCubic, easeOutCubic)
    
    public static let easeInQuart = Curve(guardedBlock: { pow($0, 4.0) })
    public static let easeOutQuart = Curve(guardedBlock: { -1.0 * (pow($0 - 1.0, 4.0) - 1.0) })
    public static let easeInOutQuart = combineInOut(easeInQuart, easeOutQuart)
    
    public static let easeInQuint = Curve(guardedBlock: { pow($0, 5.0) })
    public static let easeOutQuint = Curve(guardedBlock: { 1.0 * (pow($0 - 1.0, 5.0) + 1.0) })
    public static let easeInOutQuint = combineInOut(easeInQuint, easeOutQuint)
    
    public static let easeInSine = Curve(guardedBlock:{ (-1.0 * cos($0 * M_PI_2) + 1.0) })
    public static let easeOutSine = Curve(guardedBlock:{ sin($0 * M_PI_2) })
    public static let easeInOutSine = Curve(guardedBlock:{ (-0.5 * cos(M_PI * $0) + 0.5) })
    
    public static let easeInExpo = Curve(guardedBlock: { ($0 == 0.0 ? 0.0 : pow(2.0, 10.0 * ($0 - 1.0))) })
    public static let easeOutExpo = Curve(guardedBlock: { -pow(2.0, -10.0 * $0) + 1.0 })
    public static let easeInOutExpo = combineInOut(easeInExpo, easeOutExpo)
    
    public static let easeInCirc = Curve(guardedBlock: { -1.0 * (sqrt(1.0 - pow($0, 2.0)) - 1.0) })
    public static let easeOutCirc = Curve(guardedBlock: { sqrt(1.0 - pow($0 - 1.0, 2.0)) })
    public static let easeInOutCirc = combineInOut(easeInCirc, easeOutCirc)
    
    public static let easeInElastic = Curve(guardedBlock: {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if a < 1.0 {
            a = 1.0
            s = p / 4.0
        } else {
            s = p / (2.0 * M_PI) * asin(1.0 / a)
        }
        
        return -(a * pow(2.0, 10.0 * ($0 - 1.0)) * sin((($0 - 1.0) - s) * (2.0 * M_PI) / p))
        
    })
    public static let easeOutElastic = Curve(guardedBlock: {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if a < 1.0 {
            a = 1.0
            s = p/4
        } else {
            s = p / (2.0 * M_PI) * asin(1.0 / a)
        }
        
        return a * pow(2.0, -10.0 * $0) * sin(($0 - s) * (2 * M_PI) / p) + 1.0
        
    })
    public static let easeInOutElastic = Curve(guardedBlock: {
        
        var s = 1.70158
        var p = 0.3 * 1.5
        var a = 1.0
        
        var t = $0 / 0.5
        
        if a < 1.0 {
            a = 1.0
            s = p / 4.0
        } else {
            s = p / (2.0 * M_PI) * asin (1.0 / a)
        }
        
        if t < 1 {
            t -= 1.0
            return -0.5 * (a * pow(2.0,10.0 * t) * sin((t - s) * (2.0 * M_PI) / p))
        }
        
        t -= 1.0
        
        return a * pow(2.0, -10.0 * t) * sin((t - s) * (2.0 * M_PI) / p) * 0.5 + 1.0
        
    })
    
    public static let easeInBack = Curve(guardedBlock: { $0 * $0 * (2.70158 * $0 - 1.70158) })
    public static let easeOutBack = Curve(guardedBlock: { ($0 - 1.0) * ($0 - 1.0) * (2.70158 * ($0 - 1.0) + 1.70158) + 1.0 })
    public static let easeInOutBack = combineInOut(easeInBack, easeOutBack)
    
    public static let easeInBounce = Curve(guardedBlock: { 1.0 - easeOutBounce.block(1.0 - $0) })
    public static let easeOutBounce = Curve(guardedBlock: {
        
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
    })
    public static let easeInOutBounce = combineInOut(easeInBounce, easeOutBounce)
    
    public init(block: CurveBlock) {
        self.block = block;
        super.init()
    }
    
    private convenience init(guardedBlock: CurveBlock) {
        self.init(block: {
            guard $0 > 0.0 && $0 < 1.0 else { return $0 <= 0.0 ? 0.0 : 1.0 }
            return guardedBlock($0)
        })
    }
    
    public func add(curve: Curve) -> Curve {
        return Curve(block: { curve.block(self.block($0)) } )
    }
    
}

private let cp0 = CGPoint(x: 0.0, y: 0.0)
private let cp3 = CGPoint(x: 1.0, y: 1.0)

extension Curve {
    
    private static func evaluateAtParameterWithCoefficients(t: CGFloat, coefficients: [CGFloat]) -> CGFloat {
        return coefficients[0] + t * coefficients[1] + t * t * coefficients[2] + t * t * t * coefficients[3]
    }
    
    private static func evaluateDerivationAtParameterWithCoefficients(t: CGFloat, coefficients: [CGFloat]) -> CGFloat {
        return coefficients[1] + 2 * t * coefficients[2] + 3 * t * t * coefficients[3]
    }
    
    private static func calcParameterViaNewtonRaphsonUsingXAndCoefficientsForX(x: CGFloat, coefficientX: [CGFloat]) -> CGFloat {
        
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
        self.init(block: { position in
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
            self.init(block: { $0 })
        }
    }
    
    public convenience init(viewAnimationCurve: UIViewAnimationCurve) {
        switch viewAnimationCurve {
        case .Linear:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionLinear)
        case .EaseIn:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseIn)
        case .EaseOut:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseOut)
        case .EaseInOut:
            self.init(mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
        }
    }
    
}