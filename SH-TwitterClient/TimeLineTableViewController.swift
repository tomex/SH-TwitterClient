//
//  TimeLineTableViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Social
import Accounts

protocol AccountProtocol {
    var account:ACAccount{
        get set
    }
    func requestTwitter()
    func requestTwitter(isMax:Bool,id:String)
}

protocol TimeLineControllerProtocol:AccountProtocol{
    var api:String{
        get set
    }
    var tabBarViewController:BaseUITabBarController{
        get set
    }
}

protocol UserStreamProtocol {
    func userStreamRequest()
}

enum TimeLineError:ErrorType{
    case ParseError(String)
}

class TimeLineTableViewController: UITableViewController,TimeLineControllerProtocol,NSURLSessionDataDelegate,NSURLSessionTaskDelegate,UserStreamProtocol{
    var api:String = ""
    var account = ACAccount()
    var statuses:[Status] = []
    var tabBarViewController:BaseUITabBarController = BaseUITabBarController()
    var loading = false
    var userStream = false
    private var session:NSURLSession?
    private var connection:NSURLSessionDataTask?
    private let tableViewCellName = "TimeLineTableViewCell"
    private let inputFormatter = NSDateFormatter()
    private let exportFormatter = NSDateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        inputFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        
        exportFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        exportFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        tableView.alwaysBounceVertical = true
        
        self.tableView.registerNib(UINib(nibName: tableViewCellName, bundle: nil), forCellReuseIdentifier: tableViewCellName)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100.0
        
        userStream = Setting.get("userstream_preference") as? Bool ?? false
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(TimeLineTableViewController.refreshTableView), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func userStreamRequest() {
        
    }
    
    internal func onClickUserStream(sender:UIBarButtonItem){
        if connection == nil {
            
        }else{
            connection?.cancel()
            connection = nil
        }
        self.setUserStreamButton(sender)
    }
    
    internal func setUserStreamButton(sender:UIBarButtonItem){
        if connection != nil {
            sender.image = UIImage(named: "ic_network_wifi")
        }else{
            sender.image = UIImage(named: "ic_signal_wifi_off")
        }
    }
    
