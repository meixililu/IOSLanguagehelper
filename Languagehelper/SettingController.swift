//
//  SettingController.swift
//  Languagehelper
//
//  Created by luli on 16/8/16.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit
import RealmSwift

class SettingController: UIViewController {

    let realm = try! Realm()
    @IBOutlet var sw_auto_play: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let autoPlay = NSUserDefaults.standardUserDefaults().boolForKey(KeyUtile.autoPlay)
        sw_auto_play.setOn(autoPlay, animated: true)
        
    }
    @IBAction func onAutoPlaySwitchChange(sender: AnyObject) {
        FileManager.saveUserDefaults(sender.on, key: KeyUtile.autoPlay)
    }

    @IBAction func onAutoClearSwitchChange(sender: AnyObject) {
        FileManager.saveUserDefaults(sender.on, key: KeyUtile.autoClear)
    }
    
    @IBAction func clear_all_record(sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("kindly reminder", comment: "kindly reminder"),message: NSLocalizedString("Are you sure to delete", comment: "delete prompt"), preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Default,handler: {action in
            
            let translates = self.realm.objects(TranslateResultModel.self)
            let dics = self.realm.objects(DictionaryResultModel.self)
            try! self.realm.write {
                self.realm.delete(translates)
                self.realm.delete(dics)
            }
            
            self.noticeTop(NSLocalizedString("delete success!", comment: "success"), autoClear: true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clear_uncollected_record(sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("kindly reminder", comment: "kindly reminder"),message: NSLocalizedString("Are you sure to delete", comment: "delete prompt"), preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Default,handler: {action in
            let translates = self.realm.objects(TranslateResultModel.self).filter("iscollected=''")
            let dics = self.realm.objects(DictionaryResultModel.self).filter("iscollected=''")
            try! self.realm.write {
                self.realm.delete(translates)
                self.realm.delete(dics)
            }
            self.noticeTop(NSLocalizedString("delete success!", comment: "success"), autoClear: true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
