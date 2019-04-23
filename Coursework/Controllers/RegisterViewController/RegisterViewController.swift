//
//  RegisterViewController.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Moya
import Result

class RegisterViewController: UIViewController {
    var (lifetime, token) = Lifetime.make()
    //MARK: -Outlets
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernamedBorder: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordBorder: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK: -Properties
    var viewModel: RegisterViewModel
    var keyboardHandler = KeyboardNotificationHandler()
    
    //MARK: -Reactive
    var alertBinding: BindingTarget<ErrorAlert> {
        return BindingTarget<ErrorAlert>.init(lifetime: lifetime, action: {[weak self] (alert) in
            guard let sself = self else {return}
            sself.showAlertError(errorAlert: alert)
        })
    }
    
    var pushVCBinding: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            guard let this = self else {return}
            this.present(vc, animated: true, completion: nil)
        })
    }
    
    var didResponse: BindingTarget<String> {
        return BindingTarget<String>.init(lifetime: lifetime, action: { (string) in
            print(string)
        })
    }
    
    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler.subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardHandler.unsubscribeFromKeyboardNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    func setup() {
        self.usernamedBorder.backgroundColor = UIColor.white
        self.usernamedBorder.border = Colors.defaultColor
        self.usernamedBorder.borderWidth = 2
        self.usernamedBorder.setCircle()
        
        self.passwordBorder.backgroundColor = UIColor.white
        self.passwordBorder.border = Colors.defaultColor
        self.passwordBorder.borderWidth = 2
        self.passwordBorder.setCircle()
        
        self.usernameTextField.font = Fonts.mediumItalic(size: 14)
        self.usernameTextField.placeholder = "Логин"
        
        self.passwordTextField.font = Fonts.mediumItalic(size: 14)
        self.passwordTextField.placeholder = "Пароль"
        
        self.passwordTextField.isSecureTextEntry = true
    
        self.loginButton.backgroundColor = UIColor.white
        self.loginButton.border = Colors.defaultColor
        self.loginButton.borderWidth = 2
        self.loginButton.setCircle()
        
        self.registerButton.backgroundColor = UIColor.white
        self.registerButton.border = Colors.defaultColor
        self.registerButton.borderWidth = 2
        self.registerButton.setCircle()
    
        self.activityIndicator.isHidden = true
        
        self.keyboardHandler.setup(withView: self.view, scrollView: self.scrollView, activeFrameGetter: self)
    }
    
    func bind() {
        self.viewModel.loginSignal <~ self.loginButton.reactive.mapControlEvents(UIControl.Event.touchUpInside, {[weak self] (_) -> (String?, String?) in
            guard let sself = self else {return (nil,nil)}
            let username = sself.usernameTextField.text
            let password = sself.passwordTextField.text
            return (username,password)
        })
        
        self.alertBinding <~ self.viewModel.registerCompleted.materialize().map({(event) -> ErrorAlert? in
            if let _ = event.error {
                return ErrorAlert(title: "Поля пусты", message: "Пожалуйста заполните все поля")
            }
            else {
                return nil
            }
        }).filterMap({ (error) -> ErrorAlert? in
            if error.optional != nil {
                return error.optional!
            }
            else {
                return nil
            }
        })
        
        self.alertBinding <~ self.viewModel.didResponse.materialize().map({ (event) -> ErrorAlert? in
            guard let error = event.error else {return nil}
            switch error {
            case .moyaError(let error):
                return ErrorAlert(title: "Ошибка сервера", message: error.localizedDescription)
            default:
                return nil
            }

        }).filterMap({ (error) -> ErrorAlert? in
            if error.optional != nil {
                return error.optional!
            }
            else {
                return nil
            }
        })
        self.activityIndicator.reactive.isAnimating <~ self.viewModel.loading
        self.activityIndicator.reactive.isHidden <~ self.viewModel.loading.map({ (loading) -> Bool in
            return !loading
        })
        
        self.didResponse <~ viewModel.didResponse.materialize().map({ (event) -> String? in
        return event.value
        }).filterMap({ (string) -> String? in
            return string
        })
        
        self.pushVCBinding <~ viewModel.pushVC
    }
    
    

}

extension RegisterViewController: ActiveFrameFieldGetter {
    var activeFieldViewFrame: CGRect? {
        let inputs: [UITextField] = [self.usernameTextField, self.passwordTextField]
        guard let first = inputs.first(where: { $0.isFirstResponder }) else {
            return nil
        }
        return view.convert(first.frame, to: self.view)
    }
}
