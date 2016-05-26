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
            let imageUrl = NSURL(string: "")

            let runsImage = {
                if (errors.count + imageIds.count) >= self.images.count {
                    self.tweetOnImageId(imageIds.joinWithSeparator(","))
                }
            }
            
            let imageHandler: SLRequestHandler = { postResponseData, urlResponse, error in
                
                // リクエスト送信エラー発生時
                if let requestError = error {
                    let code = "Request Error: An error occurred while requesting: \(requestError)"
                    errors.append(code)
                    print(code)
                    runsImage()
                    return
                }
                
                // httpエラー発生時
                if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                    let code = "HTTP Error: The response status code is \(urlResponse.statusCode)"
                    errors.append(code)
                    print(code)
                    runsImage()
                    return
                }
                    // JSONシリアライズ
                let objectFromJSON: AnyObject
                do {
                    objectFromJSON = try NSJSONSerialization.JSONObjectWithData(
                        postResponseData,
                        options: NSJSONReadingOptions.MutableContainers)
                    
                    // JSONシリアライズエラー発生時
                } catch (let jsonError) {
                    let code = "JSON Error: \(jsonError)"
                    errors.append(code)
                    print(code)
                    return
                }
                let imageId = objectFromJSON["media_id_string"] as? String ?? ""
                // Tweet成功
                print("SUCCESS! Created Image with ID: %@", imageId)
                imageIds.append(imageId)
                
                runsImage()
            }
            for image in self.images {
                let imageRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                    requestMethod: SLRequestMethod.POST,
                    URL: imageUrl,
                    parameters: [:])
                let imageData = UIImageJPEGRepresentation(image,0.85)
                imageRequest.addMultipartData(imageData,
                    withName: "media",
                    type: "multipart/form-data",
                    filename: "image.jpg")
                imageRequest.account = self.account
                ThreadAction.startProcessing()
                imageRequest.performRequestWithHandler(imageHandler)
            }
        }else{
            self.tweetOnImageId("")
        }
    }
    
    private func tweetOnImageId(imageIds:String){
        let tweetString = tweetTextView.text
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let params:[String:String]
        if imageIds != "" {
            params = ["status" : tweetString,"media_ids" : imageIds, "in_reply_to_status_id":replyToId ]
        }else{
            params = ["status" : tweetString,"in_reply_to_status_id":replyToId]
        }
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                URL: url,
                                parameters: params)
        // リクエストハンドラ作成
        let handler: SLRequestHandler = { postResponseData, urlResponse, error in
            
            // リクエスト送信エラー発生時
            if let requestError = error {
                print("Request Error: An error occurred while requesting: \(requestError)")
                // インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            // httpエラー発生時
            if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                print("HTTP Error: The response status code is \(urlResponse.statusCode)")
                //** インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            // JSONシリアライズ
            let objectFromJSON: AnyObject
            do {
                objectFromJSON = try NSJSONSerialization.JSONObjectWithData(
                    postResponseData,
                    options: NSJSONReadingOptions.MutableContainers)
                
                // JSONシリアライズエラー発生時
            } catch (let jsonError) {
                print("JSON Error: \(jsonError)")
                //** インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            // Tweet成功
            print("SUCCESS! Created Tweet with ID: %@", objectFromJSON["id_str"] as! String)
            // インジケータ停止
            ThreadAction.stopProcessing()
            ThreadAction.mainThread{
                self.tweetTextView.text = ""
                self.images.removeAll()
                self.refreshImages()
            }
        }
        
        //** アカウント情報セット
        request.account = self.account
        
        //** インジケータ開始
        ThreadAction.startProcessing()
        
        //** リクエスト実行
        request.performRequestWithHandler(handler)
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
