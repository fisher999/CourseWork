//
//  MDConditions.swift
//  Coursework
//
//  Created by Victor on 15/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDConditions: Decodable {
    let wifi: Bool
    let pool: Bool
    let spa: Bool
    let allowedPets: Bool
    let conditioner: Bool
    let restaraunt: Bool
    let bar: Bool
    let gym: Bool
}

extension MDConditions {
    func arrayRepresent() -> [Condition] {
        var array: [Condition] = []
        let elementaryString = "conditions-"
        
        array.append(Condition.init(title: "WIFI", icon: elementaryString.appending("wifi"), enabled: self.wifi))
        array.append(Condition.init(title: "Бассейн", icon: elementaryString.appending("pool"), enabled: self.pool))
        array.append(Condition.init(title: "SPA", icon: elementaryString.appending("spa"), enabled: self.spa))
        array.append(Condition.init(title: "Домашние животные", icon: elementaryString.appending("pets"), enabled: self.allowedPets))
        array.append(Condition.init(title: "Кондиционер", icon: elementaryString.appending("conditioner"), enabled: self.conditioner))
        array.append(Condition.init(title: "Ресторан", icon: elementaryString.appending("restaraunt"), enabled: self.restaraunt))
        array.append(Condition.init(title: "Бар", icon: elementaryString.appending("bar"), enabled: self.bar))
        array.append(Condition.init(title: "Тренажерный зал", icon: elementaryString.appending("bar"), enabled: self.gym))
        
        return array
    }
}
