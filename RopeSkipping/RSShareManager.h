//
//  RSShareManager.h
//  RopeSkipping
//
//  Created by 管理员 on 14-3-4.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

// 酷玩部落
static NSString* const CoolPlay = @"http://www.coolplay.tv";

// ShareSDK
static NSString* const ShareSDKAppkey = @"13e8fe649240";

// 新浪
// 熊伟的
static NSString* const SinaWeiboAppkey = @"3263746661";
static NSString* const SinaWeiboAppSecret = @"f3ddddfb660e6a6c055ac2d0b0e216ac";
static NSString* const SinaWeiboRedirectUri = @"http://www.coolplay.tv";

// 我的
//static NSString* const SinaWeiboAppkey = @"2576417557";
//static NSString* const SinaWeiboAppSecret = @"815c60c2e88d722eba821545ef2e01f4";
//static NSString* const SinaWeiboRedirectUri = @"https://api.weibo.com/oauth2/default.html";

// 微信
static NSString* const WeChatAppId = @"wx2233e3f3651ff2c4";



@interface RSShareManager : NSObject

+ (instancetype) shared;

-(void) setUp;

-(void) shareAppWithText:(NSString*)text imagePath:(NSString*)path;

-(void) shareRecordWithText:(NSString*)text image:(UIImage*)image;
@end
