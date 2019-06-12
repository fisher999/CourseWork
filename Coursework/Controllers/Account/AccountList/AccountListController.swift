//
//  AccountListController.swift
//  Coursework
//
//  Created by Victor on 11/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class AccountListController: BaseController {
    //MARK: Cell model
    enum Model: String, CaseIterable {
        case history = "История бронирований"
        case signOut = "Выйти"
    }
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(AccountListCell.self)
    }
}

extension AccountListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.model = Model.allCases[indexPath.row]
        return cell
    }
}

extension AccountListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = Model.allCases[indexPath.row]
        switch cell {
        case .history:
            let viewModel = BookingHistoryViewModel()
            let vc = BookingHistoryController(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        case .signOut:
            UserDefaults.standard.removeObject(forKey: "basic_auth")
            let viewModel = RegisterViewModel()
            let vc = RegisterViewController(viewModel: viewModel)
            self.modalTransitionStyle = .flipHorizontal
            self.present(vc, animated: true, completion: nil)
        }
    }
}
