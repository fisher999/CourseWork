//
//  MDBooking.swift
//  Coursework
//
//  Created by Victor on 04/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

public struct MDBooking: Codable {
    let id: Int
    let hotelId: Int
    let apartmentId: Int
    let originAccomodation: Date
    let endAccomodation: Date
    let amountOfPersons: Int
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case hotelId = "hotel_id"
        case apartmentId = "apartment_id"
        case originAccomodation = "origin_accomodation"
        case endAccomodation = "end_accomodation"
        case amountOfPersons = "amount_of_persons"
        case date
    }
    
    init(apartmentId: Int, originAccomodation: Date, endAccomodation: Date, amountOfPersons: Int) {
        self.id = 0
        self.hotelId = 0
        self.apartmentId = apartmentId
        self.originAccomodation = originAccomodation
        self.endAccomodation = endAccomodation
        self.amountOfPersons = amountOfPersons
        self.date = Date()
    }
}

//MARK: Decodable
extension MDBooking {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try container.decode(Int.self, forKey: .id)
            hotelId = try container.decode(Int.self, forKey: .hotelId)
            apartmentId = try container.decode(Int.self, forKey: .apartmentId)
            originAccomodation = try container.decode(String.self, forKey: .originAccomodation).toDate()!
            endAccomodation = try container.decode(String.self, forKey: .endAccomodation).toDate()!
            amountOfPersons = try container.decode(Int.self, forKey: .amountOfPersons)
            date = try container.decode(String.self, forKey: .date).toDate()!
        }
        catch let error {
            throw error
        }
    }
}

//MARK: Encodable
extension MDBooking {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(id, forKey: .id)
            try container.encode(hotelId, forKey: .hotelId)
            try container.encode(apartmentId, forKey: .apartmentId)
            try container.encode(originAccomodation.getTimeString(), forKey: .originAccomodation)
            try container.encode(endAccomodation.getTimeString(), forKey: .endAccomodation)
            try container.encode(amountOfPersons, forKey: .amountOfPersons)
        }
        catch let error {
            throw error
        }
    }
}
