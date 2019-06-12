//
//  DetailHotelController.swift
//  Coursework
//
//  Created by Victor on 15/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class DetailHotelController: UIViewController {
    var (lifetime, token) = Lifetime.make()
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Properties
    var viewModel: DetailHotelViewModel
    var inputs: [UIView] = []
    
    //MARK: Reactive
    var didSelectSignal: Signal<IndexPath, NoError>
    fileprivate var didSelectObserver: Signal<IndexPath, NoError>.Observer
    
    var loading: BindingTarget<Bool> {
        return BindingTarget<Bool>.init(lifetime: lifetime, action: { (loading) in
            
        })
    }
    
    var alertBinding: BindingTarget<ErrorAlert> {
        return BindingTarget<ErrorAlert>.init(lifetime: lifetime, action: {[weak self] (alert) in
            guard let sself = self else {return}
            sself.showAlertError(errorAlert: alert)
        })
    }
    
    var insertCellsAtIndexPaths: BindingTarget<[IndexPath]> {
        return BindingTarget<[IndexPath]>.init(lifetime: lifetime, action: {[weak self] (indexPaths) in
            guard let sself = self else {return}
            print(indexPaths)
            DispatchQueue.main.async {
                sself.tableView.beginUpdates()
                sself.tableView.insertRows(at: indexPaths, with: .bottom)
                sself.tableView.endUpdates()
                
                if let indexPath = indexPaths.last {
                    sself.scrollToIndexPath(tableView: sself.tableView, indexPath)
                }
            }
        })
    }
    
    var removeCellAtIndexPaths: BindingTarget<[IndexPath]> {
        return BindingTarget<[IndexPath]>.init(lifetime: lifetime, action: { [weak self] (indexPaths) in
            guard let sself = self else {return}
            print(indexPaths)
            
            DispatchQueue.main.async {
                sself.tableView.beginUpdates()
                sself.tableView.deleteRows(at: indexPaths, with: .fade)
                sself.tableView.endUpdates()
            }
        })
    }
    
    var updateCells: BindingTarget<[IndexPath]> {
        return BindingTarget<[IndexPath]>.init(lifetime: lifetime, action: {[weak self] (indexPaths) in
            guard let sself = self else {return}
            DispatchQueue.main.async {
                sself.tableView.beginUpdates()
                sself.tableView.reloadRows(at: indexPaths, with: .none)
                sself.tableView.endUpdates()
            }
        })
    }
    
    var push: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    init(viewModel: DetailHotelViewModel) {
        self.viewModel = viewModel
        (didSelectSignal, didSelectObserver) = Signal.pipe()
        super.init(nibName: nil, bundle: nil)
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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CarouselGalleryCell.self)
        self.tableView.register(ApartmentCell.self)
        self.tableView.register(CommentCell.self)
        self.tableView.register(DescriptionCell.self)
        self.tableView.register(HotelRatingCell.self)
        self.tableView.register(PostFeedbackCell.self)
        self.title = viewModel.title
        
        //self.tableView.isScrollEnabled = false
        self.tableView.estimatedRowHeight = 600
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        viewModel.preload()
    }
    
    func bind() {
        self.tableView.reactive.reloadData <~ viewModel.reload
        self.loading <~ viewModel.loading
        self.insertCellsAtIndexPaths <~ self.viewModel.insertAtIndexPaths
        self.removeCellAtIndexPaths <~ self.viewModel.removeAtIndexPaths
        self.push <~ self.viewModel.push
        viewModel.didSelectAtIndexPath <~ self.didSelectSignal
        self.alertBinding <~ viewModel.errorAlert
        //self.updateCells <~ viewModel.updateCells
    }
}

//MARK: UITableViewDataSource
extension DetailHotelController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            print(viewModel.numberOfRowsInSection(section: section))
            
        }
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell: CarouselGalleryCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = viewModel.cellForRow(at: indexPath)
                return cell
            case 1:
                let cell: HotelRatingCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = viewModel.cellForRow(at: indexPath)
                return cell
            case 2:
                let cell: DescriptionCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = viewModel.cellForRow(at: indexPath)
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell: ApartmentCell = tableView.dequeueReusableCell(for: indexPath)
            cell.model = viewModel.cellForRow(at: indexPath)
            return cell
        case 2:
            guard let cellType = viewModel.cellForRow(at: indexPath) else {
                return UITableViewCell()
            }
            switch cellType {
            case .commentCell:
                let cell: CommentCell = tableView.dequeueReusableCell(for: indexPath)
                cell.model = viewModel.cellForRow(at: indexPath)
                cell.delegate = viewModel
                return cell
            case .postFeedbackCell:
                let cell: PostFeedbackCell = tableView.dequeueReusableCell(for: indexPath)
                self.inputs.append(cell.feedbackTextView)
                cell.delegate = viewModel
                return cell
            default:
                return UITableViewCell()
            }

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.headerForSection(section: section)
    }
}

//MARK: UITableViewDelegate
extension DetailHotelController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectObserver.send(value: indexPath)
    }
}

//MARK: ScrollToIndexPath
extension DetailHotelController {
    func scrollToIndexPath(tableView: UITableView, _ indexPath: IndexPath) {
        UIView.transition(with: tableView, duration: 0.3, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            let lastIndexPath = IndexPath.init(row: indexPath.row + 1, section: indexPath.section)
            tableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: false)
        }, completion: nil)
    }
}

//MARK: Keyboard handle
extension DetailHotelController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 40, right: 0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = .zero
        self.tableView.scrollIndicatorInsets = .zero
    }
}


