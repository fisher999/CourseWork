//
//  String+base64.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
