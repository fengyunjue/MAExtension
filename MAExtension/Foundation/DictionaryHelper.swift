//
//  DictionaryHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation

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
}
