//
//  DetailApartmentViewModel.swift
//  Coursework
//
//  Created by Victor on 29/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import UIKit

class DetailApartmentViewModel {
    //MARK: Properties
    private var apartment: MDApartment
    
    var apartmentImages: [String] {
        return apartment.pictures
    }
    
    var rating: Double {
        switch apartment.apartmentType.type {
        case .oneStar:
            return 1.0
        case .twoStar:
            return 2.0
        case .threeStar:
            return 3.0
        case .fourStar:
            return 4.0
        case .fiveStar:
            return 5.0
        }
    }
    
    var numberOfRooms: String {
        return "Кол-во комнат: \(self.apartment.apartmentType.numberOfRooms)"
    }
    
    var price: String {
        return "\(Int(self.apartment.price))р."
    }
    
    init(apartment: MDApartment) {
        self.apartment = apartment
    }
    
    func conditions() -> [ConditionCell.Model] {
        let conditions = self.apartment.conditions.arrayRepresent().map { (condition) -> ConditionCell.Model in
            let enabled = condition.enabled
            if enabled {
                return ConditionCell.Model.init(title: condition.title, iconName: condition.icon.appending("-enabled"), textColor: UIColor.black)
            }
            else {
                return ConditionCell.Model.init(title: condition.title, iconName: condition.icon.appending("-disabled"), textColor: Colors.disabled)
            }
        }
        return conditions
    }
}
