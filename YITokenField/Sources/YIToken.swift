//
//  YIToken.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/19.
//

import UIKit

enum YITokenType {
    case normal
    case textField
    case tail
}

public class YIToken {
    var type:YITokenType = .normal
    
    public var tokenWidth: CGFloat {
        return 0
    }
}

class YITailToken:YIToken {
    var width:CGFloat = 0
    
    override var tokenWidth: CGFloat {
        return width
    }
}
