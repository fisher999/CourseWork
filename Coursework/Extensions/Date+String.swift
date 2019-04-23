//
//  Date+String.swift
//  Coursework
//
//  Created by Victor on 19/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension Date {
    static func is24Format() -> Bool {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateStyle = .none
        df.timeStyle = .short
        let string = df.string(from: Date())
        var is24: Bool = true
        if string.range(of: df.amSymbol) != nil {
            is24 = false
        }
        if string.range(of: df.pmSymbol) != nil {
            is24 = false
        }
        
        return is24
    }
    
    func getTimeString() -> String {
        let df = DateFormatter()
        if Date.is24Format() {
            df.dateFormat = "HH:mm a\ndd MMM"
        } else {
            df.dateFormat = "HH:mm\ndd MMM"
        }
        
        return df.string(from: self)
    }
}
