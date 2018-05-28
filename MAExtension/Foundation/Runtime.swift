//
//  Runtime.swift
//  KF5Swift
//
//  Created by admin on 17/6/7.
//  Copyright © 2017年 ma. All rights reserved.
//

import UIKit


/// 代替initialize `protocol`
/// 例如:
/// extension UIButton:SelfAware{
///     public static func awake() {
///         /* coding */
///     }
/// }
public protocol SelfAware: class {
    static func awake()
}

// MARK: - 执行SelfAware代理的awake()
extension UIApplication {
    //使用静态属性以保证只调用一次(该属性是个方法)
    private static let runOnce:Void = {
        let typeCount = Int(objc_getClassList(nil, 0))
        let  types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount)) //获取所有的类
        for index in 0 ..< typeCount{
            (types[index] as? SelfAware.Type)?.awake() //如果该类实现了SelfAware协议，那么调用awake方法
        }
        types.deallocate()
    }()
    
    open override var next: UIResponder?{
        UIApplication.runOnce
        return super.next
    }
}


// MARK: - Runtime方法交换
extension NSObject {
    
    /// 交换对象方法
    ///
    /// - Parameters:
    ///   - originalSelector: 原方法
    ///   - swizzledSelector: 替换方法
    /// - Returns: 是否替换成功
    /// - Warning: Swift需要在要替换的方法前添加dynamic关键字
    public static func swizzleMethod(originalSelector:Selector, swizzledSelector:Selector) -> Bool{
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        if (originalMethod != nil) && (swizzledMethod != nil) {
            
            if class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!);
            }
            return true
        }
        return false
    }
    /// 交换类方法
    ///
    /// - Parameters:
    ///   - originalSelector: 原方法
    ///   - swizzledSelector: 替换方法
    /// - Returns: 是否替换成功
    /// - Warning: Swift需要在要替换的方法前添加dynamic关键字
    public static func swizzleClassMethod(originalSelector:Selector, swizzledSelector:Selector) -> Bool {
        return self.swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }
}


