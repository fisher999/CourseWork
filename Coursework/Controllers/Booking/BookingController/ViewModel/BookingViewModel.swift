//
//  BookingViewModel.swift
//  Coursework
//
//  Created by Victor on 04/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import Result
import UIKit

class BookingViewModel: BaseViewModel {
    //MARK: Properties
    var provider: MoyaProvider<Network>
    var model: MDApartment
    
    var amountOfDays: Int? {
        didSet {
            guard let days = amountOfDays else {return}
            self.amountOfPersonsText.value = String(" (\(days)) дн(ей/я) ")
        }
    }
    
    //MARK: Reactive
    var selectedDates: MutableProperty<[Date]>
    fileprivate var _selectedDates: Property<[Date]>
    
    var pushSignal: Signal<UIViewController, NoError>
    fileprivate var pushObserver: Signal<UIViewController, NoError>.Observer
    
    var amountOfPersons: MutableProperty<Int>
    fileprivate var _amountOfPersons: Property<Int>
    
    var bookingIsAvailable: Property<Bool>
    fileprivate var _bookingIsAvailable: MutableProperty<Bool>
    
    var amountOfPersonsText: MutableProperty<String>
    
    var totalPriceText: MutableProperty<String>
    
    init(model: MDApartment, provider: MoyaProvider<Network> = MoyaProvider<Network>()) {
        self.provider = provider
        self.model = model
        
        (pushSignal, pushObserver) = Signal.pipe()
        
        self.selectedDates = MutableProperty<[Date]>.init([])
        self._selectedDates = Property<[Date]>.init(self.selectedDates)
        
        self._bookingIsAvailable = MutableProperty<Bool>.init(false)
        self.bookingIsAvailable = Property<Bool>.init(self._bookingIsAvailable)
        
        self.amountOfPersons = MutableProperty<Int>.init(1)
        self._amountOfPersons = Property<Int>.init(amountOfPersons)
        
        self.amountOfPersonsText = MutableProperty<String>.init("(*) дней")
        
        self.totalPriceText = MutableProperty<String>.init("Итого: (*) р.")
        
        super.init()
        self.selectedDates.signal.observeValues { (dates) in
            print(dates)
        }
    }
    
    func setup() {
        observeDates()
        observeAmountOfPersons()
    }
}

//MARK: BindingTarget
extension BookingViewModel {
    var bookingButtonTapped: BindingTarget<()> {
        return BindingTarget<()>.init(lifetime: lifetime, action: {[weak self] (_) in
            guard let sself = self else {return}
            let (originDate, endDate) = sself.sortDates(dates: sself._selectedDates.value)
            let booking = MDBooking(apartmentId: sself.model.id, originAccomodation: originDate, endAccomodation: endDate, amountOfPersons: sself._amountOfPersons.value)
            sself.makeBookingRequest(booking: booking)
        })
    }
}

//MARK: ReactiveRequest
extension BookingViewModel {
    func makeBookingRequest(booking: MDBooking) {
        provider.request(.makeBooking(booking))
        .map(MDResponse.self)
            .on(value: {[weak self] value in
               let vc = BookingCompletedController.init(response: value)
                self?.pushObserver.send(value: vc)
            })
            .on(failed: {[weak self] error in
                let response = MDResponse.init(success: false, message: error.localizedDescription)
                let vc = BookingCompletedController.init(response: response)
                self?.pushObserver.send(value: vc)
            })
        .start()
    }
}

//MARK: Observing
extension BookingViewModel {
    func observeDates() {
        self._selectedDates.signal.observeValues { (dates) in
            self._bookingIsAvailable.value = dates.count == 2
            
            if dates.count == 2 {
                let (originDate, endDate) = self.sortDates(dates: dates)
                self.amountOfDays = Date.getDays(originDate: originDate, endDate: endDate)
                self.totalPriceText.value = self.calculateTotalPrice()
                self._bookingIsAvailable.value = true
            }
            else {
                self._bookingIsAvailable.value = false
                self.amountOfPersonsText.value = "(*) дней"
                self.totalPriceText.value = "Итого: (*) р."
            }
        }
    }
    
    func observeAmountOfPersons() {
        self._amountOfPersons.signal.observeValues { (amount) in
            self.totalPriceText.value = self.calculateTotalPrice()
        }
    }
    
    private func sortDates(dates: [Date]) -> (Date, Date) {
        let sortedDates = dates.sorted(by: { (date1, date2) -> Bool in
            return date1.compare(date2) == .orderedAscending
        })
        
        return (sortedDates[0], sortedDates[1])
    }
    
    private func calculateTotalPrice() -> String {
        guard let days = self.amountOfDays else {return "Итого: (*) р."}
        let price = days * Int(model.price) * self._amountOfPersons.value
        
        return "Итого: \(price) р."
    }
}

extension BookingViewModel {
    func numberOfRowsInComponent(_ component: Int) -> Int {
        return self.model.apartmentType.maxPersons
    }
    
    func titleForRow(component: Int, row: Int) -> String {
        return String(row+1)
    }
}
