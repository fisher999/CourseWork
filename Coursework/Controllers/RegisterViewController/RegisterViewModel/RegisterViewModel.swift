//
//  RegisterViewModel.swift
//  Coursework
//
//  Created by Victor on 07/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya
import Result
import UIKit

class RegisterViewModel: BaseViewModel {
    enum RegisterError: Error {
        case registerError(String)
        case invalidPasswordOrUsername
        case emptyField
        case moyaError(MoyaError)
    }

    //MARK: Properties
    
    var provider: MoyaProvider<Network>
    
    //MARK: -Reactive
    var loginSignal: BindingTarget<(String, String)> {
        return BindingTarget<(String, String)>.init(lifetime: lifetime, action: {[weak self] (username, password) in
            guard let sself = self else {return}
            sself.login(username: username, password: password)
        })
    }
    
    var registerSignal: BindingTarget<(String, String)> {
        return BindingTarget<(String, String)>.init(lifetime: lifetime, action: {[weak self] (username, password) in
            guard let sself = self else {return}
            sself.register(username: username, password: password)
        })
    }
    
    var didResponseAction: Action<(String?, RegisterViewModel.RegisterError?), String, RegisterViewModel.RegisterError>
    fileprivate let didResponseSignalProducerGenerator: (String?, RegisterViewModel.RegisterError?) -> SignalProducer<String, RegisterViewModel.RegisterError>  = { text, error  in
        return SignalProducer<String, RegisterViewModel.RegisterError> { (observer, lifetime) in
   
            
            if let err = error {
                observer.send(error: err)
            }
            
            if let txt = text {
                observer.send(value: txt)
            }
        }
    }
    
    var registerCompleted: Signal<(), RegisterError>
    private var registerCompetedObserver: Signal<(),RegisterError>.Observer
    
    var loading: Signal<Bool,NoError>
    private var loadingObserver: Signal<Bool,NoError>.Observer
    
    var pushVC: Signal<UIViewController,NoError>
    var pushVCObserver: Signal<UIViewController, NoError>.Observer
    
    init(provider:MoyaProvider<Network> = MoyaProvider<Network>.init()) {
        self.provider = provider
        
        didResponseAction = Action<(String?, RegisterViewModel.RegisterError?), String, RegisterViewModel.RegisterError>.init(execute: didResponseSignalProducerGenerator)
        
        (loading, loadingObserver) = Signal.pipe()
        loadingObserver.send(value: false)
        (registerCompleted, registerCompetedObserver) = Signal.pipe()
        (pushVC, pushVCObserver) = Signal.pipe()
    }
    
    //MARK: -Funcs
    
    private func login(username: String, password: String) {
        let user = User.init(username: username, password: password)
        
        self.provider.request(.login(user)).on(
            started: { [weak self] in
                guard let sself = self else {
                    return
                }
                sself.loadingObserver.send(value: true)
        },  failed: {[weak self] (error) in
            
            guard let sself = self else {
                return
            }
            sself.loadingObserver.send(value: false)
            sself.didResponseAction.apply((nil, .moyaError(error))).start()
            
        })
            .on(value: {[weak self] (response) in
                guard let sself = self else {return}
                guard let json = try? response.mapJSON() as! [String: Any] else {return}
                
                guard let token = json["token"] else {
                    sself.didResponseAction.apply((nil, .invalidPasswordOrUsername)).start()
                    return
                }
                
                sself.loadingObserver.send(value: false)
                UserDefaults.standard.set(token, forKey: "basic_auth")
                UserManager.shared.currentUser = user
                sself.pushVCObserver.send(value: UITabBarController.instantinate())
                }
            )
        .start()
    }
    
    private func register(username: String, password: String) {
        let user = User.init(username: username, password: password)
        
        self.provider.request(.register(user))
            .map(MDResponse.self)
            .on(
            started: { [weak self] in
                guard let sself = self else {
                    return
                }
                sself.loadingObserver.send(value: true)
            },  failed: {[weak self] (error) in
                guard let sself = self else {
                    return
                }
                sself.loadingObserver.send(value: false)
                sself.didResponseAction.apply((nil, .moyaError(error))).start()
                
        })
            .on(value: { [weak self] response in
                if response.success {
                    self?.login(username: username, password: password)
                }
                else {
                    self?.didResponseAction.apply((nil, .registerError(response.message))).start()
                }
            })
            .start()
    }
}
