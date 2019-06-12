//
//  UITabBar+Instantinate.swift
//  Coursework
//
//  Created by Victor on 11/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UITabBarController {
    static func instantinate() -> UITabBarController {
        //Booking
        let viewModel = HotelsListViewModel()
        let hotelListVC = HotelsListController(viewModel: viewModel)
        let bookingNavVC = UINavigationController(rootViewController: hotelListVC)
        bookingNavVC.tabBarItem = UITabBarItem(title: "Бронирование", image: UIImage(named: "tabbar-booking")?.resizeImage(targetSize: CGSize(width: 22, height: 22)), tag: 0)
        //
        //Account
        let accountListController = AccountListController()
        let accountNavVc = UINavigationController(rootViewController: accountListController)
        accountNavVc.tabBarItem = UITabBarItem(title: "Аккаунт", image: UIImage(named: "tabbar-account")?.resizeImage(targetSize: CGSize(width: 22, height: 22)), tag: 1)
        
        //TAB BAR
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = [bookingNavVC, accountNavVc]
        
        return tabBarController
    }
}
