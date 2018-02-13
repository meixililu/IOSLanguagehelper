//
//  ReadingDetailController.swift
//  Languagehelper
//
//  Created by luli on 08/02/2018.
//  Copyright © 2018 luli. All rights reserved.
//

import UIKit
import Foundation
import LeanCloud
import Kingfisher
import AVFoundation
import KTVHTTPCache

class ReadingDetailController: UIViewController {
    
    @IBOutlet weak var lb_title: PaddingLabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var img_height: NSLayoutConstraint!
    @IBOutlet weak var lb_content: UILabel!
    var newsItem: LCObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (newsItem != nil) {
            lb_title.text = newsItem?.get(AVUtil.Reading.title)?.stringValue
            let url_str = (newsItem?.get(AVUtil.Reading.img_url)?.stringValue)!
            if !url_str.isEmpty {
                let url = URL(string: url_str)
                img.kf.setImage(with: url)
            }else{
                img_height.constant = CGFloat(0)
            }
            let content = (newsItem?.get(AVUtil.Reading.content)?.stringValue)!
            lb_content.text = content
        }
        
        
    }
    
}


