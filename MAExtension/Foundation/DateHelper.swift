//
//  DateHelper.swift
//  KF5Swift
//
//  Created by admin on 17/5/31.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation

fileprivate var shareFormat = DateFormatter()

extension TimeInterval {
    
    public func dateString(_ dateFormat: String = "") -> String {
        if dateFormat.count == 0 {
            return Date.init(timeIntervalSince1970: self).defaultString
        } else {
            shareFormat.dateFormat = dateFormat
            return shareFormat.string(from: Date.init(timeIntervalSince1970: self))
        }
    }
}

extension Date {
    public func dateString(_ dateFormat: String = "") -> String {
        if dateFormat.count == 0 {
            return self.defaultString
        } else {
            shareFormat.dateFormat = dateFormat
            return shareFormat.string(from: self)
        }
    }
    public var defaultString: String {
        shareFormat.dateFormat = "yyyy年MM月dd日 HH:MM"
        return shareFormat.string(from: self)
    }
    
    public var chatString: String {
        
        if self.isToyear {// 是不是今年
            if self.isToday {// 是不是今天
                shareFormat.dateFormat = "HH:mm"
            }else if self.isYesterday {// 昨天发的
                shareFormat.dateFormat = "昨天 HH:mm"
            }else{// 其他时间发的
                shareFormat.dateFormat = "MM月dd HH:MM"
            }
        }else{// 不是今年
            shareFormat.dateFormat = "yyyy年MM月dd HH:MM"
        }
        return shareFormat.string(from: self)
    }
    
    public var isToday: Bool {
        let compoments = (Calendar.current as NSCalendar) .components([.year,.month,.day], from: self, to: Date(), options: [])
        return compoments.year == 0 && compoments.month == 0 && compoments.day == 0
    }
    
    public var isYesterday: Bool {
        let compoments = (Calendar.current as NSCalendar) .components([.year,.month,.day], from: self, to: Date(), options: [])
        return compoments.year == 0 && compoments.month == 0 && compoments.day == 1
    }
    
    public var isToyear: Bool{
        let compoments = (Calendar.current as NSCalendar) .components([.year], from: self, to: Date(), options: [])
        return compoments.year == 0
    }
    
}
