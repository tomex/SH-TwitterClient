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
}