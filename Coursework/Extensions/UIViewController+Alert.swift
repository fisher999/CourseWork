//
//  UIViewController+Alert.swift
//  Coursework
//
//  Created by Victor on 07/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlertError(errorAlert: ErrorAlert) {
        let alertError = UIAlertController(title: errorAlert.title , message: errorAlert.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok" , style: .cancel, handler: nil)
        alertError.addAction(okAction)
        self.present(alertError, animated: true, completion: nil)
    }

    func showSuccessAlert(messageTitle: String) {
        let alert = UIAlertController(title: messageTitle , message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok" , style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
