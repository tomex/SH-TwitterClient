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
    override func openURL(url: NSURL) -> Bool {
        let navigationController = getNavigationController()
        let vc = getStoryBoard("WebViewController")
        let webViewControllerCast = vc as! WebViewController
        webViewControllerCast.openUrl = url
        navigationController.pushViewController(webViewControllerCast ?? vc , animated: true)
        return true
    }
    func openUser(user: User,account:ACAccount) -> Bool {
        let navigationController = getNavigationController()
        let vc = getStoryBoard("UserTabBarViewController")
        let cast = vc as! UserTabBarViewController
        cast.account = account
        cast.user = user
        navigationController.pushViewController(cast ?? vc , animated: true)
        return true
    }
    func openSearch(query:String,account:ACAccount) -> Bool {
        let navigationController = getNavigationController()
        let vc = getStoryBoard("SearchTableViewController")
        let cast = vc as! SearchTableViewController
        cast.query = query
        cast.account = account
        navigationController.pushViewController(cast ?? vc , animated: true)
        cast.requestTwitter()
        return true
    }
    
    private func getNavigationController()->UINavigationController{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.navigationController
    }
    
    private func getStoryBoard(name:String)->UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard.instantiateViewControllerWithIdentifier(name)
    }
    
    func openBrowser(url:NSURL)->Bool{
        return super.openURL(url)
    }
}
