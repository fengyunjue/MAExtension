//
//  KFError.swift
//  KF5SDK_Swift
//
//  Created by admin on 17/1/6.
//  Copyright © 2017年 kf5. All rights reserved.
//

import Foundation

public enum KFError: LocalizedError {
    case paramsError(String)
    case underlying(Error)
    case undefined(Int,String)
    
    case connectError(String)
    case formatError(String)
    case serverError(String)
    
    public init(errorCode: Int, message: String) {
        switch errorCode {
        case 4000:
            self = .paramsError(message)
        default:
            self = .undefined(errorCode, message)
        }
    }
    public init(error: Error) {
        self = .underlying(error)
    }
    public var errorDescription: String? {
        switch self {
        case let .paramsError(message):
            return message.count != 0 ? message : "请求失败"
        case .underlying(_):
            return "请求失败"
        case  let .undefined(_, message):
            return message.count != 0 ? message : "请求失败"
        case let .connectError(message):
            return message
        case let .formatError(message):
            return message
        case let .serverError(message):
            return message
        }
    }
}
