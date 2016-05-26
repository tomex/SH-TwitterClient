//
//  TwitterApplication.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/20.
//  Copyright © 2016年 tmx3. All rights reserved.
//
import UIKit
import Accounts
import Social

class TwitterApplication: UIApplication {
    //var openUrl = NSURL()
    override func openURL(url: NSURL) -> Bool {
        //openUrl = url
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let navigationController = appDelegate.navigationController
        let webViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewController")
        let webViewControllerCast = webViewController as! WebViewController
        webViewControllerCast.openUrl = url
        navigationController.pushViewController(webViewControllerCast ?? webViewController , animated: true)
        return true
    }
    func openUser(user: User,account:ACAccount) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let navigationController = appDelegate.navigationController
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserTabBarViewController")
        let cast = vc as! UserTabBarViewController
        cast.account = account
        cast.user = user
        navigationController.pushViewController(cast ?? vc , animated: true)
        return true
    }
    func openSearch(query:String,account:ACAccount) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let navigationController = appDelegate.navigationController
        let vc = storyboard.instantiateViewControllerWithIdentifier("SearchTableViewController")
        let cast = vc as! SearchTableViewController
        cast.query = query
        cast.account = account
        navigationController.pushViewController(cast ?? vc , animated: true)
        cast.requestTwitter()
        return true
    }
    
    func openBrowser(url:NSURL)->Bool{
        return super.openURL(url)
    }
}
