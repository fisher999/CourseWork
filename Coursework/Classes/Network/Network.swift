//
//  Network.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import Alamofire

public enum Network {
    case login(User)
    case register(User)
    case hotelistAtPage(Int)
    case apartments(Int)
    case getComments(Int)
    case postComment(Int, MDFeedback)
    case deleteComment(Int, MDFeedback)
    case makeBooking(MDBooking)
    case bookingList
    case userApartments
    case getBookingListCsv
}

extension Network: TargetType {
    public var baseURL: URL {
        return URL(fileURLWithPath: AppDelegate.baseUrl)
    }
    
    public var path: String {
        switch self {
        case .login:
            return "/login/"
        case .register:
            return "/register/"
        case .hotelistAtPage(let page):
            return "/hotels/\(page)"
        case .apartments(let id):
            return "/hotels/\(id)/apartments"
        case .getComments(let id), .postComment(let id, _), .deleteComment(let id, _):
            return "/hotels/\(id)/feedbacks"
        case .makeBooking:
            return "/booking"
        case .bookingList:
            return "/user/booking"
        case .userApartments:
            return "/user/apartments"
        case .getBookingListCsv:
            return "/user/booking/csv"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .postComment, .makeBooking, .register:
            return .post
        case .hotelistAtPage, .apartments, .getComments, .bookingList, .userApartments, .getBookingListCsv:
            return .get
        case .deleteComment:
            return .delete
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .login(let user), .register(let user):
            return .requestJSONEncodable(user)
        case .hotelistAtPage, .apartments, .getComments, .bookingList, .userApartments, .getBookingListCsv:
            return .requestPlain
        case .postComment(_, let feedback), .deleteComment(_, let feedback):
            return .requestJSONEncodable(feedback)
        case .makeBooking(let booking):
            return .requestJSONEncodable(booking)
        }
    }
    
    public var headers: [String : String]? {
        //TODO
        switch self {
        case .login(_), .register:
            return nil
        default:
            return Network.addAuthorization(to: nil, user: UserManager.shared.currentUser)
        }
    }
}

extension Network {
    static func addAuthorization(to headers: [String: String]?,user:User?) -> [String: String]? {
        guard let currentUser = user else {return nil}
        let username = currentUser.username
        let pass = currentUser.password
        let authStr = "\(username):\(pass)"
        let authData = authStr.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
        let authValue = "Basic \(authData?.base64EncodedString(options: .lineLength76Characters) ?? "")"
        
        var temp: [String: String] = [:]
        if let existHeaders = headers {
            temp = existHeaders
        }
        temp["Authorization"] = authValue
        print(temp)
        return temp
    }
}

