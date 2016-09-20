//
//  UIView+Ancestor.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import UIKit

extension UIView {
    
    func commonAncestor(_ otherView: UIView) -> UIView? {
        var fromViewHierarchy = [UIView]()
        var fromView:UIView! = self
        repeat {
            fromViewHierarchy.append(fromView)
            fromView = fromView?.superview
        } while (fromView != nil)
        var toView:UIView! = otherView
        repeat {
            if let idx = fromViewHierarchy.index(of: toView) {
                return fromViewHierarchy[idx]
            }
            toView = toView.superview
        } while (toView != nil)
        return nil
    }
    
}
