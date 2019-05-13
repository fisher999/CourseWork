//
//  HotelsViewModel.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import Result
import UIKit

class HotelsListViewModel {
    //MARK: -properties
    var (lifetime, token) = Lifetime.make()
    var provider: MoyaProvider<Network>
    private var hotels: [MDHotel]?
    
    //MARK: -Reactive
    var getHotelsRequest: SignalProducer<[MDHotel], MoyaError> {
        return self.provider.request(.hotelist)
        .map([MDHotel].self)
    }
    
    var reload: Signal<(), NoError>
    fileprivate var reloadObserver: Signal<(), NoError>.Observer
    
    var pushVCSignal: Signal<UIViewController, NoError>
    fileprivate var pushVCObserver: Signal<UIViewController, NoError>.Observer
    
    init(provider:MoyaProvider<Network> = MoyaProvider<Network>.init()) {
        (reload, reloadObserver) = Signal.pipe()
        (pushVCSignal, pushVCObserver) = Signal.pipe()
        self.provider = provider
    }
    
    func preload() {
        self.getHotelsRequest.on(starting: {
            
        })
        .on(value: {[weak self] response in
            guard let sself = self else {return}
            print(response)
            sself.hotels = response
            sself.reloadObserver.send(value: ())
        })
        .on(failed: {[weak self] error in
            print(error)
            
        })
        .start()
    }
    
    func didSelectHotel(at indexPath: IndexPath) {
        guard indexPath.row < self.hotels!.count else {return}
        let hotel = self.hotels![indexPath.row]
        let viewModel = DetailHotelViewModel(model: hotel)
        let detailHotelVC = DetailHotelController(viewModel: viewModel)
        self.pushVCObserver.send(value: detailHotelVC)
    }
    
    func hotelForCell(at indexPath:IndexPath) -> HotelCell.Model? {
        guard let validHotels = self.hotels else {return nil}
        let models = validHotels.map { (hotel) -> HotelCell.Model in
            let location = "\(hotel.country), \(hotel.city)"
            return HotelCell.Model.init(imageUrl: hotel.image_url, name: hotel.name, rating: hotel.rating, location: location, price: hotel.price, description: hotel.description)
        }
        
        if indexPath.row < models.count {
            return models[indexPath.row]
        }
        
        return nil
    }
    
    func count() -> Int {
        return self.hotels?.count ?? 0
    }
}
