//
//  F4WeChatHandler.h
//  shareDemo
//
//  Created by Ryan on 15/7/17.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F4HandleProtocol.h"
#import "F4WeiXinBaseHandler.h"
@interface F4WeChatHandler : F4WeiXinBaseHandler<F4HandleProtocol>

- (void)load;

@end
