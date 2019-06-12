//
//  PostFeedbackCell.swift
//  Coursework
//
//  Created by Victor on 21/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol PostFeedbackCellDelegate: class {
    func postFeedbackCell(sendFeedback rating: Int, comment: String)
    func postFeedbackCell(sendAlert alert: ErrorAlert)
}

class PostFeedbackCell: UITableViewCell, CustomCellTypeModel, NibLoadableView, ReusableView {
    //MARK: Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType?
    var delegate: PostFeedbackCellDelegate?
    
    var currentRating: Int?
    
    //MARK: Reactive
    private var sendFeedbackAction: Action<(Int?, String?), (Int,String), DetailHotelViewModel.DetailHotelError>
    fileprivate let postButtonSignalProducerGenerator: (Int?, String?) -> SignalProducer<(Int, String), DetailHotelViewModel.DetailHotelError>  = { rating, comment  in
        return SignalProducer<(Int, String), DetailHotelViewModel.DetailHotelError> { (observer, lifetime) in
            guard let currentRating = rating else {
                observer.send(error: .validateError("Вы не указали оценку", "Пожалуйста, выберите оценку"))
                observer.sendCompleted()
                return
            }
            guard let comment = comment, !comment.isEmpty else {
                observer.send(error: .validateError("Вы не написали отзыв", "Пожалуйста, напишите отзыв"))
                observer.sendCompleted()
                return
            }
            observer.send(value: (currentRating, comment))
            observer.sendCompleted()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        sendFeedbackAction = Action<(Int?, String?), (Int,String), DetailHotelViewModel.DetailHotelError>.init(execute: postButtonSignalProducerGenerator)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sendFeedbackAction = Action<(Int?, String?), (Int,String), DetailHotelViewModel.DetailHotelError>.init(execute: postButtonSignalProducerGenerator)
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
//MARK: Setup
extension PostFeedbackCell {
    func setup() {
        self.feedbackTextView.text = ""
        self.feedbackTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        self.feedbackTextView.font = Fonts.medium(size: 13)
        self.feedbackTextView.dropShadow()
        
        self.sendFeedbackButton.setTitle("Отправить отзыв", for: .normal)
        self.sendFeedbackButton.setTitleColor(UIColor.white, for: .normal)
        self.sendFeedbackButton.titleLabel?.font = Fonts.ultraLight(size: 13)
        self.sendFeedbackButton.tintColor = UIColor.white
        self.sendFeedbackButton.backgroundColor = Colors.defaultColor
        self.sendFeedbackButton.setBackgroundColor(color: Colors.defaultColor, forState: .selected)
        self.sendFeedbackButton.setCircle()
        self.sendFeedbackButton.addTarget(self, action: #selector(postButtonTapped(_:)), for: .touchUpInside)
        
        self.ratingStackView.distribution = .fillEqually
        for index in 0 ..< 10 {
            let rateButton = UIButton()
            rateButton.borderWidth = 1
            rateButton.border = Colors.defaultColor
            rateButton.tag = index
            let stringIndex = String(index+1)
            print(stringIndex)
            rateButton.setTitle(stringIndex, for: .normal)
            rateButton.titleLabel?.font = Fonts.ultraLight(size: 10)
            rateButton.backgroundColor = UIColor.white
            rateButton.setTitleColor(UIColor.black, for: .normal)
            rateButton.setBackgroundColor(color: UIColor.lightGray, forState: .selected)
            rateButton.addTarget(self, action: #selector(rateButtonTapped(_:)), for: .touchUpInside)
            self.ratingStackView.addArrangedSubview(rateButton)
        }
    }
}

//MARK: Actions

extension PostFeedbackCell {
    @objc func rateButtonTapped(_ sender: UIButton) {
        for button in ratingStackView.arrangedSubviews as! [UIButton] {
            button.isSelected = false
        }
        sender.isSelected = true
        self.currentRating = sender.tag + 1
    }
    
    @objc func postButtonTapped(_ sender: UIButton) {
        self.sendFeedbackAction.errors.observeValues {[weak self] (error) in
            switch error {
            case .validateError(let title, let message):
                self?.delegate?.postFeedbackCell(sendAlert: ErrorAlert.init(title: title, message: message))
            }
        }
        
        self.sendFeedbackAction.apply((self.currentRating, self.feedbackTextView.text)).startWithResult {[weak self] (result) in
            if let value = result.value {
                self?.delegate?.postFeedbackCell(sendFeedback: value.0, comment: value.1)
                self?.feedbackTextView.text = ""
            }
        }

    }
}

