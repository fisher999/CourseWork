//
//  Date+String.swift
//  Coursework
//
//  Created by Victor on 19/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension Date {
    func getTimeString() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df.string(from: self)
    }
}
