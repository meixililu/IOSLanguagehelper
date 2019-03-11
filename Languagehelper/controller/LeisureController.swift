//
//  LeisureController.swift
//  Languagehelper
//
//  Created by luli on 2018/5/19.
//  Copyright © 2018 luli. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class LeisureController: UIViewController,IndicatorInfoProvider{
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: NSLocalizedString("Relax", comment: "relax"))
    
    @IBOutlet weak var btn_wyyx: UIStackView!
    @IBOutlet weak var btn_news: UIStackView!
    @IBOutlet weak var btn_smsearch: UIStackView!
    
    override func viewDidLoad() {
        
        let tap_wyyx:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeisureController.toWYYXPage(sender:)))
        btn_wyyx.isUserInteractionEnabled = true
        btn_wyyx.addGestureRecognizer(tap_wyyx)
        
        let tap_uctt:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeisureController.toUCTTPage(sender:)))
        btn_news.isUserInteractionEnabled = true
        btn_news.addGestureRecognizer(tap_uctt)
        
        let tap_smsearch:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeisureController.toSMSearchPage(sender:)))
        btn_smsearch.isUserInteractionEnabled = true
        btn_smsearch.addGestureRecognizer(tap_smsearch)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FileManagerUtil.saveUserDefaults(3, key: KeyUtile.userLastPageIndex)
    }
    
    func toWYYXPage(sender:UITapGestureRecognizer){
        let mWebviewController = storyboard?.instantiateViewController(withIdentifier: "WebviewController") as! WebviewController
        mWebviewController.url = SettingUtil.lei_wyyx
        self.navigationController!.pushViewController(mWebviewController, animated: true)
    }
    
    func toUCTTPage(sender:UITapGestureRecognizer){
        let mWebviewController = storyboard?.instantiateViewController(withIdentifier: "WebviewController") as! WebviewController
        mWebviewController.url = SettingUtil.lei_uctt
        self.navigationController!.pushViewController(mWebviewController, animated: true)
    }
    
    func toSMSearchPage(sender:UITapGestureRecognizer){
        let mWebviewController = storyboard?.instantiateViewController(withIdentifier: "WebviewController") as! WebviewController
        mWebviewController.url = SettingUtil.lei_smsearch
        self.navigationController!.pushViewController(mWebviewController, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
