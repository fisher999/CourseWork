//
//  UIView+Nib.swift
//  Coursework
//
//  Created by Victor on 17/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

public protocol NibCompatible: class {
    static func nib() -> UINib
}

extension UIView: NibCompatible {
    static public func nib() -> UINib {
        return nib(forType: self)
    }
}

public extension UIView {
    public func loadFromNib() -> UIView {
        let name = UIView.nibName(forType: self.classForCoder)
        let bundle = Bundle(for: type(of: self))
        return loadFromNibNamed(name, bundle: bundle)
    }
    
    public func loadFromNibPadAdapted() -> UIView {
        let name = UIView.nibName(forType: self.classForCoder,
                                  padAdapted: true)
        let bundle = Bundle(for: type(of: self))
        return loadFromNibNamed(name, bundle: bundle)
    }
    
    public func loadFromNibNamed(_ name: String, bundle: Bundle) -> UIView {
        guard let view = bundle.loadNibNamed(name, owner: self, options: nil)?.last
            as? UIView else {
                fatalError("Can not load view named \(name)")
        }
        addSubview(view)
        addBorderConstraintsForSubview(view: view)
        
        return view
    }
}

public extension UIView {
    static func nib(forType type: Swift.AnyClass) -> UINib {
        let nibName = self.nibName(forType: type)
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib
    }
    
    static func nibName(forType type: Swift.AnyClass,
                        padAdapted: Bool = false) -> String {
        let fullTypeName = NSStringFromClass(type)
        
        let nameComponents = fullTypeName.components(separatedBy: ".")
        if let lastNameComponent = nameComponents.last {
            if padAdapted,
                UIDevice.current.userInterfaceIdiom == .pad {
                return lastNameComponent.appending("Pad")
            }
            return lastNameComponent
        } else {
            return fullTypeName
        }
    }
    
    func addBorderConstraintsForSubview(view: UIView) {
        assert(view.superview == self, "\(view) superview must be equal self")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: ["view": view]))
    }
}
