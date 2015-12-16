//
//  F4WeiboHandler.m
//  shareDemo
//
//  Created by Ryan on 15/7/17.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "F4WeiboHandler.h"
#import "F4HandleEngine.h"
#import "F4ShareMessage.h"
#import "F4ShareUserInfo.h"
#import "WeiboSDK.h"
#import "F4ShareHTTPTool.h"
#import "OpenShare+Weibo.h"
#import "SVProgressHUD.h"

static NSString *KRedirectURI;
static NSString *KAccess_token;
static NSString *KStateString;

@interface F4WeiboHandler()

@property (nonatomic, copy) ShareResult shareResult;
@property (nonatomic, copy) LoginResult loginResult;

@end

@implementation F4WeiboHandler

- (void)load
{
    [[F4HandleEngine sharedInstance] register:(id <F4HandleProtocol>)self];
}

- (NSNumber *)supportedSharePlatform
{
    return [NSNumber numberWithInteger:SharePlatformWeibo];
}

- (BOOL)handleMessage:(F4ShareMessage *)message result:(ShareResult)result
{
    _shareResult = result;
    [self shareToWeibo:message result:result];


    return YES;
}

- (NSString *)getPlatformName
{
    return @"新浪微博";
}

- (NSString *)getPlatformImageName
{
    return @"img_icon_sina";
}

- (BOOL)registerPlatformWithAppID:(NSString *)appID redirectURI:(NSString *)redirectURI
{
    KRedirectURI = redirectURI;
    [WeiboSDK registerApp:appID];
//    KRedirectURI = redirectURI;
//    [OpenShare set:@"Weibo" Keys:@{@"appKey":appID}];
    return YES;
}

- (void)shareToWeibo:(F4ShareMessage *)msg result:(ShareResult)shareResult
{
//    [OpenShare shareToWeibo:msg Success:^(F4ShareMessage *message) {
//        //        ULog(@"分享到sina微博成功:\%@",message);
//    } Fail:^(F4ShareMessage *msg, NSError *error) {
//        //        ULog(@"分享到sina微博失败:\%@\n%@",message,error);
//    }];
    if (msg.shareType == ShareText)// text类型分享
    {
        [self sendTextContentWithMessage:msg ShareResult:shareResult];
    }
    else if (msg.shareType == ShareImage)// 图片类型分享
    {
        [self sendImageContentWithMessage:msg ShareResult:shareResult];
    }
    else if (msg.shareType == ShareNews)// 链接类型分享
    {
        [self sendNewsContentWithMessage:msg ShareResult:shareResult];
    }
    else
    {
        NSLog(@"新浪微博不支持此分享方式");
    }
}

- (BOOL)userLoginResult:(LoginResult)result
{
    self.loginResult = result;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = KRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
    return YES;
}

- (void)sendTextContentWithMessage:(F4ShareMessage *)msg ShareResult:(ShareResult)ShareResult
{
    WBMessageObject *message = [WBMessageObject message];
    if (msg.desc)
    {
        message.text = msg.desc;
        WBSendMessageToWeiboRequest *request = [self requestMessage:message access_token:KAccess_token];
        [WeiboSDK sendRequest:request];
    }
    else
    {
        NSLog(@"您的分享描述没有说明");
    }
    
}

- (void)sendImageContentWithMessage:(F4ShareMessage *)msg ShareResult:(ShareResult)ShareResult
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (msg.imageUrl)
    {
        WBImageObject *image = [WBImageObject object];
        image.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg.imageUrl]];
        message.imageObject = image;
        
        WBSendMessageToWeiboRequest *request = [self requestMessage:message access_token:KAccess_token];
        
        [WeiboSDK sendRequest:request];
    }
    else
    {
        NSLog(@"您的图片URL地址未能解析");
    }
}

- (void)sendNewsContentWithMessage:(F4ShareMessage *)msg ShareResult:(ShareResult)ShareResult
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (msg.url)
    {
        [SVProgressHUD showWithStatus:@"正在处理分享内容" maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg.imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *tempImage = [UIImage imageWithData:imageData];
                NSData *tempData = imageData;
                while ([tempData length]/1000 > 32)
                {
                    tempData = UIImageJPEGRepresentation(tempImage, 0.9);
                    tempImage = [UIImage imageWithData:tempData];
                }
                [SVProgressHUD dismiss];
                WBWebpageObject *webpage = [WBWebpageObject object];
                webpage.objectID = @"identifier1";
                webpage.title = msg.title.length > 0 ? msg.title : @"";
                webpage.description = msg.desc.length > 0 ? msg.desc : @"";
                webpage.thumbnailData = tempData;
                webpage.webpageUrl = msg.url;
                message.mediaObject = webpage;
                
                WBSendMessageToWeiboRequest *request = [self requestMessage:message access_token:KAccess_token];
                
                [WeiboSDK sendRequest:request];
            });
        });
    }
    else
    {
        NSLog(@"您的网络地址未填写");
    }
}

- (WBSendMessageToWeiboRequest *)requestMessage:(WBMessageObject *)message
                                   access_token:(NSString *)access_token
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = KRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
//    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message
//                                                                                  authInfo:authRequest
//                                                                              access_token:access_token];
    return request;
}

- (BOOL)handleWithSourceApplication:(NSString *)application url:(NSURL *)url
{
    
    if ([application isEqualToString:@"com.sina.weibo"])
    {
        NSLog(@"Sina反馈");
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else
    {
        return NO;
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    switch (response.statusCode)
    {
        case WeiboSDKResponseStatusCodeSuccess:
            KStateString = response.userInfo.allKeys.count > 0? @"新浪账号登录成功": @"新浪微博分享成功";
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            KStateString = response.userInfo.allKeys.count > 0? @"用户取消登录":@"用户取消发送";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            KStateString = response.userInfo.allKeys.count > 0? @"登录失败": @"发送失败";
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            KStateString = @"授权失败";
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            KStateString = @"用户取消安装微博客户端";
            break;
//        case WeiboSDKResponseStatusCodePayFail:
//            KStateString = @"支付失败";
//            break;
//        case WeiboSDKResponseStatusCodeShareInSDKFailed:
//            KStateString = @"分享失败 详情见response UserInfo";
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
            KStateString = @"不支持的请求";
            break;
        case WeiboSDKResponseStatusCodeUnknown:
            KStateString = @"未知错误";
            break;
        default:
            break;
    }
    
    [SVProgressHUD showInfoWithStatus:KStateString];
    
    NSInteger statusCode  = response.statusCode;
    
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"access_token"] = [(WBAuthorizeResponse *)response accessToken];
        dict[@"uid"] = [(WBAuthorizeResponse *)response userID];
    
        [F4ShareHTTPTool GET:@"https://api.weibo.com/2/users/show.json" params:dict success:^(F4ShareUserInfo *userInfo) {
            
            if (_loginResult)
            {
                _loginResult(userInfo,statusCode,KStateString);
            }
            
        } fail:^(NSError *error) {
            
            if (_loginResult)
            {
                _loginResult(nil,statusCode,KStateString);
            }

        }];
    }
    
    if (_shareResult)
    {
        _shareResult(statusCode,KStateString);
    }

    
}

@end
