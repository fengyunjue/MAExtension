//
//  TableViewHelper.swift
//  MAExtension
//
//  Created by admin on 2018/5/28.
//

import UIKit

public struct RefreshMode: Equatable {
    enum Model {
        // 插入数据,是否刷新
        case insert
        // 删除数据
        case delete
    }
    var model: Model
    var isScrollBottom: Bool
    
    static var insert = RefreshMode.init(model: .insert, isScrollBottom: true)
    static var insertNoScroll = RefreshMode.init(model: .insert, isScrollBottom: false)
    static var delete = RefreshMode.init(model: .delete, isScrollBottom: true)
    
    public static func == (lhs: RefreshMode, rhs: RefreshMode) -> Bool {
        return lhs.model == rhs.model
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
        
        DispatchQueue.global().async {
            if models.count == 0 { return }
            let oldModels = weakSelf.models
            
            var addModels: Set<Model> = Set()
            var deleteModels: Set<Model> = Set()
            
            var isScrollBottom: Bool = true
            models.forEach { (model, type) in
                isScrollBottom = type.isScrollBottom
                if type == RefreshMode.insert {
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
            
            DispatchQueue.main.async {
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
                    if isScrollBottom {
                        weakSelf.reloadTableView.scrollToRow(at: IndexPath.init(row: weakSelf.models.count-1, section: 0), at: .bottom, animated: true)
                    }
                }
            }
            
        }
    }
    public func scrollBottom(_ animated: Bool = true) {
        self.reloadTableView.scrollToRow(at: IndexPath.init(row: self.models.count-1, section: 0), at: .bottom, animated: animated)
    }
}
