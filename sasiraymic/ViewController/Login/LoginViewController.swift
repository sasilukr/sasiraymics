//
//  LoginViewController.swift
//  sasiraymic
//
//  Created by Sasi Ruangrongsorakai on 12/29/17.
//  Copyright © 2017 com.sasiluk. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider


class LoginViewController: UIViewController {
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var loginButton = UIButton()
    var signupButton = UIButton()
    var forgotPasswordButton = UIButton()
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "georgew"
        passwordTextField.text = "123456"
        emailTextField.placeholder = R.string.localizable.loginEmail()
        emailTextField.backgroundColor = Style.Color.Primary.ui
        emailTextField.layer.cornerRadius = Style.Spacing.X2
        
        passwordTextField.placeholder = R.string.localizable.loginPassword()
        passwordTextField.backgroundColor = Style.Color.Primary.ui
        passwordTextField.layer.cornerRadius = Style.Spacing.X2
        
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.setTitleColor(.gray, for: .disabled)
        loginButton.setTitle(R.string.localizable.buttonLogin(), for: .normal)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

        signupButton.setTitleColor(.black, for: .normal)
        signupButton.setTitleColor(.gray, for: .disabled)
        signupButton.setTitle(R.string.localizable.buttonSignup(), for: .normal)
        signupButton.addTarget(self, action: #selector(signupAction), for: .touchUpInside)

    
        forgotPasswordButton.setTitleColor(.black, for: .normal)
        forgotPasswordButton.setTitle(R.string.localizable.buttonForgotPassword(), for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction), for: .touchUpInside)
        

        
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(signupButton)
        self.view.addSubview(forgotPasswordButton)

        self.view.backgroundColor = .white
        emailTextField.snp.makeConstraints { m in
            m.width.equalTo(self.view.frame.size.width)
            m.top.equalTo(self.view.snp.top).offset(Style.Spacing.X8)
        }
        
        passwordTextField.snp.makeConstraints { m in
            m.width.equalTo(self.view.frame.size.width)
            m.top.equalTo(self.emailTextField.snp.bottom).offset(Style.Spacing.X2)
        }
        
        
        loginButton.snp.makeConstraints { m in
            m.width.equalTo(self.view.frame.size.width/2)
            m.height.equalTo(Style.Spacing.X4)
            m.top.equalTo(self.passwordTextField.snp.bottom).offset(Style.Spacing.X6)
            m.left.equalTo(self.view.snp.left)
        }
        
        signupButton.snp.makeConstraints { m in
            m.width.equalTo(self.view.frame.size.width/2)
            m.height.equalTo(Style.Spacing.X4)
            m.top.equalTo(self.loginButton.snp.top)
            m.left.equalTo(self.loginButton.snp.right)
        }
        
        forgotPasswordButton.snp.makeConstraints { m in
            m.width.equalTo(self.view.frame.size.width)
            m.height.equalTo(Style.Spacing.X4)
            m.top.equalTo(self.loginButton.snp.bottom).offset(Style.Spacing.X6)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailTextField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
    }
    
    
    @objc func inputDidChange() {
        if (self.emailTextField.text?.isEmpty == false
            && self.passwordTextField.text?.isEmpty == false) {
            self.loginButton.isEnabled = true
            self.loginButton.isUserInteractionEnabled = true
        } else {
            self.loginButton.isEnabled = false
            self.loginButton.isUserInteractionEnabled = false
        }
    }
    
    @objc func forgotPasswordAction() {
        guard let emailAddress = self.emailTextField.text, emailAddress.isEmpty == false else {
            let alertController = UIAlertController(title: "Enter Email",
                                                    message: "Please enter your email address and then select Forgot Password if you want to reset your password.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: R.string.localizable.buttonOk(), style: .default, handler: nil)
            alertController.addAction(retryAction)
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        let vc = ForgotPasswordViewController()
        vc.emailAddress = emailAddress
        present(vc, animated: true, completion: nil)
    }
    
    @objc func signupAction() {
        present(SignupViewController(), animated: true, completion: nil)
    }
    
    @objc func loginAction() {
        if (self.emailTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false) {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTextField.text!, password: self.passwordTextField.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        } else {
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
            self.present(alertController, animated: true, completion:  nil)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput,
                           passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        
        print("\(#function)")
        //keep a handle to the completion, you'll need it continue once you get the inputs from the end user
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        
//                DispatchQueue.main.async {
//                    if (self.usernameText == nil) {
//                        self.usernameText = authenticationInput.lastKnownUsername
//                    }
//                }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        print("\(#function)")
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
//                self.emailTextField.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

