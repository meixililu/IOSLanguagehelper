//
//  ReadingTableViewCell.swift
//  Languagehelper
//
//  Created by luli on 14/01/2018.
//  Copyright © 2018 luli. All rights reserved.
//

import UIKit


class ReadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var play_img: UIImageView!
    
    @IBOutlet weak var img_width: NSLayoutConstraint!
    @IBOutlet weak var play_img_width: NSLayoutConstraint!
    
    @IBOutlet weak var video_img: UIImageView!
    @IBOutlet weak var video_img_height: NSLayoutConstraint!
    
    @IBOutlet weak var video_play_img: UIImageView!
    @IBOutlet weak var video_play_img_height: NSLayoutConstraint!
    
    @IBOutlet weak var video_cover_height: NSLayoutConstraint!
    
    @IBOutlet weak var source_top_space: NSLayoutConstraint!
    
}
