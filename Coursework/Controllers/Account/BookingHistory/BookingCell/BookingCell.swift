//
//  BookingCell.swift
//  Coursework
//
//  Created by Victor on 11/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class BookingCell: UITableViewCell, ReusableView, NibLoadableView {
    //MARK: Model
    struct Model {
        let date: String
        let originDate: String
        let endDate: String
        let hotelName: String
        let price: String
        let numberOfPersons: String
        let numberOfRooms: String
        let hotelImageUrl: String?
    }
    
    //MARK: Outlets
    @IBOutlet weak var bookingDate: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var originDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var numberOfPersons: UILabel!
    @IBOutlet weak var numberOfRooms: UILabel!
    @IBOutlet weak var apartmentImageView: UIImageView!
    
    //MARK: Properties
    var model: Model? {
        didSet {
            guard let validModel = model else {return}
            self.setup(with: validModel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.bookingDate.font = Fonts.ultraLight(size: 13)
        self.originDate.font = Fonts.ultraLight(size: 13)
        self.endDate.font = Fonts.ultraLight(size: 13)
        self.price.font = Fonts.ultraLight(size: 13)
        self.numberOfPersons.font = Fonts.ultraLight(size: 13)
        self.numberOfRooms.font = Fonts.ultraLight(size: 13)
        self.apartmentImageView.cornerRadius = 5
        self.apartmentImageView.clipsToBounds = true
    }
}

extension BookingCell {
    func setup(with model: Model) {
        self.bookingDate.text = model.date
        self.originDate.text = model.originDate
        self.endDate.text = model.endDate
        self.hotelName.text = model.hotelName
        self.price.text = model.price
        self.numberOfPersons.text = model.numberOfPersons
        self.numberOfRooms.text = model.numberOfRooms
        guard let imgUrl = model.hotelImageUrl else {return}
        UIImage.downloadImageForUrl(url: imgUrl) { (image, error) in
            if let err = error {
                print(err)
            }
            if let img = image {
                self.apartmentImageView.image = img
            }
        }
    }
}
