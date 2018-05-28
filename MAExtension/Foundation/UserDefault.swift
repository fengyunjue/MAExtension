//
//  UserDefault.swift
//  KF5SDKSwift
//
//  Created by admin on 17/4/12.
//  Copyright © 2017年 kf5. All rights reserved.
//

import Foundation

//extension UserDefaults {
//
//    static let email = UserDefaultDataType<String>.init(key: "email")
//    static let cookie = UserDefaultDataType<Data>.init(key: "cookie")
//
//}
public struct UserDefaultDataType<E> {
    
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
    
    public var value: E? {
        return UserDefaults.standard.value(forKey: namespace(key)) as? E
    }
    
    public func set(_ value: E?) {
        UserDefaults.standard.set(value, forKey: namespace(key))
    }
    
    public func remove() {
        UserDefaults.standard.removeObject(forKey: namespace(key))
    }
    
    
    private func namespace(_ key: String) -> String {
        return "\(E.self).\(key)"
    }
}




