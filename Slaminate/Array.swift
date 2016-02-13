//
//  Array.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 12/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

extension Array {
    
    func some(filter: Element -> Bool) -> Bool {
        for element in self {
            if filter(element) {
                return true
            }
        }
        return false
    }
    
    func all(filter: Element -> Bool) -> Bool {
        if self.count == 0 { return false }
        var ret = true
        for element in self {
            ret = ret && filter(element)
        }
        return ret
    }
    
}