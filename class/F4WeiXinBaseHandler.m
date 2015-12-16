//
//  F4WeiXinBaseHandler.m
//  F4Share
//
//  Created by Apple on 7/21/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import "F4WeiXinBaseHandler.h"
#import "F4HandleEngine.h"


@interface F4WeiXinBaseHandler ()
{
    ShareResult _shareResult;
    LoginResult _loginResult;
    WeChatScene _scene;
}

@end

@implementation F4WeiXinBaseHandler

- (void)shareToWeiXinPlatformWithScene:(WeChatScene)scene message:(F4ShareMessage *)msg result:(ShareResult)result
{
    _scene = scene;
    _shareResult = result;
    
    if (!msg.shareType)
    {
        NSLog(@"微信不支持此分享类型");
    }
    else if(msg.shareType == ShareText)
    {
        // 文字
        [self sendTextContentWithMessage:msg result:result];
    }
    else if(msg.shareType == ShareImage)
    {
        // 图片
        [self sendImageContentWithMessage:msg];
    }
    else if(msg.shareType == ShareNews)
    {
        // 新闻和网址
        [self sendNewsContentWithMessage:msg];
    }
    else if(msg.shareType == ShareMusic)
    {
        //music
        [self sendMusicContentWithMessage:msg];
    }
    else if(msg.shareType == ShareVideo)
    {
        //video
        [self sendVideoContentWithMessage:msg];
    }
    else if(msg.shareType == ShareApp)
    {
        //app
        [self sendAppContentWithMessage:msg];
        
    }else if (msg.shareType == ShareGif)
    {
        //Gif
        [self sendGifContentWithMessage:msg];
        
    }else if (msg.shareType == ShareNonGif)
    {
        //NonGif
        [self sendNonGifContentWithMessage:msg];
    }

}

- (void)sendTextContentWithMessage:(F4ShareMessage *)msg result:(ShareResult)result
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = msg.desc.length > 0 ? msg.desc : @"分享";
    
    req.bText = YES;
    req.scene = _scene;
    
    [WXApi sendReq:req];
    
}

- (void)sendImageContentWithMessage:(F4ShareMessage *)msg
{
    if (msg.imageUrl.length > 0)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbData:[NSData dataWithContentsOfURL:[NSURL URLWithString:msg.thumbnailUrl]]];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg.imageUrl]];
        
        message.mediaObject = ext;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        NSLog(@"您的分享图片为空或未能解析");
    }

}

- (void)sendNewsContentWithMessage:(F4ShareMessage *)msg
{
    if (msg.url.length > 0)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = msg.title.length > 0? msg.title: @"分享";
        message.description = msg.desc.length > 0? msg.desc: @"分享详情";
        [message setThumbData:[NSData dataWithContentsOfURL:[NSURL URLWithString:msg.thumbnailUrl]]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = msg.url;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        NSLog(@"您的分享网址尚未设置");
    }
}

- (void)sendMusicContentWithMessage:(F4ShareMessage *)msg
{
    if (msg.musicUrl.length > 0)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = msg.title.length > 0? msg.title: @"分享";
        message.description = msg.desc.length > 0? msg.desc: @"分享详情";
        
        WXMusicObject *ext = [WXMusicObject object];
        ext.musicUrl = msg.musicUrl;
        //ext.musicDataUrl = @"http://stream20.qqmusic.qq.com/32464723.mp3";
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        NSLog(@"您的分享音乐地址尚未设置");
    }
    
}

- (void)sendVideoContentWithMessage:(F4ShareMessage *)msg
{
    if (msg.mediaDataUrl.length > 0)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = msg.title.length > 0? msg.title: @"分享";
        message.description = msg.desc.length > 0? msg.desc: @"分享详情";
        
        WXVideoObject *ext = [WXVideoObject object];
        ext.videoUrl = @"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html";
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        NSLog(@"您的分享视频地址尚未设置");
    }
}

#define BUFFER_SIZE 1024 * 100
- (void)sendAppContentWithMessage:(F4ShareMessage *)msg
{
    if (msg.fileExt > 0)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = msg.title.length > 0? msg.title: @"分享";
        message.description = msg.desc.length > 0? msg.desc: @"分享详情";
        
        WXAppExtendObject *ext = [WXAppExtendObject object];
        ext.extInfo = msg.fileExt;//@"<xml>extend info</xml>";
        ext.url = msg.url.length > 0? msg.url: @"http://weixin.qq.com";
        
        Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
        memset(pBuffer, 0, BUFFER_SIZE);
        NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
        free(pBuffer);
        
        ext.fileData = data;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        NSLog(@"您的分享App内容尚未设置");
    }
}

- (void)sendGifContentWithMessage:(F4ShareMessage *)msg
{
//    WXMediaMessage *message = [WXMediaMessage message];
//    
//    WXEmoticonObject *ext = [WXEmoticonObject object];
//    
//    message.mediaObject = ext;
//    
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = _scene;
//    
//    [WXApi sendReq:req];
    NSLog(@"尚不支持此分享方式");
}

- (void)sendNonGifContentWithMessage:(F4ShareMessage *)msg
{
//    WXMediaMessage *message = [WXMediaMessage message];
//    
//    WXEmoticonObject *ext = [WXEmoticonObject object];
//    
//    message.mediaObject = ext;
//    
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = _scene;
//    
//    [WXApi sendReq:req];
    NSLog(@"尚不支持此分享方式");
}


- (void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *stateString = nil;
        
        switch (resp.errCode)
        {
            case WXSuccess:
                stateString = @"微信分享成功";
                break;
            case WXErrCodeCommon:
                stateString = @"普通错误类型";
                break;
            case WXErrCodeUserCancel:
                stateString = @"用户取消";
                break;
            case WXErrCodeSentFail:
                stateString = @"发送失败";
                break;
            case WXErrCodeAuthDeny:
                stateString = @"授权否决";
                break;
            case WXErrCodeUnsupport:
                stateString = @"设备不支持";
                break;
            default:
                break;
        }
        
        if (_shareResult)
        {
            _shareResult(resp.errCode,stateString);
        }
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:stateString
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
    }
}
@end
