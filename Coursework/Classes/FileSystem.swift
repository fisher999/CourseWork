//
//  FileSystem.swift
//  Coursework
//
//  Created by Victor on 12/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

public class FileSystem {
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("/Download/")
        return directory
    }()
    
}
