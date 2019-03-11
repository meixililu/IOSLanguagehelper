//
//  WebviewController.swift
//  Languagehelper
//
//  Created by luli on 2018/5/19.
//  Copyright © 2018 luli. All rights reserved.
//

import Foundation
import WebKit

class WebviewController: UIViewController, WKUIDelegate{
    
    var webView: WKWebView!
    
    var url: String = "http://www.baidu.com/"
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
