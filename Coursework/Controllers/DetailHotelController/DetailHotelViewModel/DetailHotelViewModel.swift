//
//  DetailHotelViewModel.swift
//  Coursework
//
//  Created by Victor on 15/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import Result
import Alamofire

class DetailHotelViewModel {
    enum DetailHotelError: Error {
        case validateError(String, String)
    }
    
    var (lifetime, token) = Lifetime.make()
    enum CellType {
        case carouselGalleryCell([String])
        case hotelRatingCell(String, Float)
        case descriptionCell(String)
        case apartmentCell(MDApartmentType,[String], Float)
        case commentCell(String, String, Float, String)
        case postFeedbackCell
    }

    //MARK: Properties
    var hotel: MDHotel
    var provider: MoyaProvider<Network>
    
    private var apartments: [MDApartment]?
    
    private var feedbacks: [MDFeedback]? {
        didSet {
            
        }
    }
    
    private var cells: [[CellType]] = []
    
    var title: String {
        return self.hotel.name
    }
    
    
    
    //MARK: Reactive
    var didLoadApartmentsSignal: Signal<(), NoError>
    fileprivate var didLoadApartmentsObserver: Signal<(), NoError>.Observer
    
    var didLoadCommentsSignal: Signal<(), NoError>
    fileprivate var didLoadCommentsObserver: Signal<(), NoError>.Observer
    
    var reload: Signal<(), NoError>
    fileprivate var reloadObserver: Signal<(), NoError>.Observer
    
    var loading: Property<Bool>
    fileprivate var _loading: MutableProperty<Bool>
    
    var setImages: Signal<[String], NoError>
    fileprivate  var setImagesObserver: Signal<[String], NoError>.Observer
    
    var apartmentsForHotelRequest: SignalProducer<[MDApartment], MoyaError> {
        return self.provider.request(.apartments(hotel.id))
            .map([MDApartment].self)
            .on(starting: {[weak self] in
                guard let sself = self else {return}
                sself._loading.value = true
            })
            .on(value: {[weak self] apartments in
                guard let sself = self else {return}
                print(apartments)
                sself.apartments = apartments
                sself._loading.value = false
                sself.didLoadApartmentsObserver.send(value: ())
            })
            .on(failed: {[weak self] error in
                guard let sself = self else {return}
                sself._loading.value = false
                print(error)
            })
    }
    
    var getCommentsForHotelRequest: SignalProducer<[MDFeedback], MoyaError> {
        return self.provider.request(.getComments(hotel.id))
            .map([MDFeedback].self)
            .on(value: {[weak self] feedbacks in
                guard let sself = self else {return}
                sself.feedbacks = feedbacks
                print(feedbacks)
                sself.didLoadCommentsObserver.send(value: ())
            })
            .on(failed: {[weak self] error in
                guard let sself = self else {return}
                sself.apartmentsForHotelRequest.start()
                print(error)
                
            })
    }
    
    var postFeedback: BindingTarget<(Int, String)> {
        return BindingTarget<(Int, String)>.init(lifetime: lifetime, action: {[weak self] (rating, comment) in
            guard let sself = self else {return}
            sself.postFeedback(rating: rating, comment: comment)
        })
    }
    
    init(model: MDHotel, provider: MoyaProvider<Network> = MoyaProvider<Network>()) {
        (setImages, setImagesObserver) = Signal.pipe()
        (reload, reloadObserver) = Signal.pipe()
        (didLoadCommentsSignal, didLoadCommentsObserver) = Signal.pipe()
        (didLoadApartmentsSignal, didLoadApartmentsObserver) = Signal.pipe()
        _loading = MutableProperty<Bool>.init(false)
        loading = Property<Bool>.init(_loading)
        
        self.hotel = model
        self.provider = provider
    }
    
    func preload() {
        loadModel()
    }
}

