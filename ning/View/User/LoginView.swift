//
//  LoginView.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/6.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit
import TextFieldEffects

class LoginView: BaseView {
    
    lazy var emailView: UITextField = {
        let view = HoshiTextField()
        view.placeholder = "请输入邮箱"
        view.borderInactiveColor = UIColor.lightGray
        view.borderActiveColor = UIColor.theme
        view.placeholderColor = UIColor.lightGray
        view.autocapitalizationType = .none
        return view
    }()
    
    lazy var passwordView: UITextField = {
        let view = HoshiTextField()
        view.isSecureTextEntry = true
        view.placeholder = "请输入密码"
        view.borderInactiveColor = UIColor.lightGray
        view.borderActiveColor = UIColor.theme
        view.placeholderColor = UIColor.lightGray
        view.autocapitalizationType = .none
        return view
    }()
    
    lazy var submitView: UIButton = {
        let view = UIButton()
        view.setTitle("登录", for: .normal)
        view.backgroundColor = UIColor.theme
        view.titleLabel?.textColor = UIColor.white
        return view
    }()
    
    lazy var thirdTipView : UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var thirdTipLeftLine : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var thirdTipRightLine : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    override func setupUI() {
        let fieldWidth = 30
        let fieldHeight = 50
        let offset = 10
        self.backgroundColor = UIColor.listItem
        addSubview(emailView)
        emailView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(fieldWidth)
            make.right.equalToSuperview().offset(-fieldWidth)
            make.height.equalTo(fieldHeight)
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }
        
        addSubview(passwordView)
        passwordView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(fieldWidth)
            make.right.equalToSuperview().offset(-fieldWidth)
            make.height.equalTo(fieldHeight)
            make.top.equalTo(emailView.snp.bottom).offset(offset)
            make.centerX.equalToSuperview()
        }
        
        addSubview(submitView)
        submitView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(fieldWidth)
            make.right.equalToSuperview().offset(-fieldWidth)
            make.height.equalTo(fieldHeight)
            make.top.equalTo(passwordView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        addSubview(thirdTipView)
        thirdTipView.snp.makeConstraints { (make) in
            make.height.equalTo(fieldHeight)
            make.top.equalTo(submitView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
        }
        
       
    }
    
    
}
