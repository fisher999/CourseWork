//
//  String+Date.swift
//  Coursework
//
//  Created by Victor on 04/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df.date(from: self)
    }
}
