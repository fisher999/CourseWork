//
//  Hotel.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDHotel: Decodable {
    let id: Int
    let country: String
    let street: String
    let city: String
    let house_index: String
    let name: String
    let price: Float
    let rating: Float
    let image_url: String
    let description: String?
}
