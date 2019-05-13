//
//  ConditionsView.swift
//  Coursework
//
//  Created by Victor on 29/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift

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
    
    //MARK: Reactive
    var collectionViewHeight: Property<CGFloat>
    fileprivate var _collectionViewHeight: MutableProperty<CGFloat>
    
    override init(frame: CGRect) {
        _collectionViewHeight = MutableProperty<CGFloat>.init(0)
        collectionViewHeight = Property<CGFloat>.init(_collectionViewHeight)
        super.init(frame: frame)
        view = loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        _collectionViewHeight = MutableProperty<CGFloat>.init(0)
        collectionViewHeight = Property<CGFloat>.init(_collectionViewHeight)
        super.init(coder: aDecoder)
        view = loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        observeCollectionViewHeight()
    }
}

extension ConditionsView {
    func setup() {
        self.collectionView.register(ConditionCell.self)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isScrollEnabled = false
    }
    
    func observeCollectionViewHeight() {
        self.collectionView.reactive.signal(forKeyPath: "contentSize").observeValues {[weak self] (value) in
            guard let sself = self else {return}
            guard let contentSize = value as? CGSize else {return}
            sself._collectionViewHeight.value = contentSize.height
        }
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
extension ConditionsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.width / 2, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
