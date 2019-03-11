//
//  PlayerService.swift
//  Languagehelper
//
//  Created by luli on 27/03/2018.
//  Copyright © 2018 luli. All rights reserved.
//

import Foundation
import AVFoundation
import KTVHTTPCache
import LeanCloud

class PlayerService{
    
    static var status = "0"  // 0 player do not play, 1 playing , 3 pause
    static var player: AVPlayer?
    static let mp3FinishNf = NSNotification.Name(rawValue: "Mp3FinishNotification")
    static var lastPlayItem: String = ""
    
    class func playMp3(item: LCObject) -> Void {
        let newItemId = item.get(AVUtil.Reading.objectId)?.stringValue
        if(status == "0"){
            status = "1"
            lastPlayItem = newItemId!
            play(item: item)
        }else if(status == "1"){
            player?.pause()
            if(newItemId == lastPlayItem){
                status = "3"
            }else{
                status = "1"
                lastPlayItem = newItemId!
                play(item: item)
            }
        }else if(status == "3"){
            status = "1"
            if(newItemId == lastPlayItem){
                if(player != nil){
                    player!.play()
                }
            }else{
                lastPlayItem = newItemId!
                play(item: item)
            }
        }
    }
    
    class func play(item: LCObject) -> Void {
        let mp3Url = (item.get(AVUtil.Reading.media_url)?.stringValue)!
        let url_string = KTVHTTPCache.proxyURLString(withOriginalURLString: mp3Url)
        let Mp3Url = URL(string: url_string!)
        player = AVPlayer(url: Mp3Url!)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        player!.play()
    }
    
    @objc class func playerDidFinishPlaying(note: NSNotification) {
        print("PlayerService Video Finished")
        status = "0"
        NotificationCenter.default.post(name: mp3FinishNf, object: nil)
    }
    
    class func pause() -> Void {
        if(player != nil){
            player?.pause()
        }
    }
    
    
}
