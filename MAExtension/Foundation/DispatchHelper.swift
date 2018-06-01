//
//  DispatchHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation

// MARK: - DispatchQueue拓展after和once
public extension DispatchQueue {
    
    /// dispatch_after
    public class func after(queue: DispatchQueue? = nil, after: TimeInterval, block: @escaping ()->Void) {
        if let queue = queue {
            queue.asyncAfter(deadline: DispatchTime.now() + after, execute: block)
        }else{
            self.main.asyncAfter(deadline: DispatchTime.now() + after, execute: block)
        }
    }
    
    /// dispatch_once
    /// DispatchQueue.global().async {
    /// struct xixi { static var hehe: Bool = false }
    /// DispatchQueue.once(&xixi.hehe, {
    /// print("hehe")
    /// })
    /// }
    public class func once(_ token: inout Bool, _ block: ()->Void) {
        
        if token == false {
            objc_sync_enter(token)
            if token == false {
                block()
                token = true
            }
            objc_sync_exit(token)
        }
    }
}
