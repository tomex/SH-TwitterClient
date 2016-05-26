//
//  Setting.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/25.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class Setting{
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    static func setObject(value:AnyObject,key:String){
        userDefaults.setObject(value, forKey: key)
    }
    static func setString(value:String,key:String){
        setObject(value, key: key)
    }
    static func setInteger(value:Int,key:String){
        userDefaults.setInteger(value, forKey: key)
    }
    static func setBool(value:Bool,key:String){
        userDefaults.setBool(value, forKey: key)
    }
    static func setFloat(value:Float,key:String){
        userDefaults.setFloat(value, forKey: key)
    }
    static func setDouble(value:Double,key:String){
        userDefaults.setDouble(value, forKey: key)
    }
    static func setURL(value:NSURL?,key:String){
        userDefaults.setURL(value, forKey: key)
    }
    static func get(key:String) -> AnyObject? {
        return userDefaults.valueForKey(key)
    }
}