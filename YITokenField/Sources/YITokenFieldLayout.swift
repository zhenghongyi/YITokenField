//
//  YITokenFieldLayout.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/19.
//

import UIKit

class YITokenFieldLayout: UICollectionViewFlowLayout {
    var itemSpace:CGFloat = 10
    
    var itemHeight:CGFloat = 44
    
    var getToken:((Int) -> YIToken?)?
    
    private(set) var contentHeight:CGFloat = 0
    
    fileprivate var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        computeAttributesWithItemHeight(itemHeight)
    }
    
    func computeAttributesWithItemHeight(_ itemHeight:CGFloat) {
        contentHeight = 0
        
        let contentWidth = collectionView?.bounds.size.width ?? 0.0
        var lastX = sectionInset.left
        var lastY = sectionInset.top
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        let itemCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        var itemWidth:CGFloat = 0
        
        for index in 0..<itemCount {
            let indexPath = IndexPath.init(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            if let token = getToken?(index) {
                let isExpandIndex:Bool = (token.type == .textField)
                var hasTail:Bool = false
                
                var tokenWidth:CGFloat = isExpandIndex ? 100 : token.tokenWidth
                var tailTokenWidth:CGFloat = 0
                
                if isExpandIndex {
                    if index < itemCount - 1, let nextToken = getToken?(index + 1) {
                        hasTail = (nextToken.type == .tail)
                        tailTokenWidth = hasTail ? nextToken.tokenWidth : 0
                    }
                }
                
                var nextMaxX = lastX + tokenWidth + itemSpace
                
                if isExpandIndex && hasTail {
                    nextMaxX += tailTokenWidth + itemSpace
                }
                
                if nextMaxX + self.sectionInset.right > contentWidth {
                    lastX = self.sectionInset.left
                    lastY += itemHeight + itemSpace / 2
                }
                
                if isExpandIndex {
                    tokenWidth = contentWidth - lastX - sectionInset.right - itemSpace
                    if hasTail {
                        tokenWidth -= tailTokenWidth + itemSpace
                    }
                }
                
                itemWidth = tokenWidth
            }
            
            attributes.frame = CGRect(x: lastX, y: lastY, width: itemWidth, height: itemHeight)
            
            attributesArray.append(attributes)
            
            lastX += itemWidth + self.itemSpace
            
            contentHeight = lastY + itemHeight
        }
        
        self.layoutAttributesArray = attributesArray
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributesArray
    }
}
