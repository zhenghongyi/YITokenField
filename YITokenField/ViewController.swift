//
//  ViewController.swift
//  YITokenField
//
//  Created by 郑洪益 on 2022/2/19.
//

import UIKit

class ViewController: UIViewController, YITokenFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let importButton:UIButton = UIButton(type: .custom)
        importButton.setImage(UIImage(named: "tianj"), for: .normal)
        importButton.addTarget(self, action: #selector(importOthers), for: .touchUpInside)
        
        let tokenField = YITokenField()
        tokenField.placeholder = "请输入"
        tokenField.layer.borderWidth = 1
        tokenField.layer.borderColor = UIColor.gray.cgColor
        // tail
        tokenField.tailView = importButton
        tokenField.tailWidth = 30
        view.addSubview(tokenField)
        tokenField.translatesAutoresizingMaskIntoConstraints = false
        tokenField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        tokenField.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tokenField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tokenField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tokenField.register(CustomTokenView.self)
        tokenField.delegate = self
        tokenField.appendTokens([CustomToken(text: "123")])
    }
    
    @objc func importOthers() {
        
    }
    
    func tokenFieldShouldReturn(_ tokenField: YITokenField) -> Bool {
        if let text = tokenField.text {
            tokenField.appendTokens([CustomToken(text: text)])
            tokenField.text = nil
        }
        return true
    }
    
    func tokenFieldDidChangeHeight(_ tokenField: YITokenField, newHeight: CGFloat) {
        var constraint:NSLayoutConstraint?
        for item in tokenField.constraints where item.firstAttribute == .height {
            constraint = item
            break
        }
        constraint?.isActive = false
        tokenField.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
    }
}

