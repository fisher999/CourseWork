//
//  Floar+Round.swift
//  Coursework
//
//  Created by Victor on 25/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension Double {
    public func floorTo(precision: Int) -> Double {
        let divisor = pow(10.0, Double(precision))
        return floor(self * divisor) / divisor
    }
}
