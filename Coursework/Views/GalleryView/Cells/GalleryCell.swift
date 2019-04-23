//
//  GalleryCell.swift
//  Coursework
//
//  Created by Victor on 21/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var image: String! {
        didSet {
            UIImage.downloadImageForUrl(url: image) {[weak self] (image, error) in
                guard let sself = self else {return}
                if let img = image {
                    sself.imageView.image = img
                }
                
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
