//
//  RSAppDelegate.m
//  RopeSkipping
//
//  Created by 管理员 on 14-1-17.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSMainViewController.h"
#import <NSDate-Utilities.h>
#import "WYRandom.h"
#import "RSSettingViewController.h"
#import "RSShareManager.h"
#import "RSSyncManager.h"
#import "RSBluetoothManager.h"
#import "RSLocalNotificationManager.h"
#import <EAIntroView.h>
#import "RSUserViewController.h"


@interface RSAppDelegate() <MSDynamicsDrawerViewControllerDelegate,EAIntroDelegate>

// 欢迎页
@property (strong, nonatomic) RSWelcomeViewController* welcomeViewController;
// 主页
@property (strong, nonatomic) RSMainViewController *mainViewController;
// 设置页面
@property (strong, nonatomic) UIViewController *settingViewController;

// 引导页
@property (weak,nonatomic) EAIntroView* intro;

@end

@implementation RSAppDelegate

#define WELCOME_SLEEP 2
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 本地通知
    [[RSLocalNotificationManager shared] down];
    
    // 模拟数据
//    [self initTestData];
    
    // 视图层初始化
    [self initViewController];
    
    // 分享功能
    [[RSShareManager shared] setUp];
    
    // 统计功能
    [[RSMobClickManager shared] setUp];
    
    // 特色
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // window root
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.welcomeViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    // 本地通知
    [[RSLocalNotificationManager shared] down];
    
    if (self.window.rootViewController == self.welcomeViewController) {
        // 欢迎页跳主屏
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(WELCOME_SLEEP);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 主页
                [self.dynamicsDrawerViewController setPaneViewController:self.mainViewController animated:NO completion:nil];
                [self.dynamicsDrawerViewController setDrawerViewController:self.settingViewController forDirection:MSDynamicsDrawerDirectionRight];
                UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:self.dynamicsDrawerViewController];
                self.window.rootViewController = navigation;
                
                // 第一次 引导页
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasIntroduction"]) {
                    EAIntroPage *page1 = [EAIntroPage page];
                    page1.title = nil;
                    page1.desc = nil;
                    page1.bgImage = [UIImage imageNamed:@"introduction1"];
                    page1.titleIconView = nil;
                    
                    EAIntroPage *page2 = [EAIntroPage page];
                    page2.title = nil;
                    page2.desc = nil;
                    page2.bgImage = [UIImage imageNamed:@"introduction2"];
                    page2.titleIconView = nil;
                    
                    EAIntroPage *page3 = [EAIntroPage page];
                    page3.title = nil;
                    page3.desc = nil;
                    page3.bgImage = [UIImage imageNamed:@"introduction3"];
                    page3.titleIconView = nil;
                    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.window.bounds andPages:@[page1,page2,page3]];
                    self.intro = intro;
                    intro.skipButton = nil;
                    intro.pageControl.hidden = YES;
                    [intro setDelegate:self];

                    [intro showInView:self.window animateDuration:0.0];
                    
                }
            });
        });
    }else{
        // 主屏
        // 如果再次进入程序的时间和上次进入程序的时间不是同一天, 则修改 today
        if (![self.mainViewController.today isEqualToDateIgnoringTime:[NSDate date]]) {
            self.mainViewController.today = [NSDate date];
            self.mainViewController.index = 0;
            // 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
        }
    }
    
    // 上传数据
    [[RSSyncManager shared] upload];
    // 下载数据
    [self firstDownload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[RSBluetoothManager shared] disconnect];
    // 本地通知
    [[RSLocalNotificationManager shared] fire];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // 本地通知
    [[RSLocalNotificationManager shared] fire];
}

