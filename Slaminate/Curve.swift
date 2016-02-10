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

private func easeInOut(inCurve: Curve, _ outCurve: Curve) -> Curve {
    return Curve(block: {
        if ($0 < 0.5) { return inCurve.block($0 * 2.0) / 2.0}
        return outCurve.block(($0 - 0.5) * 2.0) / 2.0 + 0.5
    })
}

public class Curve : NSObject {
    
    internal let block: CurveBlock
    
    public static let boolean = Curve(block: { ($0 < 0.5 ? 0.0 : 1.0) })
    
    public static let linear = Curve(block: { $0 } )
    
    public static let easeInQuad = Curve(block: { pow($0, 2) });
    public static let easeOutQuad = Curve { -1.0 * $0 * ($0 - 2.0) }
    public static let easeInOutQuad = easeInOut(easeInQuad, easeOutQuad)
    
    public static let easeInCubic = Curve { pow($0, 3.0) }
    public static let easeOutCubic = Curve { pow($0 - 1.0, 3.0) + 1.0 }
    public static let easeInOutCubic = easeInOut(easeInCubic, easeOutCubic)
    
    public static let easeInQuart = Curve { pow($0, 4.0) }
    public static let easeOutQuart = Curve { -1.0 * (pow($0 - 1.0, 4.0) - 1.0) }
    public static let easeInOutQuart = easeInOut(easeInQuart, easeOutQuart)
    
    public static let easeInQuint = Curve { pow($0, 5.0) }
    public static let easeOutQuint = Curve { 1.0 * (pow($0 - 1.0, 5.0) + 1.0) }
    public static let easeInOutQuint = easeInOut(easeInQuint, easeOutQuint)
    
    public static let easeInSine = Curve { (-1.0 * cos($0 * M_PI_2) + 1.0) }
    public static let easeOutSine = Curve { sin($0 * M_PI_2) }
    public static let easeInOutSine = Curve { (-0.5 * cos(M_PI * $0) + 0.5) }
    
    public static let easeInExpo = Curve { ($0 == 0.0 ? 0.0 : pow(2.0, 10.0 * ($0 - 1.0))) }
    public static let easeOutExpo = Curve { -pow(2.0, -10.0 * $0) + 1.0 }
    public static let easeInOutExpo = easeInOut(easeInExpo, easeOutExpo)
    
    public static let easeInCirc = Curve { -1.0 * (sqrt(1.0 - pow($0, 2.0)) - 1.0) }
    public static let easeOutCirc = Curve { sqrt(1.0 - pow($0 - 1.0, 2.0)) }
    public static let easeInOutCirc = easeInOut(easeInCirc, easeOutCirc)
    
    public static let easeInElastic = Curve {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if $0 == 0.0 || $0 == 0.0 { return $0 }
        
        if a < 1.0 {
            a = 1.0
            s = p / 4.0
        } else {
            s = p / (2.0 * M_PI) * asin(1.0 / a)
        }
        
        return -(a * pow(2.0, 10.0 * ($0 - 1.0)) * sin((($0 - 1.0) - s) * (2.0 * M_PI) / p))
        
    }
    public static let easeOutElastic = Curve {
        
        var s = 1.70158
        var p = 0.3
        var a = 1.0
        
        if $0 == 0.0 || $0 == 1.0 { return $0 }
        
        if a < 1.0 {
            a = 1.0
            s = p/4
        } else {
            s = p / (2.0 * M_PI) * asin(1.0 / a)
        }
        
        return a * pow(2.0, -10.0 * $0) * sin(($0 - s) * (2 * M_PI) / p) + 1.0
        
    }
    public static let easeInOutElastic = Curve {
        
        var s = 1.70158
        var p = 0.3 * 1.5
        var a = 1.0
        
        if $0 == 0.0 || $0 == 1.0 { return $0 }
        
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
        
    }
    
    public static let easeInBack = Curve { $0 * $0 * (2.70158 * $0 - 1.70158) }
    public static let easeOutBack = Curve { ($0 - 1.0) * ($0 - 1.0) * (2.70158 * ($0 - 1.0) + 1.70158) + 1.0 }
    public static let easeInOutBack = easeInOut(easeInBack, easeOutBack)
    
    public static let easeInBounce = Curve(block: { 1.0 - easeOutBounce.block(1.0 - $0) })
    public static let easeOutBounce = Curve {
        
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
    }
    public static let easeInOutBounce = easeInOut(easeInBounce, easeOutBounce)
    
    public init(block: CurveBlock) {
        self.block = block;
        super.init()
    }
    
    public func add(curve: Curve) -> Curve {
        return Curve(block: { curve.block(self.block($0)) } )
    }
    
}

extension Curve {
    
    public convenience init(controlPoints: [CGPoint]) {
        assert(controlPoints.count > 1, "controlPoints must have at least two points.")
        self.init(block: { position in
            var points = controlPoints
            while points.count > 1 {
                var newPoints = [CGPoint]()
                for idx in 0..<points.count - 1 {
                    newPoints.append(
                        CGPoint(
                            x: points[idx].x.interpolate(points[idx+1].x, position) as! CGFloat,
                            y: points[idx].y.interpolate(points[idx+1].y, position) as! CGFloat
                        )
                    )
                }
                points = newPoints
            }
            return Double(points.first!.y)
        })
    }
    
    public convenience init(mediaTimingFunction: String) {
        switch mediaTimingFunction {
        case kCAMediaTimingFunctionDefault:
            self.init(controlPoints: [CGPoint(), CGPoint(x: 0.25, y: 0.0), CGPoint(x: 0.25, y: 1.0)])
        case kCAMediaTimingFunctionEaseIn:
            self.init(controlPoints: [CGPoint(), CGPoint(x: 0.42, y: 0.0), CGPoint(x: 1.0, y: 1.0)])
        case kCAMediaTimingFunctionEaseOut:
            self.init(controlPoints: [CGPoint(), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.58, y: 1.0)])
        case kCAMediaTimingFunctionEaseInEaseOut:
            self.init(controlPoints: [CGPoint(), CGPoint(x: 0.42, y: 0.0), CGPoint(x: 1.0, y: 1.0)])
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