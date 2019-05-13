//
//  BookingController.swift
//  Coursework
//
//  Created by Victor on 04/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import FSCalendar
import ReactiveSwift
import Result

class BookingController: BaseController {
    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var totalDays: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var numberOfPlaceTitle: UILabel!
    @IBOutlet weak var amountOfPersonsPicker: UIPickerView!
    
    //MARK: Properties
    var viewModel: BookingViewModel
    
    //MARK: Reactive
    var bookingButtonTapped: Signal<(), NoError>
    fileprivate var bookingButtonTappedObserver: Signal<(), NoError>.Observer
    
    var push: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            self?.present(vc, animated: true, completion: nil)
        })
    }
    
    
    init(viewModel: BookingViewModel) {
        (bookingButtonTapped, bookingButtonTappedObserver) = Signal.pipe()
        
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }
    
    func setup() {
        viewModel.setup()
        
        self.amountOfPersonsPicker.dataSource = self
        self.amountOfPersonsPicker.delegate = self
        
        self.titleLabel.text = "Пожалуйста, выберите даты заезда и отъезда"
        self.titleLabel.font = Fonts.ultraLight(size: 14)
        self.titleLabel.textColor = UIColor.black
        
        self.numberOfPlaceTitle.text = "Выберите кол-во мест"
        self.numberOfPlaceTitle.font = Fonts.ultraLight(size: 12)
        self.numberOfPlaceTitle.textColor = UIColor.black
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.allowsMultipleSelection = true
        
        self.totalDays.text = " (*) дней"
        self.totalDays.font = Fonts.ultraLight(size: 13)
        self.totalDays.textColor = Colors.gray140
        
        self.totalPrice.text = "Итого: 1440р."
        self.totalPrice.textColor = Colors.gray140
        self.totalPrice.font = Fonts.ultraLight(size: 13)
        
        self.bookingButton.setTitle("Забронировать", for: .normal)
        self.bookingButton.setTitleColor(UIColor.white, for: .normal)
        self.bookingButton.titleLabel?.font = Fonts.ultraLight(size: 13)
        self.bookingButton.tintColor = UIColor.white
        self.bookingButton.backgroundColor = Colors.disabled
        self.bookingButton.setCircle()
        self.bookingButton.addTarget(self, action: #selector(bookingButtonTapped(_:)), for: .touchUpInside)
    }
    
    func bind() {
        self.totalDays.reactive.text <~ viewModel.amountOfPersonsText
        self.totalPrice.reactive.text <~ viewModel.totalPriceText
        self.bookingButton.reactive.isEnabled <~ viewModel.bookingIsAvailable
        self.bookingButton.reactive.backgroundColor <~ viewModel.bookingIsAvailable.map({ (isEnabled) -> UIColor in
            if isEnabled {
                return Colors.defaultColor
            }
            else {
                return Colors.disabled
            }
        })
        self.push <~ viewModel.pushSignal
        viewModel.bookingButtonTapped <~ self.bookingButtonTapped
    }
}

//MARK: Button action
extension BookingController {
    @objc func bookingButtonTapped(_ sender: UIButton) {
        self.bookingButtonTappedObserver.send(value: ())
    }
}

//MARK: FSCalendarDataSource
extension BookingController: FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date().nextDay() ?? Date()
    }
}

//MARK: FSCalendarDelegate
extension BookingController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if viewModel.bookingIsAvailable.value {
            calendar.deselect(date)
        }
        viewModel.selectedDates.value = calendar.selectedDates
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.selectedDates.value = calendar.selectedDates
    }
}

//MARK: PickerDataSource
extension BookingController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRowsInComponent(component)
    }
}

//MARK: PickerDelegate
extension BookingController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.titleForRow(component: component, row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.amountOfPersons.value = row + 1
    }
}
