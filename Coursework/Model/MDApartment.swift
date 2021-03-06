//
//  MDApartment.swift
//  Coursework
//
//  Created by Victor on 15/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDApartment {
    let id: Int
    let hotelId: Int
    let hotelName: String
    let apartmentType: MDApartmentType
    let conditions: MDConditions
    let pictures: [String]
    let price: Float
}

extension MDApartment: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case hotelId
        case hotelName
        case apartmentType
        case conditions
        case pictures
        case price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let hotelId = try container.decode(Int.self, forKey: .hotelId)
        let hotelName = try container.decode(String.self, forKey: .hotelName)
        let apartmentType = try container.decode(MDApartmentType.self, forKey: .apartmentType)
        let conditions = try container.decode(MDConditions.self, forKey: .conditions)
        let pictures = try container.decode([String].self, forKey: .pictures)
        let price = try container.decode(Float.self, forKey: .price)
        
        self.init(id: id, hotelId: hotelId, hotelName: hotelName, apartmentType: apartmentType, conditions: conditions, pictures: pictures, price: price)
    }
}

