//
//  UserTabBarViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/23.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class UserTabBarViewController: BaseUITabBarController,UserTimeLineProtocol{
    var user: User = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestTwitter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewControllerRequestCheck(viewController: UIViewController) {
        if var timeline = viewController as? UserTimeLineProtocol{
            timeline.user = self.user
        }
        super.viewControllerRequestCheck(viewController)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
