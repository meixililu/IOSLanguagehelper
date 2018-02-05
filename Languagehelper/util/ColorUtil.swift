//
//  ColorUtil.swift
//  Languagehelper
//
//  Created by luli on 16/7/18.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation

class ColorUtil{
    
    static let appBlue: String = "#2196F3"
    
    static let appBlueDark: String = "#1976D2"
    
    static let indigo: String = "#536DFE"
    
    static let gray: String = "#f1f1f1"
    
    static let darkGray6: String = "#666666"
    
    static let darkGray3: String = "#333333"
    
    static let line_light_gray: String = "#cccccc"
    
    static let barBackground: String = "#fafafa"
    
    static let background_colors: [String] = ["#0292c7","#9fe0f6","#f3e59a","#f3b59b","#f29c9c","#e3e4c8","#e9f5b0","#d7da80","#d8a878","#ed9c17","#86c397","#ead59e","#f1cb8a","#cb8552","#b83d4f","#70CBA6","#76b351","#b2dcf5","#ffb9ad","#b5ef9b","#fdf5a1","#b2dcf5","#ffb9ad","#fffdfd"]
    
    class func getRandomColorStr() -> String {
        let size:UInt32 = UInt32(background_colors.count)
        let temp = Int(arc4random() % size)
        return background_colors[temp]
    }
    
    class func getRandomColorByStr(colorStr color_str: String) -> UIColor {
        return UIColor(hexString: color_str)!
    }
    
    class func getRandomColor() -> UIColor {
        let size:UInt32 = UInt32(background_colors.count)
        let temp = Int(arc4random() % size)
        return UIColor(hexString: background_colors[temp])!
    }
    
    class func getImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
