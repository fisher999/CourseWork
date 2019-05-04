//
//  BaseViewModel.swift
//  Coursework
//
//  Created by Victor on 02/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit
import Result

class BaseViewModel {
    //MARK: Properties
    var (lifetime, token) = Lifetime.make()
    
}
