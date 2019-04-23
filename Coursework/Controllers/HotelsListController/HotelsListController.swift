//
//  HotelsListController.swift
//  Coursework
//
//  Created by Victor on 09/04/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class HotelsListController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -properties
    var (lifetime, token) = Lifetime.make()
    var viewModel: HotelsListViewModel
    
    //MARK: Reactive
    var pushVC: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            guard let sself = self else {return}
            sself.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    init(viewModel: HotelsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    func setup() {
        viewModel.preload()
        self.title = "Список отелей"
        
        let nib = UINib.init(nibName: HotelCell.defaultReuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: HotelCell.defaultReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    func bind() {
        self.tableView.reactive.reloadData <~ self.viewModel.reload
        self.pushVC <~ self.viewModel.pushVCSignal
    }

}
//MARK: UITableViewDataSource
extension HotelsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HotelCell = tableView.dequeueReusableCell(for: indexPath)
        cell.model = viewModel.hotelForCell(at: indexPath)
        return cell
    }
}

//MARK: UITableViewDelegate
extension HotelsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectHotel(at: indexPath)
    }
}
