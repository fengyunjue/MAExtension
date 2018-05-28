//
//  Logger.swift
//  KF5Swift
//
//  Created by admin on 17/5/27.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation
import NSLogger

public func LogWarn(_ format: Any?, _ domain: NSLogger.Logger.Domain = Logger.Domain.app,
             _ filename: String = #file, lineNumber: Int = #line, fnName: String = #function) {
    LogDefault(format, domain, .warning, filename, lineNumber: lineNumber, fnName: fnName)
}

public func LogInfo(_ format: Any?, _ domain: NSLogger.Logger.Domain = Logger.Domain.app,
             _ filename: String = #file, lineNumber: Int = #line, fnName: String = #function) {
    LogDefault(format, domain, .info, filename, lineNumber: lineNumber, fnName: fnName)
}

public func LogError(_ format: Any?, _ domain: NSLogger.Logger.Domain = Logger.Domain.app,
              _ filename: String = #file, lineNumber: Int = #line, fnName: String = #function) {
    LogDefault(format, domain, .error, filename, lineNumber: lineNumber, fnName: fnName)
}

private let dateFormatter = DateFormatter()
private func date() -> String {
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter.string(from: Date())
}

private func LogDefault(_ format: Any?, _ domain: NSLogger.Logger.Domain, _ level: NSLogger.Logger.Level,
                            _ filename: String = #file, lineNumber: Int = #line, fnName: String = #function) {
#if DEBUG
    let str = "\(format ?? "")"
    
    Logger.shared.log(domain, level, str, filename, lineNumber, fnName)
    var levelStr = ""
    switch level.rawValue {
    case 0:
        levelStr = "Error"
    case 1:
        levelStr = "Warning"
    case 3:
        levelStr = "Info"
    default:
        levelStr = "Default"
    }
    
    print("[\(date()) \(levelStr) \(URL.init(fileURLWithPath: filename).lastPathComponent):\(lineNumber) \(fnName)]:\(str)")
#endif
}
