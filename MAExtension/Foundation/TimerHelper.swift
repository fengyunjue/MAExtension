//
//  TimerHelper.swift
//  MAExtension
//
//  Created by admin on 2018/6/1.
//

import Foundation

extension Timer {
    public static func timer(interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer {
        let timer = Timer.init(timeInterval: interval, target: self, selector: #selector(Timer.trigger(_:)), userInfo: block, repeats: repeats)
        RunLoop.current.add(timer, forMode: .commonModes)
        return timer
    }
     @objc private static func trigger(_ timer: Timer) {
        let block = timer.userInfo as? ((Timer) -> Void)
        if let block = block {
            block(timer)
        }
        
    }
}
