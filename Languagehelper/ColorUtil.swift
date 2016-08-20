//
//  ColorUtil.swift
//  Languagehelper
//
//  Created by luli on 16/7/18.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation

class ColorUtil{
    
    static var appBlue: String = "#2196F3"
    
    static var appBlueDark: String = "#1976D2"
    
    static var indigo: String = "#536DFE"
    
    static var gray: String = "#f1f1f1"
    
    static var darkGray6: String = "#666666"
    
    static var darkGray3: String = "#333333"
    
    class func getImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}