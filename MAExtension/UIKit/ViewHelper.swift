//
//  ViewHelper.swift
//  KF5Swift
//
//  Created by admin on 17/6/12.
//  Copyright © 2017年 ma. All rights reserved.
//

import UIKit

extension UIResponder {
    public static var identifier: String {
        return String.init(self.description().split(separator: ".").last!)
    }
}

/// 正常的使用子类的class作为xib cell的类型,xib的identifier需要和xib的名称以及类名保持一致
public protocol XibViewCellable {
    static var identifier: String {get}
}
extension XibViewCellable {
    public static func register(forTableView tableView: UITableView) {
        tableView.register(UINib.init(nibName: Self.identifier, bundle: nil), forCellReuseIdentifier: Self.identifier)
    }
}

/// 将子类的Class添加进Xib的File's Owner,xib view的类型使用默认的
@IBDesignable public class XibView: UIView {
    
    @IBOutlet public var contentView: UIView!
    
    public func initFromXib(){
        let cls = type(of: self)
        let bundle = Bundle(for: cls)
        let nib = UINib.init(nibName: "\(cls)", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView {
            contentView = view
            contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromXib()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFromXib()
    }
}

// MARK: - 快捷方法
extension UIView {
    // MARK: - x,y,width,height
    public var ma_x: CGFloat {
        get { return self.frame.minX }
        set { var frame = self.frame;frame.origin.x = newValue;self.frame = frame }
    }
    public var ma_y: CGFloat {
        get { return self.frame.minY }
        set { var frame = self.frame; frame.origin.y = newValue; self.frame = frame }
    }
    public var ma_width: CGFloat {
        get { return self.frame.width }
        set { var frame = self.frame; frame.size.width = newValue; self.frame = frame }
    }
    public var ma_height: CGFloat {
        get { return self.frame.height}
        set { var frame = self.frame; frame.size.height = newValue; self.frame = frame }
    }

    // MARK: - origin,size
    public var ma_origin: CGPoint {
        get { return self.frame.origin }
        set { var frame = self.frame; frame.origin = newValue; self.frame = frame }
    }
    public var ma_size: CGSize {
        get { return self.frame.size }
        set { var frame = self.frame; frame.size = newValue; self.frame = frame }
    }

    // MARK: - top,bottom,left,right,middleX,middleY
    public var ma_top: CGFloat {
        get { return self.ma_y }
        set { self.ma_y = newValue }
    }
    public var ma_bottom: CGFloat {
        get { return self.frame.maxY }
        set { var frame = self.frame; frame.origin.y = newValue - frame.height; self.frame = frame }
    }
    public var ma_left: CGFloat {
        get { return self.ma_x }
        set { self.ma_x = newValue }
    }
    public var ma_right: CGFloat {
        get { return self.frame.maxX }
        set { var frame = self.frame; frame.origin.x = newValue - frame.width; self.frame = frame }
    }
    public var ma_middleX: CGFloat {
        get { return self.frame.midX }
        set { var frame = self.frame; frame.origin.x = newValue - frame.width / 2; self.frame = frame }
    }
    public var ma_middleY: CGFloat {
        get { return self.frame.midY }
        set { var frame = self.frame; frame.origin.y = newValue - frame.height / 2; self.frame = frame }
    }
}
