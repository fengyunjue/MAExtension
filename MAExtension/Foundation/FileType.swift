//
//  FileType.swift
//  KF5Swift
//
//  Created by admin on 2017/7/21.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation

enum FileType {
    case image
    case rar
    case voice
    case document
    case other
    
    public static let imageTypes = ["png", "jpeg", "bmp", "gif", "jpg"]
    public static let rarTypes = ["rar", "zip"]
    public static let voiceType = "amr"
    public static let documentTypes = ["txt", "doc", "docx", "xls", "xlsx", "pdf", "csv", "ppt", "pptx"]
    
    public init(type: String) {
        let t = type.lowercased()
        if FileType.imageTypes.contains(t) {
            self = .image
        }else if FileType.rarTypes.contains(t) {
            self = .rar
        }else if FileType.voiceType == t {
            self = .voice
        }else if FileType.documentTypes.contains(t) {
            self = .document
        }else {
            self = .other
        }
    }

}
