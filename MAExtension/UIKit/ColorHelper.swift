//
//  ColorHelper.swift
//  KF5Swift
//
//  Created by admin on 17/5/31.
//  Copyright © 2017年 ma. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public class func colorFromRGB(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public class func colorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public class func colorWithHexString(_ hexString: String) -> UIColor{
        var cString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cString.count < 6 {return UIColor.black}
        
        if cString.hasPrefix("0X")||cString.hasPrefix("0x") {cString = String(cString[cString.index(cString.startIndex, offsetBy: 2)...])}
        if cString.hasPrefix("#") {cString = String(cString[cString.index(cString.startIndex, offsetBy: 1)...])}
        if cString.count != 6 {return UIColor.black}
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
    }
}
