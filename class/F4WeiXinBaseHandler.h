//
//  F4WeiXinBaseHandler.h
//  F4Share
//
//  Created by Apple on 7/21/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F4HandleProtocol.h"
#import "WXApi.h"
@interface F4WeiXinBaseHandler : NSObject<WXApiDelegate>

typedef enum {
    WeChatSceneSession  = 0,
    WeChatSceneTimeline = 1,
    WeChatSceneFavorite = 2,
}WeChatScene;

- (void)shareToWeiXinPlatformWithScene:(WeChatScene)scene message:(F4ShareMessage *)msg result:(ShareResult)result;
@end
