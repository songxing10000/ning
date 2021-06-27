//
//  LoginController.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/6.
//  Copyright © 2020 tuicool. All rights reserved.
//

import UIKit

class UserLoginController: BaseViewController {
    
    private lazy var loginView: LoginView = {
        return LoginView()
    }()

    override func setupLayout() {
        view.addSubview(loginView)
        loginView.snp.makeConstraints{ $0.edges.equalTo(self.view.usnp.edges) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登录"
        loginView.submitView.addTarget(self, action: #selector(clickLoginEmail), for: .touchUpInside)
    }
    @objc private func clickLoginEmail() {
        let email = NingUtils.trim(loginView.emailView.text)
        let password = NingUtils.trim(loginView.passwordView.text)
        if (email.isEmpty) {
            showAlert("邮箱不能为空")
            return
        }
        if (password.isEmpty) {
            showAlert("密码不能为空")
            return
        }
        UserApiLoadingProvider.request(UserApi.loginWithEmail(email: email, password: password),
            model: UserWrapper.self) { [weak self] (returnData) in
            self?.postLoginWithEmail(returnData)
        }
    }
    
    func postLoginWithEmail(_ result: UserWrapper?){
        if !showErrorResultAlert(result) {
            return
        }
        let user = result!.user!
        DAOFactory.userDAO.saveUser(user)
        if user.is_new {
            pushViewController(NingColdTopicController())
            return
        }
        reloadApp()
        pressBack()
    }
}
