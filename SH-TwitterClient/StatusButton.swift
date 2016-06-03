//
//  StatusButton.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/25.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class StatusButton: UIButton {
    var status:BaseStatus = BaseStatus()
    @IBInspectable var cornerRadius : CGFloat = 10.0
    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)
        super.drawRect(rect)
    }
}
