//
//  AppDelegate.swift
//  Languagehelper
//
//  Created by luli on 16/6/17.
//  Copyright © 2016年 luli. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import LeanCloud
import KTVHTTPCache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        LeanCloud.initialize(applicationID: "3fg5ql3r45i3apx2is4j9on5q5rf6kapxce51t5bc0ffw2y4", applicationKey: "twhlgs6nvdt7z7sfaw76ujbmaw7l12gb8v6sdyjw1nzk9b1a")
        IFlySetting.setLogFile(LOG_LEVEL.LVL_ALL);
        IFlySetting.showLogcat(true);
        
        var error: NSError?
        KTVHTTPCache.proxyStart(&error)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
        registerDefaultsValue()
        return true
    }
    
    func registerDefaultsValue(){
        UserDefaults.standard.register(defaults: [KeyUtile.autoClear : true])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        if NSUserDefaults.standardUserDefaults().boolForKey(KeyUtile.autoClear) {
//            let realm = try! Realm()
//            let translates = realm.objects(TranslateResultModel.self).filter("iscollected=''")
//            let dics = realm.objects(DictionaryResultModel.self).filter("iscollected=''")
//            try! realm.write {
//                realm.delete(translates)
//                realm.delete(dics)
//            }
//        }
        
    }

}

