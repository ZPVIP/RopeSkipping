//
//  RSMobClickManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-3-5.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSMobClickManager.h"
#import "MobClick.h"



@implementation RSMobClickManager
+ (instancetype) shared {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void) setUp{
    [MobClick startWithAppkey:MobClickAppKey reportPolicy:SEND_INTERVAL   channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
//#warning 发布前,修改此参数
//    [MobClick setLogEnabled:YES];
}
@end

@implementation RSBaseMobClickViewController

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass(self.class)];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass(self.class)];
}
@end