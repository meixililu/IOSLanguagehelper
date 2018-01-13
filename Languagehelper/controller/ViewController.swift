//
//  ViewController.swift
//  Languagehelper
//
//  Created by luli on 16/6/17.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var swiftPaagesView: SwiftPages!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let initString:String="appid="+APPID_VALUE+",timeout="+TIMEOUT_VALUE
        IFlySpeechUtility.createUtility(initString)//所有服务启动前，需要确保执行createUtility
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController--viewDidLoad")
        automaticallyAdjustsScrollViewInsets = false
        
//        let swiftPagesView : SwiftPages!
//        swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        // Initiation
        let VCIDs = ["FirstVC", "SecondVC", "StudyVC"]
        let buttonTitles = [NSLocalizedString("Translate", comment: "translate"),
                            NSLocalizedString("Dictionary", comment: "dictionary"),
                            NSLocalizedString("Study", comment: "study")]
        
        // Sample customization
        swiftPaagesView.setOriginY(0.0)
        swiftPaagesView.enableAeroEffectInTopBar(true)
        swiftPaagesView.setTopBarBackground(UIColor(hexString: ColorUtil.appBlue)!)
        swiftPaagesView.setButtonsTextColor(UIColor(hexString: ColorUtil.appBlue)!)
        swiftPaagesView.setAnimatedBarColor(UIColor(hexString: ColorUtil.appBlue)!)
        swiftPaagesView.setButtonsTextFontAndSize(UIFont.systemFont(ofSize: CGFloat.init(14)))
        swiftPaagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        swiftPaagesView.setViewdidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        swiftPaagesView.setViewdidDisappear()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("View-didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }

}

