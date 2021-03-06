//
//  Utile.swift
//  Languagehelper
//
//  Created by luli on 16/7/4.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation

class Utile {
    
    static let bd_appid = "20151111000005006"
    static let bd_secretkey = "91mGcsmdvX9HAaE8tXoI"
    
    class func getBaiduTranslateSign(_ salt:String, question:String) -> String{
        let str = bd_appid + question + salt + bd_secretkey
        return str.md5
    }

    class func isChinese(_ data:String) -> Bool{
        print("isChinese:\(data)")
        if data.containsChineseCharacters {
            print("Contains Chinese")
            return true
        }else{
            print("not Chinese")
            return false
        }
    }
    
}

extension String {
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
}

extension String {
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        result.deinitialize();
        
        return String(format: hash as String)
    }
}
