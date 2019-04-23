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
