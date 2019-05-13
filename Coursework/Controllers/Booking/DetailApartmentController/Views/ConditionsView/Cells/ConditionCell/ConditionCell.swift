//
//  ConditionCell.swift
//  Coursework
//
//  Created by Victor on 29/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class ConditionCell: UICollectionViewCell, ReusableView, NibLoadableView {
    struct Model {
        var title: String
        var iconName: String
        var textColor: UIColor
    }
    //MARK: Outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Properties
    var model: Model? {
        didSet {
            guard let validModel = model else {return}
            self.setup(model: validModel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension ConditionCell {
    func setup(model: Model) {
        self.titleLabel.text = model.title
        self.titleLabel.font = Fonts.ultraLight(size: 11)
        self.titleLabel.textColor = model.textColor
        
        self.iconView.image = UIImage(named: model.iconName)
    }
}
