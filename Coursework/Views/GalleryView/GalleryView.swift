//
//  GalleryView.swift
//  Coursework
//
//  Created by Victor on 21/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class GalleryView: UIView {
    //MARK: Outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [String]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        view = loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        view = loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}

extension GalleryView {
    func setup() {
        let nib = UINib.init(nibName: "GalleryCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "GalleryCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

extension GalleryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = self.images else {return 0}
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let images = self.images, images.count > indexPath.row else {return UICollectionViewCell()}
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.image = images[indexPath.row]
        return cell
    }
}

extension GalleryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
