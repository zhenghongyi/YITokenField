//
//  YITokenField.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/19.
//

import UIKit

protocol YITokenFieldDelegate: NSObjectProtocol {
    func tokenFieldDidChangeHeight(_ tokenField: YITokenField, newHeight:CGFloat)
    func tokenField(_ tokenField: YITokenField, didAdd tokens:[YIToken])
    func tokenField(_ tokenField: YITokenField, didRemove tokens:[YIToken])
    func tokenField(_ tokenField: YITokenField, didSelect token:YIToken)
    
    func tokenFieldShouldReturn(_ tokenField: YITokenField) -> Bool
    func tokenFieldDidBeginEditing(_ tokenField: YITokenField)
    func tokenFieldDidEndEditing(_ tokenField: YITokenField)
    func tokenFieldTextDidChange(_ tokenField: YITokenField)
}

extension YITokenFieldDelegate {
    func tokenFieldDidChangeHeight(_ tokenField: YITokenField, newHeight:CGFloat) {}
    func tokenField(_ tokenField: YITokenField, didAdd tokens:[YIToken]) {}
    func tokenField(_ tokenField: YITokenField, didRemove tokens:[YIToken]) {}
    func tokenField(_ tokenField: YITokenField, didSelect token:YIToken) {}
    
    func tokenFieldShouldReturn(_ tokenField: YITokenField) -> Bool { return true }
    func tokenFieldDidBeginEditing(_ tokenField: YITokenField) {}
    func tokenFieldDidEndEditing(_ tokenField: YITokenField) {}
    func tokenFieldTextDidChange(_ tokenField: YITokenField) {}
}

class YITokenField: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var delegate:YITokenFieldDelegate?
    
    // MARK: Token
    private var tokens:[YIToken] = []
    var allTokens:[YIToken] {
        return tokens.filter({ $0.type == .normal })
    }
    // MARK: Tail
    private var tailToken:YITailToken = {
        let token:YITailToken = YITailToken()
        token.type = .tail
        return token
    }()
    var tailView:UIView? {
        didSet {
            if tokens.last?.type != .tail {
                tokens.append(tailToken)
            }
        }
    }
    var tailWidth:CGFloat {
        set(newValue) {
            tailToken.width = newValue
        }
        get {
            return tailToken.width
        }
    }
    private var hasTail:Bool {
        return tokens.last?.type == .tail
    }
    // MARK: Textfield
    private(set) var textField:UITextField?
    var text:String? {
        set(newValue) {
            textField?.text = newValue
        }
        get {
            return textField?.text
        }
    }
    var placeholder:String? {
        didSet {
            textField?.placeholder = placeholder
        }
    }
    
    private
    var collectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: YITokenFieldLayout())
    private
    var updating:Bool = false
    
    // 默认可删除已选择的高亮选项
    var deleteHighlightEnable:Bool = true
    private var highlightIndex:Int?
    
    // MARK: initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let layout:YITokenFieldLayout = YITokenFieldLayout()
        layout.getToken = {[weak self] (index) in
            if let count = self?.tokens.count, index >= count {
                return nil
            }
            return self?.tokens[index]
        }
        
        let textfieldToken:YIToken = YIToken()
        textfieldToken.type = .textField
        tokens = [textfieldToken]
        
        let collectionView:UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        // 禁止滚动，否则局部updateIndex，会导致contentOffset不对
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(YITextFieldTokenCell.self, forCellWithReuseIdentifier: "YITokenTextFieldCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "YITokenTailCell")
        
        self.collectionView = collectionView
        
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
    }
    
    func register(_ tokenViewClass: AnyClass?) {
        collectionView.register(tokenViewClass, forCellWithReuseIdentifier: "YITokenNormalCell")
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tokens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let token = tokens[indexPath.item]
        
        switch token.type {
        case .textField:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YITokenTextFieldCell", for: indexPath) as? YITextFieldTokenCell {
                cell.textField.placeholder = placeholder
                cell.textField.removeTarget(self, action: #selector(textFieldWasUpdated), for: .editingChanged)
                cell.textField.addTarget(self, action: #selector(textFieldWasUpdated), for: .editingChanged)
                cell.textField.delegate = self
                cell.delTokenBlock = {[weak self] in
                    if let index = self?.textFieldDelIndex {
                        self?.deleteTokens(indexes: [index])
                        self?.highlightIndex = nil
                    }
                }
                textField = cell.textField
                return cell
            }
        case .tail:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YITokenTailCell", for: indexPath)
            if let tailView = tailView, tailView.superview == nil {
                cell.contentView.addSubview(tailView)
                tailView.translatesAutoresizingMaskIntoConstraints = false
                tailView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
                tailView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
                tailView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
                tailView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            }
            return cell
        case .normal:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YITokenNormalCell", for: indexPath) as? YITokenView {
                cell.setup(token: token)
                cell.delTokenBlock = {[weak self, weak cell] _ in
                    if let cell = cell, let collectionView = self?.collectionView,
                        let indexPath = collectionView.indexPath(for: cell) {
                        self?.deleteTokens(indexes: [indexPath.item])
                    }
                }
                return cell
            }
        }
        
        let cell = UICollectionViewCell()
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < tokens.count else {
            return
        }
        let token = tokens[indexPath.item]
        if token.type == .normal {
            if highlightIndex == indexPath.item {
                highlightIndex = nil
                collectionView.deselectItem(at: indexPath, animated: false)
            } else {
                highlightIndex = indexPath.item
                delegate?.tokenField(self, didSelect: token)
            }
        }
    }
    
    private var textFieldDelIndex:Int {
        if let index = highlightIndex, deleteHighlightEnable {
            return index
        }
        if hasTail {
            return tokens.count - 3
        }
        return tokens.count - 2
    }
}

