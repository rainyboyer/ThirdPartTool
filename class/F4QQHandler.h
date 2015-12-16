//
//  F4ShareQQHandler.h
//  F4Share
//
//  Created by Apple on 7/15/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F4HandleProtocol.h"
#import <TencentOpenAPI/TencentOAuth.h>
@interface F4QQHandler : NSObject<F4HandleProtocol, TencentSessionDelegate>

- (void)load;
@end
