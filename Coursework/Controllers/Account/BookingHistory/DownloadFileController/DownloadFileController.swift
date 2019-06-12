//
//  DownloadFileController.swift
//  Coursework
//
//  Created by Victor on 12/05/2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import WebKit

class DownloadFileController: BaseController {
    //MARK: Outlets
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: Properties
    var url: String
    
    init(url: String) {
        self.url = url
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRequest()
    }
    
    func makeRequest() {
        self.webView.navigationDelegate = self
        let url = URL(string:self.url)!
        var request = URLRequest(url: url)
        guard let dict = Network.addAuthorization(to: nil, user: UserManager.shared.currentUser) else {return}
        request.addValue(dict.values.first!, forHTTPHeaderField: dict.keys.first!)
        self.webView.load(request)
    }

}

extension DownloadFileController: WKNavigationDelegate {
    
}
