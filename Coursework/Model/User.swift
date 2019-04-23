//
//  User.swift
//  Coursework
//
//  Created by Victor on 07/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

public struct User: Codable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}

//MARK: -Encodable
extension User {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(username, forKey: .username)
            try container.encode(password, forKey: .password)
        }
        catch let error {
            throw error
        }
    }
}

//MARK: -Decodable
extension User {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            username = try values.decode(String.self, forKey: .username)
            password = try values.decode(String.self, forKey: .password)
        }
        catch let error {
            throw error 
        }
       
    }
}
