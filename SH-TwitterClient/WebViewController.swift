//
//  WebViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/13.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,WKNavigationDelegate{
    
    var openUrl:NSURL?
    private var webView:WKWebView? = nil
    private var progressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if openUrl == nil {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_open_in_browser"), style: .Plain, target: self, action: #selector(WebViewController.openBrowser))
        
        webView = WKWebView(frame: view.bounds, configuration: WKWebViewConfiguration())
        webView?.navigationDelegate = self
        
        webView?.allowsBackForwardNavigationGestures = true
        
        view = self.webView
        
        let request = NSURLRequest(URL: openUrl!)
        webView?.loadRequest(request)
        
        progressView = UIProgressView(progressViewStyle: .Bar)
        //progressView.frame = CGRectMake(0, self.navigationController?.navigationBar.frame.size.height ?? 2 - 2, view.bounds.size.width, 2)
        //progressView.frame = CGRectMake(0, calcBarHeight(), view.bounds.size.width, 2)
        self.view.addSubview(progressView)
        
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        // Do any additional setup after loading the view.
    }
    
    deinit{
        if webView != nil {
            self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    func openBrowser(){
        if let url = webView?.URL {
            (UIApplication.sharedApplication() as? TwitterApplication)?.openBrowser(url)
        }
    }
    
    override func viewWillLayoutSubviews() {
        progressView.frame = CGRectMake(0, calcBarHeight(), view.bounds.size.width, 2)
    }
    
    override func observeValueForKeyPath(keyPath:String?, ofObject object:AnyObject?, change:[String:AnyObject]?, context:UnsafeMutablePointer<Void>) {
        switch keyPath! {
        case "estimatedProgress":
            //if let progress = change![NSKeyValueChangeNewKey] as? Float {
            self.progressView.setProgress(Float(object?.estimatedProgress ?? 0.0), animated: true)
            //progressView.progress = Float(object?.estimatedProgress ?? 0.0)
            //}
            print(change)
        default:
            break
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ThreadAction.startProcessing()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.progress = 0.0
        ThreadAction.stopProcessing()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        progressView.progress = 0.0
        ThreadAction.stopProcessing()
        print("Request error: An error onccurred while requesting: \(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func calcBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        return statusBarHeight + navigationBarHeight
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
