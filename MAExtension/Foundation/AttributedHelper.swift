//
//  AttributedHelper.swift
//  KF5Swift
//
//  Created by admin on 2017/7/21.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation

public class MATextAttachment : NSTextAttachment {
    
    init(image: UIImage?) {
        super.init(data: nil, ofType: nil)
        self.image = image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect.init(x: 0, y: -3, width: lineFrag.size.width, height: lineFrag.size.height)
    }
}

extension NSAttributedStringKey {
    public static let highlight: NSAttributedStringKey = NSAttributedStringKey.init("HighlightLinkAttributeName") // Dictionary<String,Any>
}
//import YYKit

// MARK: - 匹配文本
public struct Regular {
    public static let http = try! NSRegularExpression.init(pattern: "([hH]ttp[s]{0,1})://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\-~!@#$%^&*+?:_/=<>.\',;]*)?", options: [])
    public static let emoji = try! NSRegularExpression.init(pattern: "\\[[^ \\[\\]]+?\\]", options: [])
    public static let phone = try! NSRegularExpression.init(pattern: "1[0-9]{10}", options: [])
    
    // emoji对应的字典 name:path
    public static var emojiDict: [String: String]? = nil
}
// MARK: - 匹配标签
extension Regular {
    
    /// a链接
    public static let atag = try! NSRegularExpression.init(pattern: "<a.*?href\\s*=\\s*\"(.*?)\".*?>(.*?)</a>", options: [])
    /// 图片
    public static let img = try! NSRegularExpression.init(pattern: "<img.*?src\\s*=\\s*\"(.*?)\".*?/>", options: [])
    /// label标签
    public static let label = try! NSRegularExpression.init(pattern: "<[^>]*>", options: [])
    /// 两个以上的换行符
    public static let line = try! NSRegularExpression.init(pattern: "(^\n+|\n+$)|(\n{2,})", options: [])
}

public enum AttributedType: String {
    case url
    case phone
    case image
    
    public static func userInfo(_ userInfo: [AnyHashable : Any]) -> (AttributedType, String)? {
        guard let typeStr = userInfo["type"] as? String,  let type = AttributedType(rawValue: typeStr), let info = userInfo["info"] as? String else {
            return nil
        }
        return (type, info)
    }
}

// MARK: - 辅助内容
extension NSAttributedString {

    /// 制作带图片的文本
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - text: 文字
    ///   - font: 字体
    ///   - textColor: 颜色
    ///   - spacing: 图文之间的间距，默认10
    public static func icon(WithImage image: UIImage?, text: String, font: UIFont, textColor: UIColor, spacing: CGFloat = 10) -> NSMutableAttributedString? {
        if text.count == 0 { return nil }
        let attribute = baseAttributed(text, font: font, color: textColor)
        if let image = image {
            attribute.insert(NSAttributedString.init(attachment: MATextAttachment.init(image: image)), at: 0)
        }
        return attribute
    }

    /// 解析a标签,http,phone,emoji
    ///
    /// - Parameters:
    ///   - text: 文本
    ///   - font: 字体
    ///   - textColor: 文本颜色
    ///   - urlColor: 链接颜色
    ///   - icon: a链接是否需要图片
    public static func attributed(withText text: String, font: UIFont, textColor: UIColor, urlColor: UIColor, icon: Bool = false) -> NSMutableAttributedString? {
        if text.count == 0 { return nil }
        return baseAttributed(text, font: font, color: textColor).matchingAtag(font: font, urlColor: urlColor, icon: icon).matchingImg(font: font, urlColor: urlColor,icon: icon).matchingHttp(font: font, urlColor: urlColor).matchingPhone(font: font, urlColor: urlColor).matchingEmoji(font: font, color: textColor).matchingLabel().matchingLine()
    }
    public static func baseAttributed(_ text: String, font: UIFont, color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        return NSMutableAttributedString.init(string: text).add(font: font, range: range).add(color: color, range: range)
    }
}



extension NSMutableAttributedString {

    /// 解析首尾换行符,以及中间两个以上的换行
    public func matchingLine() -> NSMutableAttributedString {
        return matching(WithRegular: Regular.line, mapHandle: { (results) -> NSAttributedString? in
            guard results.count == 3 else {return nil}
            if let _ = results[1] {
                return NSAttributedString.init()
            }
            if let _ = results[2] {
                return NSAttributedString.init(string: "\n")
            }
            return nil
        })
    }
    /// 解析普通标签
    public func matchingLabel() -> NSMutableAttributedString {
        return matching(WithRegular: Regular.label, mapHandle: { (results) -> NSAttributedString? in
            guard results.count == 1 else {return nil}
            if let label = results[0] {
                if label.lowercased() == "<br/>" || label.lowercased() == "<br>" || label.lowercased() == "</p>" {
                    return NSAttributedString.init(string: "\n")
                }
                return NSAttributedString.init(string: "")
            }
            return nil
        })
    }
    /// 匹配phone
    public func matchingPhone(font: UIFont, urlColor: UIColor) -> NSMutableAttributedString {
        return matching(WithRegular: Regular.phone, mapHandle: { (results) -> NSAttributedString? in
            guard results.count == 1, let phone = results[0] else{ return nil }
            return NSAttributedString.baseAttributed(phone, font: font, color: urlColor).add(highlight: .phone, info: phone)
        })
    }


