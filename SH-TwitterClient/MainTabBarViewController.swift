//
//  MainTabBarViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/17.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Social
import Accounts

class MainTabBarViewController: BaseUITabBarController{
    private var accounts = [ACAccount]()
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterAccountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        self.setAccountsByDevice(twitterAccountType)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAccountsByDevice(accountType: ACAccountType) {
        let accountStore = ACAccountStore()
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
            
            // アカウント取得に失敗したとき
            if let accountError = error {
                print("Account Error: %@", accountError.localizedDescription)
                return
            }
            
            // アカウント情報へのアクセス権限がない時
            if !granted {
                print("Account Error: Cannot access to account data.")
                return
            }
            
            // アカウント情報の取得に成功
            self.accounts = accountStore.accountsWithAccountType(accountType) as? [ACAccount] ?? []
            
            // Twitterアカウントが0件の時
            if (self.accounts.count > 0){
                self.account = self.accounts[0]
                if let screenName = Setting.get("defaultAccount") as? String{
                    for account in self.accounts{
                        if account.username == screenName{
                            self.account = account
                            break
                        }
                    }
                }
            }
            
            self.requestTwitter()
        }
    }
    
    func setTwitterAccount(baseView:UIView,result:((account:ACAccount) -> ())){
        let alertController = UIAlertController(
            title: "アカウント一覧",
            message: "選択してください",
            preferredStyle: .ActionSheet)
        alertController.popoverPresentationController?.sourceView = baseView
        alertController.popoverPresentationController?.sourceRect = CGRectMake(baseView.frame.origin.x + (baseView.frame.width / 2),baseView.frame.origin.y + (baseView.frame.height / 2), 0.0, 0.0)
        for account in accounts {
            let otherAction = UIAlertAction(title: account.username, style: .Default) { action in
                self.account = account
                ThreadAction.mainThread{
                    self.requestTwitter()
                    result(account: account)
                    
                    Setting.setString(account.username, key: "defaultAccount")
                }
                print("Account set \(account.username)")
            }
            alertController.addAction(otherAction)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in
            print("Cancel setting")
        }
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tweetChange(text:String,replyToId:String){
        if let viewControllers = self.viewControllers{
            for i in 0 ..< viewControllers.count {
                if let tweetViewController = viewControllers[i] as? TweetViewController{
                    changeViewController(i)
                    tweetViewController.replyToId = replyToId
                    tweetViewController.text = text
                    tweetViewController.setTweet()
                }
            }
        }
    }
    
    func setUserStreamButton(){
        setUserStreamButton(leftBarButtonItem,connectionChange: false)
    }
    
    @IBAction func userStreamButton(sender: UIBarButtonItem) {
        setUserStreamButton(sender,connectionChange: true)
    }
    
    func setUserStreamButton(sender:UIBarButtonItem,connectionChange:Bool){
        if let viewControllers = self.viewControllers{
            for i in 0 ..< viewControllers.count {
                if let userStreamViewController = viewControllers[i] as? MainTimeLineTableViewController{
                    if connectionChange {
                        userStreamViewController.onClickUserStream(sender)
                    }else{
                        userStreamViewController.setUserStreamButton(sender)
                    }
                }
            }
        }
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
