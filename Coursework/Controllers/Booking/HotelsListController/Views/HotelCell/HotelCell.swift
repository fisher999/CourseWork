//
//  HotelCell.swift
//  Coursework
//
//  Created by Victor on 12/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class HotelCell: UITableViewCell, ReusableView {
    struct Model {
        let imageUrl: String
        let name: String
        let rating: Float?
        let location: String
        let price: Float
        let description: String?
    }
    
    //MARK: Outlets
    @IBOutlet weak var hotemImageView: UIImageView!
    @IBOutlet weak var hotelTitle: UILabel!
    @IBOutlet weak var ratingTitle: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ratingBounds: UIView!
    @IBOutlet weak var priceBounds: UIView!
    
    //MARK: Properties
    var model: Model? {
        didSet {
            setup()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutSubviews()
        initSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initSetup() {
        self.activityIndicator.isHidden = true
        
        self.hotelTitle.font = Fonts.mediumItalic(size: 15)
        self.ratingTitle.font = Fonts.demiBold(size: 13)
        self.locationTitle.font = Fonts.medium(size: 15)
        self.priceTitle.font = Fonts.ultraLight(size: 14)
        self.descriptionTitle.font = Fonts.medium(size: 11)
        
        self.imageView?.cornerRadius = 5
        self.imageView?.clipsToBounds = true
        
        self.ratingBounds.setCircle()
        self.priceTitle.setCircle()
        self.priceTitle.borderWidth = 2
        self.priceTitle.border = Colors.defaultColor
        
    }
    
    func setup() {
        guard let validModel = self.model else {return}
        
//        self.activityIndicator.isHidden = false
//        self.activityIndicator.startAnimating()
//        self.activityIndicator.layer.zPosition = 100
        self.contentView.layoutSubviews()
        UIImage.downloadImageForUrl(url: validModel.imageUrl, succes: { [weak self](image, error) in
            guard let sself = self else {return}
            if let img = image {
                sself.imageView?.image = img.crop(to: sself.hotemImageView.frame.size)
                sself.setNeedsLayout()
//                self?.activityIndicator.isHidden = true
//                self?.activityIndicator.stopAnimating()
            }
            
            if let err = error {
                print(err)
            }
        })
        self.hotemImageView.contentMode = .center
        self.hotemImageView.clipsToBounds = true
        
        self.hotelTitle.text = validModel.name
        
        if let rating = validModel.rating {
            switch rating {
            case 0..<4.0:
                self.ratingBounds.backgroundColor = UIColor.red
            case 4.0 ..< 7.0:
                self.ratingBounds.backgroundColor = UIColor.yellow
            case 7.0 ... 10.0:
                self.ratingBounds.backgroundColor = UIColor.green
            default:
                break
            }
            let rate = Double(rating).floorTo(precision: 2)
            self.ratingTitle.text = String(rate)
        }
        else
        {
            self.ratingBounds.backgroundColor = UIColor.white
            self.ratingTitle.text = ""
        }
        
        self.locationTitle.text = validModel.location
        self.priceTitle.text = String(Int(validModel.price)) + "р."
        
        if validModel.description != nil && self.descriptionTitle != nil {
            self.descriptionTitle.text = validModel.description
        }
        else if self.descriptionTitle != nil {
            self.descriptionTitle.removeFromSuperview()
            self.contentView.addConstraint(NSLayoutConstraint(item: self.locationTitle, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -16))
        }
    }
    
}
