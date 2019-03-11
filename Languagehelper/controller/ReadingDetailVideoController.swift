//
//  ReadingDetailController.swift
//  Languagehelper
//
//  Created by luli on 31/01/2018.
//  Copyright © 2018 luli. All rights reserved.
//

import UIKit
import AVKit
import LeanCloud
import Foundation
import Kingfisher
import AVFoundation
import KTVHTTPCache

class ReadingDetailVideoController: UIViewController {

    @IBOutlet weak var lb_title: PaddingLabel!
    @IBOutlet weak var video: UIView!
    @IBOutlet weak var video_height: NSLayoutConstraint!
    
    @IBOutlet weak var content_lb: UILabel!
    var avplayer: AVPlayer?
    var newsItem: LCObject?
    
    @IBAction func back(_ sender: Any) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReadingDetailController---viewDidLoad")
        lb_title.setLineHeight(lineHeight: 5.0)
        if (newsItem != nil) {
            PlayerService.pause()
            lb_title.text = newsItem?.get(AVUtil.Reading.title)?.stringValue
            
            let content = (newsItem?.get(AVUtil.Reading.content)?.stringValue)!
            let attributedString = NSMutableAttributedString(string: content)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            content_lb.attributedText = attributedString
            
            let mp4_url = (newsItem?.get(AVUtil.Reading.media_url)?.stringValue)!
            let url_string = KTVHTTPCache.proxyURLString(withOriginalURLString: mp4_url)
            let Mp4Url = URL(string: url_string!)
            avplayer = AVPlayer(url: Mp4Url!)
            
            let playerController = AVPlayerViewController()
            playerController.player = avplayer
            video.addSubview(playerController.view)
            playerController.view.frame = video.bounds
            self.addChildViewController(playerController)
            video.addSubview(playerController.view)
            playerController.didMove(toParentViewController: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.avplayer?.play()
            }
        }
    }
    


}
