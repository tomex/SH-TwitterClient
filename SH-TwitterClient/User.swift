//
//  User.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class User{
    var id:String = ""
    var userName:String = ""
    var screenName:String = ""
    var url:String = ""
    var description:String = ""
    var location:String = ""
    var followerCount:Int = -1
    var followCount:Int = -1
    var favoriteCount:Int = -1
    var tweetCount:Int = -1
    var profileImageUrlHttps:String = ""
    var profileImage:UIImage? = nil
    var protected:Bool = false
    var following:Bool = false
}