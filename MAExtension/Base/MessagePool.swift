//
//  MessagePool.swift
//  KF5Swift
//
//  Created by admin on 2017/7/25.
//  Copyright © 2017年 ma. All rights reserved.
//

import Foundation

fileprivate enum TimerType {
    case start
    case pause
}

public class MessagePool<T> {
    
    private var queue: [T] = []
    
    /// 推出队列的最大数量
    public let maxPop: Int
    /// 消息等待时间
    public let interval: TimeInterval
    /// 最大消息间隔
    public let maxTime: TimeInterval
    /// 是否为空
    public var isEmpty: Bool { return queue.isEmpty }
    /// 队列消息数量
    public var size: Int { return queue.count }
    
    /// 定时推出消息的block
    private let popBlock: (([T]) -> Void)
    /// (如果在间隔时间内又有消息进去队列则为true, 记录时间)
    private var time: (Bool, TimeInterval) = (false, 0)
    
    /// 定时器是否暂停
    private var timerType: TimerType = .start
    
    private var timer: Timer!
    
    public init(maxPop: Int = 500, interval: TimeInterval = 0.5, maxTime: TimeInterval = 5, pop: @escaping (([T]) -> Void)) {
        self.maxPop = maxPop
        self.interval = interval
        self.maxTime = maxTime
        self.popBlock = pop
        self.timer = Timer.init(timeInterval: self.interval, target: self, selector: #selector(tickDown), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    public func push(_ messages: [T]){
        if timerType != .start {// 如果计时器被暂停,则说明刚才是静默状态
            initial(timerType: .start)
        }else{
            time.0 = true
        }
        queue.append(contentsOf: messages)
//        LogInfo("\(String(describing: messages.first))--\(queue.count)")
    }
    /// 定时器触发事件
    @objc private func tickDown() {
        if !time.0 || time.1 >= maxTime || queue.count >= maxPop {
            pop()
        }
        time.0 = false
        time.1 += interval
    }
    private func pop(){
        if isEmpty {
            // 如果消息池里没有了消息,则暂停定时器
            initial(timerType: .pause)
//            LogInfo("如果消息池里没有了消息,则关闭定时器")
        }else{
            var messages : [T]!
            if size >= maxPop {
                let range = queue.startIndex ..< maxPop
                messages = Array(queue[range])
                queue.removeSubrange(range)
            }else{
                messages = queue
                queue.removeAll(keepingCapacity: false)
            }
            self.popBlock(messages)
//            LogInfo("有消息\(messages)")
            initial(timerType: .start)
        }
    }
    
    /// 初始化数据
    ///
    /// - Parameter pause: 是否暂停定时器
    private func initial(timerType: TimerType) {
        if self.timerType != timerType {
            switch timerType {
            case .start:
                timer.fireDate = Date.distantPast
            case .pause:
                timer.fireDate = Date.distantFuture
            }
            self.timerType = timerType
        }
        self.time.0 = false
        self.time.1 = 0
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
}
