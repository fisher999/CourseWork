//
//  AppDelegate.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var baseUrl = "http://10.0.30.149:8000"

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        if !UserManager.shared.userIsAuth {
            let viewModel = RegisterViewModel()
            let vc = RegisterViewController(viewModel: viewModel)
            self.window?.rootViewController = vc
        }
        else {
            self.window?.rootViewController = UITabBarController.instantinate()
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

