//
//  HotelRatingCell.swift
//  Coursework
//
//  Created by Victor on 17/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class HotelRatingCell: UITableViewCell, CustomCellTypeModel, ReusableView, NibLoadableView {
    struct Model {
        let title: String
        let rating: Float?
    }
    
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = model else {return}
            switch cellType {
            case .hotelRatingCell(let title, let rating):
                let model = Model(title: title, rating: rating)
                setup(model: model)
            default:
                return
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension HotelRatingCell {
    func setup(model: Model) {
        self.layoutIfNeeded()
        self.titleLabel.text = model.title
        self.titleLabel.font = Fonts.mediumItalic(size: 15)
        self.titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        if let rating = model.rating {
            switch rating {
            case 0..<4.0:
                self.ratingView.backgroundColor = UIColor.red
            case 4.0 ..< 7.0:
                self.ratingView.backgroundColor = UIColor.yellow
            case 8.0 ... 10.0:
                self.ratingView.backgroundColor = UIColor.green
            default:
                break
            }
            let rate = Double(rating).floorTo(precision: 2)
            self.ratingLabel.text = String(rate)
        }
        else {
            self.ratingLabel.text = ""
        }
        
        self.ratingView.setCircle()
        
        self.ratingLabel.font = Fonts.demiBold(size: 13)
        self.ratingLabel.textColor = UIColor.black
        self.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
