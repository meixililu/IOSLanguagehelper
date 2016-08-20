//
//  XFUtil.swift
//  Languagehelper
//
//  Created by luli on 16/7/7.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation

class XFutil{
    
    // xiaoqi chinese; vimary english
    static var speaker:   String = "xiaoqi"
    
    class func playSynthesizer(iflySpeechSynthesizer: IFlySpeechSynthesizer, fileName: String, content: String){
        selectSpeaker(content)
        iflySpeechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.SPEED());//合成的语速,取值范围 0~100
        iflySpeechSynthesizer.setParameter("100", forKey: IFlySpeechConstant.VOLUME());//合成的音量          
        iflySpeechSynthesizer.setParameter(speaker, forKey: IFlySpeechConstant.VOICE_NAME());//发音人,默认为”xiaoyan”;可以设置的参数列表可参考个性化发音人列表;
        iflySpeechSynthesizer.setParameter("16000", forKey: IFlySpeechConstant.SAMPLE_RATE());//音频采样率,目前支持的采样率有 16000 和 8000;
        if !fileName.isEmpty {
            iflySpeechSynthesizer.setParameter(fileName, forKey: IFlySpeechConstant.TTS_AUDIO_PATH());//保存音频时，请在必要的地方加上这行。
        }else{
            iflySpeechSynthesizer.setParameter(nil, forKey: IFlySpeechConstant.TTS_AUDIO_PATH());//当你再不需要保存音频时，请在必要的地方加上这行。
        }
        print("speaker:\(speaker)")
        print("content:\(content)")
        iflySpeechSynthesizer.startSpeaking(content);
    }
    
    class func playSynthesizer(iflySpeechSynthesizer: IFlySpeechSynthesizer, fileName: String, content: String,
                               sp: String){
        iflySpeechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.SPEED());//合成的语速,取值范围 0~100
        iflySpeechSynthesizer.setParameter("100", forKey: IFlySpeechConstant.VOLUME());//合成的音量
        iflySpeechSynthesizer.setParameter(sp, forKey: IFlySpeechConstant.VOICE_NAME());//发音人,默认为”xiaoyan”;可以设置的参数列表可参考个性化发音人列表;
        iflySpeechSynthesizer.setParameter("16000", forKey: IFlySpeechConstant.SAMPLE_RATE());//音频采样率,目前支持的采样率有 16000 和 8000;
        if !fileName.isEmpty {
            iflySpeechSynthesizer.setParameter(fileName, forKey: IFlySpeechConstant.TTS_AUDIO_PATH());//保存音频时，请在必要的地方加上这行。
        }else{
            iflySpeechSynthesizer.setParameter(nil, forKey: IFlySpeechConstant.TTS_AUDIO_PATH());//当你再不需要保存音频时，请在必要的地方加上这行。
        }
        print("speaker:\(speaker)")
        print("content:\(content)")
        iflySpeechSynthesizer.startSpeaking(content);
    }
    
    
    class func recognize(iflySpeechRecognizer: IFlySpeechRecognizer, isSpeakEnglish: Bool){
        if isSpeakEnglish {
            iflySpeechRecognizer.setParameter("en_us", forKey: IFlySpeechConstant.LANGUAGE())//zh_cn  ACCENT:mandarin
        }else{
            iflySpeechRecognizer.setParameter("zh_cn", forKey: IFlySpeechConstant.LANGUAGE())//zh_cn
            iflySpeechRecognizer.setParameter("mandarin", forKey: IFlySpeechConstant.ACCENT())//mandarin
        }
        iflySpeechRecognizer.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
        iflySpeechRecognizer.setParameter("16000", forKey: IFlySpeechConstant.SAMPLE_RATE())
        iflySpeechRecognizer.setParameter("asr.pcm", forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
        iflySpeechRecognizer.setParameter("json", forKey: IFlySpeechConstant.RESULT_TYPE())
        iflySpeechRecognizer.startListening();
    }
    
    class func selectSpeaker(content: String){
        if Utile.isChinese(content) {
            speaker = "xiaoqi"
        }else{
            speaker = "vimary"
        }
    }
    
    
}

