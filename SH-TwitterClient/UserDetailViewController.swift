//
//  UserDetailViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/23.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Accounts
import Social

class UserDetailViewController: UIViewController,AccountProtocol,UserTimeLineProtocol{
    var user: User = User()
    var account: ACAccount = ACAccount()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestTwitter() {
        let req = TwitterAccess.generateRequest("users/show", isPostMethod: false, params: ["user_id":user.id])
        let handler = generateRequestHandler()
        req.account = account
        ThreadAction.startProcessing()
        req.performRequestWithHandler(handler)
    }
    func requestTwitter(isMax:Bool,id:String){
        requestTwitter()
    }
    
    
    func generateRequestHandler() -> SLRequestHandler {
        let handler: SLRequestHandler = { getResponseData, urlResponse, error in
            
            // リクエスト送信エラー発生時
            if let requestError = error {
                print("Request Error: An error occurred while requesting: \(requestError)")
                // インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            // httpエラー発生時（ステータスコードが200番台以外ならエラー）
            if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                print("HTTP Error: The response status code is \(urlResponse.statusCode)")
                // インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            // JSONシリアライズ
            do {
                let dic = try NSJSONSerialization.JSONObjectWithData(getResponseData,options: .AllowFragments) as? [String:AnyObject] ?? [:]
                print(dic)
                ThreadAction.mainThread{
                    let name = dic["name"] as? String ?? ""
                    let screenName = dic["screen_name"] as? String ?? ""
                    let text = dic["description"] as? String ?? ""
                    let location = dic["location"] as? String ?? ""
                    let url = dic["url"] as? String ?? ""
                    let profileImage = dic["profile_image_url_https"] as? String ?? ""
                    let count = dic["statuses_count"] as? Int ?? 0
                    let follow = dic["friends_count"] as? Int ?? 0
                    let follower = dic["followers_count"] as? Int ?? 0
                    let favorite = dic["favorite_count"] as? Int ?? 0
                    self.user.userName = name
                    self.user.screenName = screenName
                    self.user.description = text
                    self.user.followCount = follow
                    self.user.followerCount = follower
                    self.user.favoriteCount = favorite
                    self.user.tweetCount = count
                    self.user.url = url
                    
                    self.nameLabel.text = name
                    self.idLabel.text = screenName
                    self.locationLabel.text = location
                    self.urlButton.setTitle(url, forState: .Normal)
                    self.followLabel.text = String(follow)
                    self.followerLabel.text = String(follower)
                    self.favoriteCountLabel.text = String(favorite)
                    self.tweetCountLabel.text = String(count)
                    self.descriptionTextView.text = text
                    ThreadAction.subThread{
                        if let url = NSURL(string: profileImage){
                            let data = UIImage(data: NSData(contentsOfURL: url) ?? NSData())
                            ThreadAction.mainThread{
                                self.profileImageView.image = data
                            }
                        }
                    }
                }
            } catch (let jsonError) {
                print("JSON Error: \(jsonError)")
                ThreadAction.stopProcessing()
                return
            }
            ThreadAction.stopProcessing()
        }
        return handler
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let webView = segue.destinationViewController as? WebViewController{
            if user.url != "" {
                webView.openUrl = NSURL(string: user.url)!
            }
        }
    }
}
