//
//  FileManagerUtil.swift
//  FileManagerDemo
//
//  Created by luli on 16/5/15.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation


class FileManagerUtil {
    
    class func getDocumentPath()->String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    class func getCachesPath()->String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask , true).first!
    }
    
    class func getLibraryPath()->String{
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    }
    
    class func getTmpPath()->String {
        return NSTemporaryDirectory()
    }
    
    class func getHomePath()->String{
        return NSHomeDirectory()
    }
    
    class func isDirectoryExistsAtPath(_ path: String) -> Bool{
        NSLog("isDirectoryExistsAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        let result = fileManager.fileExists(atPath: path)
        if result {
            NSLog("directory exists")
        } else {
            NSLog("directory do not exists")
        }
        return result
    }
    
    class func createDirectoryAtPath(_ path: String) {
        NSLog("createDirectoryAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("createDirectoryAtPath exception")
        }
    }
    
    class func deleteDirectoryAtPath(_ path: String) {
        NSLog("deleteDirectoryAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            NSLog("create directory at path exception")
        }
    }
    
    class  func isFileExistsAtPath(_ path: String) -> Bool{
        NSLog("isFileExistsAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        let result = fileManager.fileExists(atPath: path)
        if result {
            NSLog("file exists")
        } else {
            NSLog("file do not exists")
        }
        return result
    }
    
    class func createFileAtPath(_ path: String) -> Bool{
        NSLog("createFileAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        return fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }
    
    class func deleteFileAtPath(_ path: String) {
        NSLog("deleteFileAtPath:\(path)")
        let fileManager = Foundation.FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            NSLog("delete file at path fail")
        }
    }
    
    class func saveUserDefaults(_ object:Bool, key:String){
        let userDafault = UserDefaults.standard
        userDafault.set(object, forKey: key)
        userDafault.synchronize()
    }
    
    class func saveUserDefaults(_ object:Int, key:String){
        let userDafault = UserDefaults.standard
        userDafault.set(object, forKey: key)
        userDafault.synchronize()
    }
    
    class func saveUserDefaults(_ object:String, key:String){
        let userDafault = UserDefaults.standard
        userDafault.set(object, forKey: key)
        userDafault.synchronize()
    }
    
}
