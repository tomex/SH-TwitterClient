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
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestTwitter() {
        TwitterAccess.getAction(self, api: "users/show", isPostMethod: false, params: ["user_id":user.id], successCode: { (_,obj) in
            let dic = obj as? [String:AnyObject] ?? [:]
            let name = dic["name"] as? String ?? ""
            let screenName = dic["screen_name"] as? String ?? ""
            let text = dic["description"] as? String ?? ""
            let location = dic["location"] as? String ?? ""
            let url = dic["url"] as? String ?? ""
            let profileImage = dic["profile_image_url_https"] as? String ?? ""
            let count = dic["statuses_count"] as? Int ?? 0
            let follow = dic["friends_count"] as? Int ?? 0
            let follower = dic["followers_count"] as? Int ?? 0
            let favorite = dic["favourites_count"] as? Int ?? 0
            let protected = dic["protected"] as? Bool ?? false
            let following = dic["following"] as? Bool ?? false
            self.user.userName = name
            self.user.screenName = screenName
            self.user.description = text
            self.user.followCount = follow
            self.user.followerCount = follower
            self.user.favoriteCount = favorite
            self.user.tweetCount = count
            self.user.url = url
            self.user.protected = protected
            self.user.following = following
            ThreadAction.mainThread{
                self.nameLabel.text = name
                self.idLabel.text = screenName
                self.locationLabel.text = location
                self.urlButton.setTitle(url, forState: .Normal)
                self.followLabel.text = String(follow)
                self.followerLabel.text = String(follower)
                self.favoriteCountLabel.text = String(favorite)
                self.tweetCountLabel.text = String(count)
                self.descriptionTextView.text = text
                self.followUnfollowButton.setTitle(following ? "Unfollow" : "Follow", forState: .Normal)
                ThreadAction.subThread{
                    if let url = NSURL(string: profileImage){
                        let data = UIImage(data: NSData(contentsOfURL: url) ?? NSData())
                        ThreadAction.mainThread{
                            self.profileImageView.image = data
                        }
                    }
                }
            }
        })
    }
    
    func requestTwitter(isMax:Bool,id:String){
        requestTwitter()
    }
    @IBAction func onClickUrlButton(sender: UIButton) {
        if user.url == "" {
            return
        }
        UIApplication.sharedApplication().openURL(NSURL(string: user.url)!)
    }
    
    @IBAction func onClickFollowUnfollowButton(sender: UIButton) {
        let following = !user.following
        let api = user.following ? "create" : "destroy"
        TwitterAccess.getAction(self, api: "friendships/\(api)", isPostMethod: true, params: ["user_id":user.id], successCode: {(_,obj) in
            self.user.following = following
            ThreadAction.mainThread{
                self.followUnfollowButton.setTitle(following ? "Unfollow" : "Follow", forState: .Normal)
            }
        })
    }
}
