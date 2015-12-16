//
//  F4WeiboHandler.h
//  shareDemo
//
//  Created by Ryan on 15/7/17.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F4HandleProtocol.h"
#import "WeiboSDK.h"

@interface F4WeiboHandler : NSObject <F4HandleProtocol,WeiboSDKDelegate>

typedef NS_ENUM(NSInteger, F4WeiboSDKResponseStatusCode)
{
    F4WeiboSDKResponseStatusCodeSuccess               = 0,//成功
    F4WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
    F4WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
    F4WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
    F4WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
    F4WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
    F4WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
    F4WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
    F4WeiboSDKResponseStatusCodeUnknown               = -100,
};

- (void)load;

@end
