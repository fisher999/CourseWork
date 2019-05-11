//
//  TabBarController.swift
//  Coursework
//
//  Created by Victor on 09/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    func setup(viewController: [UIViewController]) {
        self.viewControllers = viewControllers
        print(self.viewControllers)
        self.viewControllers![0].tabBarItem = UITabBarItem(title: "Бронирование", image: UIImage(named: "tabbar-booking"), tag: 0)
        self.viewControllers![1].tabBarItem = UITabBarItem(title: "Аккаунт", image: UIImage(named: "tabbar-account"), tag: 1)
    }
}
