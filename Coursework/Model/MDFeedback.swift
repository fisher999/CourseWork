//
//  MDFeedback.swift
//  Coursework
//
//  Created by Victor on 18/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

public struct MDFeedback {
    var id: Int?
    let date: String?
    let rating: Float
    let user: MDUser?
    let comment: String
    
    init(rating: Float, comment: String) {
        self.rating = rating
        self.comment = comment
        self.id = nil
        self.date = nil
        self.user = nil
    }
    
    init(id: Int?, date: String?, rating: Float, user: MDUser?, comment: String) {
        self.id = id
        self.date = date
        self.rating = rating
        self.user = user
        self.comment = comment
    }
}

//MARK: Decodable
extension MDFeedback: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case rating
        case user
        case comment
        case isYourComment
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let date = try container.decode(String.self, forKey: .date)
        let rating = try container.decode(Float.self, forKey: .rating)
        let user = try container.decode(MDUser.self, forKey: .user)
        let comment = try container.decode(String.self, forKey: .comment)
        
        self.init(id: id, date: date, rating: rating, user: user, comment: comment)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(rating, forKey: .rating)
        try container.encode(comment, forKey: .comment)
    }
    
}

//MARK: Equatable
extension MDFeedback: Equatable {
    public static func == (lhs: MDFeedback, rhs: MDFeedback) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}

