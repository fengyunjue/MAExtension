//
//  UIImageHelper.swift
//  KF5SDKSwift
//
//  Created by admin on 17/1/9.
//  Copyright © 2017年 kf5. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 图片改变颜色
    public func changeColor(_ color: UIColor) -> UIImage?{
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.clip(to: rect, mask: cgImage)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let imgcgImage = img?.cgImage else {
            return nil
        }
        
        return UIImage.init(cgImage: imgcgImage, scale: UIScreen.main.scale, orientation: UIImageOrientation.downMirrored)
    }
    
    /// 图片旋转方向
    public func rotation(forRotate rotate: UIImageOrientation) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        return UIImage.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: rotate)
    }
    
    /// 剪切圆形图片
    public func ellipseImage() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect.init(origin: CGPoint.zero, size: self.size)
        ctx?.addEllipse(in: rect)
        ctx?.clip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
