//
//  Hotel.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct Hotel: Decodable {
    let name: String
    let price: Float
    let rating: Float
    let address: Address
    let location: Location
}
