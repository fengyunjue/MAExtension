//
//  TableViewHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/28.
//

import UIKit
public enum ScrollType {
    case none   // 不滚动
    case bottom // 滚动到底部
    case hold   // 滚动到原来的位置,界面上不动
}
public enum RefreshMode {
    case insert(ScrollType) // 插入数据,是否刷新
    case delete(ScrollType) // 删除数据
    
    public var type: ScrollType {
        switch self {
        case .insert(let type):
            return type
        case .delete(let type):
            return type
        }
    }
    
    public var isDelete: Bool {
        switch self {
        case .delete(_):
            return true
        default:
            return false
        }
    }
    
    public var isInsert: Bool {
        switch self {
        case .insert(_):
            return true
        default:
            return false
        }
    }
}


// MARK: - UITableView扩展
public protocol Reloadable {
    
    associatedtype Model: Comparable, Hashable
    
    var models: [Model] { get set }
    var reloadTableView: UITableView { get }
    
    mutating func refresh(_ models: [(Model, RefreshMode)])
}

extension Reloadable where Model: Comparable {
    
    public mutating func refresh(_ models: [(Model, RefreshMode)]){
        var weakSelf = self
        
        if models.count == 0 { return }
        let oldModels = weakSelf.models
        
        var addModels: Set<Model> = Set()
        var deleteModels: Set<Model> = Set()
        
        var scrollType: ScrollType = .none
        models.forEach { (model, type) in
            scrollType = type.type
            if type.isInsert {
                deleteModels.remove(model)
                addModels.insert(model)
            }else{
                addModels.remove(model)
                deleteModels.insert(model)
            }
        }
        
        // 处理数据
        weakSelf.models.remove(contentsOf: deleteModels)
        
        let orders = weakSelf.models.insertOrder(contentsOf: addModels)
        
        let deleteIndexPaths: [IndexPath] = deleteModels.compactMap{ (model) -> IndexPath? in
            if let index = oldModels.index(of: model) {
                return IndexPath.init(row: index, section: 0)
            }else{
                return nil
            }
        }
        let reloadIndexPaths: [IndexPath] = orders.1.compactMap { (model) -> IndexPath? in
            if let index = oldModels.index(of: model) {
                return IndexPath.init(row: index, section: 0)
            }else{
                return nil
            }
        }
        let insertIndexPaths: [IndexPath] = orders.0.compactMap { (model) -> IndexPath? in
            if let index = weakSelf.models.index(of: model) {
                return IndexPath.init(row: index, section: 0)
            }else{
                return nil
            }
        }
        
        var bottomIndexPath: IndexPath? = nil
        // bottom的偏移量
        var offsetInset: CGFloat? = nil
        if let cell = self.reloadTableView.visibleCells.last, let indexPath = self.reloadTableView.indexPath(for: cell), indexPath.row < oldModels.count {
            let model = oldModels[indexPath.row]
            if let index = self.models.index(of: model) {
                bottomIndexPath = IndexPath.init(row: index, section: 0)
                offsetInset = cell.frame.maxY - self.reloadTableView.frame.height - self.reloadTableView.contentOffset.y
            }
        }
        UIView.noAnimation {
            weakSelf.reloadTableView.beginUpdates()
            if deleteIndexPaths.count > 0{
                weakSelf.reloadTableView.deleteRows(at: deleteIndexPaths, with: .none)
            }
            if insertIndexPaths.count > 0{
                weakSelf.reloadTableView.insertRows(at: insertIndexPaths, with: .none)
            }
            if reloadIndexPaths.count > 0{
                weakSelf.reloadTableView.reloadRows(at: reloadIndexPaths, with: .none)
            }
            weakSelf.reloadTableView.endUpdates()
            
            if scrollType == .bottom {
                weakSelf.reloadTableView.scrollToRow(at: IndexPath.init(row: weakSelf.models.count-1, section: 0), at: .bottom, animated: true)
            }else if scrollType == .hold && bottomIndexPath != nil && offsetInset != nil{
                weakSelf.reloadTableView.scrollToRow(at: bottomIndexPath!, at: .none, animated: false)
                var offset = self.reloadTableView.contentOffset
                offset.y -= offsetInset!
                self.reloadTableView.contentOffset = offset
            }
        }
    }
    public func scrollBottom(_ animated: Bool = true) {
        self.reloadTableView.scrollToRow(at: IndexPath.init(row: self.models.count-1, section: 0), at: .bottom, animated: animated)
    }
    
    public func classifyModel(_ models: [(Model, RefreshMode)]) -> ([(Model, RefreshMode)], [(Model, RefreshMode)]) {
        var deleteMessages: [(Model, RefreshMode)] = []
        var insertMessages: [(Model, RefreshMode)] = []
        models.forEach({ (model, mode) in
            if mode.isInsert {
                insertMessages.append((model, mode))
            }else{
                deleteMessages.append((model, mode))
            }
        })
        return (insertMessages, deleteMessages)
    }
}
