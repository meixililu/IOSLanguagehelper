//
//  PracticeController.swift
//  Languagehelper
//
//  Created by luli on 2018/5/17.
//  Copyright © 2018 luli. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PracticeController: UIViewController{
    
    @IBOutlet weak var lb_result: UILabel!
    @IBOutlet weak var lb_question: UILabel!
    var item: TranslateResultModel?
    
    override func viewDidLoad() {
        print("PracticeController---viewDidLoad")
        lb_result.text = item?.result
        lb_question.text = item?.question
    }
    
    
    
}
