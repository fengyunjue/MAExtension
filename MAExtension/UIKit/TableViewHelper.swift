
//
//  Created by admin on 2018/5/28.
//

import UIKit

extension IndexPath {
    init?(row: Int?, section: Int?) {
        if let row = row, let section = section {
            self.init(row: row, section: section)
        }else{
            return nil
        }
    }
}

public enum ScrollType {
    case none   // 不滚动
    case bottom // 滚动到底部
    case hold   // 滚动到原来的位置,界面上不动
}

public enum RefreshMode {
    case insert // 插入数据
    case delete // 删除数据
}

// MARK: - UITableView扩展
public protocol Reloadable {
    
    associatedtype Model: Comparable, Hashable
    
    var models: [Model] { get set }
    var reloadTableView: UITableView { get }
    
    mutating func refresh(_ models: [(Model, RefreshMode)], _ scrollType: ScrollType)
}

extension Reloadable where Model: Comparable {
    
    public mutating func refresh(_ models: [(Model, RefreshMode)], _ scrollType: ScrollType = .bottom) {
        
        if models.count == 0 { return }
        
        let oldModels = self.models
        
        var addModels: Set<Model> = Set()
        var deleteModels: Set<Model> = Set()
        
        models.forEach { (model, type) in
            switch type {
            case .insert:
                deleteModels.remove(model)
                addModels.insert(model)
            case .delete:
                addModels.remove(model)
                deleteModels.insert(model)
            }
        }
        
        // 处理数据
        self.models.remove(contentsOf: deleteModels)
        let orders = self.models.insertOrder(contentsOf: addModels)
        
        let deleteIndexPaths: [IndexPath] =  deleteModels.compactMap{IndexPath.init(row: oldModels.index(of: $0), section: 0)}
        let reloadIndexPaths: [IndexPath] = orders.1.compactMap{IndexPath.init(row: oldModels.index(of: $0), section: 0)}
        let insertIndexPaths: [IndexPath] = orders.0.compactMap{IndexPath.init(row: self.models.index(of: $0), section: 0)}
        
        // bottom的偏移量
        var bottomIndexPath: IndexPath? = nil
        var offsetInset: CGFloat? = nil
        if scrollType == .hold, let cell = self.reloadTableView.visibleCells.last, let indexPath = self.reloadTableView.indexPath(for: cell), indexPath.row < oldModels.count {
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
                scrollBottom()
            }else if scrollType == .hold && bottomIndexPath != nil && offsetInset != nil{
                self.reloadTableView.scrollToRow(at: bottomIndexPath!, at: .none, animated: false)
                var offset = self.reloadTableView.contentOffset
                offset.y -= offsetInset!
                self.reloadTableView.contentOffset = offset
            }
        }
    }
    
    public func scrollBottom(_ animated: Bool = true) {
        if self.models.count > 0 {
            self.reloadTableView.scrollToRow(at: IndexPath.init(row: self.models.count-1, section: 0), at: .bottom, animated: animated)
        }
    }
}
