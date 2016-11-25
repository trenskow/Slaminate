//
//  ConstraintPresenceInfo.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 10/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

protocol ConstraintPresenceInfoProtocol {
    var view: UIView { get }
    var constraint: NSLayoutConstraint { get }
    var added: Bool { get }
}

struct ConstraintPresenceInfo: ConstraintPresenceInfoProtocol {
    var view: UIView
    var constraint: NSLayoutConstraint
    var added: Bool
}

extension Array where Element: ConstraintPresenceInfoProtocol {
    
    func applyPresent(_ present: Bool) {
        var toRemove = [Element]()
        var toAdd = [Element]()
        for info in self {
            if info.added && !present || !info.added && present {
                toRemove.append(info)
            }
            if !info.added && !present || info.added && present {
                toAdd.append(info)
            }
        }
        for info in toRemove {
            info.view.removeConstraint(info.constraint)
        }
        for info in toAdd {
            info.view.addConstraint(info.constraint)
        }
    }
    
}
