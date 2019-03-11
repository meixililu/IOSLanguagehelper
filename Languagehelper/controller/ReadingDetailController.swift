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
    @IBOutlet weak var play_btn: UIButton!
    var newsItem: LCObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.play_btn.layer.masksToBounds = true //没这句话它圆不起来
        self.play_btn.layer.cornerRadius = 22.5 //设置图片圆角的尺度
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
            let attributedString = NSMutableAttributedString(string: content)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            lb_content.attributedText = attributedString
        }
        let type = (newsItem?.get(AVUtil.Reading.type)?.stringValue)!
        if type == "mp3"{
            if(PlayerService.status == "1"){
                if(newsItem?.get(AVUtil.Reading.objectId)?.stringValue == PlayerService.lastPlayItem){
                    play_btn.setImage(UIImage(named:"cm_pause_white"), for: .normal)
                }
            }
        }else{
            play_btn.isHidden = true
        }
    }
    
    @IBAction func onClickPlayBtn(_ sender: Any) {
        PlayerService.playMp3(item: newsItem!)
        if(PlayerService.status == "1"){
            play_btn.setImage(UIImage(named:"cm_pause_white"), for: .normal)
        }else{
            play_btn.setImage(UIImage(named:"cm_play_white"), for: .normal)
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("ReadingDetailController Video Finished")
        play_btn.setImage(UIImage(named:"cm_play_white"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name:PlayerService.mp3FinishNf , object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}


