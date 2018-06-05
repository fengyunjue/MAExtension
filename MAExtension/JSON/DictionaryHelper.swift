//
//  DictionaryHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation
import SwiftyJSON

extension Dictionary{
    /// Dictionary.init(json["xxx"].arrayValue.map{($0["xxx"].intValue, $0)})
    public init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    public mutating func setValue(_ value: Value?, forKey key: Key){
        if let value = value {
            updateValue(value, forKey: key)
        }
    }
    /// 包含
    public func isSub(of dict: Dictionary) -> Bool {
        let selfJSON = JSON.init(self)
        let dictJSON = JSON.init(dict)
        var isSub = true
        for (key,value) in selfJSON.dictionaryValue {
            isSub = dictJSON[key] == value
            if isSub == false {break}
        }
        return isSub
    }
    /// 严格包含
    public func isStrictSub(of dict: Dictionary) -> Bool {
        return  (self as NSDictionary != dict as NSDictionary) && self.isSub(of: dict)
    }
    /// 超集
    public func isSuper(of dict: Dictionary) -> Bool {
        return dict.isSub(of: self)
    }
    /// 严格超集
    public func isStrictSuper(of dict: Dictionary) -> Bool {
        return dict.isStrictSub(of: self)
    }
}
