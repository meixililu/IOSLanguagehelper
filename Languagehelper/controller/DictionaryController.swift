//
//  DictionaryController.swift
//  Languagehelper
//
//  Created by luli on 16/7/26.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import AVFoundation
import XLPagerTabStrip

class DictionaryController: UIViewController, IFlySpeechSynthesizerDelegate, IFlySpeechRecognizerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: NSLocalizedString("Dictionary", comment: "dictionary"))
    let realm = try! Realm()
    var translates = try! Realm().objects(DictionaryResultModel.self).sorted(byProperty: "creatTime",ascending: false )
    let headers: HTTPHeaders = [
        "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
    ]
    let baiduApi:  String = "https://fanyi-api.baidu.com/api/trans/vip/translate"
    let icibaiApi_new: String = "http://fy.iciba.com/ajax.php?a=fy"
    let youdaoWeb: String = "http://dict.youdao.com/w/"
    let youdaoWebEnd: String = "/#keyfrom=dict.index"
    let biyingWeb: String = "http://cn.bing.com/dict/search?q="
    let biyingWebEnd: String = "&go=%E6%90%9C%E7%B4%A2&qs=bs&form=Z9LH5"
    
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
        super.viewDidLoad()
        print("dic-viewDidLoad")
        img_voice.isHidden = true
        ed_input.delegate = self
        ed_input.text = NSLocalizedString("Please input Chinese or English", comment: "input prompt")
        ed_input.textColor = UIColor.lightGray
        
        img_voice.layer.masksToBounds = true //没这句话它圆不起来
        img_voice.layer.cornerRadius = 8.0 //设置图片圆角的尺度
        
        btn_speak.layer.masksToBounds = true
        btn_speak.layer.cornerRadius = 30.0
        btn_speak.layer.borderWidth = 5.0
        btn_speak.layer.borderColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.7)?.cgColor
        btn_chinese.roundedButton(corner1: .topLeft, corner2: .bottomLeft)
        btn_english.roundedButton(corner1: .topRight, corner2: .bottomRight)
        
        tableview.estimatedRowHeight = 100
        tableview.rowHeight = UITableViewAutomaticDimension
        
        isSpeakEnglish = UserDefaults.standard.bool(forKey: KeyUtile.isSelectEnglish_DicKey)
        if isSpeakEnglish {
            onSelectedEnglish(btn_english)
        } else {
            onSelectedChinese(btn_chinese)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if inNeedRefreshData {
            translates = try! realm.objects(DictionaryResultModel.self).sorted(byProperty: "creatTime",ascending: false)
            self.tableview.reloadData()
            inNeedRefreshData = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("dic-viewDidDisappear")
        self.iflySpeechRecognizer.stopListening();
        self.iflySpeechSynthesizer.stopSpeaking();
        inNeedRefreshData = true
        super.viewWillDisappear(animated)
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        btn_submit.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.8)
        ed_input.resignFirstResponder()
        question = ed_input.text
        if !question.isEmpty && question != NSLocalizedString("Please input Chinese or English", comment: "input prompt"){
            self.Translate_youdao_web()
        }else{
            self.noticeTop(NSLocalizedString("Please input Chinese or English", comment: "input prompt"), autoClear: true)
        }
    }
    
    @IBAction func onSpeakBtnClick(_ sender: AnyObject) {
        self.iflySpeechRecognizer.delegate = self
        self.iflySpeechSynthesizer.delegate = self
        ed_input.resignFirstResponder()
        if self.iflySpeechRecognizer.isListening {
            self.btn_speak.setTitle("", for: UIControlState())
            self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState())
            self.iflySpeechRecognizer.stopListening();
        } else {
            self.btn_speak.setTitle(NSLocalizedString("Finish", comment: "Finish"), for: UIControlState())
            self.btn_speak.setImage(nil, for: UIControlState())
            XFutil.recognize(iflySpeechRecognizer,isSpeakEnglish: isSpeakEnglish)
        }
        
    }
    
    @IBAction func onSelectedChinese(_ sender: AnyObject) {
        isSpeakEnglish = false
        btn_chinese.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.85)
        btn_chinese.setTitleColor(UIColor.white, for: UIControlState())
        btn_english.backgroundColor = UIColor(hexString: ColorUtil.gray, alpha: 0.85)
        btn_english.setTitleColor(UIColor(hexString: ColorUtil.darkGray6), for: UIControlState())
        FileManagerUtil.saveUserDefaults(false, key: KeyUtile.isSelectEnglish_DicKey)
    }
    
    @IBAction func onSelectedEnglish(_ sender: AnyObject) {
        isSpeakEnglish = true
        btn_chinese.backgroundColor = UIColor(hexString: ColorUtil.gray, alpha: 0.85)
        btn_chinese.setTitleColor(UIColor(hexString: ColorUtil.darkGray6), for: UIControlState())
        btn_english.backgroundColor = UIColor(hexString: ColorUtil.appBlue, alpha: 0.85)
        btn_english.setTitleColor(UIColor.white, for: UIControlState())
        FileManagerUtil.saveUserDefaults(true, key: KeyUtile.isSelectEnglish_DicKey)
    }
    
    func translateBaidu(){
        self.pleaseWait()
        let salt = NSString(format: "%f" , Date().timeIntervalSince1970) as String
        Alamofire.request(baiduApi,method: .post, parameters: ["appid": Utile.bd_appid, "salt":salt , "q":question, "from":"auto", "to":"auto",
            "sign":Utile.getBaiduTranslateSign(salt, question: question)])
            .responseJSON { response in
                self.clearAllNotice()
                if let resutl = response.result.value {
                    let json = JSON(resutl)
                    if let dst: String = json["trans_result",0,"dst"].string {
                        print("value1:\(dst)")
                        self.result = dst
                        self.ed_input.text = nil
                        self.textViewDidEndEditing(self.ed_input)
                    } else{
                        self.noticeTop(NSLocalizedString("Translate fail,please retry later!", comment: "error"), autoClear: true)
                    }
                    
                    let resultModel = DictionaryResultModel()
                    self.showResult(resultModel)
                    print(resultModel)
                }else{
                    self.noticeTop(NSLocalizedString("Translate fail,please retry later!", comment: "error"), autoClear: true)
                }
        }
    }
    
    func translateIcibai_new(){
        self.pleaseWait()
        if Utile.isChinese(question) {
            from = "zh-CN"
            to = "en-US"
        }else{
            from = "en-US"
            to = "zh-CN"
        }
        Alamofire.request(icibaiApi_new, method: .post, parameters: ["w": question,"":"","f": from,"t":to], headers: headers)
            .responseJSON { response in
                self.clearAllNotice()
                let resultModel = DictionaryResultModel()
                if let resutl = response.result.value {
                    let json = JSON(resutl)
                    let status = json["status"].int
                    if status == 0 {//dic
                        if json["content","word_mean"].array != nil {
                            ResultParser.getIcibaiNewRusult(json,resultModel: resultModel)
                            self.ed_input.text = nil
                            self.textViewDidEndEditing(self.ed_input)
                        }else{
                            self.translateBaidu()
                        }
                    } else if status == 1 {//tran
                        if let out: String = json["content","out"].string {
                            resultModel.result = out.replacingOccurrences(of: "<br/>", with: "")
                            self.ed_input.text = nil
                            self.textViewDidEndEditing(self.ed_input)
                        }else{
                            self.translateBaidu()
                        }
                    }else{
                        self.translateBaidu()
                    }
                    self.showResult(resultModel)
                }else{
                    self.translateBaidu()
                }
        }
    }
    
    func showResult(_ resultModel:DictionaryResultModel){
        resultModel.id = UUID().uuidString
        if resultModel.result.isEmpty {
            resultModel.result = self.result
        }
        resultModel.question = self.question
        resultModel.creatTime = Date()
        let name = NSString(format: "%f" , Date().timeIntervalSince1970) as String
        resultModel.resultVoiceId = "tts_r_" + (name) + ".pcm"
        resultModel.questionVoiceId = "tts_q_" + (name) + ".pcm"

        try! self.realm.write {
            self.realm.add(resultModel)
        }
        self.tableview.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableview?.scrollToRow(at: indexPath, at:UITableViewScrollPosition.top,
                                               animated: true)
        if UserDefaults.standard.bool(forKey: KeyUtile.autoPlay) {
            self.playResultData(0)
        }
    }
    
    func Translate_youdao_web(){
        self.pleaseWait()
        let tem = question.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = youdaoWeb + tem! + youdaoWebEnd
        Alamofire.request(url, headers:headers)
            .responseString { response in
                self.clearAllNotice()
                let resultModel = DictionaryResultModel()
                if (response.result.value != nil) {
                    ResultParser.parseYoudaoWeb(response.result.value!, question: self.question, resultModel: resultModel)
                    self.ed_input.text = nil
                    self.textViewDidEndEditing(self.ed_input)
                }else {
                    self.Translate_biying_web()
                }
                self.showResult(resultModel)
        }
    }
    
    func Translate_biying_web(){
        self.pleaseWait()
        let tem = question.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = biyingWeb + tem! + biyingWebEnd
        Alamofire.request(url, headers:headers)
            .responseString { response in
                self.clearAllNotice()
                let resultModel = DictionaryResultModel()
                if (response.result.value != nil) {
                    ResultParser.parseBiyingWeb(response.result.value!, question: self.question, resultModel: resultModel)
                    self.ed_input.text = nil
                    self.textViewDidEndEditing(self.ed_input)
                }else {
                    
                }
                self.showResult(resultModel)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            submit(btn_submit)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultcell", for: indexPath) as! TranslateTableViewCell
        
        cell.lb_quesstion.text = self.translates[indexPath.row].result
        cell.lb_quesstion.setLineHeight(lineHeight: 10.0)
        cell.lb_result.text = self.translates[indexPath.row].question
        cell.lb_result.setLineHeight(lineHeight: 5.0)
        if self.translates[indexPath.row].iscollected == "1" {
            cell.btn_collect.image = UIImage(named: "collect_d")
        }else {
            cell.btn_collect.image = UIImage(named: "uncollected")
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.questionClick(sender:)))
        cell.lb_result.tag = indexPath.row
        cell.lb_result.isUserInteractionEnabled = true
        cell.lb_result.addGestureRecognizer(tap)
        let qtap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.resultClick(sender:)))
        cell.lb_quesstion.tag = indexPath.row
        cell.lb_quesstion.isUserInteractionEnabled = true
        cell.lb_quesstion.addGestureRecognizer(qtap)
        
        let tap_share:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.share_btn_click(sender:)))
        cell.btn_share.tag = indexPath.row
        cell.btn_share.isUserInteractionEnabled = true
        cell.btn_share.addGestureRecognizer(tap_share)
        
        let tap_copy:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.copy_btn_click(sender:)))
        cell.btn_copy.tag = indexPath.row
        cell.btn_copy.isUserInteractionEnabled = true
        cell.btn_copy.addGestureRecognizer(tap_copy)
        
        let tap_collect:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.collect_btn_click(sender:)))
        cell.btn_collect.tag = indexPath.row
        cell.btn_collect.isUserInteractionEnabled = true
        cell.btn_collect.addGestureRecognizer(tap_collect)
        
        let tap_delete:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.delete_btn_click(sender:)))
        cell.btn_delete.tag = indexPath.row
        cell.btn_delete.isUserInteractionEnabled = true
        cell.btn_delete.addGestureRecognizer(tap_delete)
        
        return cell
    }
    
    func resultClick(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        self.playResultData(label.tag)
    }
    
    func playResultData(_ index : Int){
        if (currentPlayIndex-1000) ==  index {
            self.stopPlayer()
            self.resetData()
        }else {
            currentPlayIndex = index + 1000
            let filePath: String = FileManagerUtil.getCachesPath() + "/" + self.translates[index].resultVoiceId
            if Foundation.FileManager.default.fileExists(atPath: filePath) {
                let pcmData: NSMutableData = pcmPlayer.writeWaveHead(try? Data(contentsOf: URL(fileURLWithPath: filePath)), sampleRate: 16000)
                self.playMp3WithData(pcmData)
            }else {
                self.pleaseWait()
                let resultforplay:String = self.translates[index].resultForPlay
                playType = 2
                if !resultforplay.isEmpty {
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[index].resultVoiceId, content: resultforplay, sp: "vimary")
                }else{
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[index].resultVoiceId, content: self.translates[index].result)
                }
            }
        }
    }
    
    func questionClick(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        if (currentPlayIndex-1001) ==  label.tag {
            self.stopPlayer()
            self.resetData()
        }else {
            currentPlayIndex = label.tag + 1001
            if !self.translates[label.tag].ph_tts_mp3.isEmpty {
                let mp3_name = (self.translates[label.tag].ph_tts_mp3 as NSString).lastPathComponent
                if !mp3_name.isEmpty {
                    let filePath: String = FileManagerUtil.getCachesPath() + "/" + mp3_name
                    if Foundation.FileManager.default.fileExists(atPath: filePath) {
                        self.playMp3(filePath)
                    }else {
                        self.pleaseWait()
                        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
                        Alamofire.download(self.translates[label.tag].ph_tts_mp3, to: destination).response{ response in
                            self.clearAllNotice()
                            if let error = response.error {
                                NSLog(error.localizedDescription)
                            } else {
                                self.playMp3(filePath)
                            }
                        }
                    }
                }
            }else{
                let filePath: String = FileManagerUtil.getCachesPath() + "/" + self.translates[label.tag].questionVoiceId
                if Foundation.FileManager.default.fileExists(atPath: filePath) {
                    let pcmData: NSMutableData = pcmPlayer.writeWaveHead(try? Data(contentsOf: URL(fileURLWithPath: filePath)), sampleRate: 16000)
                    self.playMp3WithData(pcmData)
                }else {
                    self.pleaseWait()
                    self.playType = 2
                    XFutil.playSynthesizer(iflySpeechSynthesizer, fileName: self.translates[label.tag].questionVoiceId, content: self.translates[label.tag].question)
                }
            }
        }
        
    }
    
    func playMp3(_ filePath: String){
        self.playType = 1
        let mp3NSURL = URL(fileURLWithPath: filePath)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: mp3NSURL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
//            print(error)
        }
    }
    
    func playMp3WithData(_ pcmData: NSMutableData){
        self.playType = 1
        do {
            try audioPlayer = AVAudioPlayer(data: pcmData as Data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
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
        let textToShare = self.translates[img.tag].question + "\n" + self.translates[img.tag].result
        
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIImageView
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func copy_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        UIPasteboard.general.string = self.translates[img.tag].question + "\n" + self.translates[img.tag].result
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
        print(self.translates[img.tag])
        self.tableview.reloadData()
    }
    
    func delete_btn_click(sender:UITapGestureRecognizer){
        let img = sender.view as! UIImageView
        try! realm.write {
            realm.delete(self.translates[img.tag])
        }
        tableview.reloadData()
    }
    
    //MARK: - IFlySpeechRecognizerDelegate
    /**
     * @fn      onVolumeChanged
     * @brief   音量变化回调
     *
     * @param   volume      -[in] 录音的音量，音量范围1~30
     * @see
     */
    func onVolumeChanged(_ volume: Int32) {
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
        self.btn_speak.setTitle("", for: UIControlState())
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState())
        img_voice.isHidden = true
    }
    
    /**
     * @fn      onError
     * @brief   识别结束回调
     * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
     */
    func onIFlyError(_ error:IFlySpeechError){
        self.btn_speak.setTitle("", for: UIControlState())
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState())
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
        if(results != nil && results.count>0){
            let dic: NSDictionary = results[0] as! NSDictionary;
            for (key,_) in dic {
                temp = ISRDataHelper.string(fromJson: key as! String)
            }
            ed_input.text = ed_input.text! + temp
        }
        if isLast {
            temp = ed_input.text.lowercased()
            let last_str = temp.characters.last
            if last_str=="。" || last_str=="？" || last_str=="！" || last_str=="." || last_str=="?" || last_str=="!" {
                temp = String(temp.characters.dropLast())
            }
            ed_input.text = temp
            self.result = temp
            submit(btn_submit)
        }
    }
    
    /**
     * @fn      onCancal
     * @brief   取消识别回调
     *
     * @see
     */
    
    func onCancel(){
        self.btn_speak.setTitle("", for: UIControlState())
        self.btn_speak.setImage(UIImage(named: "ic_voice_padded_normal"), for: UIControlState())
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
    func onBufferProgress(_ progress:Int, msg message:String){
    }
    
    /** 播放进度回调
     
     @param progress 播放进度，0-100
     */
    func onSpeakProgress(_ progress:Int32){
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
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playType = 0
        self.resetData()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.playType = 0
        self.resetData()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}
