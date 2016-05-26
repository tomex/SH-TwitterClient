//
//  TimeLineTableViewCell.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var protectedImage: UIImageView!
    @IBOutlet weak var protectedImageWidth: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: StatusButton!
    @IBOutlet weak var retweetButton: StatusButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UILabel!
    @IBOutlet weak var retweetedTextView: UILabel!
    @IBOutlet weak var retweetedTextViewHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
