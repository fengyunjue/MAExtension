//
//  ArrayHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/24.
//

import Foundation

// MARK: - Array 拓展
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
    public mutating func remove<S>(contentsOf oldElements: S) -> [Int?] where Element == S.Element, S : Sequence  {
        var indexs: [Int?] = []
        oldElements.forEach { (element) in
            indexs.append(self.remove(element: element))
        }
        return indexs
    }
}

extension Array where Element: Comparable {
    /// 返回: (位置, 插入是true更新是false)
    @discardableResult
    public mutating func insertOrder(_ element: Element) -> (Int, Bool){
        if self.contains(element) {
            let index = self.index(of: element)!
            self[index] = element
            return (index, false)
        }else{
            var index: Int = 0
            for (i, value) in self.enumerated().reversed() {
                if element > value {
                    index = i+1
                    break
                }
            }
            self.insert(element, at: index)
            return (index, true)
        }
    }
    @discardableResult
    public mutating func insertOrder<S>(contentsOf newElements: S) -> ([Element], [Element]) where Element == S.Element, S : Sequence{
        var inserts: [Element] = []
        var reloads: [Element] = []
        
        newElements.forEach { (m) in
            let result = self.insertOrder(m)
            if result.1 {
                inserts.append(m)
            }else {
                reloads.append(m)
            }
        }
        return (inserts, reloads)
    }
    @discardableResult
    public mutating func insertOrderIndexs<S>(contentsOf newElements: S) -> ([Int], [Int]) where Element == S.Element, S : Sequence{
        var inserts: [Int] = []
        var reloads: [Int] = []
        
        newElements.forEach { (m) in
            let result = self.insertOrder(m)
            if result.1 {
                inserts.append(result.0)
            }else {
                reloads.append(result.0)
            }
        }
        return (inserts, reloads)
    }
    
}
