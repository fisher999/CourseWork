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
    var alertSignal: Signal<ErrorAlert,NoError>
    fileprivate var alertSignalObserver: Signal<ErrorAlert,NoError>.Observer
    
    var loginSignal: Signal<(String, String), NoError>
    fileprivate var loginSignalObserver: Signal<(String, String), NoError>.Observer
    
    var registerSignal: Signal<(String, String), NoError>
    fileprivate var registerSignalObserver: Signal<(String, String), NoError>.Observer
    
    private var loginButtonAction: Action<(String?, String?), (String,String), RegisterViewModel.RegisterError>
    fileprivate let loginButtonSignalProducerGenerator: (String?, String?) -> SignalProducer<(String, String), RegisterViewModel.RegisterError>  = { login, password  in
        return SignalProducer<(String, String), RegisterViewModel.RegisterError> { (observer, lifetime) in
            guard let login = login, !login.isEmpty else {
                observer.send(error: RegisterViewModel.RegisterError.emptyField)
                return
            }
            guard let password = password, !password.isEmpty else {
                observer.send(error: RegisterViewModel.RegisterError.emptyField)
                return
            }
            observer.send(value: (login, password))
            observer.sendCompleted()
        }
    }
    
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
        loginButtonAction = Action<(String?, String?), (String,String), RegisterViewModel.RegisterError>.init(execute: loginButtonSignalProducerGenerator)
        (alertSignal, alertSignalObserver) = Signal.pipe()
        (loginSignal, loginSignalObserver) = Signal.pipe()
        (registerSignal, registerSignalObserver) = Signal.pipe()
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
        self.loginButton.addTarget(self, action: #selector(loginTapped(_:)), for: .touchUpInside)
        
        self.registerButton.backgroundColor = UIColor.white
        self.registerButton.border = Colors.defaultColor
        self.registerButton.borderWidth = 2
        self.registerButton.setCircle()
        self.registerButton.addTarget(self, action: #selector(registerTapped(_:)), for: .touchUpInside)
    
        self.activityIndicator.isHidden = true
        
        self.keyboardHandler.setup(withView: self.view, scrollView: self.scrollView, activeFrameGetter: self)
    }
    
    func bind() {
        self.alertBinding <~ alertSignal
        viewModel.registerSignal <~ self.registerSignal
        self.viewModel.loginSignal <~ self.loginSignal
        self.alertBinding <~ viewModel.didResponseAction.errors.map({ (error) -> ErrorAlert in
            switch error {
            case .moyaError(let error):
                return ErrorAlert(title: "Ошибка сервера", message: error.localizedDescription)
            case .invalidPasswordOrUsername:
                return ErrorAlert.init(title: "Ошибка авторизации", message: "Введен неправильный логин или пароль")
            case .registerError(let errorString):
                return ErrorAlert.init(title: "Ошибка регистрации", message: errorString)
            default:
                return ErrorAlert.init(title: "Ошибка", message: error.localizedDescription)
            }
        })
        
        self.activityIndicator.reactive.isAnimating <~ self.viewModel.loading
        self.activityIndicator.reactive.isHidden <~ self.viewModel.loading.map({ (loading) -> Bool in
            return !loading
        })
        
        self.didResponse <~ viewModel.didResponseAction.values
        
        self.pushVCBinding <~ viewModel.pushVC
        
        self.loginButtonAction.errors.observeValues {[weak self] (error) in
            guard let sself = self else {return}
            switch error {
            case .emptyField:
                sself.alertSignalObserver.send(value: ErrorAlert(title: "Поля пусты", message: "Пожалуйста заполните все поля"))
            case .moyaError(let error):
                sself.alertSignalObserver.send(value: ErrorAlert.init(title: "Ошибка сервера", message: error.localizedDescription))
            default:
                return
            }
        }
    }
    
    

}

//MARK: Actions
extension RegisterViewController {
    @objc func loginTapped(_ sender: UIButton) {
        self.loginButtonAction.apply((self.usernameTextField.text, self.passwordTextField.text)).startWithResult {[weak self] (result) in
            guard let sself = self else {return}

            if let value = result.value {
                sself.loginSignalObserver.send(value: value)
            }
        }
    }
    
    @objc func registerTapped(_ sender: UIButton) {
        self.loginButtonAction.apply((self.usernameTextField.text, self.passwordTextField.text)).startWithResult {[weak self] (result) in
            guard let sself = self else {return}
            
            if let value = result.value {
                sself.registerSignalObserver.send(value: value)
            }
        }
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
