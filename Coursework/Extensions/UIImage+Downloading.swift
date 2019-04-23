//
//  UIImage+Downloading.swift
//  Coursework
//
//  Created by Victor on 13/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//
import Foundation
import UIKit
import Alamofire

fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImage {
    
    static func downloadImageForUrl(url:URLConvertible,succes:@escaping (UIImage?,Error?)->()) {
        Alamofire.request(url).responseData {(response) in
            if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
                succes(cachedImage,nil)
            }
            
            if let data = response.data {
                print(data)
                DispatchQueue.main.async {
                    if let image = UIImage.init(data: data) {
                        imageCache.setObject(image, forKey: url as AnyObject)
                        succes(image,nil)
                    }
                }
            }
            
            if let error = response.error {
                succes(nil,error)
            }
        }
    }
}
