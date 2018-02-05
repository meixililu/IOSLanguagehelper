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

class ReadingDetailController: UIViewController {

    @IBOutlet weak var lb_title: PaddingLabel!
    @IBOutlet weak var img: UIImageView!
//    @IBOutlet weak var img_height: NSLayoutConstraint!
    @IBOutlet weak var video: UIView!
    @IBOutlet weak var video_height: NSLayoutConstraint!
    
    var avplayer: AVPlayer?
    var newsList: LCObject?
    
    @IBAction func back(_ sender: Any) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReadingDetailController---viewDidLoad")
        let url = URL(string: "http://pic.kekenet.com/2018/0131/1517403636.jpg")
        img.kf.setImage(with: url)
//        img_height.constant = CGFloat(0)
        lb_title.setLineHeight(lineHeight: 9.0)
        
        let mp4_url = "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"
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

    }
    


}
