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
    var searchController: UISearchController!
    var activityIndicator: UIActivityIndicatorView!
    
    //MARK: -properties
    var (lifetime, token) = Lifetime.make()
    var viewModel: HotelsListViewModel
    
    var isPulled: Bool = false
    
    //MARK: Reactive
    var pushVC: BindingTarget<UIViewController> {
        return BindingTarget<UIViewController>.init(lifetime: lifetime, action: {[weak self] (vc) in
            guard let sself = self else {return}
            sself.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    var insertRowsAtIndexPaths: BindingTarget<[IndexPath]> {
        return BindingTarget<[IndexPath]>.init(lifetime: lifetime, action: { (indexPaths) in
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .fade)
                self.tableView.endUpdates()
            }
        })
    }
    
    var text: MutableProperty<String>
    
    init(viewModel: HotelsListViewModel) {
        self.viewModel = viewModel
        self.text = MutableProperty<String>.init("")
        activityIndicator = UIActivityIndicatorView(style: .gray)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setup() {
        viewModel.preload()
        self.title = "Список отелей"
        
        //self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -100, right: 0)
        self.tableView.estimatedRowHeight = 80
        
        self.searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        activityIndicator.center = CGPoint(x: self.view.width / 2, y: 50)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 100))
        self.tableView.tableFooterView?.addSubview(activityIndicator)
        
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = HotelsListViewModel.FilterType.allCases.map({ (type) -> String in
            return type.rawValue
        })
        
        let nib = UINib.init(nibName: HotelCell.defaultReuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: HotelCell.defaultReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    func bind() {
        self.tableView.reactive.reloadData <~ self.viewModel.reload
        self.pushVC <~ self.viewModel.pushVCSignal
        self.insertRowsAtIndexPaths <~ viewModel.insertRowsAtIndexPath
        self.activityIndicator.reactive.isHidden <~ viewModel.reloading.signal.map({ (reloading) -> Bool in
            return !reloading
        })
        self.activityIndicator.reactive.isAnimating <~ viewModel.reloading
    }
}

//MARK: Refreshing
extension HotelsListController {
   
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

//MARK: SearchResultsUpdating
extension HotelsListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.text.value = searchController.searchBar.text
    }
}

extension HotelsListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(HotelsListViewModel.FilterType.allCases[selectedScope].rawValue)
        viewModel.filterType.value = HotelsListViewModel.FilterType.allCases[selectedScope]
    }
}

extension HotelsListController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if !viewModel.reloading.value && deltaOffset <= 20 && !isPulled {
            self.isPulled = true
            viewModel.loadMore()
        }
        else {
            self.isPulled = false
        }
    }
}
