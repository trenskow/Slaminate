//
//  PropertyInfo.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 08/02/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

import Foundation

protocol PropertyInfoProtocol: Equatable, Hashable {
    weak var object: NSObject? { get set }
    var key: String { get set }
    var fromValue: NSObject? { get set }
    var toValue: NSObject? { get set }
    func applyFromValue()
    func applyToValue()
    init(object: NSObject, key: String)
}

extension PropertyInfoProtocol {
    func applyFromValue() {
        object?.setValue(fromValue, forKey: key)
    }
    func applyToValue() {
        object?.setValue(toValue, forKey: key)
    }
    var hashValue: Int {
        return (object?.hashValue ?? 0) + key.hashValue
    }
}

func ==<T: PropertyInfoProtocol>(lhs: T, rhs: T) -> Bool {
    return lhs.object == rhs.object && lhs.key == rhs.key
}

func ==<T: PropertyInfoProtocol>(lhs: T, rhs: (NSObject, String)) -> Bool {
    return lhs.object == rhs.0 && lhs.key == rhs.1
}

struct PropertyInfo: PropertyInfoProtocol {
    weak var object: NSObject?
    var key: String
    var fromValue: NSObject?
    var toValue: NSObject?
    init(object: NSObject, key: String) {
        self.object = object
        self.key = key
    }
}

extension Array where Element: PropertyInfoProtocol {
    mutating func indexOf(_ object: NSObject, key: String) -> Index {
        for index in self.indices {
            if self[index] == (object, key) {
                return index
            }
        }
        append(Element(object: object, key: key))
        return endIndex.advanced(by: -1)
    }
    func applyFromValues() {
        self.forEach({ $0.applyFromValue() })
    }
    func applyToValues() {
        self.forEach({ $0.applyToValue() })
    }
}
