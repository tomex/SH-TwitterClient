//
//  TwitterAccess.swift
//  SH-TwitterClient
//
//  Created by guest on 2016/05/16.
//  Copyright © 2016年 tmx3. All rights reserved.
//

import UIKit
import Social
import Accounts

struct TwitterAccess {
    static func generateRequestFullName(api:String,isPostMethod:Bool,params:[NSObject:AnyObject]) -> SLRequest {
        let url = NSURL(string: api)
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: isPostMethod ? SLRequestMethod.POST : SLRequestMethod.GET,
                                URL: url,
                                parameters: params)
        return request
    }
    static func generateRequest(api:String,isPostMethod:Bool,params:[NSObject:AnyObject]) -> SLRequest {
        return generateRequestFullName("https://api.twitter.com/1.1/\(api).json", isPostMethod: isPostMethod, params: params)
    }
    
    static func getAction(vc:AccountProtocol,api:String,isPostMethod:Bool,params:[String:AnyObject],successCode:(BaseStatus,AnyObject)->()){
        getAction(vc,status: BaseStatus(), api: api, isPostMethod: isPostMethod, params: params, successCode: successCode)
    }
    static func getAction(vc:AccountProtocol,api:String,isPostMethod:Bool,params:[String:AnyObject],successCode:(BaseStatus,AnyObject)->(),errors:(String)->(),prepare:(SLRequest)->()){
        getAction(vc, status: BaseStatus(), api: api, isPostMethod: isPostMethod, params: params, successCode: successCode,errors: errors,prepare: prepare)
    }
    static func getAction(vc:AccountProtocol,status:BaseStatus,api:String,isPostMethod:Bool,params:[String:AnyObject],successCode:(BaseStatus,AnyObject)->()){
        getAction(vc, status: status, api: api, isPostMethod: isPostMethod, params: params, successCode: successCode,errors: { (_) in }){ _ in }
    }
    static func getAction(vc:AccountProtocol,status:BaseStatus,api:String,isPostMethod:Bool,params:[String:AnyObject],successCode:(BaseStatus,AnyObject)->(),errors:(String)->(),prepare:(SLRequest)->()){
        let request:SLRequest
        if !api.containsString("://"){
            request = TwitterAccess.generateRequest(api, isPostMethod:isPostMethod, params: params)
        }else{
            request = TwitterAccess.generateRequestFullName(api, isPostMethod: isPostMethod, params: params)
        }
        let handler: SLRequestHandler = { postResponseData, urlResponse, error in
            // リクエスト送信エラー発生時
            if let requestError = error {
                let msg = "Request Error: An error occurred while requesting: \(requestError)"
                errors(msg)
                print(msg)
                ThreadAction.stopProcessing()
                return
            }
            
            // httpエラー発生時
            if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300 {
                let msg = "HTTP Error: The response status code is \(urlResponse.statusCode)"
                errors(msg)
                print(msg)
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
                let msg = "JSON Error: \(jsonError)"
                errors(msg)
                print(msg)
                //** インジケータ停止
                ThreadAction.stopProcessing()
                return
            }
            
            successCode(status,objectFromJSON)
            
            ThreadAction.stopProcessing()
        }
        
        //** アカウント情報セット
        request.account = vc.account
        
        prepare(request)
        
        //** インジケータ開始
        ThreadAction.startProcessing()
        
        //** リクエスト実行
        request.performRequestWithHandler(handler)
    }
}