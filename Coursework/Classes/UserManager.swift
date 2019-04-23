//
//  UserManager.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

class UserManager {
    //MARK: -Properties
    static var shared: UserManager = UserManager()
    var currentUser: User?
    
    var userIsAuth: Bool {
        guard let _ = self.currentUser else {
            return false
        }
        
        return true
    }
    
    var basicAuth: String? {
        if userIsAuth {
            return "\(currentUser!.username):\(currentUser!.password)".toBase64()
        }
        else {
            return nil
        }
    }
    
    private init() {
        if let token = UserDefaults.standard.string(forKey: "basic_auth") {
            let string = token.fromBase64()
            let components = string?.components(separatedBy: ":")
            if let username = components?[0] ,let password = components?[1] {
                self.currentUser = User.init(username: username, password: password)
            }
        }
    }
    
    
}
