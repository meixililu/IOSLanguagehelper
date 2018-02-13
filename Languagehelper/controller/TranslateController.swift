//
//  TranslateController.swift
//  Languagehelper
//
//  Created by luli on 16/7/2.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kanna
import RealmSwift
import AVFoundation
import XLPagerTabStrip


class TranslateController: UIViewController, IFlySpeechSynthesizerDelegate, IFlySpeechRecognizerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: NSLocalizedString("Translate", comment: "translate"))
    let realm = try! Realm()
    var translates = try! Realm().objects(TranslateResultModel.self).sorted(byKeyPath: "creatTime",ascending: false)
    let headers: HTTPHeaders = [
        "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
    ]
    let baiduApi:  String = "https://fanyi-api.baidu.com/api/trans/vip/translate"
    let icibaiApi_new: String = "http://fy.iciba.com/ajax.php?a=fy"
    let HjTranslateApi: String = "https://dict.hjenglish.com/services/Translate.ashx"
    var question:  String = ""
    var result:    String = ""
    var from:    String = "auto"
    var to:    String = "auto"
    var isSpeakEnglish:  Bool = false
    var currentPlayIndex: Int = 0
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    let pcmPlayer: PcmPlayer = PcmPlayer()
    var playType: Int = 0 //0 default 1 AVAudioPlayer 2 iflySpeechSynthesizer
    var inNeedRefreshData: Bool = false

    // 创建合成对象
    var iflySpeechSynthesizer: IFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance() as IFlySpeechSynthesizer
    var iflySpeechRecognizer: IFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance() as IFlySpeechRecognizer

    @IBOutlet var btn_chinese: UIButton!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var btn_english: UIButton!
    @IBOutlet var img_voice: UIImageView!
    @IBOutlet var btn_submit: UIButton!
    @IBOutlet var ed_input: UITextView!
    @IBOutlet var btn_speak: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.iflySpeechRecognizer.delegate = self
        self.iflySpeechSynthesizer.delegate = self
    }
    
    override func viewDidLoad() {
        print("TranslateController---viewDidLoad")
        super.viewDidLoad()
        self.img_voice.isHidden = true
        self.ed_input.delegate = self
        self.ed_input.text = NSLocalizedString("Please input Chinese or English", comment: "input prompt")
        self.ed_input.textColor = UIColor.lightGray

        self.img_voice.layer.masksToBounds = true //没这句话它圆不起来
        self.img_voice.layer.cornerRadius = 8.0 //设置图片圆角的尺度

        self.btn_speak.layer.masksToBounds = true
        self.btn_speak.layer.cornerRadius = 30.0
        self.btn_speak.layer.borderWidth = 5.0
        self.btn_speak.layer.borderColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.7)?.cgColor

        self.btn_chinese.roundedButton(corner1: .topLeft, corner2: .bottomLeft)
        self.btn_english.roundedButton(corner1: .topRight, corner2: .bottomRight)
        
        self.tableview.estimatedRowHeight = 100
        self.tableview.rowHeight = UITableViewAutomaticDimension

        isSpeakEnglish = UserDefaults.standard.bool(forKey: KeyUtile.isSelectEnglish_TranKey)
        if isSpeakEnglish {
            onSelectedEnglish(sender: btn_english)
        } else {
            onSelectedChinese(sender: btn_chinese)
        }
        initData()
    }
    
    func initData(){
        if !UserDefaults.standard.bool(forKey: KeyUtile.initTranslateData) {
            let resultModel = TranslateResultModel()
            resultModel.id = NSUUID().uuidString
            resultModel.result = "Click the mic to speak"
            resultModel.question = "点击话筒说话"
            resultModel.creatTime = NSDate() as Date
            let name = NSString(format: "%f" , NSDate().timeIntervalSince1970) as String
            resultModel.resultVoiceId = "tts_r_" + (name) + ".pcm"
            resultModel.questionVoiceId = "tts_q_" + (name) + ".pcm"
            try! self.realm.write {
                self.realm.add(resultModel)
            }
            let resultModel1 = TranslateResultModel()
            resultModel1.id = NSUUID().uuidString
            resultModel1.result = "Click here to listen"
            resultModel1.question = "猛戳这里听语音"
            resultModel1.creatTime = NSDate() as Date
            let name1 = NSString(format: "%f" , NSDate().timeIntervalSince1970) as String
            resultModel1.resultVoiceId = "tts_r_" + (name1) + ".pcm"
            resultModel1.questionVoiceId = "tts_q_" + (name1) + ".pcm"
            try! self.realm.write {
                self.realm.add(resultModel1)
            }

            self.tableview.reloadData()
            FileManagerUtil.saveUserDefaults(true, key: KeyUtile.initTranslateData)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("tran-viewDidAppear")
        FileManagerUtil.saveUserDefaults(0, key: KeyUtile.userLastPageIndex)
        if inNeedRefreshData {
            translates = try! Realm().objects(TranslateResultModel.self).sorted(byProperty: "creatTime",ascending: false)
            self.tableview.reloadData()
            inNeedRefreshData = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("tran-viewDidDisappear")
        self.iflySpeechRecognizer.stopListening()
        self.iflySpeechSynthesizer.stopSpeaking()
        inNeedRefreshData = true
        super.viewWillDisappear(animated)
    }
    
    @IBAction func submit(sender: AnyObject) {
        btn_submit.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.8)
        ed_input.resignFirstResponder()
        question = ed_input.text
        if !question.isEmpty && question != NSLocalizedString("Please input Chinese or English", comment: "input prompt"){
            self.translateIcibai_new()
        }else{
            self.noticeTop(NSLocalizedString("Please input Chinese or English", comment: "input prompt"), autoClear: true)
        }
    }
    
    @IBAction func onSpeakBtnClick(sender: AnyObject) {
        self.iflySpeechRecognizer.delegate = self
        self.iflySpeechSynthesizer.delegate = self
        ed_input.resignFirstResponder()
        if self.iflySpeechRecognizer.isListening {
            self.btn_speak.setTitle("", for: UIControlState.normal)
            self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState.normal)
            self.iflySpeechRecognizer.stopListening();
        } else {
            self.btn_speak.setTitle(NSLocalizedString("Finish", comment: "Finish"), for: UIControlState.normal)
            self.btn_speak.setImage(nil, for: UIControlState.normal)
            XFutil.recognize(iflySpeechRecognizer,isSpeakEnglish: isSpeakEnglish)
        }
    }
    
    @IBAction func onSelectedChinese(sender: AnyObject) {
        isSpeakEnglish = false
        btn_chinese.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.85)
        btn_chinese.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn_english.backgroundColor = UIColor(hexString: ColorUtil.gray, alpha: 0.85)
        btn_english.setTitleColor(UIColor(hexString: ColorUtil.darkGray6), for: UIControlState.normal)
        FileManagerUtil.saveUserDefaults(false, key: KeyUtile.isSelectEnglish_TranKey)
    }
    
    @IBAction func onSelectedEnglish(sender: AnyObject) {
        isSpeakEnglish = true
        btn_chinese.backgroundColor = UIColor(hexString: ColorUtil.gray, alpha: 0.85)
        btn_chinese.setTitleColor(UIColor(hexString: ColorUtil.darkGray6), for: UIControlState.normal)
        btn_english.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.85)
        btn_english.setTitleColor(UIColor.white, for: UIControlState.normal)
        FileManagerUtil.saveUserDefaults(true,  key: KeyUtile.isSelectEnglish_TranKey)
    }
    
    func translateBaidu(){
        NSLog("translateBaidu")
        self.pleaseWait()
        let salt = NSString(format: "%f" , NSDate().timeIntervalSince1970) as String
        Alamofire.request(baiduApi, method: .post,  parameters: ["appid": Utile.bd_appid, "salt":salt , "q":question, "from":"auto", "to":"auto",
                                                                 "sign":Utile.getBaiduTranslateSign(salt, question: question)])
            .responseJSON { response in
                self.clearAllNotice()
                if let resutl = response.result.value {
                    let json = JSON(resutl)
                    if let dst: String = json["trans_result",0,"dst"].string {
                        self.result = dst
                        self.ed_input.text = nil
                        self.textViewDidEndEditing(self.ed_input)
                    } else{
                        self.noticeTop(NSLocalizedString("Translate fail,please retry later!", comment: "error"), autoClear: true)
                    }
                    let resultModel = TranslateResultModel()
                    self.setData(resultModel: resultModel)
                }else{
                    self.noticeTop(NSLocalizedString("Translate fail,please retry later!", comment: "error"), autoClear: true)
                }
        }
    }
    
    func translateHjApi(){
        self.pleaseWait()
        if Utile.isChinese(question) {
            from = "zh-CN"
            to = "en"
        }else{
            from = "en"
            to = "zh-CN"
        }
        Alamofire.request(HjTranslateApi, method:.post, parameters: ["text": question,"from": from, "to": to], headers: headers)
            .responseJSON { response in
                self.clearAllNotice()
                if let resutl = response.result.value {
                    let json = JSON(resutl)
                    if json["status"].int == 0{
                        if let temp = json["content"].string{
                            self.result = temp
                            self.ed_input.text = nil
                            self.textViewDidEndEditing(self.ed_input)
                            let resultModel = TranslateResultModel()
                            self.setData(resultModel: resultModel)
                        }else{
                            self.translateBaidu()
                        }
                    } else{
                        self.translateBaidu()
                    }
                }else{
                    self.translateBaidu()
                }
        }
    }
    
    func translateIcibai_new(){
        self.pleaseWait()
        if Utile.isChinese(question) {
            from = "zh"
            to = "en"
        }else{
            from = "en"
            to = "zh"
        }
        Alamofire.request(icibaiApi_new, method:.post, parameters: ["w": question,"":"","f": from,"t":to],headers:headers)
            .responseJSON { response in
                self.clearAllNotice()
                let resultModel = TranslateResultModel()
                if let resutl = response.result.value {
                    let json = JSON(resutl)
                    let status = json["status"].int
                    if status == 0 {//dic
                        if json["content","word_mean"].array != nil {
                            self.getIcibaiNewRusult(json: json,resultModel: resultModel)
                            self.ed_input.text = nil
                            self.textViewDidEndEditing(self.ed_input)
                        }else{
                            self.translateHjApi()
                        }
                    } else if status == 1 {//tran
                        if let out: String = json["content","out"].string {
                            resultModel.result = out.replacingOccurrences(of:"<br/>", with: "")
                            self.ed_input.text = nil
                            self.textViewDidEndEditing(self.ed_input)
                        }else{
                            self.translateHjApi()
                        }
                    }else{
                       self.translateHjApi()
                    }
                    self.setData(resultModel: resultModel)
                }else{
                  self.translateHjApi()
                }
        }
    }
    
    func setData(resultModel: TranslateResultModel){
        resultModel.id = NSUUID().uuidString
        resultModel.question = self.question
        if resultModel.result.isEmpty {
            resultModel.result = self.result
        }
        resultModel.creatTime = NSDate() as Date
        let name = NSString(format: "%f" , NSDate().timeIntervalSince1970) as String
        resultModel.resultVoiceId = "tts_r_" + (name) + ".pcm"
        resultModel.questionVoiceId = "tts_q_" + (name) + ".pcm"
        try! self.realm.write {
            self.realm.add(resultModel)
        }
        self.tableview.reloadData()
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableview?.scrollToRow(at: indexPath as IndexPath, at:UITableViewScrollPosition.top,
                                               animated: true)
        
        if UserDefaults.standard.bool(forKey: KeyUtile.autoPlay) {
            self.playResultData(index: 0)
        }
    }
    
    func getIcibaiNewRusult(json: JSON, resultModel: TranslateResultModel){
        var sb:    String = ""
        var sbp:   String = ""
        let ph_en: String = json["content","ph_en"].string!
        if !ph_en.isEmpty {
            sb += "英[" + ph_en + "]    "
        }
        let ph_am = json["content","ph_am"].string!
        if !ph_am.isEmpty {
            sb += "美[" + ph_am + "]  "
        }
        if let word_mean = json["content","word_mean"].array {
            for (index,item) in word_mean.enumerated() {
                if index == 0 && !sb.isEmpty{
                    sb += "\n"
                }else if index > 0 {
                    sb += "\n"
                }
                sbp += item.string!
                sb += item.string!
            }
        }
        if let ph_am_mp3 = json["content","ph_am_mp3"].string {
            resultModel.ph_am_mp3 = ph_am_mp3
        }
        if let ph_en_mp3 = json["content","ph_en_mp3"].string {
            resultModel.ph_en_mp3 = ph_en_mp3
        }
        if let ph_tts_mp3 = json["content","ph_tts_mp3"].string {
            resultModel.ph_tts_mp3 = ph_tts_mp3
        }
        resultModel.result = sb
        resultModel.resultForPlay = sbp
    }
    
    func getIcibaiRusult(html: String) -> String {
        var sb = ""
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            for link in doc.css("span.dd") {
                let tem = link.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                if !tem.isEmpty {
                    sb += tem
                }
            }
        }
        return sb
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            submit(sender: btn_submit)
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("Please input Chinese or English", comment: "input prompt")
            textView.textColor = UIColor.lightGray
        }
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.translates.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultcell", for: indexPath as IndexPath) as! TranslateTableViewCell
        
        cell.lb_quesstion.text = self.translates[indexPath.row].result
        cell.lb_quesstion.setLineHeight(lineHeight: 5.0)
        cell.lb_result.text = self.translates[indexPath.row].question
        cell.lb_result.setLineHeight(lineHeight: 7.0)
        if self.translates[indexPath.row].iscollected == "1" {
            cell.btn_collect.image = UIImage(named: "collect_d")
        }else {
            cell.btn_collect.image = UIImage(named: "uncollected")
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.questionClick(sender:)))
        cell.lb_result.tag = indexPath.row
        cell.lb_result.isUserInteractionEnabled = true
        cell.lb_result.addGestureRecognizer(tap)
        let qtap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslateController.resultClick(sender:)))
        cell.lb_quesstion.tag = indexPath.row
        cell.lb_quesstion.isUserInteractionEnabled = true
        cell.lb_quesstion.addGestureRecognizer(qtap)
        
        let tap_share:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslateController.share_btn_click(sender:)))
        cell.btn_share.tag = indexPath.row
        cell.btn_share.isUserInteractionEnabled = true
        cell.btn_share.addGestureRecognizer(tap_share)
        
        let tap_copy:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslateController.copy_btn_click(sender:)))
        cell.btn_copy.tag = indexPath.row
        cell.btn_copy.isUserInteractionEnabled = true
        cell.btn_copy.addGestureRecognizer(tap_copy)
        
        let tap_collect:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslateController.collect_btn_click(sender:)))
        cell.btn_collect.tag = indexPath.row
        cell.btn_collect.isUserInteractionEnabled = true
        cell.btn_collect.addGestureRecognizer(tap_collect)
        
        let tap_delete:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslateController.delete_btn_click(sender:)))
        cell.btn_delete.tag = indexPath.row
        cell.btn_delete.isUserInteractionEnabled = true
        cell.btn_delete.addGestureRecognizer(tap_delete)
        
        return cell
    }
    
    func resultClick(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        playResultData(index: label.tag)
    }
    
    func playResultData(index : Int){
        self.iflySpeechRecognizer.delegate = self
        self.iflySpeechSynthesizer.delegate = self
        if (currentPlayIndex-1000) == index{
            self.stopPlayer()
            resetData()
        }else {
            currentPlayIndex = index + 1000
            let filePath: String = FileManagerUtil.getCachesPath() + "/" + self.translates[index].resultVoiceId
            if FileManager.default.fileExists(atPath: filePath) {
                let pcmData: NSMutableData = pcmPlayer.writeWaveHead(NSData(contentsOfFile:filePath) as Data!, sampleRate: 16000)
                self.playMp3WithData(pcmData: pcmData)
            }else {
                self.pleaseWait()
                playType = 2
                let resultforplay:String = self.translates[index].resultForPlay
                if !resultforplay.isEmpty {
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[index].resultVoiceId, content: resultforplay)
                }else{
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[index].resultVoiceId, content: self.translates[index].result)
                }
            }
        }
    }
    
    
    func questionClick(sender:UITapGestureRecognizer){
        self.iflySpeechRecognizer.delegate = self
        self.iflySpeechSynthesizer.delegate = self
        let label = sender.view as! UILabel
        if (currentPlayIndex-1001) ==  label.tag {
            self.stopPlayer()
            resetData()
        }else {
            currentPlayIndex = label.tag + 1001
            if !self.translates[label.tag].ph_tts_mp3.isEmpty {
                let mp3_name = (self.translates[label.tag].ph_tts_mp3 as NSString).lastPathComponent
                if !mp3_name.isEmpty {
                    let filePath: String = FileManagerUtil.getCachesPath() + "/" + mp3_name
                    if FileManager.default.fileExists(atPath: filePath) {
                        self.playMp3(filePath: filePath)
                    }else {
                        self.pleaseWait()
                        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
                        Alamofire.download(self.translates[label.tag].ph_tts_mp3,
                                           to: destination).response{ response in
                            self.clearAllNotice()
                            if let error = response.error {
                                NSLog("Failed with error: \(error)")
                            } else {
                                self.playMp3(filePath: filePath)
                            }
                        }
                    }
                }
            }else{
                let filePath: String = FileManagerUtil.getCachesPath() + "/" + self.translates[label.tag].questionVoiceId
                if FileManager.default.fileExists(atPath: filePath) {
                    let pcmData: NSMutableData = pcmPlayer.writeWaveHead(NSData(contentsOfFile:filePath) as Data!, sampleRate: 16000)
                    self.playMp3WithData(pcmData: pcmData)
                }else {
                    self.pleaseWait()
                    playType = 2
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[label.tag].questionVoiceId, content: self.translates[label.tag].question)
                }
            }
        }
        
    }
    
    func playMp3(filePath: String){
        self.playType = 1
        let mp3NSURL = NSURL(fileURLWithPath: filePath)
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOf: mp3NSURL as URL)
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch {
//            print(error)
        }
    }
    
    func playMp3WithData(pcmData: NSMutableData){
        self.playType = 1
        do {
            try self.audioPlayer = AVAudioPlayer(data: pcmData as Data)
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch {
//            print(error)
        }
    
    }
    
    func stopPlayer(){
        if playType == 2 {
            if iflySpeechSynthesizer.isSpeaking {
                iflySpeechSynthesizer.stopSpeaking()
            }
        }
        if playType == 1 {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        resetData()
    }
    
    func resetData(){
        currentPlayIndex = 0
    }
    
    func share_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        let textToShare = self.translates[img.tag].result
    
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIImageView
        self.present(activityVC, animated: true, completion: nil)

    }
    
    func copy_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        UIPasteboard.general.string = self.translates[img.tag].result
        self.noticeTop(NSLocalizedString("copy success", comment: "copy"), autoClear: true)
    }
    
    func collect_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        if self.translates[img.tag].iscollected == "1" {
            try! realm.write {
                self.translates[img.tag].iscollected = ""
            }
        }else {
            try! realm.write {
                self.translates[img.tag].iscollected = "1"
            }
        }
        self.tableview.reloadData()
    }
    
    func delete_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        try! realm.write {
            realm.delete(self.translates[img.tag])
        }
        self.tableview.reloadData()
    }

    //MARK: - IFlySpeechRecognizerDelegate
    /**
     * @fn      onVolumeChanged
     * @brief   音量变化回调
     *
     * @param   volume      -[in] 录音的音量，音量范围1~30
     * @see
     */
    func onVolumeChanged(volume: Int32) {
        if volume < 4 {
            img_voice.image = UIImage(named: "speak_voice_1")
        }else if volume < 8 {
            img_voice.image = UIImage(named: "speak_voice_2")
        }else if volume < 12 {
            img_voice.image = UIImage(named: "speak_voice_3")
        }else if volume < 16 {
            img_voice.image = UIImage(named: "speak_voice_4")
        }else if volume < 20 {
            img_voice.image = UIImage(named: "speak_voice_5")
        }else if volume < 25 {
            img_voice.image = UIImage(named: "speak_voice_6")
        }else {
            img_voice.image = UIImage(named: "speak_voice_7")
        }
    }
    
    /**
     * @fn      onBeginOfSpeech
     * @brief   开始识别回调
     * @see
     */
    func onBeginOfSpeech(){
        img_voice.isHidden = false
        self.ed_input.text = nil
        self.result = ""
    }
    
    /**
     * @fn      onEndOfSpeech
     * @brief   停止录音回调
     * @see
     */
    func onEndOfSpeech(){
        self.btn_speak.setTitle("", for: UIControlState.normal)
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState.normal)
        img_voice.isHidden = true
    }
    
    
    func onIFlyError(_ errorCode: IFlySpeechError!) {
        self.btn_speak.setTitle("", for: UIControlState.normal)
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState.normal)
        img_voice.isHidden = true
    }
    
    /**
     * @fn      onResults
     * @brief   识别结果回调
     * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
     * @see
     */
    func onResults(_ results: [Any]!, isLast: Bool) {
        var temp:String = ""
                ed_input.textColor = UIColor.black
                if(results.count>0){
                    let dic: NSDictionary = results[0] as! NSDictionary;
                    for (key,_) in dic {
                        temp = ISRDataHelper.string(fromJson: key as! String)
                    }
                    ed_input.text = ed_input.text! + temp
                }
                if isLast {
                    temp = ed_input.text.lowercased()
                    let last_str = temp.characters.last
                    if last_str=="。" || last_str=="！" || last_str=="." || last_str=="!" {
                        temp = String(temp.characters.dropLast())
                    }
                    ed_input.text = temp
                    self.result = temp
                    submit(sender: btn_submit)
                }
    }
    
    
    /**
     * @fn      onCancal
     * @brief   取消识别回调
     *
     * @see
     */
    
    func onCancel(){
        self.btn_speak.setTitle("", for: UIControlState.normal)
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState.normal)
    }
    
    //MARK: - iflySpeechSynthesizerDelegate
    
    /** 结束回调
     当整个合成结束之后会回调此函数
     @param error 错误码
     */
    func onCompleted(_ error:IFlySpeechError){
        self.playType = 0
        self.resetData()
    }
    
    /** 开始合成回调 */
    func onSpeakBegin(){
        self.clearAllNotice()
    }
    
    /** 缓冲进度回调
     @param progress 缓冲进度，0-100
     @param msg 附件信息，此版本为nil
     */
    func onBufferProgress(progress:Int, msg message:String){
    }
    
    /** 播放进度回调
     
     @param progress 播放进度，0-100
     */
    func onSpeakProgress(progress:Int32){
    }
    
    /** 暂停播放回调 */
    func onSpeakPaused(){
    }
    
    /** 恢复播放回调 */
    func onSpeakResumed(){
    }
    
    /** 正在取消回调
     
     当调用`cancel`之后会回调此函数
     */
    func onSpeakCancel(){
        self.playType = 0
        self.clearAllNotice()
        self.resetData()
    }
    
    //AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.playType = 0
        self.resetData()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        self.playType = 0
        self.resetData()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }}

extension UIButton{
    func roundedButton(corner1:UIRectCorner, corner2:UIRectCorner){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [corner1 , corner2],
                                     cornerRadii:CGSize(width:20, height:20))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
        
    }
}

extension UILabel {
    
    func setLineHeight(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributeString.length))
            self.attributedText = attributeString
        }
    }
}
