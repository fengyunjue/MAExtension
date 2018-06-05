//
//  Convertible.swift
//  KF5Swift
//
//  Created by admin on 2017/8/3.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var isNull: Bool {
        return self.type == .null
    }
}

public protocol Convertible{
    init(_ json: JSON?)
}

extension Convertible {
    public init() {
        self.init(nil)
    }
}

public protocol Mapable: Convertible {
    static func modelArray(_ json: JSON?) -> Array<Self>
}

infix operator <-

public func <- <T: Equatable>(left: inout T?, right: (String?, (String)-> T?)) {
    left = right.0 != nil ? right.1(right.0!) : nil
}

public func <- <T: SignedInteger>(left: inout T, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = T.init(right.int64Value)
}

public func <- <T: UnsignedInteger>(left: inout T, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = T.init(right.uInt64Value)
}

public func <- (left: inout Double, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.doubleValue
}

public func <- (left: inout Float, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.floatValue
}

public func <- (left: inout NSNumber, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.numberValue
}

public func <- (left: inout String, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.stringValue
}

public func <- (left: inout [String: SwiftyJSON.JSON], right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.dictionaryValue
}

public func <- (left: inout [JSON], right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.arrayValue
}

public func <- (left: inout URL, right: SwiftyJSON.JSON?) {
    guard let url = right?.url else { return }
    left = url
}

// MARK: - Optional
public func <- <T: SignedInteger>(left: inout T?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = T.init(right.int64Value)
}

public func <- <T: UnsignedInteger>(left: inout T?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = T.init(right.uInt64Value)
}

public func <- (left: inout Double?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.doubleValue
}

public func <- (left: inout Float?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.floatValue
}

public func <- (left: inout NSNumber?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.numberValue
}

public func <- (left: inout String?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.stringValue
}

public func <- (left: inout [String: SwiftyJSON.JSON]?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.dictionaryValue
}

public func <- (left: inout [JSON]?, right: SwiftyJSON.JSON?) {
    guard let right = right, !right.isNull else { return }
    left = right.arrayValue
}

public func <- (left: inout URL?, right: SwiftyJSON.JSON?) {
    guard let url = right?.url else { return }
    left = url
}
