//
//  BookingHistoryController.swift
//  Coursework
//
//  Created by Victor on 12/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import ReactiveSwift

class BookingHistoryController: BaseController {
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    let viewModel: BookingHistoryViewModel
    
    init(viewModel: BookingHistoryViewModel) {
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
        self.tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.separatorStyle = .none
        
        let csvItem = UIBarButtonItem(title: "CSV", style: .plain, target: self, action: #selector(csvTapped(_:)))
        //let pdfItem = UIBarButtonItem(title: "PDF", style: .plain, target: self, action: #selector(pdfTapped(_:)))
        
        self.navigationItem.rightBarButtonItem = csvItem
        
        self.tableView.register(BookingCell.self)
        viewModel.preload()
    }
    
    func bind() {
        self.tableView.reactive.reloadData <~ viewModel.reloadSignal
    }
}

//MARK: DataSource
extension BookingHistoryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BookingCell = tableView.dequeueReusableCell(for: indexPath)
        cell.model = viewModel.modelForCell(at: indexPath)
        return cell
    }
}

//MARK: ButtonActions
extension BookingHistoryController {
    @objc func csvTapped(_ sender: UIButton) {
        let vc = DownloadFileController(url: BookingHistoryViewModel.DownloadingFile.csv.rawValue)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pdfTapped(_ sender: UIButton) {
        
    }
}




