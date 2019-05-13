//
//  ApartmentCell.swift
//  Coursework
//
//  Created by Victor on 18/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import Cosmos

class ApartmentCell: UITableViewCell, CustomCellTypeModel, ReusableView, NibLoadableView {
    //MARK: Oultets
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numberOfRoomsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var apartmentImageView: UIImageView!
    
    //MARK: Property
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = model else {return}
            switch cellType {
            case .apartmentCell(let apartmentType, let pictures, let price):
                self.setup(apartmentType: apartmentType, pictures: pictures, price: price)
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

extension ApartmentCell {
    func setup(apartmentType: MDApartmentType, pictures: [String], price: Float) {
        let type = apartmentType.type
        
        switch type {
        case .oneStar:
            self.ratingView.rating = 1
        case .twoStar:
            self.ratingView.rating = 2
        case .threeStar:
            self.ratingView.rating = 3
        case .fourStar:
            self.ratingView.rating = 4
        case .fiveStar:
            self.ratingView.rating = 5
        }
        
        self.numberOfRoomsLabel.text = "Кол-во комнат: \(apartmentType.numberOfRooms)"
        self.numberOfRoomsLabel.font = Fonts.mediumItalic(size: 12)
        
        self.priceView.border = Colors.defaultColor
        self.priceView.borderWidth = 2
        self.priceView.setCircle()
        
        self.ratingView.settings.updateOnTouch = false
        
        self.priceLabel.text = "\(Int(price))р."
        self.priceLabel.font = Fonts.medium(size: 12)
        
        if let picture = pictures.first {
            UIImage.downloadImageForUrl(url: picture, succes: { (image, error) in
                if let img = image {
                    self.apartmentImageView.image = img.crop(to: self.apartmentImageView.frame.size)
                }
            })
        }
    }
}