//MARK: Bussiness logic
extension DetailHotelViewModel {
    fileprivate func reloadCells() {
        self.cells = []
    
        let carouselGalleryCell: DetailHotelViewModel.CellType = .carouselGalleryCell(self.getImages())
        
        let hotelRatingCell: DetailHotelViewModel.CellType = .hotelRatingCell(self.hotel.name, self.hotel.rating)
        
        let apartments = getApartments()
        
        let feedbacks = getFeedbacks()
        
        if let description = self.hotel.description {
            let descriptionCell: DetailHotelViewModel.CellType = .descriptionCell(description) 
            self.cells.append([carouselGalleryCell, hotelRatingCell, descriptionCell])
        }
        else {
            self.cells.append([carouselGalleryCell,hotelRatingCell])
        }
        
        self.cells.append(apartments)
        self.cells.append(feedbacks)
        
        self.reloadObserver.send(value: ())
    }
    
    fileprivate func loadModel() {
        apartmentsForHotelRequest.zip(with: getCommentsForHotelRequest)
            .on(starting: {[weak self] in
                guard let sself = self else {return}
                sself._loading.value = true
            })
            .on(completed: {[weak self] in
                guard let sself = self else {return}
                sself._loading.value = false
                sself.reloadCells()
            })
            .on(failed: {[weak self] error in
                guard let sself = self else {return}
                sself._loading.value = false
                sself.reloadCells()
            })
            .start()
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellType? {
        return self.cells[indexPath.section][indexPath.row]
    }
    
    func numberOfSections() -> Int {
        print(self.cells.count)
        return self.cells.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == 2 {
            print(self.cells[section].count)
            
        }
        return self.cells[section].count
    }
    
    func headerForSection(section: Int) -> String? {
        switch section {
        case 1:
            return "Наши предложения"
        case 2:
            if self.cells.contains(where: { (cells) -> Bool in
                for cell in cells {
                    switch cell {
                    case .commentCell:
                        return true
                    default:
                        return false
                    }
                }
                return false
            })
                
            {
                return "Отзывы о нас"
            }
            
            return "Отзывов пока нет"
        default:
            return nil
        }
    }
    
    fileprivate func postFeedback(rating: Int, comment: String) {
        let user = MDUser.init(id: 0, username: UserManager.shared.currentUser!.username)
        let feedback = MDFeedback.init(rating: Float(rating), comment: comment)
        self.provider.request(.postComment(self.hotel.id, feedback))
            .on(starting: {[weak self] in
                
            })
            .on(value: {[weak self] value in
                guard let sself = self else {return}
                print(value)
                sself.reloadCells()
            })
            .on(failed: {[weak self] error in
                print(error)
            }).start()
    }
}

//MARK: Logic for cells
extension DetailHotelViewModel {
    fileprivate func getImages() -> [String] {
        guard let apartments = self.apartments else {return []}
        let pictures = apartments
        .map({ (apartment) -> [String] in
            return apartment.pictures
        })
        var allPictures: [String] = []
        for row in pictures {
            for picture in row {
                allPictures.append(picture)
            }
        }
        
        return allPictures
    }
    
    fileprivate func getFeedbacks() -> [CellType] {
        guard var feedbacks = self.feedbacks?.map({ (feedback) -> CellType?  in
            guard let date = feedback.date, let username = feedback.user?.username else {return nil}
            return .commentCell(date, username, feedback.rating, feedback.comment)
        }).filter({ (cellType) -> Bool in
            return cellType != nil
        }).map({ (cellType) -> CellType in
            return cellType!
        }) else {return [.postFeedbackCell]}
        
        feedbacks.append(.postFeedbackCell)
        print(feedbacks)
        return feedbacks
    }
    
    fileprivate func getApartments() -> [CellType] {
        guard let apartments = self.apartments?.map({ (apartment) -> CellType in
            return .apartmentCell(apartment.apartmentType, apartment.pictures, apartment.price)
        }) else {return []}
        
        return apartments
    }
}

