//
//  BookingHistoryViewModel.swift
//  Coursework
//
//  Created by Victor on 12/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import Result

class BookingHistoryViewModel: BaseViewModel {
    enum DownloadingFile: String {
        case csv = "http://10.0.30.149:8000/user/booking/csv"
        case pdf = "http://10.0.30.149:8000/user/booking/pdf"
    }
    
    //MARK: Properties
    private var provider: MoyaProvider<Network>
    private var bookingModel: [BookingCell.Model]? {
        didSet {
            self.reloadObserver.send(value: ())
        }
    }
    
    //MARK: Reactive
    var reloadSignal: Signal<(), NoError>
    fileprivate var reloadObserver: Signal<(), NoError>.Observer
    
    init(provider: MoyaProvider<Network> = MoyaProvider<Network>()) {
        (reloadSignal, reloadObserver) = Signal.pipe()
        self.provider = provider
    }
    
    func preload() {
        makeRequest()
    }
}

//MARK: Network
extension BookingHistoryViewModel {
    var bookingHistoryRequest: SignalProducer<[MDBooking], MoyaError> {
        return provider.request(.bookingList)
            .map([MDBooking].self)
    }
    
    var userApartmentsRequest: SignalProducer<[MDApartment], MoyaError> {
        return provider.request(.userApartments)
        .map([MDApartment].self)
    }
    
    
    func makeRequest() {
        bookingHistoryRequest.zip(with: userApartmentsRequest)
            .on(value: {[weak self] value in
                var bookingList: [BookingCell.Model] = []
                for booking in value.0 {
                    guard let apartment = self?.getAparmentById(model: value.1, id: booking.apartmentId) else {continue}
                    let date = "Дата бронирования: \(booking.date.getTimeString())"
                    let originDate = "Дата заезда: \(booking.originAccomodation.getTimeString())"
                    let endDate = "Дата выезда: \(booking.endAccomodation.getTimeString())"
                    let hotelName = "Название отеля: \(apartment.hotelName)"
                    let price = "Стоимость: \(Int(apartment.price) * booking.amountOfPersons * Date.getDays(originDate: booking.originAccomodation, endDate: booking.endAccomodation)!) р."
                    let numberOfPersons = "Число персон: \(booking.amountOfPersons)"
                    let numberOfRooms = "Число комнат: \(apartment.apartmentType.numberOfRooms)"
                    let model = BookingCell.Model.init(date: date, originDate: originDate, endDate: endDate, hotelName: hotelName, price: price, numberOfPersons: numberOfPersons, numberOfRooms: numberOfRooms, hotelImageUrl: apartment.pictures.first)
                    
                    bookingList.append(model)
                }
                self?.bookingModel = bookingList
            })
            .on(failed: {error in
                print(error)
            }).start()
    }
    
    
    private func getAparmentById(model: [MDApartment], id: Int) -> MDApartment? {
        return model.filter({ (apartment) -> Bool in
            return apartment.id == id
        }).first
    }
}

extension BookingHistoryViewModel {
    func modelForCell(at indexPath: IndexPath) -> BookingCell.Model? {
        guard indexPath.row < self.bookingModel?.count ?? 0 else {return nil}
        return self.bookingModel?[indexPath.row]
    }
    
    func count() -> Int {
        return self.bookingModel?.count ?? 0
    }
}
