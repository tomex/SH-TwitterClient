//
//  BaseUITabBarController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/23.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Social
import Accounts

protocol UserTimeLineProtocol{
    var user:User{
        get set
    }
}

class BaseUITabBarController: UITabBarController,AccountProtocol,UITabBarControllerDelegate{
    var account = ACAccount()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setTitle(0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestTwitter() {
        ThreadAction.mainThread{
            if let viewControllers = self.viewControllers{
                for vc in viewControllers{
                    self.viewControllerRequestCheck(vc)
                }
            }
        }
    }
    
    func requestTwitter(isMax: Bool, id: String) {
        requestTwitter()
    }
    
    func viewControllerRequestCheck(viewController:UIViewController){
        if var timeline = viewController as? AccountProtocol{
            timeline.account = self.account
            if var timelineprotocol = timeline as? TimeLineControllerProtocol {
                timelineprotocol.tabBarViewController = self
            }
            timeline.requestTwitter()
        }
    }
    
    func changeViewController(index:Int){
        self.selectedIndex = index
        setTitle(index)
    }
    
    private func setTitle(index:Int){
        setNavigationTitle(viewControllers?[index].title)
    }
    
    func setNavigationTitle(title:String?){
        self.navigationItem.title = title
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationItem.title = viewController.title
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
