//
//  BaseStatus.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class BaseStatus {
    var id:String = ""
    var text:String = ""
    var urls:[String] = []
    var hashtags:[String] = []
    var mentions:[[String:String]] = []
    var medias:[[String:String]] = []
    var user:User = User()
    var date:String = ""
    var favorited:Bool = false
    var retweeted:Bool = false
}