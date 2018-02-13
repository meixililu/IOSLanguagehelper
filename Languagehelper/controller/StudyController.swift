//
//  StudyController.swift
//  Languagehelper
//
//  Created by luli on 16/04/2017.
//  Copyright © 2017 luli. All rights reserved.
//

import UIKit
import LeanCloud
import Kingfisher
import AVFoundation
import KTVHTTPCache
import MJRefresh
import XLPagerTabStrip

class StudyController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider{

    var itemInfo: IndicatorInfo = IndicatorInfo(title: NSLocalizedString("Read", comment: "read"))
    @IBOutlet weak var tableview: UITableView!
    var newsList = Array<LCObject>()
    var player: AVPlayer?
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshAutoNormalFooter()
    var limit = 15
    var skip = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("study-viewDidLoad")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.estimatedRowHeight = 80
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10)
        tableview.separatorColor = UIColor(hexString: ColorUtil.line_light_gray, alpha: 0.7)
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.tableview.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableview.mj_footer = footer
        
        getDataTask();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FileManagerUtil.saveUserDefaults(2, key: KeyUtile.userLastPageIndex)
    }
    
    func headerRefresh(){
        print("headerRefresh")
        skip = 0
        getDataTask()
    }
    func footerRefresh(){
        print("footerRefresh")
        getDataTask()
    }

    func getDataTask(){
        let query = LCQuery(className: AVUtil.Reading.Reading)
        query.whereKey(AVUtil.Reading.publish_time, .descending)
        query.limit = limit
        query.skip = self.skip * limit
           query.find { result in
            switch result {
            case .success(let objects):
                if self.skip == 0 {
                    self.newsList.removeAll()
                }
                for obg in objects{
                    obg.set(AVUtil.Reading.color_str, value: ColorUtil.getRandomColorStr())
                }
                self.newsList.append(contentsOf: objects)
                self.tableview.reloadData()
                self.skip = self.skip + 1
                print(self.skip)
                print(self.newsList.count)
                self.tableview.mj_footer.endRefreshing()
                self.tableview.mj_header.endRefreshing()
                break
            case .failure(let error):
                self.tableview.mj_footer.endRefreshing()
                self.tableview.mj_header.endRefreshing()
                print(error)
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisplaying:"+indexPath.description)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay:"+indexPath.description)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt:"+indexPath.description)
        self.tableview!.deselectRow(at: indexPath, animated: true)
        let type = (self.newsList[indexPath.row].get(AVUtil.Reading.type)?.stringValue)!
        if type == "video"{
            let detailViewController = storyboard?.instantiateViewController(withIdentifier: "ReadingDetailVideoController") as! ReadingDetailVideoController
            detailViewController.newsItem = self.newsList[indexPath.row]
            self.navigationController!.present(detailViewController, animated: true, completion: nil)
        }else{
            let detailViewController = storyboard?.instantiateViewController(withIdentifier: "ReadingDetailController") as! ReadingDetailController
            detailViewController.newsItem = self.newsList[indexPath.row]
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newscell", for: indexPath as IndexPath) as! ReadingTableViewCell
        cell.title.text = (self.newsList[indexPath.row].get(AVUtil.Reading.title)?.stringValue)!
        let source = (self.newsList[indexPath.row].get(AVUtil.Reading.source_name)?.stringValue)!
        let type_name = (self.newsList[indexPath.row].get(AVUtil.Reading.type_name)?.stringValue)!
        if source.isEmpty {
            cell.source.text = type_name
        }else{
            cell.source.text = source + "       " + type_name
        }
        
        let url_str = (self.newsList[indexPath.row].get(AVUtil.Reading.img_url)?.stringValue)!
        let color_str = (self.newsList[indexPath.row].get(AVUtil.Reading.color_str)?.stringValue)!
        let url = URL(string: url_str)
        cell.img.kf.setImage(with: url, placeholder: ColorUtil.getImageWithColor(ColorUtil.getRandomColorByStr(colorStr: color_str)))
        
        let type = (self.newsList[indexPath.row].get(AVUtil.Reading.type)?.stringValue)!
        if type == "mp3"{
            cell.video_cover_height.constant = CGFloat(0)
            cell.video_img_height.constant = CGFloat(0)
            cell.video_play_img_height.constant = CGFloat(0)
            
            cell.img_width.constant = CGFloat(90)
            cell.play_img.isHidden = false
            if let state = self.newsList[indexPath.row].get(AVUtil.Reading.play_status),
                state.stringValue == "1" {
                cell.play_img.image = UIImage(named:"jz_pause_normal")
            }else{
                cell.play_img.image = UIImage(named:"jz_play_normal")
            }
        }else if type == "video" {
            cell.video_cover_height.constant = CGFloat(170)
            cell.video_img_height.constant = CGFloat(170)
            cell.video_play_img_height.constant = CGFloat(45)
            
            cell.play_img.isHidden = true
            cell.img_width.constant = CGFloat(0)
            cell.video_img.backgroundColor = ColorUtil.getRandomColorByStr(colorStr: color_str)
            cell.video_img.kf.setImage(with: url)
        }else{
            cell.video_cover_height.constant = CGFloat(0)
            cell.video_img_height.constant = CGFloat(0)
            cell.video_play_img_height.constant = CGFloat(0)
            
            cell.play_img.isHidden = true
            cell.img_width.constant = CGFloat(90)
        }
        let tap_share:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StudyController.play_img_click(sender:)))
        cell.play_img.tag = indexPath.row
        cell.play_img.isUserInteractionEnabled = true
        cell.play_img.addGestureRecognizer(tap_share)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    func play_img_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        let mp3Url = (self.newsList[img.tag].get(AVUtil.Reading.media_url)?.stringValue)!
        if (player != nil),(player?.isPlaying)!{
            if let status = self.newsList[img.tag].get(AVUtil.Reading.play_status),
            status.stringValue == "1" {
                player?.pause()
                self.newsList[img.tag].set(AVUtil.Reading.play_status, value: "3")
                self.tableview.reloadData()
            }else{
                clearPlaySign()
                self.newsList[img.tag].set(AVUtil.Reading.play_status, value: "1")
                playMp3(mp3_url: mp3Url)
            }
        }else{
            if let status = self.newsList[img.tag].get(AVUtil.Reading.play_status),
                status.stringValue == "3",(player != nil) {
                player!.play()
                self.newsList[img.tag].set(AVUtil.Reading.play_status, value: "1")
                self.tableview.reloadData()
            }else{
                self.newsList[img.tag].set(AVUtil.Reading.play_status, value: "1")
                playMp3(mp3_url: mp3Url)
            }
        }
    }
    
    func playMp3(mp3_url: String) -> Void {
        print(mp3_url)
        let url_string = KTVHTTPCache.proxyURLString(withOriginalURLString: mp3_url)
        let Mp3Url = URL(string: url_string!)
        player = AVPlayer(url: Mp3Url!)
        NotificationCenter.default.addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
        player!.play()
        self.tableview.reloadData()
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        clearPlaySign()
        self.tableview.reloadData()
    }

    func clearPlaySign(){
        for object in self.newsList{
            object.set(AVUtil.Reading.play_status, value: "0")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
