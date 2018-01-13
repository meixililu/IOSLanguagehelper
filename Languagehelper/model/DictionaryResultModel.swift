//
//  TranslateResultModel.swift
//  Languagehelper
//
//  Created by luli on 16/7/6.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation
import RealmSwift

class DictionaryResultModel: Object {
    
    dynamic var id = ""
    dynamic var question = ""
    dynamic var result = ""
    dynamic var resultForPlay = ""
    dynamic var ph_tts_mp3 = ""
    dynamic var ph_am_mp3 = ""
    dynamic var ph_en_mp3 = ""
    dynamic var to = ""
    dynamic var from = ""
    dynamic var ph_am = ""
    dynamic var ph_en = ""
    dynamic var ph_zh = ""
    dynamic var type = ""
    dynamic var questionVoiceId = ""
    dynamic var questionAudioPath = ""
    dynamic var resultVoiceId = ""
    dynamic var resultAudioPath = ""
    dynamic var iscollected = ""
    dynamic var speak_speed = ""
    dynamic var creatTime = Date()
    dynamic var backup1 = ""
    dynamic var backup2 = ""
    dynamic var backup3 = ""
    dynamic var backup4 = ""
    dynamic var backup5 = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    // Specify properties to ignore (Realm won't persist these)
//  override static func ignoredProperties() -> [String] {
//        return ["isPlaying"]
//  }
}
