//
//  RSShareManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-3-4.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSShareManager.h"

@implementation RSShareManager
+ (instancetype) shared {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void) setUp{
    [ShareSDK registerApp:ShareSDKAppkey];
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:SinaWeiboAppkey
                               appSecret:SinaWeiboAppSecret
                             redirectUri:SinaWeiboRedirectUri];
    // 微信
    [ShareSDK connectWeChatWithAppId:WeChatAppId
                           wechatCls:[WXApi class]];
    
    //连接短信分享
    [ShareSDK connectSMS];
}

// 分享应用
#define ShareTitle @"跳一跳"
-(void) shareAppWithText:(NSString*)text imagePath:(NSString*)path{
    //构造分享内容
    id<ISSCAttachment> imageISS = [ShareSDK imageWithPath:path];

    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:imageISS
                                                title:ShareTitle
                                                  url:CoolPlay
                                          description:@"描述信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    // 微信朋友圈
    [publishContent addWeixinTimelineUnitWithType:@(SSPublishContentMediaTypeNews)
                                          content:@""
                                            title:text
                                              url:INHERIT_VALUE
                                       thumbImage:INHERIT_VALUE
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    // 微信收藏
    [publishContent addWeixinFavUnitWithType:@(SSPublishContentMediaTypeNews)
                                     content:@""
                                       title:text
                                         url:INHERIT_VALUE
                                  thumbImage:INHERIT_VALUE
                                       image:INHERIT_VALUE
                                musicFileUrl:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil];
    // 微信好友
    [publishContent addWeixinSessionUnitWithType:@(SSPublishContentMediaTypeNews)
                                         content:INHERIT_VALUE
                                           title:INHERIT_VALUE
                                             url:INHERIT_VALUE
                                      thumbImage:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    // 定制短信信息
//    [publishContent addSMSUnitWithContent:@"Hello SMS"];
    
    // 发射
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}
// 分享记录
-(void) shareRecordWithText:(NSString*)text image:(UIImage*)image{
    //构造分享内容
    id<ISSCAttachment> imageISS = [ShareSDK imageWithData:UIImageJPEGRepresentation(image, 0.5) fileName:@"test" mimeType:@"jpg"];

    
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:imageISS
                                                title:ShareTitle
                                                  url:CoolPlay
                                          description:@"描述信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    // 微信朋友圈
    [publishContent addWeixinTimelineUnitWithType:@(SSPublishContentMediaTypeImage)
                                          content:INHERIT_VALUE
                                            title:INHERIT_VALUE
                                              url:INHERIT_VALUE
                                       thumbImage:INHERIT_VALUE
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    // 微信收藏
    [publishContent addWeixinFavUnitWithType:@(SSPublishContentMediaTypeImage)
                                     content:INHERIT_VALUE
                                       title:INHERIT_VALUE
                                         url:INHERIT_VALUE
                                  thumbImage:INHERIT_VALUE
                                       image:INHERIT_VALUE
                                musicFileUrl:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil];
    // 微信好友
    [publishContent addWeixinSessionUnitWithType:@(SSPublishContentMediaTypeImage)
                                         content:INHERIT_VALUE
                                           title:INHERIT_VALUE
                                             url:INHERIT_VALUE
                                      thumbImage:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    // 定制短信信息
    //    [publishContent addSMSUnitWithContent:@"Hello SMS"];
    
    // 发射
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}
@end
