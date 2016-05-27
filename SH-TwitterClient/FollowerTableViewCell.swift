//
//  FollowerTableViewCell.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/27.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class FollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var protectedConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
