//
//  StringHelprt.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation

extension String {
    
    public var allRange: NSRange {
        return NSMakeRange(0, self.count)
    }
    
    public func jsonValue() -> Any? {
        if let data = self.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            return json
        }
        return nil
    }
}