    internal func refreshTableView(){
        refreshControl?.beginRefreshing()
        if statuses.count >= 1 {
            requestTwitter(false,id: statuses[0].id)
        }else{
            requestTwitter()
        }
        refreshControl?.endRefreshing()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let tabBarViewController = self.tabBarViewController as? MainTabBarViewController {
            tabBarViewController.setUserStreamButton()
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let tmp = NSString(data: data ?? NSData(), encoding: NSUTF8StringEncoding){
            if let tabBarViewController = self.tabBarViewController as? MainTabBarViewController {
                tabBarViewController.setUserStreamButton()
            }
            let split = tmp.componentsSeparatedByString("\n")
            for string in split{
                if string.containsString("{") || string.containsString("[") {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData() ,options: .AllowFragments)
                        if let dic = json as? [String:AnyObject]{
                            if dic.keys.contains("friends"){
                                if (dic["friends"] as? [Int]) != nil{
                                    continue
                                }
                            }else if dic.keys.contains("text"){
                                let status = try self.parseJSON(dic)
                                let action = { (vc:TimeLineTableViewController) in
                                    if !vc.statuses.contains({ return $0.id == status.id }) {
                                        vc.statuses.insert(status, atIndex: 0)
                                        ThreadAction.mainThread{
                                            vc.tableView.reloadData()
                                        }
                                    }
                                }
                                for vc in self.tabBarViewController.viewControllers ?? [] {
                                    if let timeline = vc as? MainTimeLineTableViewController {
                                        action(timeline)
                                    }else if let timeline = vc as? MentionsTimeLineTableViewController {
                                        for mention in status.mentions{
                                            if timeline.account.username == mention["screen_name"] ?? "" {
                                                action(timeline)
                                                break
                                            }
                                        }
                                    }
                                }
                            }else if dic.keys.contains("delete"){
                                let deleteStatusId = (dic["delete"]?["status"])?["id_str"] as? String ?? ""
                                ThreadAction.mainThread{
                                    while(self.statuses.contains({return $0.id == deleteStatusId})){
                                        let i = self.statuses.indexOf({return $0.id == deleteStatusId})
                                        if let index = i {
                                            self.statuses.removeAtIndex(index)
                                        }
                                    }
                                    self.tableView.reloadData()
                                }
                            }else if dic.keys.contains("event"){
                                let myId = account.valueForKey("properties")?["user_id"] as? String ?? ""
                                let event = dic["event"] as? String ?? ""
                                let source = dic["source"] as? [String:AnyObject] ?? [:]
                                let targetObject = dic["target_object"] as? [String:AnyObject] ?? [:]
                                let sourceId = source["id_str"] as? String ?? ""
                                let targetStatusId = targetObject["id_str"] as? String ?? ""
                                let status = try self.parseJSON(targetObject)
                                let action = { (vc:TimeLineTableViewController,favorite:Bool) in
                                    ThreadAction.mainThread{
                                        if vc.statuses.contains({return $0.id == targetStatusId}){
                                            let i = vc.statuses.indexOf({return $0.id == targetStatusId})
                                            if let index = i {
                                                let statusIndex = index.advancedBy(0)
                                                vc.statuses[statusIndex].favorited = favorite
                                            }
                                        }
                                        self.tableView.reloadData()
                                    }
                                }
                                if sourceId == myId{
                                    if event == "unfavorite" {
                                        for vc in self.tabBarViewController.viewControllers ?? [] {
                                            if let timeline = vc as? FavoriteTableViewController {
                                                ThreadAction.mainThread{
                                                    if timeline.statuses.contains({return $0.id == targetStatusId}) {
                                                        let i = timeline.statuses.indexOf({return $0.id == targetStatusId})
                                                        if let index = i {
                                                            timeline.statuses.removeAtIndex(index)
                                                        }
                                                    }
                                                    timeline.tableView.reloadData()
                                                }
                                            }else if let timeline = vc as? TimeLineTableViewController {
                                                action(timeline,false)
                                            }
                                        }
                                    }else if event == "favorite"{
                                        for vc in self.tabBarViewController.viewControllers ?? [] {
                                            if let timeline = vc as? FavoriteTableViewController {
                                                ThreadAction.mainThread{
                                                    if !timeline.statuses.contains({ return $0.id == targetStatusId }) {
                                                        status.favorited = true
                                                        timeline.statuses.insert(status, atIndex: 0)
                                                    }
                                                    timeline.tableView.reloadData()
                                                }
                                            }else if let timeline = vc as? TimeLineTableViewController {
                                                action(timeline,true)
                                            }
                                        }
                                    }
                                }
                            }else{
                                print(dic)
                            }
                        }
                    } catch (let jsonError) {
                        print("JSON Error: \(jsonError)")
                        return
                    }
                }
            }
        }
    }
    
    
    func requestTwitter() {
        if connection != nil {
            connection?.cancel()
            connection = nil
        }
        let req = TwitterAccess.generateRequestFullName("https://userstream.twitter.com/1.1/user.json", isPostMethod: false, params:[:])
        req.account = self.account
        connection = session?.dataTaskWithRequest(req.preparedURLRequest())
        connection?.resume()
    }
    
    func requestTwitter(isMax: Bool, id: String) {
        
    }
    
    func timelineLoad(params:[String:AnyObject]){
        self.timelineLoad(params,insert: true)
    }
    
    func timelineLoad(params:[String:AnyObject],insert:Bool){
        let isSearch = api.containsString("search/")
        TwitterAccess.getAction(self, api: api, isPostMethod: false, params: params, successCode: { (_,objectFromJSON) in
            let array:[AnyObject]
            if isSearch {
                let search = objectFromJSON as? [String:AnyObject] ?? [:]
                array = search["statuses"] as? [AnyObject] ?? []
            }else{
                array = objectFromJSON as? [AnyObject] ?? []
            }
            do{
                let statuses = try self.parseJSON(array)
                if insert{
                    self.statuses.insertContentsOf(statuses,at: 0)
                }else{
                    self.statuses.appendContentsOf(statuses)
                }
            }catch (let e){
                print("parse error: \(e)")
            }
            ThreadAction.mainThread{
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statuses.count
    }
    
    func parseJSON(array:[AnyObject]) throws -> [Status]{
        return try array.map { r in
            guard let result = r as? [String:AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            let status = try self.parseJSON(result)
            return status
        }
    }
    
    func parseJSON(result:[String:AnyObject]) throws ->Status{
        let status = try setStatus(Status(),result: result) as! Status
        if result.keys.contains("retweeted_status") {
            guard let retweeted_status = result["retweeted_status"] as? [String:AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            status.retweeted_status = try setStatus(RetweetStatus(), result: retweeted_status) as! RetweetStatus
        }
        return status
    }
    
    private func setStatus(status:BaseStatus,result:[String:AnyObject]) throws -> BaseStatus{
        guard let text = result["text"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let id = result["id_str"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let createdAt = result["created_at"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let favorited = result["favorited"] as? Bool else { throw TimeLineError.ParseError("Parse error!") }
        guard let retweeted = result["retweeted"] as? Bool else { throw TimeLineError.ParseError("Parse error!") }
        guard let user = result["user"] as? NSDictionary else { throw TimeLineError.ParseError("Parse error!") }
        guard let entities = result["entities"] as? [String:AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
        if entities.keys.contains("urls") {
            guard let urls = entities["urls"] as? [AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            for dic in urls {
                guard let url = dic["expanded_url"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                status.urls.append(url)
            }
        }
        
        if entities.keys.contains("user_mentions") {
            guard let user_mentions = entities["user_mentions"] as? [AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            for dic in user_mentions {
                guard let id = dic["id_str"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                guard let screenName = dic["screen_name"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                status.mentions.append(["id":id,"screen_name":screenName])
            }
        }
        
        if entities.keys.contains("hashtags") {
            guard let hashtags = entities["hashtags"] as? [AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            for dic in hashtags {
                guard let text = dic["text"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                status.hashtags.append(text)
            }
        }
        
        if result.keys.contains("extended_entities") {
            guard let extended_entities = result["extended_entities"] as? [String:AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
            if extended_entities.keys.contains("media"){
                guard let medias = extended_entities["media"] as? [AnyObject] else { throw TimeLineError.ParseError("Parse error!") }
                for dic in medias {
                    guard let url = dic["expanded_url"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                    guard let media_url = dic["media_url_https"] as? String else { throw TimeLineError.ParseError("Parse error!") }
                    status.medias.append(["url":url,"media_url":media_url])
                }
            }
        }
        guard let screenName = user["screen_name"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let userName = user["name"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let userId = user["id_str"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let profileImageUrlHttps = user["profile_image_url_https"] as? String else { throw TimeLineError.ParseError("Parse error!") }
        guard let protected = user["protected"] as? Bool else { throw TimeLineError.ParseError("Parse error!") }
        status.id = id
        status.text = text
        status.favorited = favorited
        status.retweeted = retweeted
        status.user.id = userId
        status.user.screenName = screenName
        status.user.userName = userName
        status.user.profileImageUrlHttps = profileImageUrlHttps
        status.user.protected = protected
        status.date = exportFormatter.stringFromDate(inputFormatter.dateFromString(createdAt) ?? NSDate())
        return status
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cast = tableView.dequeueReusableCellWithIdentifier(tableViewCellName, forIndexPath: indexPath)
        if let cell = cast as? TimeLineTableViewCell{
            let row = indexPath.row
            let status = statuses[row]
            let flag = status.retweeted_status.id != ""
            let baseStatus = flag ? status.retweeted_status : status
            cell.profileImageView.image = UIImage(named: "ic_autorenew")
            cell.nameLabel.text = "@\(baseStatus.user.screenName)"
            cell.tweetTextView.text = baseStatus.text
            cell.retweetButton.setTitleColor(baseStatus.retweeted ? UIColor(red: 0.0,green: 128.0 / 255.0,blue: 0.0,alpha: 1.0 ) : UIColor.blackColor(), forState: .Normal)
            cell.favoriteButton.setTitleColor(baseStatus.favorited ? UIColor(red: 255.0 / 255.0 , green: 152.0 / 255.0 , blue: 0.0, alpha: 1.0) : UIColor.blackColor(), forState: .Normal)
            cell.favoriteButton.setImage(baseStatus.favorited ? UIImage(named: "ic_favorite") : UIImage(named: "ic_favorite_border") , forState: .Normal)
            cell.favoriteButton.status =  baseStatus
            cell.retweetButton.status = baseStatus
            cell.favoriteButton.addTarget(self, action: #selector(TimeLineTableViewController.favoriteButtonAction), forControlEvents: .TouchUpInside)
            cell.retweetButton.addTarget(self, action: #selector(TimeLineTableViewController.retweetButtonAction), forControlEvents: .TouchUpInside)
            if baseStatus.user.protected {
                cell.protectedImage.hidden = false
                cell.protectedImageWidth.constant = 24
            }else{
                cell.protectedImage.hidden = true
                cell.protectedImageWidth.constant = 0
            }
            if flag {
                cell.retweetedTextView.hidden = false
                cell.retweetedTextViewHeight.constant = 21
                cell.retweetedTextView.text = "Retweeted By @\(status.user.screenName), Date: \(status.date)"
                cell.dateLabel.text = "Source Date: \(baseStatus.date)"
            } else {
                cell.retweetedTextView.hidden = true
                cell.retweetedTextViewHeight.constant = 0
                cell.dateLabel.text = "Tweet Date: \(baseStatus.date)"
            }
            ThreadAction.subThread{
                let profileImage = baseStatus.user.profileImageUrlHttps
                if let image = baseStatus.user.profileImage {
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
                        baseStatus.user.profileImage = data
                        cell.profileImageView.image = data
                        cell.setNeedsLayout()
                    }
                }
            }
            return cell
        }
        return cast
    }
    
    func onItemTouchEvent(indexPath:NSIndexPath,tableView:UITableView){
        let row = indexPath.row
        let myId = account.valueForKey("properties")?["user_id"] as? String ?? ""
        let status = statuses[row]
        let baseStatus = status.retweeted_status.id == "" ? status : status.retweeted_status
        let alertController = UIAlertController(
            title: "メニュー",
            message: "選択してください",
            preferredStyle: .ActionSheet)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRectMake((cell?.frame.size.width ?? self.view.bounds.size.width) / 2, (cell?.frame.origin.y ?? self.view.frame.origin.y) + ((cell?.frame.size.height ?? self.view.frame.size.height) / 2), 0.0, 0.0)
        //alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        
        let replyAction = UIAlertAction(title: "リプライ", style: .Default) { action in
            if let tabViewController = self.parentViewController as? MainTabBarViewController{
                let screenName = status.retweeted_status.id != "" ? status.retweeted_status.user.screenName : status.user.screenName
                tabViewController.tweetChange("@\(screenName) ", replyToId: status.id)
            }
        }
        alertController.addAction(replyAction)
        
        if baseStatus.user.id == myId {
            self.setDeleteAction(alertController, status: baseStatus)
        } else if status.user.id == myId {
            self.setDeleteAction(alertController, status: status)
        }
        
        let unofficialRetweetAction = UIAlertAction(title: "非公式リツイート", style: .Default) { action in
            if let tabViewController = self.parentViewController as? MainTabBarViewController{
                let screenName = status.retweeted_status.id != "" ? status.retweeted_status.user.screenName : status.user.screenName
                let text = status.retweeted_status.id != "" ? status.retweeted_status.text : status.text
                tabViewController.tweetChange("RT @\(screenName): \(text)", replyToId: status.id)
            }
        }
        alertController.addAction(unofficialRetweetAction)
        
        var userNames:[String] = [],userIds:[String] = [],tmpNames:[String] = [],tmpIds:[String] = []
        tmpNames.append(status.user.screenName)
        tmpIds.append(status.user.id)
        
        if status.retweeted_status.id != "" {
            tmpNames.append(status.retweeted_status.user.screenName)
            tmpIds.append(status.retweeted_status.user.id)
        }
        
        for mention in status.mentions {
            let sn = mention["screen_name"] ?? ""
            let id = mention["id"] ?? ""
            if sn != "" && id != "" {
                tmpNames.append(sn)
                tmpIds.append(id)
            }
        }
        
        for i in 0 ..< tmpIds.count {
            let tmpId = tmpIds[i]
            let tmpName = tmpNames[i]
            if userNames.contains(tmpName) || userIds.contains(tmpId) {
                continue
            }
            userNames.append(tmpName)
            userIds.append(tmpId)
            let user = User()
            user.id = tmpId
            user.screenName = tmpName
            self.setUserAction(alertController,user: user)
        }
        
        for media in status.medias {
            let mediaUrl = media["media_url"] ?? ""
            let action = UIAlertAction(title: mediaUrl, style: .Default) { action in
                self.openUrl("\(mediaUrl):orig")
            }
            alertController.addAction(action)
        }

        for tmp in status.hashtags {
            let hashtag = "#\(tmp)"
            let action = UIAlertAction(title: hashtag, style: .Default) { action in
                self.openSearch(hashtag)
            }
            alertController.addAction(action)
        }
        
        for url in status.urls {
            let action = UIAlertAction(title: url ?? "", style: .Default) { action in
                self.openUrl(url)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func openUrl(url:String){
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    private func openSearch(query:String){
        (UIApplication.sharedApplication() as? TwitterApplication)?.openSearch(query,account: self.account)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onItemTouchEvent(indexPath,tableView: tableView)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) && statuses.count > 0{
            if !loading{
                loading = true
                self.requestTwitter(true,id: String(Int64(self.statuses[statuses.count-1].id)! - Int64(1)))
            }
        }
    }
    
    internal func retweetButtonAction(sender:StatusButton){
        retweetAction(sender.status)
    }
    
    private func retweetAction(baseStatus:BaseStatus){
        let flag = !baseStatus.retweeted ? "un" : ""
        TwitterAccess.getAction(self, status: baseStatus,api: "statuses/\(flag)retweet/\(baseStatus.id)",isPostMethod: true,params: [:]){ status,object in
            print("SUCCESS! Retweeted Favorite with ID: %@", object["id_str"] as? String ?? "")
            ThreadAction.mainThread{
                status.retweeted = !status.retweeted
                self.tableView.reloadData()
            }
            ThreadAction.stopProcessing()
        }
    }
    
    internal func favoriteButtonAction(sender:StatusButton){
        favoriteAction(sender.status)
    }
    
    private func favoriteAction(baseStatus:BaseStatus){
        let flag = !baseStatus.favorited ? "create" : "destroy"
        TwitterAccess.getAction(self, status: baseStatus,api: "favorites/\(flag)",isPostMethod: true,params: ["id":baseStatus.id]){ status,object in
            print("SUCCESS! Favorite(\(flag)) with ID: %@", object["id_str"] as? String ?? "")
            ThreadAction.mainThread{
                status.favorited = !status.favorited
                self.tableView.reloadData()
            }
        }
    }
    
    private func setDeleteAction(alertController:UIAlertController,status:BaseStatus){
        let tweetDeleteAction = UIAlertAction(title: "ツイート削除", style: .Default) { action in
            TwitterAccess.getAction(self, status: status,api: "statuses/destroy/\(status.id)",isPostMethod: true,params: [:]){ status,object in
                if let index = self.statuses.indexOf({ return $0.id == status.id }) {
                    self.statuses.removeAtIndex(index)
                    self.tableView.reloadData()
                }
                print("SUCCESS! Tweet Destroy with ID: %@", object["id_str"] as? String ?? "")
            }
        }
        alertController.addAction(tweetDeleteAction)
    }
    
    private func setUserAction(alertController:UIAlertController,user:User){
        let action = UIAlertAction(title: "@\(user.screenName)", style: .Default) { action in
            if let app = UIApplication.sharedApplication() as? TwitterApplication{
                app.openUser(user,account: self.account)
            }
        }
        alertController.addAction(action)
    }
    //
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    

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
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
