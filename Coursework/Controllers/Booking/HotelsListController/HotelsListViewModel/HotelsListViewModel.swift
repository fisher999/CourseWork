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
    enum FilterType: String, CaseIterable {
        case byCountry = "Страна"
        case byCity = "Город"
        case byHotelName = "Название"
    }
    
    enum ReloadState {
        case reloading
        case updating
    }
    
    //MARK: -properties
    var (lifetime, token) = Lifetime.make()
    var provider: MoyaProvider<Network>
    
    var reloadState: ReloadState = .reloading
    
    private var hotels: [MDHotel]? {
        didSet {
            switch self.reloadState {
            case .updating:
                switch self.filterType.value {
                case .byCity:
                    self.filterByCity(text: self._text.value)
                case .byCountry:
                    self.filterByCountry(text: self._text.value)
                case .byHotelName:
                    self.filterByName(text: self._text.value)
                }
            case .reloading:
                self.filtered = hotels
            }
        }
    }
    
    private var filtered: [MDHotel]? {
        didSet {
            switch self.reloadState {
            case .reloading:
                self.reloadObserver.send(value: ())
                self.reloadState = .updating
            case .updating:
                return
            }
        }
    }
    
    //MARK: -Reactive
    
    var reload: Signal<(), NoError>
    fileprivate var reloadObserver: Signal<(), NoError>.Observer
    
    var currentDownoadedPage: Property<Int?>
    fileprivate var _currentDownloadedPage: MutableProperty<Int?>
    
    var pushVCSignal: Signal<UIViewController, NoError>
    fileprivate var pushVCObserver: Signal<UIViewController, NoError>.Observer
    
    var filterType: MutableProperty<FilterType>
    fileprivate var _filterType: Property<FilterType>
    
    var text: MutableProperty<String?>
    fileprivate var _text: Property<String?>
    
    var insertRowsAtIndexPath: Signal<[IndexPath], NoError>
    fileprivate var insertRowsAtIndexPathObserver: Signal<[IndexPath], NoError>.Observer
    
    fileprivate(set) var _reloading: MutableProperty<Bool>
    var reloading: Property<Bool>
    
    init(provider:MoyaProvider<Network> = MoyaProvider<Network>.init()) {
        (reload, reloadObserver) = Signal.pipe()
        (pushVCSignal, pushVCObserver) = Signal.pipe()
        
        filterType = MutableProperty<FilterType>.init(.byCountry)
        _filterType = Property<FilterType>.init(filterType)
        
        text = MutableProperty<String?>.init("")
        _text = Property<String?>.init(text)
        
        _currentDownloadedPage = MutableProperty<Int?>.init(nil)
        currentDownoadedPage  = Property<Int?>.init(_currentDownloadedPage)
        
        (insertRowsAtIndexPath, insertRowsAtIndexPathObserver) = Signal.pipe()
        
        _reloading = MutableProperty<Bool>.init(false)
        reloading = Property<Bool>.init(_reloading)
        
        self.provider = provider
    }
    
    func preload() {
        self.getHotelsAtPageRequest(page: 0)
        observeText()
        observeFilterType()
        observeCurrentDownloadedPage()
    }
    
    func didSelectHotel(at indexPath: IndexPath) {
        guard indexPath.row < self.filtered?.count ?? 0 else {return}
        let hotel = self.filtered![indexPath.row]
        let viewModel = DetailHotelViewModel(model: hotel)
        let detailHotelVC = DetailHotelController(viewModel: viewModel)
        self.pushVCObserver.send(value: detailHotelVC)
    }
    
    func hotelForCell(at indexPath:IndexPath) -> HotelCell.Model? {
        guard let validHotels = self.filtered else {return nil}
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
        return self.filtered?.count ?? 0
    }
}

//MARK: Requests
extension HotelsListViewModel {
    func getHotelsAtPageRequest(page: Int) {
        self.provider.request(.hotelistAtPage(page))
        .map([MDHotel].self)
        .on(starting: {
                self._reloading.value = true
            })
        .on(value: {[weak self] response in
                self?._reloading.value = false
                print(response)
                self?._currentDownloadedPage.value = page
                self?.update(hotels: response)
            })
        .on(failed: {[weak self] error in
                print(error)
                self?._reloading.value = false
            })
        .start()
    }
}

//MARK: observing
extension HotelsListViewModel {
    var newPage: BindingTarget<Int> {
        return BindingTarget<Int>.init(lifetime: lifetime, action: { (page) in
            //MARK: TODO
        })
    }
    
    func observeText() {
        self._text.signal.observeValues { (text) in
            self.reloadState = .reloading
            switch self._filterType.value {
            case .byCity:
                self.filterByCity(text: text)
            case .byCountry:
                self.filterByCountry(text: text)
            case .byHotelName:
                self.filterByName(text: text)
            }
        }
    }
    
    func observeFilterType() {
        self._filterType.signal.observeValues { (type) in
            self.reloadState = .reloading
            switch self._filterType.value {
            case .byCity:
                self.filterByCity(text: self._text.value)
            case .byCountry:
                self.filterByCountry(text: self._text.value)
            case .byHotelName:
                self.filterByName(text: self._text.value)
            }
        }
    }
    
    func observeCurrentDownloadedPage() {
        self.currentDownoadedPage.signal.observeValues { (page) in

        }
    }
}

//MARK: Helping methods
extension HotelsListViewModel {
    func filterByName(text: String?) {
        guard !(text?.isEmpty ?? true) else {
            self.filtered = self.hotels
            return
        }
        self.filtered = self.hotels?.filter({ (hotel) -> Bool in
            return hotel.name.lowercased().contains(text!.lowercased())
        })
    }
    
    func filterByCountry(text: String?) {
        guard !(text?.isEmpty ?? true) else {
            self.filtered = self.hotels
            return
        }
        self.filtered = self.hotels?.filter({ (hotel) -> Bool in
            return hotel.country.lowercased().contains(text!.lowercased())
        })
    }
    
    func filterByCity(text: String?) {
        guard !(text?.isEmpty ?? true) else {
            self.filtered = self.hotels
            return
        }
        self.filtered = self.hotels?.filter({ (hotel) -> Bool in
            return hotel.city.lowercased().contains(text!.lowercased())
        })
    }
    
    func loadMore() {
        guard let currentDownloadedPage = self.currentDownoadedPage.value else {return}
        print(currentDownloadedPage)
        getHotelsAtPageRequest(page: currentDownloadedPage + 1)
    }
    
    fileprivate func update(hotels: [MDHotel]) {
        if self.hotels == nil {
            self.hotels = hotels
        }
        else {
            var indexPaths: [IndexPath] = []
            let section = 0
            
            let oldCount = self.filtered?.count ?? 0
            self.hotels?.append(contentsOf: hotels)
            let newCount = self.filtered?.count ?? 0
            
            for row in oldCount ..< newCount {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
            
            self.insertRowsAtIndexPathObserver.send(value: indexPaths)
        }
    }

}
