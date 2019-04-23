//
//  Moya+Request.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import ReactiveSwift

public extension MoyaProvider {
    public func request(_ targetType: Target) -> SignalProducer<Response, MoyaError> {
        
        return reactive.request(targetType).observe(on: UIScheduler()).filterSuccessfulStatusCodes()
    }
}
