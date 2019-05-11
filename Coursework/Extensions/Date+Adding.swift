//
//  Date+Adding.swift
//  Coursework
//
//  Created by Victor on 08/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension Date {
    func nextDay() -> Date? {
        let calendar = Calendar.init(identifier: .gregorian)
        let nextDay = calendar.date(byAdding: .init(day: 1), to: self)
        return nextDay
    }
    
    static func getDays(originDate: Date, endDate: Date) -> Int? {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: originDate)
        let date2 = calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day
    }
}
