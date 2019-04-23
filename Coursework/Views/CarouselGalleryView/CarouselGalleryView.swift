//
//  CarouselGalleryView.swift
//  BMSCard
//
//  Created by Victor on 12/04/2019.
//  Copyright © 2019 ASD Group. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

class CarouselGalleryView: UIView {
    //MARK: Outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var carouselScrollView: UIScrollView!
    @IBOutlet weak var carouselContentView: UIView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    
    //MARK: Properties
    var (lifetime, token) = Lifetime.make()
    var viewModel: CarouselGalleryViewModel? {
        didSet {
            guard let validViewModel = viewModel else {return}
            setup()
            bind(viewModel: validViewModel)
        }
    }
    
    //MARK: Reactive
    var imagesLoadingSignal: Signal<(Bool, UIActivityIndicatorView, UIImageView), NoError>
    var imagesLoadingObserver: Signal<(Bool, UIActivityIndicatorView, UIImageView), NoError>.Observer
    
    var imageLoaded: BindingTarget<(Bool, UIActivityIndicatorView, UIImageView)> {
        return BindingTarget<(Bool,UIActivityIndicatorView,UIImageView)>.init(lifetime: lifetime, action: { (loaded,activityIndicator,imageView) in
            activityIndicator.isHidden = loaded
            imageView.isHidden = !loaded
            if loaded {
                activityIndicator.stopAnimating()
            }
            else {
                activityIndicator.startAnimating()
            }
        })
    }
    
    override init(frame: CGRect) {
        (imagesLoadingSignal, imagesLoadingObserver) = Signal.pipe()
        super.init(frame: frame)
        view = loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        (imagesLoadingSignal, imagesLoadingObserver) = Signal.pipe()
        super.init(coder: aDecoder)
        view = loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(viewModel: CarouselGalleryViewModel) {
        self.scrollTo <~ viewModel.scrollToSignal
        self.imageLoaded <~ self.imagesLoadingSignal.map({ (loaded,activityIndicator,imageView) -> (Bool,UIActivityIndicatorView,UIImageView) in
            return (!loaded, activityIndicator, imageView)
        })
    }
    
}

//MARK: SETUP
extension CarouselGalleryView {
    func setup() {
        guard let validViewModel = self.viewModel else { return }
        self.carouselScrollView.delegate = self
        guard validViewModel.images.count > 0 else {return}
        self.pageIndicator.numberOfPages = validViewModel.images.count
        self.pageIndicator.currentPage = 0
        carouselScrollView.showsHorizontalScrollIndicator = false
        
        let imageView = UIImageView(frame: CGRect(x:self.carouselContentView.x, y: self.carouselContentView.y, width: self.view.width, height: self.carouselScrollView.height))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        
        let activityIndicator = UIActivityIndicatorView(frame: imageView.frame)
        activityIndicator.center = imageView.center
        self.carouselContentView.addSubview(activityIndicator)
        
        self.imagesLoadingObserver.send(value: (true, activityIndicator,imageView))
        
        self.carouselContentView.frame = CGRect(x: self.carouselContentView.x, y: self.carouselContentView.y, width: self.carouselScrollView.frame.width * CGFloat(validViewModel.images.count), height: self.carouselScrollView.height)
        
        let imageUrl = validViewModel.images.first!
        
        UIImage.downloadImageForUrl(url: imageUrl, succes: {[weak self] (image, error) in
            guard let strongSelf = self else {return}
            if let img = image {
                imageView.image = img
                
                strongSelf.carouselContentView.translatesAutoresizingMaskIntoConstraints = true
                strongSelf.imagesLoadingObserver.send(value: (false, activityIndicator,imageView))
                
                strongSelf.carouselContentView.addSubview(imageView)
                imageView.setNeedsLayout()
            }
            
            if let err = error {
                print(err)
            }
        })
        
    }
}

//MARK: Scrolling
extension CarouselGalleryView {
    var scrollTo: BindingTarget<((CGPoint),Int)> {
        return BindingTarget<(CGPoint,Int)>.init(lifetime: lifetime, action: {[weak self] (offset,index) in
            guard let strongSelf = self, let validViewModel = strongSelf.viewModel, index < validViewModel.images.count else {return}
            let imageUrl = validViewModel.images[index]
            
            strongSelf.carouselScrollView.setContentOffset(offset, animated: true)
            strongSelf.pageIndicator.currentPage = index
            
            guard validViewModel.imageLoaded[index] == false else {return}
            
            let imageView = UIImageView(frame: CGRect(x: strongSelf.carouselScrollView.width * CGFloat(index), y: strongSelf.carouselContentView.y, width: strongSelf.view.width, height: strongSelf.carouselScrollView.height))
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleToFill
            
            let activityIndicator = UIActivityIndicatorView(frame: imageView.frame)
            activityIndicator.center = imageView.center
            strongSelf.carouselContentView.addSubview(activityIndicator)
            
            strongSelf.imagesLoadingObserver.send(value: (true, activityIndicator,imageView))
            
            UIImage.downloadImageForUrl(url: imageUrl, succes: {[weak self] (image, error) in
                guard let strongSelf = self else {return}
                if let img = image {
                    imageView.image = img
                    strongSelf.carouselContentView.translatesAutoresizingMaskIntoConstraints = true
                    strongSelf.imagesLoadingObserver.send(value: (false, activityIndicator,imageView))
                    
                    strongSelf.carouselContentView.addSubview(imageView)
                    imageView.setNeedsLayout()
                    validViewModel.imageLoaded[index] = true
                }
                
                if let err = error {
                    print(err)
                }
            })
        })
    }
}

//MARK: -UIScrollViewDelegate
extension CarouselGalleryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let validViewModel = self.viewModel else {return}
        validViewModel.didScroll(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let validViewModel = self.viewModel else {return}
        validViewModel.didScroll(scrollView: scrollView)
    }
}
