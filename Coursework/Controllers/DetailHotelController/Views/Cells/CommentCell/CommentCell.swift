//
//  CommentCell.swift
//  Coursework
//
//  Created by Victor on 17/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell, CustomCellTypeModel, ReusableView, NibLoadableView {
    struct Model{
        let date: String
        let userName: String
        let rating: Float
        let comment: String
    }
    
    //MARK: Outlets
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var cimmentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = model else {return}
            switch cellType {
            case .commentCell(let date, let username, let rating, let comment):
                let model = Model(date: date, userName: username,  rating: rating, comment: comment)
                setup(model: model)
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

extension CommentCell {
    func setup(model: Model) {
        switch model.rating {
        case 0..<5.0:
            self.ratingView.backgroundColor = UIColor.red
        case 5.0 ..< 8.0:
            self.ratingView.backgroundColor = UIColor.yellow
        case 8.0 ... 10.0:
            self.ratingView.backgroundColor = UIColor.green
        default:
            break
        }
        self.ratingView.setCircle()
        
        self.ratingLabel.font = Fonts.demiBold(size: 13)
        self.ratingLabel.textColor = UIColor.black
        self.ratingLabel.text = String(model.rating)
        
        self.cimmentLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        self.cimmentLabel.text = model.comment
        self.cimmentLabel.font = Fonts.medium(size: 15)
        
        self.usernameLabel.textColor = UIColor.black
        self.usernameLabel.text = model.userName
        self.cimmentLabel.font = Fonts.demiBold(size: 14)
        
        self.dateLabel.textColor = Colors.gray112
        self.dateLabel.text = model.date
        self.dateLabel.font = Fonts.ultraLight(size: 9)
    }
}
