//
//  DetailApartmentController.swift
//  Coursework
//
//  Created by Victor on 29/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import Cosmos
import ReactiveSwift

class DetailApartmentController: BaseController {
    //MARK: IBOutlets
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numberOfRoomsLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var conditionsView: ConditionsView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bookingButton: UIButton!
    
    //MARK: Properties
    var viewModel: DetailApartmentViewModel
    
    init(viewModel: DetailApartmentViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
}

//MARK: View
extension DetailApartmentController {
    func setup() {
        self.galleryView.images = viewModel.apartmentImages
        
        self.ratingView.rating =  viewModel.rating
        self.ratingView.settings.updateOnTouch = false
        
        self.numberOfRoomsLabel.text = viewModel.numberOfRooms
        self.numberOfRoomsLabel.font = Fonts.medium(size: 13)

        self.priceLabel.font = Fonts.medium(size: 12)
        self.priceLabel.text = viewModel.price
        
        self.priceView.border = Colors.defaultColor
        self.priceView.borderWidth = 2
        self.priceView.setCircle()
        
        self.bookingButton.setTitle("Перейти к бронированию", for: .normal)
        self.bookingButton.setTitleColor(UIColor.white, for: .normal)
        self.bookingButton.titleLabel?.font = Fonts.ultraLight(size: 13)
        self.bookingButton.tintColor = UIColor.white
        self.bookingButton.backgroundColor = Colors.defaultColor
        self.bookingButton.setBackgroundColor(color: Colors.defaultColor, forState: .selected)
        self.bookingButton.setCircle()
        self.bookingButton.addTarget(self, action: #selector(goToBooking(_:)), for: .touchUpInside)
        
        self.conditionsView.model = viewModel.conditions()
    }
    
    func bind() {
        self.conditionsViewHeight <~ self.conditionsView.collectionViewHeight
        self.push <~ viewModel.push
    }
}

//MARK: BindingTargets
extension DetailApartmentController {
    var conditionsViewHeight: BindingTarget<CGFloat> {
        return BindingTarget<CGFloat>.init(lifetime: lifetime, action: {[weak self] (height) in
            self?.collectionViewHeight.constant = height
        })
    }
    
    var push: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

//MARK: Actions
extension DetailApartmentController {
    @objc func goToBooking(_ sender: UIButton) {
        viewModel.goToBooking()
    }
}
