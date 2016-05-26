//
//  SearchViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/25.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Social
import Accounts

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccountProtocol{
    var account:ACAccount = ACAccount()
    var trends:[[String:String]] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestTwitter() {
        if trends.count >= 1{
            return
        }
        TwitterAccess.getAction(self, api: "trends/place", isPostMethod: false, params: ["id":"1118370"], successCode: { (_,obj) in
            let array = obj as? [AnyObject] ?? []
            self.trends.appendContentsOf(self.parseJSON(array))
        })
    }

    func requestTwitter(isMax: Bool, id: String) {
        requestTwitter()
    }
    
    @IBAction func onClickSearchButton(sender: UIButton) {
        openSearch(searchTextField.text ?? "")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchTableViewCell", forIndexPath: indexPath)
        let trend = trends[indexPath.row]
        cell.textLabel?.text = trend["name"]
        cell.detailTextLabel?.text = (trend["volume"] ?? "0") + "件のツイート"
        return cell
    }

    private func parseJSON(json:[AnyObject])->[[String:String]]{
        guard let result = json[0] as? [String:AnyObject] else { fatalError("Parse error!") }
        guard let trends = result["trends"] as? [AnyObject] else { fatalError("Parse error!") }
        return trends.map{ trend in
            var output:[String:String] = [:]
            output["volume"] = String(trend["tweet_volume"] as? Int ?? 0)
            output["name"] = trend["name"] as? String ?? ""
            return output
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let trend = trends[indexPath.row]
        searchTextField.text = trend["name"]
    }
    
    private func openSearch(query:String){
        (UIApplication.sharedApplication() as? TwitterApplication)?.openSearch(query,account: self.account)
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
