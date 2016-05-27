//
//  BaseFollowerTableViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/27.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Accounts
import Social

class BaseFollowerTableViewController: UITableViewController,TimeLineControllerProtocol{
    var account: ACAccount = ACAccount()
    var api:String = ""
    var users:[User] = []
    var tabBarViewController:BaseUITabBarController = BaseUITabBarController()
    var loading = false
    var nextCursor = ""
    private let tableViewCellName = "FollowerTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = true
        
        self.tableView.registerNib(UINib(nibName: tableViewCellName, bundle: nil), forCellReuseIdentifier: tableViewCellName)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(BaseFollowerTableViewController.refreshTableView), forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestTwitter() {
        
    }
    
    func requestTwitter(isMax: Bool, id: String) {
        
    }
    
    func apiLoad(params:[String:AnyObject]){
        apiLoad(params,insert:true)
    }
    
    func apiLoad(params:[String:AnyObject],insert:Bool){
        TwitterAccess.getAction(self, api: api, isPostMethod: false, params: params, successCode: { (_,obj) in
            let array = obj["users"] as? [AnyObject] ?? []
            self.nextCursor = obj["next_cursor_str"] as? String ?? ""
            do{
                let users = try self.parseJSON(array)
                if insert{
                    self.users.insertContentsOf(users,at: 0)
                }else{
                    self.users.appendContentsOf(users)
                }
            }catch (let e){
                print("parse error: \(e)")
            }
            ThreadAction.mainThread{
                self.tableView.reloadData()
            }
        })
    }
    
    func parseJSON(array:[AnyObject]) throws -> [User]{
        return try array.map { r in
            guard let result = r as? [String:AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            let status = try self.parseJSON(result)
            return status
        }
    }
    
    func parseJSON(result:[String:AnyObject]) throws -> User {
        let user = try setUser(User(),result: result)
        return user
    }
    
    private func setUser(user:User,result:[String:AnyObject]) throws -> User{
        guard let screenName = result["screen_name"] as? String else { throw TimeLineError.ParseError("Parse error! 1") }
        guard let userName = result["name"] as? String else { throw TimeLineError.ParseError("Parse error! 2") }
        guard let userId = result["id_str"] as? String else { throw TimeLineError.ParseError("Parse error! 3") }
        guard let profileImageUrlHttps = result["profile_image_url_https"] as? String else { throw TimeLineError.ParseError("Parse error! 4") }
        guard let description = result["description"] as? String else { throw TimeLineError.ParseError("Parse error! 5") }
        guard let location = result["location"] as? String else { throw TimeLineError.ParseError("Parse error! 6") }
        guard let followCount = result["friends_count"] as? Int else { throw TimeLineError.ParseError("Parse error! 7") }
        guard let followerCount = result["followers_count"] as? Int else { throw TimeLineError.ParseError("Parse error! 8") }
        guard let favoriteCount = result["favourites_count"] as? Int else { throw TimeLineError.ParseError("Parse error! 9") }
        guard let statusesCount = result["statuses_count"] as? Int else { throw TimeLineError.ParseError("Parse error! 10") }
        guard let protected = result["protected"] as? Bool else { throw TimeLineError.ParseError("Parse error! 11") }
        user.id = userId
        user.screenName = screenName
        user.userName = userName
        user.profileImageUrlHttps = profileImageUrlHttps
        user.protected = protected
        user.description = description
        user.location = location
        user.followCount = followCount
        user.followerCount = followerCount
        user.favoriteCount = favoriteCount
        user.tweetCount = statusesCount
        return user
    }

    
    internal func refreshTableView(){
        refreshControl?.beginRefreshing()
        requestTwitter()
        refreshControl?.endRefreshing()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cast = tableView.dequeueReusableCellWithIdentifier(tableViewCellName, forIndexPath: indexPath)
        if let cell = cast as? FollowerTableViewCell{
            let row = indexPath.row
            let user = users[row]
            cell.profileImageView.image = UIImage(named: "ic_autorenew")
            cell.nameLabel.text = "@\(user.screenName)"
            cell.descriptionLabel.text = user.description
            if user.protected {
                cell.protectedConstraint.constant = 24
            }else{
                cell.protectedConstraint.constant = 0
            }
            ThreadAction.subThread{
                let profileImage = user.profileImageUrlHttps
                if let image = user.profileImage {
                    ThreadAction.mainThread{
                        cell.profileImageView.image = image
                    }
                    return
                }
                if profileImage == "" {
                    return
                }
                if let url = NSURL(string: profileImage){
                    let data = UIImage(data: NSData(contentsOfURL: url) ?? NSData())
                    ThreadAction.mainThread{
                        user.profileImage = data
                        cell.profileImageView.image = data
                        cell.setNeedsLayout()
                    }
                }
            }
            return cell
        }
        return cast
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let user = users[row]
        self.openUser(user)
    }
    
    private func openUser(user:User){
        (UIApplication.sharedApplication() as? TwitterApplication)?.openUser(user,account: self.account)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) && users.count > 0{
            if !loading{
                loading = true
                self.requestTwitter(false,id:"")
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
//    */
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if let vc = segue.destinationViewController as? UserDetailViewController {
//            vc.account = account
//            vc.user = user
//        }
//    }
}
