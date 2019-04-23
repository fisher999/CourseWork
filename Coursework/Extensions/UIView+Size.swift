//
//  UIView+Size.swift
//  Coursework
//
//  Created by Victor on 07/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var width: CGFloat {
        return self.frame.size.width
    }
    
    var height: CGFloat {
        return self.frame.size.height
    }
    
    var top: CGFloat {
        return self.y
    }
    
    var bottom: CGFloat {
        return self.y + self.height
    }
    
    func setCircle() {
        self.layoutSubviews()
        self.layer.cornerRadius = self.height / 2
        self.clipsToBounds = true
    }
}