    /// 匹配http链接
    public func matchingHttp(font: UIFont, urlColor: UIColor) -> NSMutableAttributedString {
        return matching(WithRegular: Regular.http, mapHandle: { (results) -> NSAttributedString? in
            guard results.count == 1, let httpString = results[0] else{ return nil }
            return NSAttributedString.baseAttributed(httpString, font: font, color: urlColor).add(highlight: .url, info: httpString)
        })
    }
    /// 匹配emoji表情
    public func matchingEmoji(font: UIFont, color: UIColor) -> NSMutableAttributedString {
        return matching(WithRegular: Regular.emoji) { (results) -> NSAttributedString? in
            guard results.count == 1, let emoji = results[0], let path = Regular.emojiDict?[emoji], let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)), let image = UIImage.init(data: data) else{ return nil }
            return NSAttributedString.init(attachment: MATextAttachment.init(image: image))
        }
    }
    /// 匹配img标签
    public func matchingImg(font: UIFont, urlColor: UIColor, icon: Bool = false) -> NSMutableAttributedString {
        return matching(WithRegular: Regular.img) { (results) -> NSAttributedString? in
            guard results.count == 2, let href = results[1] else {
                return nil
            }
            return NSAttributedString.icon(WithImage: icon ? #imageLiteral(resourceName: "ticket_comment_picture") : nil, text: "查看图片", font: font, textColor: urlColor)?.add(highlight: .image, info: href)
        }
    }
    /// 匹配a标签
    public func matchingAtag(font: UIFont, urlColor: UIColor, icon: Bool = false) -> NSMutableAttributedString {

        return matching(WithRegular: Regular.atag) { (results) -> NSAttributedString? in
            guard results.count == 3, let href = results[1], let title = results[2] else {
                return nil
            }
            var replace: NSMutableAttributedString? = nil
            var isImage = false
            if icon {
                if title == "[图片]" || title == "[image]" {
                    replace = NSAttributedString.icon(WithImage: #imageLiteral(resourceName: "ticket_comment_picture"), text: "查看图片", font: font, textColor: urlColor)
                    isImage = true
                }else if title == "[语音]" || title == "[voice]" {
                    replace = NSAttributedString.icon(WithImage: #imageLiteral(resourceName: "ticket_comment_music"), text: "收听语音", font: font, textColor: urlColor)
                }else {
                    replace = NSAttributedString.icon(WithImage: #imageLiteral(resourceName: "ticket_comment_link"), text: title, font: font, textColor: urlColor)
                }
            }else{
                replace = NSAttributedString.icon(WithImage: nil, text: title, font: font, textColor: urlColor)
            }
            return replace?.add(highlight: isImage ? .image : .url, info: href)
        }
    }

    /// 统一匹配处理
    public func matching(WithRegular regular: NSRegularExpression, mapHandle: @escaping ([String?]) -> NSAttributedString?) -> NSMutableAttributedString {
        let array = regular.matches(in: self.string, options: [], range: NSRange.init(location: 0, length: self.length))
        var offSet = 0
        for value in array {
            if !checkoutCanReplace(result: value, offSet: offSet) {continue}

            var range = value.range
            range.location += offSet

            var results: [String?] = []

            for index in 0..<value.numberOfRanges {
                var ran = value.range(at: index)
                if ran.location != NSNotFound {
                    ran.location += offSet
                    let str = (self.string as NSString).substring(with: ran)
                    results.append(str)
                }
            }
            // 处理数据
            guard let replace = mapHandle(results) else {
                continue
            }
            // 替换数据
            self.replaceCharacters(in: range, with: replace)
            // 修改偏移量
            offSet += replace.length - range.length
        }
        return self
    }

    /// 检测该内容是否可被替换
    public func checkoutCanReplace(result: NSTextCheckingResult, offSet: Int) -> Bool {
        // 没有找到内容
        if result.numberOfRanges == 0 { return false }
        // 存在偏移量
        var newRange = result.range
        newRange.location += offSet
        // 范围存在
        if newRange.location == NSNotFound || newRange.length == 0 { return false }
        // 当前要替换的文本不是高亮文本
        if self.attribute(.highlight, at: newRange.location, effectiveRange: nil) != nil { return false }
        return true
    }
}

extension NSMutableAttributedString {
    public func add(highlight type: AttributedType, info: String, range: NSRange? = nil) -> Self {
        self.addAttribute(.highlight, value: ["type": type.rawValue, "info": info], range: range ?? NSRange.init(location: 0, length: self.length))
        return self
    }
    public func add(font: UIFont, range: NSRange? = nil) -> Self {
        self.addAttribute(.font, value: font, range: range ?? NSRange.init(location: 0, length: self.length))
        return self
    }
    public func add(color: UIColor, range: NSRange? = nil) -> Self {
        self.addAttribute(.foregroundColor, value: color, range: range ?? NSRange.init(location: 0, length: self.length))
        return self
    }
}
