//
//  ViewController.swift
//  Languagehelper
//
//  Created by luli on 16/6/17.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainViewController: ButtonBarPagerTabStripViewController{
    
    var isReload = false
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("MainViewController--required init")
        let initString:String="appid="+APPID_VALUE+",timeout="+TIMEOUT_VALUE
        IFlySpeechUtility.createUtility(initString)//所有服务启动前，需要确保执行createUtility
    }
    
    override func viewDidLoad() {
        print("MainViewController--viewDidLoad")
        self.settings.style.buttonBarItemFont = .systemFont(ofSize: 14)
        self.settings.style.buttonBarItemTitleColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.7)
        self.settings.style.buttonBarBackgroundColor = UIColor(hexString: ColorUtil.barBackground, alpha: 1.0)
        self.settings.style.buttonBarItemBackgroundColor = UIColor(hexString: ColorUtil.barBackground, alpha: 1.0)
        self.settings.style.selectedBarBackgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.5)!
        self.settings.style.selectedBarHeight = 1
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        let item = UIBarButtonItem(title: "   ", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.moveToViewController(at: 2)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        print("MainViewController---viewControllers")
        let child_tran = storyboard?.instantiateViewController(withIdentifier: "TranslateController")
        let child_dic = storyboard?.instantiateViewController(withIdentifier: "DictionaryController")
        let child_reading = storyboard?.instantiateViewController(withIdentifier: "StudyController")
        return [child_tran!, child_dic!, child_reading!]
    }
    
}

