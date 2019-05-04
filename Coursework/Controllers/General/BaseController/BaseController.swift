//
//  BaseController.swift
//  Coursework
//
//  Created by Victor on 02/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

import UIKit
import ReactiveSwift
import Result

class BaseController: UIViewController {
    //MARK: Properties
    var (lifetime, token) = Lifetime.make()
    
    var menuButtonTapped: Signal<(), NoError>
    fileprivate var menuButtonTappedObserver: Signal<(), NoError>.Observer
    
    init() {
        (menuButtonTapped, menuButtonTappedObserver) = Signal.pipe()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
