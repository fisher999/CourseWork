//
//  AccountListCell.swift
//  Coursework
//
//  Created by Victor on 11/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class AccountListCell: UITableViewCell, ReusableView, NibLoadableView  {
    //MARK: Outlet
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Properties
    var model: AccountListController.Model? {
        didSet {
            guard let validModel = model else {return}
            self.titleLabel.text = validModel.rawValue
            switch validModel {
            case .history:
                self.titleLabel.textColor = UIColor.black
            case .signOut:
                self.titleLabel.textColor = Colors.red
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        self.titleLabel.font = Fonts.demiBold(size: 13)
    }
}
