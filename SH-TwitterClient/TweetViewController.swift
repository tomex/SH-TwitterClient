//
//  TweetViewController.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Accounts
import Social

class TweetViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AccountProtocol{
    var account = ACAccount()
    var images:[UIImage] = []
    var replyToId:String = ""
    var text:String = ""
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var accountSelectButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageSelectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTitle(account)
        //self.tweetTextView
        // = "@\(account.username)"
        // Do any additional setup after loading the view.
    }
    
    private func setTitle(account:ACAccount){
        accountSelectButton.setTitle("@\(account.username)", forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTweet(){
        tweetTextView.text = text
    }
    
    func requestTwitter() {
    }
    
    func requestTwitter(isMax: Bool, id: String) {
        
    }
    
    @IBAction func tweet() {
        var imageIds:[String] = []
        var errors = [String]()
        
        if self.images.count >= 1 {
            for image in self.images {
                let runsImage = {
                    if (errors.count + imageIds.count) >= self.images.count {
                        self.tweetOnImageId(imageIds.joinWithSeparator(","))
                    }
                }
                TwitterAccess.getAction(self, api: "https://upload.twitter.com/1.1/media/upload.json", isPostMethod: true, params: [:], successCode: { (_,obj) in
                        let imageId = obj["media_id_string"] as? String ?? ""
                        print("SUCCESS! Created Image with ID: %@", imageId)
                        imageIds.append(imageId)
                        runsImage()
                    },errors: { (str:String) in
                        errors.append(str)
                    },prepare: { (req:SLRequest) in
                        let imageData = UIImageJPEGRepresentation(image,0.85)
                        req.addMultipartData(imageData, withName: "media", type: "multipart/form-data", filename: "image.jpg")
                    }
                )
            }
        }else{
            self.tweetOnImageId("")
        }
    }
    
    private func tweetOnImageId(imageIds:String){
        let tweetString = tweetTextView.text
        let params:[String:String]
        if imageIds != "" {
            params = ["status" : tweetString,"media_ids" : imageIds, "in_reply_to_status_id":replyToId ]
        }else{
            params = ["status" : tweetString,"in_reply_to_status_id":replyToId]
        }
        TwitterAccess.getAction(self, api: "statuses/update", isPostMethod: true, params: params, successCode: {(_,obj) in
            // Tweet成功
            print("SUCCESS! Created Tweet with ID: %@", obj["id_str"] as! String)
            // インジケータ停止
            ThreadAction.stopProcessing()
            ThreadAction.mainThread{
                self.tweetTextView.text = ""
                self.images.removeAll()
                self.refreshImages()
            }
        })
    }
    
    @IBAction func accountSelect() {
        if let vc = self.parentViewController as? MainTabBarViewController{
            vc.setTwitterAccount(accountSelectButton){ account in
                self.setTitle(account)
            }
        }
    }
    
    @IBAction func photoSelect() {
        if !imageSelectButton.enabled {
            return
        }
        let camera = UIImagePickerControllerSourceType.PhotoLibrary
        if UIImagePickerController.isSourceTypeAvailable(camera){
            let picker = UIImagePickerController()
            picker.sourceType = camera
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func removeAtImage(sender:UIButton){
        if let image = sender.currentImage{
            if let index = images.indexOf(image){
                images.removeAtIndex(index)
                refreshImages()
            }
        }else{
            print("画像がないよ")
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage ?? UIImage()
        images.insert(image, atIndex: images.count)
        refreshImages()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshImages(){
        let subViews = stackView.subviews
        for i in 0..<subViews.count {
            let subView = subViews[i] as? UIButton ?? UIButton()
            if images.count <= i {
                subView.hidden = true
            }else{
                subView.hidden = false
                subView.setImage(images[i], forState: .Normal)
            }
        }
        if images.count >= 4 {
            imageSelectButton.enabled = false
        }else{
            imageSelectButton.enabled = true
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
