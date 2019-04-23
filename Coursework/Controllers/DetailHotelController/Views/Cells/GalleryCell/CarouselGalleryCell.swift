//
//  CarouselGalleryCell.swift
//  Coursework
//
//  Created by Victor on 21/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class CarouselGalleryCell: UITableViewCell, CustomCellTypeModel, NibLoadableView, ReusableView {
    //MARK: Outlets
    @IBOutlet weak var galleryView: GalleryView!
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = self.model else {return}
            switch cellType {
            case .carouselGalleryCell(let images):
                galleryView.images = images
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
