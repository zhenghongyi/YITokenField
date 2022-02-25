//
//  CustomTokenView.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/20.
//

import UIKit

class CustomToken: YIToken {
    var text:String
    
    init(text:String) {
        self.text = text
    }
    
    override var tokenWidth: CGFloat {
        let size = text.size(withAttributes: [.font:UIFont.systemFont(ofSize: 14)])
        return size.width + 20 + 20
    }
}

class CustomTokenView: YITokenView {
    let tokenLabel:UILabel = UILabel()
    let delButton:UIButton = UIButton(type: .custom)
    
    let containerView:UIView = UIView()
    
    var token:YIToken?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setupUI() {
        containerView.backgroundColor = .systemGray5
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true

        containerView.addSubview(tokenLabel)
        tokenLabel.font = UIFont.systemFont(ofSize: 13)
        tokenLabel.textAlignment = .center
        tokenLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        tokenLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        containerView.addSubview(delButton)
        delButton.setTitle("x", for: .normal)
        delButton.translatesAutoresizingMaskIntoConstraints = false
        delButton.leadingAnchor.constraint(equalTo: tokenLabel.trailingAnchor).isActive = true
        delButton.centerYAnchor.constraint(equalTo: tokenLabel.centerYAnchor, constant: -2).isActive = true
        delButton.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
    }
    
    @objc func tapDelete() {
        if let token = token {
            delTokenBlock?(token)
        }
    }
    
    override func setup(token: YIToken) {
        self.token = token
        if let textToken = token as? CustomToken {
            tokenLabel.text = textToken.text
        }
    }
    
    override func handle(isSelected: Bool) {
        containerView.backgroundColor = isSelected ? .systemBlue : .systemGray5
    }
}
