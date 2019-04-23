//
//  KeyboardNotificationHandler.swift
//  Coursework
//
//  Created by Victor on 07/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

/**
 Views that implement this protocol must return rect position for scroll view
 */
public protocol ActiveFrameFieldGetter: class {
    var activeFieldViewFrame: CGRect? { get }
}

public extension UIView.AnimationCurve {
    var animationOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(rawValue << 16))
    }
}

public struct KeyboardFrameChangeParams {
    public let animationDuration: Double
    public let animationOptions: UIView.AnimationOptions
    public let isShowing: Bool
    public let keyboardSize: CGSize
    
    public init(duration: Double,
                curve: UIView.AnimationCurve,
                isShowing: Bool,
                size: CGSize) {
        self.animationDuration = duration
        self.animationOptions = curve.animationOptions
        self.isShowing = isShowing
        self.keyboardSize = size
    }
}

public class KeyboardNotificationHandler: NSObject {
    public typealias KeyboardWillChangeFrameBlock = ((KeyboardFrameChangeParams) -> Void)
    
    // MARK: Public
    public var keyboardWillChangeFrame: KeyboardWillChangeFrameBlock?
    
    // MARK: Private properties
    fileprivate weak var view: UIView?
    fileprivate weak var scrollView: UIScrollView?
    fileprivate weak var bottomView: UIView?
    fileprivate weak var activeFrameGetter: ActiveFrameFieldGetter?
    
    fileprivate var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    public override init() {
        super.init()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    /**
     Configurate in viewDidLoad
     */
    public func setup(withView view: UIView,
                      scrollView: UIScrollView?,
                      activeFrameGetter: ActiveFrameFieldGetter?,
                      addTapGesture: Bool = true,
                      bottomView: UIView? = nil) {
        
        self.view = view
        self.scrollView = scrollView
        self.bottomView = bottomView
        self.activeFrameGetter = activeFrameGetter
        
        if addTapGesture {
            configure()
        }
    }
    
    /** Controller must subscribe this in viewDidAppear/viewWillAppear
     */
    public func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillChangeFrame(notification:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    /** Controller must unsubscribe this in viewDidDisappear/viewWillDisappear
     */
    public func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

// MARK: Actions
private extension KeyboardNotificationHandler {
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardShown = keyboardFrame.origin.y < UIScreen.main.bounds.height
        
        //giving other views a chance to adapt by calling a block with all animation params
        if let closure = keyboardWillChangeFrame {
            if let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                let curveIntValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                let curve = UIView.AnimationCurve(rawValue: curveIntValue) {
                let params = KeyboardFrameChangeParams(
                    duration: duration,
                    curve: curve,
                    isShowing: keyboardShown,
                    size: keyboardFrame.size
                )
                closure(params)
                return
            }
        }
        
        guard let scrollView = scrollView else {
            return
        }
        
        if keyboardShown {
            let keyboardSize = keyboardFrame.size
            var offset = keyboardSize.height
            if let bottomView = bottomView {
                offset -= bottomView.frame.height
            }
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            guard let activeFieldRect = activeFrameGetter?.activeFieldViewFrame else {
                return
            }
            
            var rect = scrollView.frame
            rect.size.height -= keyboardSize.height
            if !rect.contains(activeFieldRect) {
                DispatchQueue.main.async { [weak self] in
                    self?.scrollView?.scrollRectToVisible(activeFieldRect, animated: true)
                }
            }
        } else {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    @objc func viewTapped() {
        view?.endEditing(true)
    }
}

// MARK: UIGestureRecognizerDelegate
extension KeyboardNotificationHandler: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let activeView = touch.view {
            if activeView.isKind(of: UIControl.self) {
                return false
            }
        }
        return true
    }
}

// MARK: Supporting methods
private extension KeyboardNotificationHandler {
    func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view?.addGestureRecognizer(tapGesture)
    }
}
