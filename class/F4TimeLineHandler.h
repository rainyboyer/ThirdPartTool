//
//  F4TimeLineHandler.h
//  F4Share
//
//  Created by Apple on 7/21/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F4HandleProtocol.h"
#import "F4WeiXinBaseHandler.h"
@interface F4TimeLineHandler : F4WeiXinBaseHandler<F4HandleProtocol>

- (void)load;
@end