#pragma mark - private
// 模拟数据
//- (void) initTestData{
//    // 是否清空数据并生成模拟数据
//#define RECORD_RECREATE 0
//    // 跳绳时间最小值 s
//#define RECORD_INTERVAL_MIN 1
//    // 跳绳时间最大值 s
//#define RECORD_INTERVAL_MAX 3600
//    // 跳绳数量最小值
//#define RECORD_COUNT_MIN 1
//    // 跳绳数量最大值
//#define RECORD_COUNT_MAX 999
//    // 模拟数据的数量,从今天开始往前的天数
//#define RECORD_NUMBER 40
//    // 模拟数据出现的几率 算子
//#define RECORD_RAN 3
//    // 同一天跳绳的最小次数
//#define RECORD_ROUND_MIN 1
//    // 同一天跳绳的最大次数
//#define RECORD_ROUND_MAX 3
//    
//    if (([RSRecordEntity count] == 0) || RECORD_RECREATE) {
//        [RSRecordEntity deleteAll];
//        NSDate* today = [NSDate date];
//        // 今天的数据
//        RSRecordEntity* record = [RSRecordEntity create];
//        record.beginTime = @([today timeIntervalSince1970]);
//        record.time = @([WYRandom randomFrom:RECORD_INTERVAL_MIN to:RECORD_INTERVAL_MAX]);
//        record.count = @([WYRandom randomFrom:RECORD_COUNT_MIN to:RECORD_COUNT_MAX]);
//        record.uuid = [[NSUUID UUID]UUIDString];
//        record.sync = @(NO);
//        // 随机的数据
//        for (int i=0;i<RECORD_NUMBER; i++) {
//            if (arc4random()%RECORD_RAN == 0) {
//                NSTimeInterval aTimeInterval = [today timeIntervalSinceReferenceDate] + D_DAY * -i;
//                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
//                for (int j=0; j<[WYRandom randomFrom:RECORD_ROUND_MIN to:RECORD_ROUND_MAX]; j++) {
//                    RSRecordEntity* record = [RSRecordEntity create];
//                    record.beginTime = @([date timeIntervalSince1970]);
//                    record.time = @([WYRandom randomFrom:RECORD_INTERVAL_MIN to:RECORD_INTERVAL_MAX]);
//                    record.count = @([WYRandom randomFrom:RECORD_COUNT_MIN to:RECORD_COUNT_MAX]);
//                    record.uuid = [[NSUUID UUID]UUIDString];
//                    record.sync = @(NO);
//                }
//            }
//        }
//    }
//}
// 视图层初始化
-(void) initViewController{
    // 欢迎界面
    self.welcomeViewController = [[RSWelcomeViewController alloc] initWithNibName:nil bundle:nil];
    
    // 主页面
    self.mainViewController = [[RSMainViewController alloc] initWithNibName:nil bundle:nil];
//    self.mainViewController.view;
    self.mainViewController.today = [NSDate date];
    self.mainViewController.index = 0;
    
    // 设置界面
    self.settingViewController = [[RSSettingViewController alloc] initWithNibName:nil bundle:nil];
    // 主界面&设置界面
    self.dynamicsDrawerViewController = [RSDynamicsDrawerViewController new];
    self.dynamicsDrawerViewController.delegate = self;
    
//    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler],[MSDynamicsDrawerFadeStyler styler],[MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionRight];
    
    [self.dynamicsDrawerViewController addStylersFromArray:@[] forDirection:MSDynamicsDrawerDirectionRight];
}

-(void) firstDownload{
    // 第一次登陆,下载数据
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notNeedDownload"]) {
        NSLog(@"开始下载数据");
        [[RSSyncManager shared] downloadWithBlock:^(BOOL success) {
            if (success) {
                // 通知
                [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notNeedDownload"];
            }
        }];
    }else{
        NSLog(@"无需下载数据");
    }
}


#pragma mark - 微信分享支持
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)editUser:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]] && self.intro.currentPageIndex == 2) {
        UINavigationController* navi = (UINavigationController*)self.window.rootViewController;
        RSUserViewController* userViewController = [[RSUserViewController alloc] initWithNibName:nil bundle:nil];
        [navi pushViewController:userViewController animated:YES];
        
        if (self.intro) {
            [self.intro hideWithFadeOutDuration:0.2];
            self.intro = nil;
        }
    }
}



#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasIntroduction"];
}

#define RSMyButtonTag 8888

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
    
    if (pageIndex == 2) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = RSMyButtonTag;
        [btn addTarget:self action:@selector(editUser:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(80, 370, 160, 60)];
        [introView addSubview:btn];
    }else{
        for (UIView* view in introView.subviews) {
            if (view.tag == RSMyButtonTag) {
                [view removeFromSuperview];
            }
        }
    }
}
@end
