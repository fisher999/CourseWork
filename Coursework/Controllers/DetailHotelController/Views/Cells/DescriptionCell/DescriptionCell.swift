//
//  DescriptionCell.swift
//  Coursework
//
//  Created by Victor on 17/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell, CustomCellTypeModel, ReusableView, NibLoadableView {
    //MARK: Outlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = model else {return}
            switch cellType {
            case .descriptionCell(let description):
                setup(description: description)
            default:
                return
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension DescriptionCell {
    func setup(description: String) {
        self.descriptionLabel.text = description
        self.descriptionLabel.font = Fonts.ultraLight(size: 15)
        self.descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.7)
    }
}
