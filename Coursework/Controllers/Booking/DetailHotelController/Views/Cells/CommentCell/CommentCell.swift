//
//  CommentCell.swift
//  Coursework
//
//  Created by Victor on 17/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol CommentCellDelegate: class {
    func commentCell(deleteFeedbackAt id: Int)
}

class CommentCell: UITableViewCell, CustomCellTypeModel, ReusableView, NibLoadableView {
    struct Model{
        let id: Int
        let date: String
        let userName: String
        let rating: Float
        let comment: String
        let isMyComment: Bool
    }
    
    //MARK: Outlets
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var cimmentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteFeedbackButton: UIButton!
    
    //MARK: Properties
    var model: DetailHotelViewModel.CellType? {
        didSet {
            guard let cellType = model else {return}
            switch cellType {
            case .commentCell(let feedback):
                guard let id = feedback.id, let date = feedback.date, let username = feedback.user?.username, let isMyComment = feedback.user?.isMyComment else {return}
                let model = Model(id: id, date: date, userName: username,  rating: feedback.rating, comment: feedback.comment, isMyComment: isMyComment)
                setup(model: model)
            default:
                return
            }
        }
    }
    
    weak var delegate: CommentCellDelegate?
    
    //MARK: Reactive
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//MARK: Setup
extension CommentCell {
    func setup(model: Model) {
        switch model.rating {
        case 0..<5.0:
            self.ratingView.backgroundColor = UIColor.red
        case 5.0 ..< 8.0:
            self.ratingView.backgroundColor = UIColor.yellow
        case 8.0 ... 10.0:
            self.ratingView.backgroundColor = UIColor.green
        default:
            break
        }
        self.ratingView.setCircle()
        
        self.ratingLabel.font = Fonts.demiBold(size: 13)
        self.ratingLabel.textColor = UIColor.black
        self.ratingLabel.text = String(model.rating)
        
        self.cimmentLabel.textColor = UIColor.black.withAlphaComponent(1)
        self.cimmentLabel.text = model.comment
        self.cimmentLabel.font = Fonts.demiBold(size: 12)
        
        self.usernameLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        self.usernameLabel.text = model.userName
        self.usernameLabel.font = Fonts.medium(size: 13)
        
        self.dateLabel.textColor = Colors.gray112
        self.dateLabel.text = model.date
        self.dateLabel.font = Fonts.ultraLight(size: 9)
        
        if model.isMyComment {
            self.deleteFeedbackButton.tag = model.id
            self.deleteFeedbackButton.isHidden = false
            self.deleteFeedbackButton.addTarget(self, action: #selector(deleteFeedback(_:)), for: .touchUpInside)
            self.usernameLabel.text = "\(model.userName) (это Вы)"
        }
        else {
            self.deleteFeedbackButton.isHidden = true
        }
    }
}

//MARK:Actions
extension CommentCell {
    @objc func deleteFeedback(_ sender: UIButton) {
        self.delegate?.commentCell(deleteFeedbackAt: sender.tag)
    }
}
