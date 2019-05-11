//
//  BookingCompletedController.swift
//  Coursework
//
//  Created by Victor on 09/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class BookingCompletedController: BaseController {
    //MARK: Outlets
    @IBOutlet weak var successView: UIImageView!
    @IBOutlet weak var successLabelText: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    
    let response: MDResponse
    
    init(response: MDResponse) {
        self.response = response
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup () {
        self.successLabelText.font = Fonts.ultraLight(size: 13)
        self.successLabelText.textColor = Colors.gray140
        
        self.dismissButton.setTitle("Вернуться на главный экран", for: .normal)
        self.dismissButton.setTitleColor(UIColor.white, for: .normal)
        self.dismissButton.titleLabel?.font = Fonts.ultraLight(size: 13)
        self.dismissButton.tintColor = UIColor.white
        self.dismissButton.backgroundColor = Colors.defaultColor
        self.dismissButton.setCircle()
        self.dismissButton.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
        
        if self.response.success {
            successView.image = UIImage(named: "success")
        }
        else {
            successView.image = UIImage(named: "error")
        }
        
        self.successLabelText.text = self.response.message
    }
}

extension BookingCompletedController {
    @objc func dismissButtonTapped(_ sender: UIButton) {
        
    }
}
