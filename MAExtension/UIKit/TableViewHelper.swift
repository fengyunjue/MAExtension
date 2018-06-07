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
    case insert(ScrollType) // 插入数据
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
        
        if models.count == 0 { return }
        let oldModels = self.models
        
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
        let deleteIndexPaths: [IndexPath] = self.models.remove(contentsOf: deleteModels).compactMap {($0 != nil) ? IndexPath.init(row: $0!, section: 0) : nil}

        let orderIndexs = self.models.insertOrderIndexs(contentsOf: addModels)
        
        let reloadIndexPaths:[IndexPath]  = orderIndexs.1.map{IndexPath.init(row: $0, section: 0)}
        let insertIndexPaths: [IndexPath] = orderIndexs.0.map{IndexPath.init(row: $0, section: 0)}
        
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
            self.reloadTableView.beginUpdates()
            if deleteIndexPaths.count > 0{
                self.reloadTableView.deleteRows(at: deleteIndexPaths, with: .none)
            }
            if insertIndexPaths.count > 0{
                self.reloadTableView.insertRows(at: insertIndexPaths, with: .none)
            }
            if reloadIndexPaths.count > 0{
                self.reloadTableView.reloadRows(at: reloadIndexPaths, with: .none)
            }
            self.reloadTableView.endUpdates()
            
            if scrollType == .bottom {
                self.reloadTableView.scrollToRow(at: IndexPath.init(row: self.models.count-1, section: 0), at: .bottom, animated: true)
            }else if scrollType == .hold && bottomIndexPath != nil && offsetInset != nil{
                self.reloadTableView.scrollToRow(at: bottomIndexPath!, at: .none, animated: false)
                var offset = self.reloadTableView.contentOffset
                offset.y -= offsetInset!
                self.reloadTableView.contentOffset = offset
            }
        }
    }
    public func scrollBottom(_ animated: Bool = true) {
        self.reloadTableView.scrollToRow(at: IndexPath.init(row: self.models.count-1, section: 0), at: .bottom, animated: animated)
    }
}
