//
//  UIView+IBDesignable.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    @IBInspectable var border: UIColor {
        get {
            guard let borderColor = self.layer.borderColor else {return UIColor.black}
            return UIColor(cgColor: borderColor)
        }
        set(newValue) {
            self.layer.borderColor = newValue.cgColor
        }

    }
    
    @IBInspectable var borderWidth: CGFloat {
        set(newValue) {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
}


