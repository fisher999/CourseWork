//
//  ConditionsView.swift
//  Coursework
//
//  Created by Victor on 29/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class ConditionsView: UIView {
    //MARK: Outlets
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    var model: [ConditionCell.Model]? {
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

extension ConditionsView {
    func setup() {
        self.collectionView.register(ConditionCell.self)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

//MARK: UICollectionViewDataSource
extension ConditionsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = self.model else {return UICollectionViewCell()}
        let cell: ConditionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.model = model[indexPath.row]
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension ConditionsView: UICollectionViewDelegate {
    
}
