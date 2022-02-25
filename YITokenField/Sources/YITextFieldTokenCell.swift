//
//  YITextFieldTokenCell.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/19.
//

import UIKit

class DelDetectingTextField: UITextField {
    var onDeleteBackwardWhenEmpty: (() -> Void)?
    
    override public func deleteBackward() {
        let isEmpty: Bool = text?.isEmpty ?? false
        super.deleteBackward()
        
        if isEmpty {
            onDeleteBackwardWhenEmpty?()
        }
    }
}

class YITextFieldTokenCell: UICollectionViewCell {
    let textField:DelDetectingTextField = DelDetectingTextField()
    
    var delTokenBlock:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        textField.onDeleteBackwardWhenEmpty = {[weak self] in
            self?.delTokenBlock?()
        }
    }
    
    // 支持iOS14上不响应的古怪问题
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInside = super.point(inside: point, with: event)
        if #available(iOS 14.0, *) {
            if isInside && !textField.isFirstResponder {
                textField.becomeFirstResponder()
            }
        }
        return isInside
    }
}
