//
//  ThreadAction.swift
//  TwitterClient02
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 tmx3. All rights reserved.
//
import UIKit

struct ThreadAction{
    private static let mainQueue = dispatch_get_main_queue()
    private static let subQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    
    static func mainThread(thread:()->()){
        dispatch_async(self.mainQueue, thread)
    }
    
    static func subThread(thread:()->()){
        dispatch_async(self.subQueue, thread)
    }
    
    static func startProcessing() {
        self.mainThread{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    static func stopProcessing() {
        self.mainThread{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }    
}