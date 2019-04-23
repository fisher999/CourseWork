//
//  UIColor + RGB.swift
//  Coursework
//
//  Created by Victor on 06/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    func isEqual(to color: UIColor?, with tolerance: CGFloat) -> Bool {
        guard let right = color else {
            return false
        }
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        right.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return fabs(r1 - r2) <= tolerance &&
            fabs(g1 - g2) <= tolerance &&
            fabs(b1 - b2) <= tolerance &&
            fabs(a1 - a2) <= tolerance
    }
    
    func rgbToHue() -> (h:CGFloat, s:CGFloat, b:CGFloat)? {
        let components = self.cgColor.components
        var (r,g,b):(CGFloat,CGFloat,CGFloat)
        guard let comp = components else {return nil}
        r = comp[0]
        g = comp[1]
        b = comp[2]
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
            if r == maxV {
                hue = (g - b) / delta
            }
            else if g == maxV {
                hue = 2 + (b - r) / delta
            }
            else {
                hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV
        return (h:hue/360, s:saturation, b:brightness)
    }
    
    func hsba() -> (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.responds(to: #selector(UIColor.getHue(_:saturation:brightness:alpha:))) && self.cgColor.numberOfComponents == 4 {
            self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        }
        
        return (h, s, b, a)
    }
    
}
