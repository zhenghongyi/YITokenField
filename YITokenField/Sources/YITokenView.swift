//
//  YITokenView.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/20.
//

import UIKit

class YITokenView: UICollectionViewCell {
    var delTokenBlock:((YIToken) -> Void)?
    
    func setup(token:YIToken) {
        
    }
    
    override var isSelected: Bool {
        didSet {
            handle(isSelected: isSelected)
        }
    }
    
    func handle(isSelected:Bool) {
        
    }
}
