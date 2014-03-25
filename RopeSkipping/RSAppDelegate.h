//
//  RSAppDelegate.h
//  RopeSkipping
//
//  Created by 管理员 on 14-1-17.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSDynamicsDrawerViewController.h"
#import "RSWelcomeViewController.h"

@interface RSAppDelegate : UIResponder <UIApplicationDelegate>

// 主页&设置页
@property (strong, nonatomic) RSDynamicsDrawerViewController *dynamicsDrawerViewController;

@property (strong, nonatomic) UIWindow *window;

@end
