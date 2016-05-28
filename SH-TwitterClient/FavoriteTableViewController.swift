//
//  FavoriteTableViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/26.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit

class FavoriteTableViewController:TimeLineTableViewController,UserTimeLineProtocol{
    var user: User = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.api = "favorites/list"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func requestTwitter(){
        self.statuses.removeAll()
        self.tableView.reloadData()
        let params:[String:String]
        if user.id != ""{
            params = ["count":"20","user_id":user.id]
        }else{
            params = ["count":"20"]
        }
        self.timelineLoad(params)
    }
    
    override func requestTwitter(isMax:Bool,id:String){
        let name = isMax ? "max_id" : "since_id"
        let params:[String:String]
        if user.id != ""{
            params = ["count":"20",name:id,"user_id":user.id]
        }else{
            params = ["count":"20",name:id]
        }
        self.timelineLoad(params,insert: !isMax )
    }

    // MARK: - Table view data source
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
