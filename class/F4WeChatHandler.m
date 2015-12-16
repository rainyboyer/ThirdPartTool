//
//  F4WeChatHandler.m
//  shareDemo
//
//  Created by Ryan on 15/7/17.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "F4WeChatHandler.h"
#import "F4HandleEngine.h"
#import "WXApi.h"

@interface F4WeChatHandler ()
{
    ShareResult _shareResult;
}

@end

@implementation F4WeChatHandler

- (void)load
{
    [[F4HandleEngine sharedInstance] register:(id <F4HandleProtocol>)self];
}

- (NSNumber *)supportedSharePlatform
{
    return [NSNumber numberWithInteger:SharePlatformWeChat];
}

- (NSString *)getPlatformName
{
    return @"微信好友";
}

- (NSString *)getPlatformImageName
{
    return @"img_icon_wechat";
}

- (BOOL)handleMessage:(F4ShareMessage *)message result:(ShareResult)result
{
    _shareResult = result;

    [self shareToWeChatSession:message result:result];

    return YES;
}

- (BOOL)handleWithSourceApplication:(NSString *)application url:(NSURL *)url
{
    
    if ([application isEqualToString:@"com.tencent.xin"])
    {
        NSLog(@"微信好友反馈");
        [WXApi handleOpenURL:url delegate:self];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)registerPlatformWithAppID:(NSString *)appID redirectURI:(NSString *)redirectURI
{
    return [WXApi registerApp:appID];
}

- (void)shareToWeChatSession:(F4ShareMessage *)msg result:(ShareResult)result
{
    NSLog(@"weChat");
    [super shareToWeiXinPlatformWithScene:WeChatSceneSession message:msg result:result];
}
@end
