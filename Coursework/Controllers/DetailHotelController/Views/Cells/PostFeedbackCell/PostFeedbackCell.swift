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

class PostFeedbackCell: UITableViewCell, CustomCellTypeModel, NibLoadableView, ReusableView {
    //MARK: Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType?
    
    var currentRating: Int?
    var firstBeginEditing: Bool = true
    
    //MARK: Reactive
    var postButtonTapped: Signal<(Int, String), DetailHotelViewModel.DetailHotelError>
    fileprivate var postButtonTappedObserver: Signal<(Int, String), DetailHotelViewModel.DetailHotelError>.Observer
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        (postButtonTapped, postButtonTappedObserver) = Signal.pipe()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        (postButtonTapped, postButtonTappedObserver) = Signal.pipe()
        
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
        self.feedbackTextView.delegate = self
        self.feedbackTextView.text = "Оставьте здесь ваш комментарий ..."
        self.feedbackTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        self.feedbackTextView.font = Fonts.medium(size: 13)
        self.feedbackTextView.dropShadow()
        
        self.sendFeedbackButton.setTitle("Отправить отзыв", for: .normal)
        self.sendFeedbackButton.setTitleColor(UIColor.white, for: .normal)
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
        self.currentRating = sender.tag
    }
    
    @objc func postButtonTapped(_ sender: UIButton) {
        guard let currentRating = self.currentRating else {
            self.postButtonTappedObserver.send(error: .validateError("Вы не указали оценку", "Пожалуйста, выберите оценку"))
            
            return
        }
        guard let comment = self.feedbackTextView.text, !comment.isEmpty, !firstBeginEditing else {
            self.postButtonTappedObserver.send(error: .validateError("Вы не написали отзыв", "Пожалуйста, напишите отзыв"))

            return
        }
        self.postButtonTappedObserver.send(value: (currentRating, comment))
    }
}

extension PostFeedbackCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.firstBeginEditing {
            textView.text = ""
            self.firstBeginEditing = false
        }
    }
}
