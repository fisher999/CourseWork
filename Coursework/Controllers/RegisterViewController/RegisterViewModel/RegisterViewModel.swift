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

class RegisterViewModel {
    enum RegisterError: Error {
        case emptyField
        case moyaError(MoyaError)
    }
    //MARK: -Properties
    var (lifetime, token) = Lifetime.make()
    
    var provider: MoyaProvider<Network>
    
    //MARK: -Reactive
    var loginSignal: BindingTarget<(String?, String?)> {
        return BindingTarget<(String?, String?)>.init(lifetime: lifetime, action: {[weak self] (username, password) in
            guard let sself = self else {return}
            if let name = username, !name.isEmpty, let pass = password, !pass.isEmpty {
                sself.login(username: name, password: pass)
            }
            else {
                sself.registerCompetedObserver.send(error: .emptyField)
            }
        })
    }
    
    var didResponse: Signal<String,RegisterError>
    private var didResponseObserver: Signal<String,RegisterError>.Observer
    
    var registerCompleted: Signal<(), RegisterError>
    private var registerCompetedObserver: Signal<(),RegisterError>.Observer
    
    var loading: Signal<Bool,NoError>
    private var loadingObserver: Signal<Bool,NoError>.Observer
    
    var pushVC: Signal<UIViewController,NoError>
    var pushVCObserver: Signal<UIViewController, NoError>.Observer
    
    init(provider:MoyaProvider<Network> = MoyaProvider<Network>.init()) {
        self.provider = provider
        
        (didResponse, didResponseObserver) = Signal.pipe()
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
            sself.didResponseObserver.send(error: .moyaError(error))
        }) {[weak self] (response) in
            guard let json = try? response.mapJSON() as! [String: Any] else {return}
    
            let token = json["token"]
            guard let sself = self else {return}
            sself.loadingObserver.send(value: false)
            UserDefaults.standard.set(token, forKey: "basic_auth")
            UserManager.shared.currentUser = user
            
            let viewModel = HotelsListViewModel()
            let hotelsListVC = HotelsListController(viewModel: viewModel)
            let navVC = UINavigationController(rootViewController: hotelsListVC)
            
            sself.pushVCObserver.send(value: navVC)
        }
        .start()
    }
}
