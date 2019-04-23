//
//  MDApartmentType.swift
//  Coursework
//
//  Created by Victor on 15/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

enum ApartmentType: String {
    case oneStar = "1 star"
    case twoStar = "2 star"
    case threeStar = "3 star"
    case fourStar = "4 star"
    case fiveStar = "5 star"
}

struct MDApartmentType {
    let type: ApartmentType
    let numberOfRooms: Int
}

extension MDApartmentType: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case numberOfRooms
    }
    
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            fatalError("Cant make container")
        }
        guard let name = try container.decodeIfPresent(String.self, forKey: .name) else {
            fatalError()
        }
        
        guard let numberOfRooms = try container.decodeIfPresent(Int.self, forKey: .numberOfRooms) else {
            fatalError()
        }
        
        guard let apartmentType = ApartmentType.init(rawValue: name) else {
            fatalError()
        }
        
        self.init(type: apartmentType, numberOfRooms: numberOfRooms)
    }
}
