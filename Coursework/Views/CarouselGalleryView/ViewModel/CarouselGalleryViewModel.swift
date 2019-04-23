//
//  CarouselGalleryViewModel.swift
//  BMSCard
//
//  Created by Victor on 12/04/2019.
//  Copyright © 2019 ASD Group. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

class CarouselGalleryViewModel {
    //MARK: Properties
    var images: [String]
    var imageLoaded: [Bool]
    var selectedPictureIndex: Int = 0
    
    //MARK: Reactive
    var scrollToSignal: Signal<(CGPoint,Int), NoError>
    private var scrollToObserver: Signal<(CGPoint,Int), NoError>.Observer
    
    init(images: [String]) {
        self.images = images
        (scrollToSignal, scrollToObserver) = Signal.pipe()
        imageLoaded = Array.init(repeating: false, count: images.count)
    }
    
    func didScroll(scrollView:UIScrollView) {
        let pageWidth = scrollView.frame.size.width;
        let offsetX = scrollView.contentOffset.x
        let index = Int(floor((offsetX - pageWidth / 2) / pageWidth) + 1);
        
        if (selectedPictureIndex != index) {
            selectedPictureIndex = index;
            print(selectedPictureIndex)
            print(offsetX)
        }
        let neededOffset = pageWidth * CGFloat(selectedPictureIndex)
        self.scrollToObserver.send(value: (CGPoint(x: neededOffset, y: 0),selectedPictureIndex))
    }
}
