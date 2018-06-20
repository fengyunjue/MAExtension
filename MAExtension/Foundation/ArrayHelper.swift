//
//  ArrayHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation

// MARK: - Array 拓展
extension Array {
    // 随机打乱数据
    func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}

extension Array where Element: Equatable {
    
    @discardableResult
    public mutating func remove(element: Element) -> Int?{
        if let index = self.index(of: element) {
            self.remove(at: index)
            self.append(contentsOf: [])
            return index
        }else{
            return nil
        }
    }
    
    @discardableResult
    public mutating func remove<S>(contentsOf oldElements: S) -> [Int] where Element == S.Element, S : Sequence {
        var indexs: [Int] = []
        oldElements.forEach { (element) in
            if let index = self.remove(element: element) {
                indexs.append(index)
            }
        }
        return indexs
    }
}

extension Array where Element: Comparable {
    /// 返回: (位置, 插入是true更新是false)
    @discardableResult
    public mutating func insertOrder(_ element: Element, _ asc: Bool = true) -> (Int, Bool){
        
        var index: Int = 0
        var hasValue = false
        
        var left = 0
        var right = self.count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            let value = self[mid]
            if value == element {
                index = mid
                hasValue = true
                break
            }else if value < element {
                left = asc ? mid + 1 : left
                index = asc ? mid + 1 : mid
                right = asc ? right : mid - 1
            }else if value > element {
                left = !asc ? mid + 1 : left
                index = !asc ? mid + 1 : mid
                right = !asc ? right : mid - 1
            }
        }
        
        if hasValue {
            self[index] = element
            return (index, false)
        }else{
            self.insert(element, at: index)
            return (index, true)
        }
    }
    
    public mutating func insertOrder<S>(contentsOf newElements: S, _ asc: Bool = true) -> ([Element], [Element]) where Element == S.Element, S : Sequence{
        var inserts: [Element] = []
        var reloads: [Element] = []
        
        newElements.forEach { (m) in
            let result = self.insertOrder(m, asc)
            if result.1 {
                inserts.append(m)
            }else {
                reloads.append(m)
            }
        }
        return (inserts, reloads)
    }
}
