//
//  F4ShareQQHandler.m
//  F4Share
//
//  Created by Apple on 7/15/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import "F4QQHandler.h"
#import "F4HandleEngine.h"
#import "F4ShareUserInfo.h"
#import "NSDictionary+URLQuery.h"
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <UIKit/UIKit.h>

@interface F4QQHandler()
@property (nonatomic, strong) TencentOAuth *tencent;
@property (nonatomic, copy) ShareResult shareResult;
@property (nonatomic, copy) LoginResult loginResult;
@property (nonatomic, copy) NSString *stateString;
@end
@implementation F4QQHandler

- (void)load
{
    [[F4HandleEngine sharedInstance] register:(id <F4HandleProtocol>)self];
}

- (NSNumber *)supportedSharePlatform
{
    return [NSNumber numberWithInt:SharePlatformQQ];
}

- (NSString *)getPlatformName
{
    return @"QQ";
}

- (NSString *)getPlatformImageName
{
    return @"img_icon_qq";
}

#pragma mark - TencentShare
- (BOOL)handleMessage:(F4ShareMessage *)message result:(ShareResult)result
{
    self.shareResult = result;
    id apiObject = [self setApiObjectWithMessage:message];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:apiObject];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];

    return YES;
}

- (id)setApiObjectWithMessage:(F4ShareMessage *)message
{
    __block id apiObject = nil;
    if (message.shareType == ShareImage)// 分享图片
    {
        if (message.imageUrl == nil)
        {
            NSLog(@"您的分享图片为空或未能解析");
        }
        else
        {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.imageUrl]];
            apiObject = [QQApiImageObject objectWithData:imageData
                                        previewImageData:imageData
                                                   title:message.title.length? message.title: @"分享图片"
                                             description:message.desc.length? message.desc: @"图片详情"];
        }

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//            });
//        });
    }
    else if (message.shareType == ShareText)
    {
        if (message.desc == nil)
        {
            NSLog(@"您的分享文字为空");
        }
        else
        {
            apiObject = [QQApiTextObject objectWithText:message.desc? message.desc: @"分享"];
        }
    }
    else if (message.shareType == ShareVideo)// 分享视频
    {
        if (message.mediaDataUrl == nil)
        {
            NSLog(@"您的视频网址尚未设置");
        }
        else
        {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.imageUrl]];
            apiObject = [QQApiVideoObject objectWithURL:[NSURL URLWithString:message.mediaDataUrl]
                                                  title:message.title.length? message.title: @"分享视频"
                                            description:message.desc.length? message.desc: @"视频详情"
                                       previewImageData:imageData? imageData: nil];
        }
    }
    else if (message.shareType == ShareNews)// 分享新闻
    {
        if (message.url == nil)
        {
             NSLog(@"您的分享网址尚未设置");
        }
        else
        {
            apiObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:message.url]
                                                 title:message.title.length? message.title: @"分享"
                                           description:message.desc.length? message.desc: @"详情"
                                       previewImageURL:message.imageUrl.length?
                                                        [NSURL URLWithString:message.imageUrl]: nil];
        }
    }
    else// 分享其他类型
    {
        NSLog(@"QQ不支持此分享类型");
    }
    return apiObject;
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            _stateString = [@"App未注册" copy];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            _stateString = [@"发送参数错误" copy];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            _stateString = [@"未安装手Q" copy];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            _stateString = [@"API接口不支持" copy];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            _stateString = [@"发送失败" copy];
            break;
        }
        default:
        {
            break;
        }
    }
    _shareResult(sendResult,_stateString);
}

#pragma mark - TencentLogin
- (BOOL)userLoginResult:(LoginResult)result
{
    NSArray *permissions = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    [_tencent authorize:permissions inSafari:NO];
    _loginResult = result;
    
    return YES;
}

#pragma mark - TencentRegister
- (BOOL)registerPlatformWithAppID:(NSString *)appID redirectURI:(NSString *)redirectURI
{
    self.tencent = [[TencentOAuth alloc]initWithAppId:appID andDelegate:self];
    _tencent.redirectURI = redirectURI;
    _tencent.sessionDelegate = self;
    
    return YES;
}

#pragma mark - TencentHandleUrl
- (BOOL)handleWithSourceApplication:(NSString *)application url:(NSURL *)url
{
    if ([application isEqualToString:@"com.tencent.mqq"])
    {
        NSLog(@"QQ反馈");
        NSMutableDictionary *dic = [NSMutableDictionary dealWithQueryWithMask:url.absoluteString];
        
        NSEnumerator * enumeratorKey = [dic keyEnumerator];
        
        //快速枚举遍历所有KEY的值
        for (NSString *object in enumeratorKey)
        {
            if ([object isEqualToString:@"error"])
            {
                _shareResult([[dic objectForKey:@"error"] integerValue],_stateString);
            }
        }
        
        
        [TencentOAuth HandleOpenURL:url];
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - TencentSessionDelegate
// 登录失败
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"登录失败");
}

// 连接网络失败
- (void)tencentDidNotNetWork
{
    NSLog(@"连接网络失败");
}

// 登录成功
- (void)tencentDidLogin
{
    [_tencent getUserInfo];
}

#pragma mark - TencentLoginDelegate
- (void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"response: %@", response.jsonResponse);
    F4ShareUserInfo *userInfo = [F4ShareUserInfo qqUserInfoWithJson:response.jsonResponse];
    _loginResult(userInfo, response.detailRetCode,_stateString);
}
@end