// MARK: Action
extension YITokenField {
    private func perform(updates:@escaping (() -> Void), completion:(() -> Void)? = nil) {
        if updating != false { // 上一个操作还未更新完毕，稍后再尝试
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.perform(updates: updates, completion: completion)
            }
            return
        }
        
        updating = true
        UIView.setAnimationsEnabled(false)// 禁用隐式动画
        collectionView.performBatchUpdates({
            updates()
        }, completion: {[weak self] finished in
            self?.updating = !finished
            self?.updateHeight()
            UIView.setAnimationsEnabled(true)
            completion?()
        })
    }
    
    public func reload() {
        perform(updates: {[weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    public func appendTokens(_ newTokens:[YIToken]) {
        guard newTokens.count > 0 else { return }
        var index:Int
        if hasTail {
            index = tokens.count - 2
        } else {
            index = tokens.count - 1
        }
        
        var paths:[IndexPath] = []
        for i in 0..<newTokens.count {
            let indexPath = IndexPath(item: index + i, section: 0)
            paths.append(indexPath)
        }
        tokens.insert(contentsOf: newTokens, at: index)
        delegate?.tokenField(self, didAdd: newTokens)
        perform(updates: {[weak self] in
            self?.collectionView.insertItems(at: paths)
        })
    }
    
    public func deleteTokens(indexes:[Int]) {
        guard indexes.count > 0 else { return }
        var paths:[IndexPath] = []
        var popTokens:[YIToken] = []
        for item in indexes {
            if item < 0 {
                continue
            }
            if (!hasTail && item > tokens.count - 1) || (hasTail && item > tokens.count - 2) {
                continue
            }
            let path:IndexPath = IndexPath(item: item, section: 0)
            paths.append(path)
            
            let t = tokens.remove(at: item)
            popTokens.append(t)
        }
        delegate?.tokenField(self, didRemove: popTokens)
        perform(updates: {[weak self] in
            self?.collectionView.deleteItems(at: paths)
        })
    }
    
    @objc func textFieldWasUpdated() {
        delegate?.tokenFieldTextDidChange(self)
    }
    
    func updateHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let contentHeight = (self.collectionView.collectionViewLayout as? YITokenFieldLayout)?.contentHeight
            self.delegate?.tokenFieldDidChangeHeight(self, newHeight: contentHeight ?? 0)
        }
    }
}

// MAKR: UITextFieldDelegate
extension YITokenField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.tokenFieldShouldReturn(self) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.tokenFieldDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.tokenFieldDidEndEditing(self)
    }
}

extension YITokenField: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let token = tokens[indexPath.row]
        if token.type == .normal {
            let itemProvider = NSItemProvider(object: token as NSItemProviderWriting)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = tokens[indexPath.row]
            return [dragItem]
        } else {
            return []
        }
    }
    
    // 添加拖动的任务
    // 下面的代码，一次拖动一个
    // 可以通过这个方法，开始拖动后，继续添加拖动的任务
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let token = tokens[indexPath.row]
        let itemProvider = NSItemProvider(object: token as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = tokens[indexPath.row]
        return [dragItem]
    }


    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        // 拖动开始的时机
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        // 拖动结束的时机
    }
    
    // MARK: UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let destinationIndexPath = destinationIndexPath,
                tokens[destinationIndexPath.row].type == .normal else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
     }

     func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath, case UIDropOperation.move = coordinator.proposal.operation{
            reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
        }
    }
    
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        if  items.count == 1, let item = items.first,
            let sourceIndexPath = item.sourceIndexPath,
            let localObject = item.dragItem.localObject as? YIToken {

            collectionView.performBatchUpdates ({
                tokens.remove(at: sourceIndexPath.item)
                tokens.insert(localObject, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
        }
    }
}
